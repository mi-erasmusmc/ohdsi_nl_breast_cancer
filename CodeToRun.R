# 1. Open this project in RStudio and restore the R environment
renv::restore()

# 2. Edit the variables below to create a connection and run CohortDiagnostics

#  postgresql", "snowflake", "spark", and "redshift", "sql server"
dbms <- "..."
host <- Sys.getenv("...")
dbname <- Sys.getenv("...")
user <- Sys.getenv("...")
password <-  Sys.getenv("...")
port <- Sys.getenv("...")

connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                server = paste0(host, "/", dbname),
                                                                user = user,
                                                                password = password,
                                                                port = port)

connection <- DatabaseConnector::connect(connectionDetails)


# The database schema where the observational data in CDM is located
cdmDatabaseSchema <- "..."

# The database schema where the cohorts can be instantiated
cohortDatabaseSchema <- "..."

# The name of the table that will be created in the cohortDatabaseSchema
cohortTable <- paste0("tmp_cohort_", as.integer(Sys.time()) %% 10000)

# A folder with cohorts
cohortsFolder <- here::here("inst", "cohorts")

# The databaseId is a short (<= 20 characters)
databaseId <- "YOUR_DATABASE_ID"

# A folder on the local file system to store results
outputDir <- here::here(paste("results", databaseId))

# test connection details ----
connection <- DatabaseConnector::connect(connectionDetails)

test <- DatabaseConnector::renderTranslateQuerySql(
  connection, 
  "select count(*) as n_persons from @cdmDatabaseSchema.person",
  cdmDatabaseSchema = cdmDatabaseSchema) |> dplyr::pull(1)

print(paste(test, "persons in the cdm database"))
DatabaseConnector::disconnect(connection)

# setup output folder and log -----
if (!file.exists(outputDir)) {
  dir.create(outputDir, recursive = TRUE)
}

source(here::here("runCohortDiagnostics.R"))


# Review and return the csv files in the output folder

# To view the shiny app run the following code

# CohortDiagnostics::createMergedResultsFile(dataFolder = outputDir,
#                                            sqliteDbPath = file.path(outputDir, "MergedCohortDiagnosticsData.sqlite"))
# 
# CohortDiagnostics::launchDiagnosticsExplorer(sqliteDbPath = file.path(outputDir, "MergedCohortDiagnosticsData.sqlite"))


