#!/bin/bash
# run as root during EC2 instance creation

set -eu
trap "{ echo 'user creation failed' ; exit 255; }" SIGINT SIGTERM ERR

[[ $# -ne 1 ]] && { echo "ERROR: missing parameter userid"; exit 254 }

userid=$1

echo "creating user $userid"

# create user 
useradd --create-home --shell /bin/bash  --disable-password "$userid"
usermod -aG devs "$userid"
usermod -aG tools "$userid"
usermod -aG sudo "$userid"


echo "user $userid created"

