#!/bin/bash
# tested against  a AWS EC2 instance with a Linux 2 VM (Ubuntu)

set -eu
trap "{ echo 'ERROR - MLflow UI failed' ; exit 255; }" SIGINT SIGTERM ERR

! tmux has-session -t mlflowui 2>/dev/null && {
  echo "=== starting MLFlow UI"
  tmux new -d -s mlflowui bash -c "conda activate python36; mlflow ui" &
}

# TODO check for existence

echo "INFO - MLFlow UI started"




