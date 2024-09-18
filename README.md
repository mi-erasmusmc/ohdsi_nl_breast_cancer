# How to use CohortDiagnostics Template

1.  Create a new repo from this template on Github and clone it locally

2.  Use the extras/pullCohortJsonFromAtlas.R script to extract cohort definitions from Atlas using a regular expression to filter specific cohorts for your study

3.  Replace CohortDiagnosticsTemplate with {Study ID}-CohortDiagnostics in three places (require for execution engine)

    1.  The name of the folder/repository should be {Study ID}-CohortDiagnostics instead of CohortDiagnosticsTemplate

    2.  If you are using the Darwin Execution Engine then replace CohortDiagnosticsTemplate with {Study ID}-CohortDiagnostics in the execution-config.yml file both in the studyId and entrypoint fields. Also replace the StudyTitle field with a descriptive name.

    3.  Rename or recreate the .Rproj file in this repo so that it is also {Study ID}-CohortDiagnostics

4.  Commit your changes and push the updated files to github

# Running the code in RStudio

-   Install the latest version of renv

``` r
install.packages("renv")
```

-   Restore the project library

``` r
renv::restore()
```

- Edit the variables in the codeToRun.R script below to the correct values for your environment. Execute the script in RStudio.

# Running the code in Arachne

-   Install and configure Arachne to use Docker mode <https://darwin-eu-dev.github.io/execution-engine/install.html>
-   Download the code from Github as a zip file.
-   Upload the zip file to Arachne and fill in the additional parameters
-   The entrypoint should be set to codeToRunArachne.R and the Docker Runtime image should be set the value in the execution-config.yml file (currently this is executionengine.azurecr.io/darwin-cohort-diagnostics:v0.1)
  
# Running the code in the Darwin Execution Engine

-   Install and configure Execution Engine <https://darwin-eu-dev.github.io/execution-engine/install.html>
-   Download the code from Github as a zip file.
-   Rename the zip file to match the folder name in the execution-config.yml file, {Study ID}-CohortDiagnostics
-   Upload the zip file to ExecutionEngine and click submit

# Note on Docker images

This template can be used with Arachne (in Docker mode) or with the Darwin execution engine. Both pull docker images and run the R code inside them. The docker image used for this template is created from the dockerfile [here](https://github.com/darwin-eu/execution-engine/blob/da1679f3c653d21e4becc83087dc04d97f91bf55/execution-engine-runtime/DockerImages/darwin-base/Dockerfile#L1). It is maintained by the darwin project. The dockerfile in this reposity adds a specific set of R packages based on the renv lock file to the darwin base docker image.
