#!/bin/bash
# tested against  a AWS EC2 instance with a Linux 2 VM (Ubuntu)

set -eu
trap "{ echo 'h2o failed' ; exit 255; }" SIGINT SIGTERM ERR

# TODO check h2o for existence
# TODO check java for existence

tmux new -s h2o "cd /opt/web; python -m SimpleHTTPServer 80 &"



