#!/bin/bash
# tested against  a AWS EC2 instance with a Linux 2 VM (Ubuntu)

set -eu
trap "{ echo 'ERROR - web failed' ; exit 255; }" SIGINT SIGTERM ERR

! tmux has-session -t web 2>/dev/null && {
  echo "=== starting static web server"
  tmux new -d -s web bash -c "cd /opt/web; python -m SimpleHTTPServer 80" &
}

# TODO check page  for existence

echo "INFO - web started"




