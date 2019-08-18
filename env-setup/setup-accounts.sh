#!/bin/bash
# run as root during EC2 instance creation

set -eu
trap "{ echo 'user creation failed' ; exit 255; }" SIGINT SIGTERM ERR

[[ $# -ne 1 ]] && { echo "ERROR: missing parameter userid"; exit 254 }

userid=$1

echo "creating user $userid"

# create groups

groupadd devs
groupadd tools

# create services 

for account in anaconda h2o
do
  useradd --create-home --shell /bin/bash --disable-password  $account
  usermod -aG tools $account
  usermod -aG sudo $account
done

echo "user tools accounts"
