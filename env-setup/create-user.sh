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

# key pair
key_dir="/home/${userid}/.ssh"
mkdir "$key_dir"
chmod 700 "$key_dir"
touch "${key_dir}//authorized_keys"
chmod 600 "${key_dir}/authorized_keys"
#TODO s3 path cat >> ".${key_dir}/authorized_keys"

# conda configuration
cp env-setup/user-condarc "/home/${userid}/.condarc
PATH="/opt/miniconda/bin;${PATH}"

# useful variables
echo "export LOCAL_IP=$( curl --silent http://169.254.169.254/latest/meta-data/local-ipv4 )" | sudo tee -a "/home/${userid}/.bashrc"
echo "export PUBLIC_IP=$( curl --silent http://169.254.169.254/latest/meta-data/public-ipv4 )" | sudo tee -a "/home/${userid}/.bashrc"


echo "user $userid created"
