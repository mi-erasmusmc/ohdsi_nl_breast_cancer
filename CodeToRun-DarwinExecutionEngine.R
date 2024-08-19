# This script is used as the entry point when using the Darwin Execution Engine
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

source(here::here("runCohortDiagnostics.R"))

# to launch the shiny app uncomment and run these lines
# CohortDiagnostics::createMergedResultsFile(
#   dataFolder = outputDir,
#.  sqliteDbPath = file.path(outputDir, "MergedCohortDiagnosticsData.sqlite"))

# CohortDiagnostics::launchDiagnosticsExplorer(sqliteDbPath = file.path(outputDir, "MergedCohortDiagnosticsData.sqlite"))


