
# How to use CohortDiagnostics Template

1. Create a new repo from this template on Github and clone it locally

2. Use the extras/pullCohortJsonFromAtlas.R script to extract cohort defintions from Atlas using a regular expression specific to your study

3. Push the updated json files to github

# Running the code in RStudio

- Install the latest version of renv

```R
install.packages("renv")
```

- Restore the project library

```R
renv::restore()
```

Edit the variables in the codeToRun.R script below to the correct values for your environment. 
Execute the script in RStudio.

# Running the code in Arachne

- Install and configure Arachne
- Download the code from Github as a zip file. 
- Upload the zip file to Arachne
