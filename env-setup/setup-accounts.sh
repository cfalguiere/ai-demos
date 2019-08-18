#!/bin/bash
# run as root during EC2 instance creation

set -eu
trap "{ echo 'user creation failed' ; exit 255; }" SIGINT SIGTERM ERR

# create groups
echo "creating groups"

groupadd devs
groupadd tools

# create services 
echo "creating services"

# TODO disable password
for account in anaconda h2o
do
  useradd --create-home --shell /bin/bash $account
  usermod -aG tools $account
  usermod -aG sudo $account
done

echo "accounts created"
