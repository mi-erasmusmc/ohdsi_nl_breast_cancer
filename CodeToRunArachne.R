# Run this script in Arachne 

# renv::restore()

print(paste("working directory:"), getwd())

# These environment variables are pass in by Arachne
dbms   <- Sys.getenv("DBMS_TYPE")
connectionString <- Sys.getenv("CONNECTION_STRING")
user   <- Sys.getenv("DBMS_USERNAME")
password    <- Sys.getenv("DBMS_PASSWORD")
cdmDatabaseSchema <- Sys.getenv("CDM_SCHEMA")
cohortDatabaseSchema <- Sys.getenv("RESULT_SCHEMA")
databaseId <- Sys.getenv("DB_NAME")

connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                connectionString = connectionString,
                                                                user = user,
                                                                password = password)

connection <- DatabaseConnector::connect(connectionDetails)

test <- DatabaseConnector::renderTranslateQuerySql(
  connection, 
  "select count(*) as n_persons from @cdmDatabaseSchema.person",
  cdmDatabaseSchema = cdmDatabaseSchema)

print(paste(test$n_persons, "persons in the cdm database"))

DatabaseConnector::disconnect(connection)

vars <- c(DBMS_TYPE = dbms, 
          CONNECTION_STRING = connectionString, 
          DBMS_USERNAME = user, 
          DBMS_PASSWORD = password, 
          RESULT_SCHEMA = cohortDatabaseSchema,
          CDM_SCHEMA = cdmDatabaseSchema,
          DB_NAME = databaseId)

print(vars)

for (i in seq_along(vars)) {
  if (vars[i] == "") {
    stop(paste(names(vars)[i], "environment variable is empty!"))
  } 
}

cohortTable <- paste0("temp_cohort_", as.integer(Sys.time()) %% 10000)

# A folder with cohorts
cohortsFolder <- "inst"

# A folder on the local file system to store results
outputDir <- here::here("results")

runDiagnostics(connectionDetails = connectionDetails,
               cdmDatabaseSchema = cdmDatabaseSchema,
               vocabularyDatabaseSchema = cdmDatabaseSchema,
               cohortDatabaseSchema = cohortDatabaseSchema,
               cohortTable = cohortTable,
               cohortsFolder = cohortsFolder,
               outputDir = outputDir,
               databaseId = databaseId)

print("creating the sqlite file")

CohortDiagnostics::createMergedResultsFile(dataFolder = file.path(outputDir),
                                           sqliteDbPath = file.path(outputDir, "MergedCohortDiagnosticsData.sqlite"))

# CohortDiagnostics::launchDiagnosticsExplorer(sqliteDbPath = file.path(outputDir, "MergedCohortDiagnosticsData.sqlite"))
