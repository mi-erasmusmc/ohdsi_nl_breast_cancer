# Run this script in Arachne 

# renv::restore()

print(paste("working directory:", getwd()))
setwd(file.path(getwd(), "CohortDiagnosticsTemplate"))
# print(list.dirs())
# 
# print(Sys.getenv())

# These environment variables are pass in by Arachne
dbms   <- Sys.getenv("DBMS_TYPE")
connectionString <- Sys.getenv("CONNECTION_STRING")
user   <- Sys.getenv("DBMS_USERNAME")
password    <- Sys.getenv("DBMS_PASSWORD")
cdmDatabaseSchema <- Sys.getenv("DBMS_SCHEMA")
cohortDatabaseSchema <- Sys.getenv("RESULT_SCHEMA")
databaseId <- Sys.getenv("DATA_SOURCE_NAME")

vars <- c(DBMS_TYPE = dbms,
          CONNECTION_STRING = connectionString,
          DBMS_USERNAME = user,
          # DBMS_PASSWORD = password,
          RESULT_SCHEMA = cohortDatabaseSchema,
          DBMS_SCHEMA = cdmDatabaseSchema,
          DATA_SOURCE_NAME = databaseId)

print(vars)

for (i in seq_along(vars)) {
  if (vars[i] == "") {
    stop(paste(names(vars)[i], "environment variable is empty!"))
  }
}

connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                connectionString = connectionString,
                                                                user = user,
                                                                password = password)

connection <- DatabaseConnector::connect(connectionDetails)

test <- DatabaseConnector::renderTranslateQuerySql(
  connection,
  "select count(*) as n_persons from @cdmDatabaseSchema.person",
  cdmDatabaseSchema = cdmDatabaseSchema)

print(paste(test[[1]], "persons in the cdm database"))

DatabaseConnector::disconnect(connection)

cohortTable <- paste0("temp_cohort_", as.integer(Sys.time()) %% 10000)

# A folder with cohorts
cohortsFolder <- "inst"

# A folder on the local file system to store results
outputDir <- here::here("results")

# setup output folder and log -----
if (!file.exists(outputDir)) {
  dir.create(outputDir, recursive = TRUE)
}

source("runCohortDiagnostics.R")

print("creating the sqlite file")

CohortDiagnostics::createMergedResultsFile(dataFolder = file.path(outputDir),
                                           sqliteDbPath = file.path(outputDir, "MergedCohortDiagnosticsData.sqlite"))

# CohortDiagnostics::launchDiagnosticsExplorer(sqliteDbPath = file.path(outputDir, "MergedCohortDiagnosticsData.sqlite"))
