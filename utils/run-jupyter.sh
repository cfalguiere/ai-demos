#!/bin/bash
# tested against  a AWS EC2 instance with a Linux 2 VM (Ubuntu)

set -eu
trap "{ echo 'ERROR - Jupyter failed' ; exit 255; }" SIGINT SIGTERM ERR

! tmux has-session -t jupyter  2>/dev/null && {
  echo "=== starting Jupyter"
  tmux new -d -s jupyter bash -c "conda activate python367; jupyter notebook" &
}

# TODO check for existence

echo "INFO - Jupyter started"




