#!/bin/bash
# run as root during EC2 instance creation

set -eu
trap "{ echo 'ERROR - user creation failed' ; exit 255; }" SIGINT SIGTERM ERR

# create groups
echo "INFO - creating groups"

groupadd devs
groupadd tools

# tools dir
for p in /opt/ /data/aidemos/ /var/log/aidemos/
do
  mkdir -p $p
  chgrp tools $p
  chmod g+w $p
done

for p in /data/aidemos/projects
do
  mkdir -p $p
  chgrp devs $p
  chmod g+w $p
done

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
  sudo -u ${account} mkdir -p /opt/${account}
  # data
  sudo -u ${account} mkdir -p /data/aidemos/${account}
  # logs
  sudo -u ${account} mkdir -p /var/log/aidemos/${account}

done

echo "INFO - accounts created"
