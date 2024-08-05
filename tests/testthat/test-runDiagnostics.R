test_that("Testing with Eunomia cohorts", {
  connectionDetails <- Eunomia::getEunomiaConnectionDetails()
  connection <- DatabaseConnector::connect(connectionDetails)
  outputDir <- file.path(tempdir(), "results_Eunomia")

  dir.create(outputDir)

  databaseResultsSchema <- "main"
  cdmDatabaseSchema <- "main"
  cohortDatabaseSchema <- "main"
  cohortTable <- "example"
  databaseId <- "Eunomia"

  # Test
  settingsFileName <- "Cohorts.csv"
  jsonFolder <- "cohorts"
  sqlFolder <- "sql/sql_server"
  packageName <- "CohortDiagnostics"

  runDiagnostics(
    connectionDetails = connectionDetails,
    cdmDatabaseSchema = cdmDatabaseSchema,
    vocabularyDatabaseSchema = cdmDatabaseSchema,
    cohortDatabaseSchema = cohortDatabaseSchema,
    cohortTable = cohortTable,
    settingsFileName = settingsFileName,
    jsonFolder = jsonFolder,
    sqlFolder = sqlFolder,
    packageName = packageName,
    outputDir = outputDir,
    databaseId = databaseId
  )

  num_files <- length(list.files(outputDir))
  expect_equal(num_files, 36)

  results_file_loc <- list.files(outputDir, pattern = ".zip", full.names = TRUE)
  expect_true(file.exists(results_file_loc))

  results_file <- list.files(outputDir, pattern = ".zip")
  expect_equal(results_file, "Results_Eunomia.zip")

  unlink(outputDir, recursive = TRUE)
})
