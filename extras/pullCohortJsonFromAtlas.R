
# this script extracts the cohort json files from Atlas.
# The ILD cohorts were created by Nick Hunt and pulled out of Atlas by Adam Black on June 6, 2024

library(ROhdsiWebApi)
library(dplyr)

baseUrl <- "https://atlas-dev.darwin-eu.org/WebAPI"

# copy the browser token from the browser following the instructions here: 
# https://ohdsi.github.io/ROhdsiWebApi/articles/authenticationSecurity.html
token <- "Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhLmJsYWNrQGRhcndpbi1ldS5vcmciLCJTZXNzaW9uLUlEIjpudWxsLCJleHAiOjE3MjI4OTMxOTd9.zYb_35nROT1mwL_Fr9hQPfq9Pq5G74umXOkcq5KeXElutRGIVyPzgE03yMm3_xa3phpaQ7GLWgtU55Id5Kx5nA"

setAuthHeader(baseUrl, authHeader = token)

md0 <- getCohortDefinitionsMetaData(baseUrl)

# use the study tag or other substring to get just the cohort for your study
prefix <- "CohortDiagnostics test "
md <- md0 %>% 
  filter(stringr::str_detect(name, prefix)) %>% 
  select(name, id) %>% 
  mutate(name2 = snakecase::to_snake_case(tolower(stringr::str_remove(name, prefix)))) 

dir.create("inst")

cohortsToCreate <- dplyr::tibble(atlasId = md$id, cohortId = md$id, cohortName = md$name2)
readr::write_csv(cohortsToCreate, here::here("inst", "cohortsToCreate.csv"))

insertCohortDefinitionSetInPackage(
  fileName = "inst/cohortsToCreate.csv",
  baseUrl = "https://atlas-dev.darwin-eu.org/WebAPI",
  jsonFolder = "inst/cohorts",
  sqlFolder = "inst/sql/sql_server",
  insertCohortCreationR = F,
  insertTableSql = F
)

# rename files to match cohort name
df <- CohortGenerator::getCohortDefinitionSet(
  here::here("inst", "cohortsToCreate.csv"),
  jsonFolder = here::here("inst", "cohorts"),
  sqlFolder = here::here("inst", "sql", "sql_server"),
  cohortFileNameValue = "cohortId"
) %>% dplyr::tibble()

# rename json and sql files with the cohort name instead of the cohort number
for (i in seq_len(nrow(df))) {
  file.rename(here::here("inst/cohorts", paste0(cohortsToCreate[i, "cohortId"], ".json")),
              here::here("inst/cohorts", paste0(cohortsToCreate[i, "cohortName"], ".json")))
}

for (i in seq_len(nrow(df))) {
  file.rename(here::here("inst/sql/sql_server", paste0(cohortsToCreate[i, "cohortId"], ".sql")),
              here::here("inst/sql/sql_server", paste0(cohortsToCreate[i, "cohortName"], ".sql")))
}

# check that CohortGenerator::getCohortDefinitionSet will work
df <- CohortGenerator::getCohortDefinitionSet(
  here::here("inst", "cohortsToCreate.csv"),
  jsonFolder = here::here("inst/cohorts"),
  sqlFolder = here::here("inst/sql/sql_server"),
  cohortFileNameValue = "cohortName"
) %>% dplyr::tibble()

df


