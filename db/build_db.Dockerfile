FROM rocker/r-ver:4.1.0

RUN install2.r --error \
  tidyverse \
  rprojroot

WORKDIR /home/OpenPedCan-api

COPY ./OpenPedCan-analysis/ ./OpenPedCan-analysis/
# Create a placeholder .git/index file for rprojroot to work
RUN mkdir ./OpenPedCan-analysis/.git && touch ./OpenPedCan-analysis/.git/index
COPY ./src/tpm_data_lists.R ./src/tpm_data_lists.R

# tpm_data_lists.R should be run with the directory that contains this file as
# working directory.
WORKDIR /home/OpenPedCan-api/src
# This creates /home/OpenPedCan-api/db/tpm_data_lists.rds
RUN Rscript --vanilla tpm_data_lists.R

WORKDIR /home/OpenPedCan-api

RUN sha256sum db/tpm_data_lists.rds
