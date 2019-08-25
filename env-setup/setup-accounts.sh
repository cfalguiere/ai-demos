#!/bin/bash
# run as root during EC2 instance creation

set -eu
trap "{ echo 'ERROR - user creation failed' ; exit 255; }" SIGINT SIGTERM ERR

# create groups
echo "INFO - creating groups"

groupadd devs
groupadd tools

# tools dir
mkdir -p /opt/
chgrp tools /opt/
chmod g+w /opt/

# create services
echo "INFO - creating services"

# TODO disable password
for account in anaconda h2o mlflow airflow jupyter
do
  [[ $account == "anaconda" ]] && path_home="/opt/miniconda" || path_home="/opt/$account"
  useradd --home "$path_home"  --shell /bin/bash $account
  usermod -aG tools $account
  usermod -aG sudo $account
done

for account in h2o mlflow airflow jupyter
do
  # data
  mkdir -p /data/aidemos/${account}
  # logs
  mkdir -p /var/logs/aidemos/${account}
done

echo "INFO - accounts created"
