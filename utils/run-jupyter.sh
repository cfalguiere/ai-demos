#!/bin/bash
# tested against  a AWS EC2 instance with a Linux 2 VM (Ubuntu)

set -eu
trap "{ echo 'ERROR - Jupyter failed' ; exit 255; }" SIGINT SIGTERM ERR

! tmux has-session -t jupyter  2>/dev/null && {
  echo "=== starting Jupyter"
  tmux new -d -s jupyter bash -c "source /etc/profile.d/conda.sh; conda activate python367; cd /opt/jupyter; jupyter notebook" &
}

# TODO check for existence

echo "INFO - Jupyter started"




