#!/bin/bash
# run as root during EC2 instance creation

set -eu
trap "{ echo 'ERROR - user creation failed' ; exit 255; }" SIGINT SIGTERM ERR

[[ $# -eq 1 ]] || {
  echo "ERROR - missing parameter userid in user creation"
  exit 254 
}

userid=$1

echo "INFO - creating user $userid"

# create user
#TODO disable password
useradd --create-home --shell /bin/bash "$userid"
usermod -aG devs "$userid"
usermod -aG tools "$userid"
usermod -aG sudo "$userid"

# key pair
key_dir="/home/${userid}/.ssh"
mkdir "$key_dir"
chmod 700 "$key_dir"
touch "${key_dir}//authorized_keys"
chmod 600 "${key_dir}/authorized_keys"
cp /home/ubuntu/.ssh/authorized_keys "${key_dir}/authorized_keys"
chown -R "${userid}:${userid}"  "$key_dir"

# conda configuration
cp env-setup/user-condarc "/home/${userid}/.condarc"
#echo 'export PATH="/opt/miniconda/bin;${PATH}"' | tee -a "/home/${userid}/.bashrc"
echo "source . /etc/profile.d/conda.sh" | tee -a "/home/${userid}/.bashrc"

# useful variables
echo "export LOCAL_IP=$( curl --silent http://169.254.169.254/latest/meta-data/local-ipv4 )" |  tee -a "/home/${userid}/.bashrc"
echo "export PUBLIC_IP=$( curl --silent http://169.254.169.254/latest/meta-data/public-ipv4 )" |  tee -a "/home/${userid}/.bashrc"

id $userid

echo "INFO - user $userid created"



