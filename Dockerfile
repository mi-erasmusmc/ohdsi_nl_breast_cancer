FROM executionengine.azurecr.io/darwin-base:v0.3
MAINTAINER Adam Black <a.black@darwin-eu.org>

# the darwin base image is built on ubuntu 22.04

# Copy all the files from the repo into the docker image
COPY ./renv.lock /renv.lock

RUN R -e 'install.packages("renv")'

# run renv::restore. By using the rstudio package manager we can skip compilation and speed up installation.
RUN R -e 'renv::restore(lockfile = "/renv.lock", library = "/usr/local/lib/R/site-library", repos = "https://packagemanager.posit.co/cran/__linux__/jammy/latest")'

