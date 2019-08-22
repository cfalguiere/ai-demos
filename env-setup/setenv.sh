#!/bin/bash
# tested against  a AWS EC2 instance with a Linux 2 VM (Ubuntu)
# run as root
# requires source env-setup/setenv.h
# requires users h2o, anaconda, mlflow, airflow, jupyter
# requires /opt writable by group tools

set -eu
trap "{ echo 'ERROR - setenv failed' ; exit 255; }" SIGINT SIGTERM ERR

AIDEMOS_TRACKING_DIR="/var/log/aidemos/setup"
mkdir -p "${AIDEMOS_TRACKING_DIR}"
chgrp tools "${AIDEMOS_TRACKING_DIR}"
chmod g+w "${AIDEMOS_TRACKING_DIR}"
echo "AIDEMOS_TRACKING_DIR=$AIDEMOS_TRACKING_DIR"
export AIDEMOS_TRACKING_DIR

AIDEMOS_TMP_DIR="/tmp/aidemos/install"
mkdir -p "${AIDEMOS_TMP_DIR}"
chgrp tools "${AIDEMOS_TMP_DIR}"
chmod g+w "${AIDEMOS_TMP_DIR}"
echo "AIDEMOS_WORK_DIR=$AIDEMOS_TMP_DIR"
export AIDEMOS_TMP_DIR

AIDEMOS_REPO_DIR="/var/git-repos/ai-demos"
export AIDEMOS_REPO_DIR

