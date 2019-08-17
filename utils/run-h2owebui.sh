#!/bin/bash
# tested against  a AWS EC2 instance with a Linux 2 VM (Ubuntu)

set -eu
trap "{ echo 'h2o failed' ; exit 255; }" SIGINT SIGTERM ERR

! tmux has-session -t h2o 2>/dev/null && {
  echo "=== starting h2o Web UI"
  tmux new -d -s h2o bash -c "cd /opt/h2o; java -jar h2o.jar" &
}

# TODO check h2o for existence
# TODO check java for existence





