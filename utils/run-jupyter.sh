#!/bin/bash
# tested against  a AWS EC2 instance with a Linux 2 VM (Ubuntu)

set -eu
trap "{ echo 'ERROR - Jupyter failed' ; exit 255; }" SIGINT SIGTERM ERR

! tmux has-session -t jupyter  2>/dev/null && {
  echo "=== starting Jupyter"
  tmux new -d -s jupyter bash -c "source /etc/profile.d/conda.sh; conda activate python36; source env-setup/setenv.sh; cd /opt/jupyter; jupyter notebook --no-browser --ip "${PUBLIC_IP}"
 | tee ${AIDEMOS_TRACKING_DIR}/jupyter.out" &
}

# TODO check for existence

echo "INFO - Jupyter started"
