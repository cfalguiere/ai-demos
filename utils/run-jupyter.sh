#!/bin/bash
# tested against  a AWS EC2 instance with a Linux 2 VM (Ubuntu)

set -eu
trap "{ echo 'ERROR - Jupyter failed' ; exit 255; }" SIGINT SIGTERM ERR

! tmux has-session -t jupyter  2>/dev/null && {
  echo "=== starting Jupyter"
  set +u
  cd ${AIDEMOS_REPO_DIR}
  tmux new -d -s jupyter bash -c "source env-setup/setenv.sh; cd /opt/jupyter; source /etc/profile.d/conda.sh; conda activate python36; jupyter notebook --no-browser --ip ${PUBLIC_IP} | tee ${AIDEMOS_TRACKING_DIR}/jupyter.out" &
  set -u
}

# TODO check for existence

echo "INFO - Jupyter started"
