#!/bin/bash
# tested against  a AWS EC2 instance with a Linux 2 VM (Ubuntu)

set -eu
trap "{ echo 'ERROR - Jupyter failed' ; exit 255; }" SIGINT SIGTERM ERR

! tmux has-session -t jupyter  2>/dev/null && {
  echo "=== starting Jupyter"
  tmux new -d -s jupyter bash -c 'source env-setup/setenv.sh; cd /opt/jupyter; source /etc/profile.d/conda.sh; conda activate python36; jupyter notebook --no-browser --ip 0.0.0.0 | tee /opt/jupyter/jupyter.out' &
  # show token
  tmux new -d -s jupyter bash -c 'source env-setup/setenv.sh; cd /opt/jupyter; source /etc/profile.d/conda.sh; conda activate python36; jupyter notebook list'
}

# TODO check for existence

echo "INFO - Jupyter started"
