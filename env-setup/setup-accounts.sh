#!/bin/bash
# run as root during EC2 instance creation

set -eu
trap "{ echo 'ERROR - user creation failed' ; exit 255; }" SIGINT SIGTERM ERR

# create groups
echo "INFO - creating groups"

groupadd devs
groupadd tools

# create services 
echo "INFO - creating services"

# TODO disable password
for account in anaconda h2o
do
  useradd --create-home --shell /bin/bash $account
  usermod -aG tools $account
  usermod -aG sudo $account
done

echo "INFO - accounts created"
