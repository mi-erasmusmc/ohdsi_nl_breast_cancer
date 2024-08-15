# Run this script in the Darwin Execution Engine 

print(paste("working directory:", getwd()))

# get parameters and create connection details ----
# These environment variables are pass in by the Darwin Execution Engine
dbms   <- Sys.getenv("DBMS_TYPE")
checkmate::assertChoice(dbms, choices = c("postgresql", "redshift", "sql server", "snowflake", "spark"))

connectionString <- Sys.getenv("CONNECTION_STRING")
user   <- Sys.getenv("DBMS_USERNAME")
password <- Sys.getenv("DBMS_PASSWORD")
server <- Sys.getenv("DBMS_SERVER")
dbname <- Sys.getenv("DBMS_NAME")
port <- Sys.getenv("DBMS_PORT")
databaseId <- Sys.getenv("DATA_SOURCE_NAME")

if (port == "") port <- NULL

cdmVersion <- Sys.getenv("CDM_VERSION")
catalog <- Sys.getenv("DBMS_CATALOG")
cdmDatabaseSchema <- Sys.getenv("CDM_SCHEMA")
cohortDatabaseSchema <- Sys.getenv("RESULT_SCHEMA")

if (nchar(catalog) >= 1) {
  cdmDatabaseSchema <- paste(catalog, cdmDatabaseSchema, sep = ".")
  cohortDatabaseSchema <- paste(catalog, cohortDatabaseSchema, sep = ".")
}

if (connectionString != "") {
  stopifnot(nchar(user) >= 1, nchar(password) >= 1)
  connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                  connectionString = connectionString,
                                                                  user = user,
                                                                  password = password)
} else {
  stopifnot(nchar(server) >= 1, nchar(dbname) >= 1, nchar(user) >= 1, nchar(password) >= 1)
  
  connectionDetails <- DatabaseConnector::createConnectionDetails(
    dbms = dbms,
    server = paste0(server, "/", dbname),
    port = port,
    user = user,
    password = password)
}

# test connection details ----
connection <- DatabaseConnector::connect(connectionDetails)

test <- DatabaseConnector::renderTranslateQuerySql(
  connection, 
  "select count(*) as n_persons from @cdmDatabaseSchema.person",
  cdmDatabaseSchema = cdmDatabaseSchema)

print(paste(test$n_persons, "persons in the cdm database"))
DatabaseConnector::disconnect(connection)

# setup output folder and log -----
cohortTable <- paste0("temp_cohort_", as.integer(Sys.time()) %% 10000)
cohortsFolder <- here::here("inst")
outputDir <- "/results"

if (!file.exists(outputDir)) {
  dir.create(outputDir, recursive = TRUE)
}

ParallelLogger::addDefaultFileLogger(file.path(outputDir, "log.txt"))
ParallelLogger::addDefaultErrorReportLogger(file.path(outputDir, "errorReportR.txt"))

# generate cohorts ----
ParallelLogger::logInfo("Creating cohorts")
cohortTableNames <- CohortGenerator::getCohortTableNames(cohortTable = cohortTable)

CohortGenerator::createCohortTables(
  connectionDetails = connectionDetails,
  cohortTableNames = cohortTableNames,
  cohortDatabaseSchema = cohortDatabaseSchema,
  incremental = FALSE
)

cohortDefinitionSet <- CohortGenerator::getCohortDefinitionSet(
  settingsFileName = here::here("inst", "cohortsToCreate.csv"),
  jsonFolder = here::here("inst", "cohorts"),
  sqlFolder = here::here("inst", "sql", "sql_server"),
  cohortFileNameValue = "cohortName"
  
)

CohortGenerator::generateCohortSet(
  connectionDetails = connectionDetails,
  cdmDatabaseSchema = cdmDatabaseSchema,
  cohortDatabaseSchema = cohortDatabaseSchema,
  cohortTableNames = cohortTableNames,
  cohortDefinitionSet = cohortDefinitionSet
)

CohortGenerator::exportCohortStatsTables(
  connectionDetails = connectionDetails,
  cohortDatabaseSchema = cohortDatabaseSchema,
  cohortTableNames = cohortTableNames,
  cohortStatisticsFolder = outputDir
)

# run diagnostics ----
temporalCovariateSettings <- FeatureExtraction::createTemporalCovariateSettings(
  useDemographicsGender = TRUE,
  useDemographicsAge = TRUE,
  useDemographicsAgeGroup = TRUE,
  useDemographicsIndexYear = TRUE,
  useDemographicsIndexMonth = TRUE,
  useDemographicsIndexYearMonth = TRUE,
  useDemographicsPriorObservationTime = TRUE,
  useDemographicsPostObservationTime = TRUE,
  useDemographicsTimeInCohort = TRUE,
  useConditionOccurrence = TRUE,
  useProcedureOccurrence = FALSE,
  useDrugEraStart = TRUE,
  useMeasurement = TRUE,
  useDrugExposure = TRUE,
  temporalStartDays = CohortDiagnostics::getDefaultCovariateSettings()$temporalStartDays,
  temporalEndDays =  CohortDiagnostics::getDefaultCovariateSettings()$temporalEndDays
)

CohortDiagnostics::executeDiagnostics(
  cohortDefinitionSet = cohortDefinitionSet,
  exportFolder = outputDir,
  databaseId = databaseId,
  cohortDatabaseSchema = cohortDatabaseSchema,
  connectionDetails = connectionDetails,
  cdmDatabaseSchema = cdmDatabaseSchema,
  tempEmulationSchema = cohortDatabaseSchema,
  cohortTable = cohortTable,
  cohortTableNames = cohortTableNames,
  vocabularyDatabaseSchema = cdmDatabaseSchema,
  cdmVersion = 5,
  runInclusionStatistics = TRUE,
  runIncludedSourceConcepts = TRUE,
  runOrphanConcepts = TRUE,
  runTimeSeries = TRUE,
  runVisitContext = FALSE,
  runBreakdownIndexEvents = TRUE,
  runIncidenceRate = TRUE,
  runCohortRelationship = TRUE,
  runTemporalCohortCharacterization = TRUE,
  temporalCovariateSettings = temporalCovariateSettings,
  minCellCount = 5
)

ParallelLogger::unregisterLogger("DEFAULT_FILE_LOGGER", silent = TRUE)
ParallelLogger::unregisterLogger("DEFAULT_ERRORREPORT_LOGGER", silent = TRUE)

print("Creating merged results sqlite file")

CohortDiagnostics::createMergedResultsFile(dataFolder = outputDir,
                                           sqliteDbPath = file.path(outputDir, "MergedCohortDiagnosticsData.sqlite"))

# CohortDiagnostics::launchDiagnosticsExplorer(sqliteDbPath = file.path(outputDir, "MergedCohortDiagnosticsData.sqlite"))


