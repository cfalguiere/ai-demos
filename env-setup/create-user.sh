#!/bin/bash
# run as root during EC2 instance creation

set -eu
trap "{ echo 'user creation failed' ; exit 255; }" SIGINT SIGTERM ERR


