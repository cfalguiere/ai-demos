#!/bin/bash
# tested against  a AWS EC2 instance with a Linux 2 VM (Ubuntu)

echo "starting init $( date )"

echo "HOME: $HOME"
echo "USER: $USER"


echo "installing anaconda"

# add anaconda
sudo mkdir /opt/
wget https://repo.anaconda.com/archive/Anaconda3-2019.07-Linux-x86_64.sh  -O ~/miniconda.sh
bash ~/miniconda.sh -b -p /opt/miniconda
sudo chown -R anaconda:tools /opt/anaconda

echo "end of init $( date )"
