#!/bin/bash
# run as root during EC2 instance creation

set -eu
trap "{ echo 'user creation failed' ; exit 255; }" SIGINT SIGTERM ERR

[[ $# -ne 1 ]] && { echo "ERROR: missing parameter userid"; exit 254 }

userid=$1

echo "creating user $userid"

echo "user $userid created"

