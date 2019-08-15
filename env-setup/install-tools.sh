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
  ANACONDA_URL="https://repo.anaconda.com/archive/${ANACONDA_VERSION}"
  wget "${ANACONDA_URL}"  -O ~/miniconda.sh
  bash ~/miniconda.sh -b -p /opt/miniconda3
  ln -s /opt/miniconda3 /opt/miniconda
  conda --version
  conda update -y conda
  chown -R anaconda:tools /opt/miniconda
}

# h2o
[[ -d /opt/miniconda ]] || {
  echo "=== installing h2o standalone"
  # https://www.h2o.ai/download/#h2o
  H2O_VERSION="3.26.0.2"
  H2O_PACKAGE="h2o-${H2O_VERSION}.zip"
  H2O_URL="http://h2o-release.s3.amazonaws.com/h2o/rel-yau/2/${H2O_PACKAGE}"
  wget "${H2O_URL}" -O ~/h2o-3.26.0.2.zip
  unzip ~/${H2O_PACKAGE} -d /opt/h2o-${H2O_VERSION}
  ln -s /opt/h2o-${H2O_VERSION} /opt/h2o
}

# sparkling water ( TODO spark )
# https://s3.amazonaws.com/h2o-release/sparkling-water/spark-2.4/3.26.2-2.4/sparkling-water-3.26.2-2.4.zip








echo "end of install-tools $( date )"

