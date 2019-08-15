#!/bin/bash
# tested against  a AWS EC2 instance with a Linux 2 VM (Ubuntu)

echo "starting install-tools $( date )"

echo "HOME: $HOME"
echo "USER: $USER"

mkdir -p /opt/

# anaconda
[[ -d /opt/miniconda ]] || {
  echo "=== installing anaconda"

  ANACONDA_VERSION="Anaconda3-2019.07-Linux-x86_64.sh"
  wget "https://repo.anaconda.com/archive/$ANACONDA_VERSION"  -O ~/miniconda.sh
  bash ~/miniconda.sh -b -p /opt/miniconda
  chown -R anaconda:tools /opt/miniconda
}

echo "end of install-tools $( date )"

