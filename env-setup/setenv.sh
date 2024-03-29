#!/bin/bash
# tested against  a AWS EC2 instance with a Linux 2 VM (Ubuntu)
# run as root
# requires source env-setup/setenv.h
# requires users h2o, anaconda, mlflow, airflow, jupyter
# requires /opt writable by group tools

set -eu
trap "{ echo 'ERROR - setenv failed' ; exit 255; }" SIGINT SIGTERM ERR

export LOCAL_IP=$( curl --silent http://169.254.169.254/latest/meta-data/local-ipv4 )
export PUBLIC_IP=$( curl --silent http://169.254.169.254/latest/meta-data/public-ipv4 )

export AIDEMOS_TRACKING_DIR="/var/log/aidemos/setup"
echo "AIDEMOS_TRACKING_DIR=$AIDEMOS_TRACKING_DIR"

export AIDEMOS_TMP_DIR="/tmp/aidemos/install"
echo "AIDEMOS_WORK_DIR=$AIDEMOS_TMP_DIR"


export AIDEMOS_REPO_DIR="/var/git-repos/ai-demos"

echo "INFO - setenv Completed"
