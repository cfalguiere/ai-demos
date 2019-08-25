#!/bin/bash
# tested against  a AWS EC2 instance with a Linux 2 VM (Ubuntu)

set -eu
trap "{ echo 'ERROR - MLflow UI failed' ; exit 255; }" SIGINT SIGTERM ERR

! tmux has-session -t mlflowui 2>/dev/null && {
  echo "=== starting MLFlow UI"
  set +u
  cd ${AIDEMOS_REPO_DIR}
  tmux new -d -s mlflowui bash -c "source env-setup/setenv.sh; cd /opt/mlflow; source /etc/profile.d/conda.sh; conda activate python36; mlflow server --backend-store-uri /opt/mlflow/mlruns  --default-artifact-root /opt/mlflow/mlruns --host ${PUBLIC_IP} | tee ${AIDEMOS_TRACKING_DIR}/mlflow-ui.out" &
  set -u
  #TODO creation d'un espace /data ou s3
}

# TODO check for existence

echo "INFO - MLFlow UI started"
