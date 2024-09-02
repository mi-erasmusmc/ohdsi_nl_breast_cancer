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
  cohortStatisticsFolder = outputDir,
  cohortDefinitionSet = cohortDefinitionSet
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
