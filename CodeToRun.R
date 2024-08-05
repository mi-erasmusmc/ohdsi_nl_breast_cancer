# 1. Open this project in RStudio and restore the R environment
renv::restore()

# 2. Edit the variables below to create a connection and run CohortDiagnostics
dbms <- Sys.getenv("dbms")
host <- Sys.getenv("host")
dbname <- Sys.getenv("dbname")
user <- Sys.getenv("user")
password <- Sys.getenv("password")
port <- Sys.getenv("port")

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
cohortTable <- "..."

# A folder with cohorts
cohortsFolder <- "..."

# A folder on the local file system to store results
outputDir <- "..."

# The databaseId is a short (<= 20 characters)
databaseId <- "..."

# Using an ExternalConceptCountsTable ------------------------

# If using the DARWIN version of CohortDiagnostics you can create in advance the concept_counts table

# 1. Create the conceptCountsTable in the cohortDatabaseSchema
CohortDiagnostics::createConceptCountsTable(connectionDetails = connectionDetails,
                                            connection = NULL,
                                            cdmDatabaseSchema = cdmDatabaseSchema,
                                            tempEmulationSchema = NULL,
                                            conceptCountsDatabaseSchema = cohortDatabaseSchema,
                                            conceptCountsTable = "concept_counts",
                                            conceptCountsTableIsTemp = FALSE,
                                            removeCurrentTable = TRUE)

# 2. Set useExternalConceptCountsTable = TRUE if created.
#    - Provide the name of the table witn conceptCountsTable = "concept_counts"
# 	 - Or just set useExternalConceptCountsTable = "achilles" to use the counts in the CDM
CohortDiagnosticsRenv::runDiagnostics(connectionDetails = connectionDetails,
                                      cdmDatabaseSchema = cdmDatabaseSchema,
                                      vocabularyDatabaseSchema = cdmDatabaseSchema,
                                      cohortDatabaseSchema = cohortDatabaseSchema,
                                      cohortTable = cohortTable,
                                      cohortsFolder = cohortsFolder,
                                      outputDir = outputDir,
                                      databaseId = databaseId,
                                      useExternalConceptCountsTable = TRUE,
                                      conceptCountsTable = "concept_counts")

# 3. If not using an ExternalConceptCountsTable, CohortDiagnostics can be run as default
CohortDiagnosticsRenv::runDiagnostics(connectionDetails = connectionDetails,
                                      cdmDatabaseSchema = cdmDatabaseSchema,
                                      vocabularyDatabaseSchema = cdmDatabaseSchema,
                                      cohortDatabaseSchema = cohortDatabaseSchema,
                                      cohortTable = cohortTable,
                                      cohortsFolder = cohortsFolder,
                                      outputDir = outputDir,
                                      databaseId = databaseId)

# 4. (Optionally) to view the results locally:
CohortDiagnostics::createMergedResultsFile(dataFolder = file.path(outputDir),
                                           sqliteDbPath = file.path(outputDir, "MergedCohortDiagnosticsData.sqlite"))

CohortDiagnostics::launchDiagnosticsExplorer(sqliteDbPath = file.path(outputDir, "MergedCohortDiagnosticsData.sqlite"))
