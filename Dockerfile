FROM rocker/r-ver:4.1.0

# Install operating system and R packages
#
# hadolint ignore=DL3008
RUN apt-get update -qq \
  && apt-get install -y --no-install-recommends \
    libssl-dev \
    libcurl4-gnutls-dev \
    # Install curl to download data
    curl \
    # Install odbc to operate database
    unixodbc \
    unixodbc-dev \
    odbc-postgresql \
    # Install R X11 runtime dependencies
    #
    # Adapted from
    # https://github.com/rocker-org/rocker-versioned/blob/dff37a27698cfe8cda894845fa194ecb5f668d84/X11/Dockerfile
    libx11-6 \
    libxss1 \
    libxt6 \
    libxext6 \
    libsm6 \
    libice6 \
    xdg-utils \
  && rm -rf /var/lib/apt/lists/* \
  # Install R packages
  && install2.r --error \
    tidyverse \
    plumber \
    rprojroot \
    jsonlite \
    ggthemes \
    odbc \
    DBI \
  && rm -rf /tmp/downloaded_packages/*

# Run the following commands to run API HTTP server on port 80 as root user, by
# design.
WORKDIR /home/open-ped-can-api-web/

# Copy API server files to docker image WORKDIR
COPY ./main.R .
COPY ./src/ ./src/
COPY ./db/ ./db/

# Use DB_LOCATION to determine where to get the database.
#
# - aws_s3: download database from aws s3 bucket.
# - local: use local database in ./db dir COPY. If database is not built
#   locally, report an error.
ARG DB_LOCATION="aws_s3"

# Use CACHE_DATE to prevent the following RUN commands from using cache. Pass
# new CACHE_DATE docker build --build-arg CACHE_DATE=$(date +%s) .
#
# Adapted from https://stackoverflow.com/a/38261124/4638182
ARG CACHE_DATE="not_a_date"

RUN ./db/load_db.sh

EXPOSE 80

ENTRYPOINT ["Rscript", "--vanilla", "main.R"]
