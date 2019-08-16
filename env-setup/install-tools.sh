#!/bin/bash
# tested against  a AWS EC2 instance with a Linux 2 VM (Ubuntu)
# run as root

echo "starting install-tools $( date )"

set -eu
trap "{ echo 'install failed' ; exit 255; }" SIGINT SIGTERM ERR

TRACKING_DIR="/var/log/aidemos/setup"
mkdir -p "${TRACKING_DIR}"
TMP_DIR="/tmp/aidemos/install"
mkdir -p "${TMP_DIR}"

mkdir -p /opt/

# anaconda
[[ -f "${TRACKING_DIR}/.anaconda" ]] || {
  echo "=== installing anaconda"

  ANACONDA_VERSION="Anaconda3-2019.07-Linux-x86_64.sh"
  ANACONDA_URL="https://repo.anaconda.com/archive/${ANACONDA_VERSION}"
  wget -q  "${ANACONDA_URL}"  -O "${TMP_DIR}/miniconda.sh"
  bash "${TMP_DIR}/miniconda.sh" -b -p /opt/miniconda
  rm -rf "${TMP_DIR}/miniconda.sh"
  /opt/miniconda/bin/conda --version
  /opt/miniconda/bin/conda update -y conda
  cp env-setup/admin-condarc /opt/miniconda/.condarc
  chown -R anaconda:tools /opt/miniconda
  touch "${TRACKING_DIR}/.anaconda" 
}

[[ -f "${TRACKING_DIR}/.env-python3" ]] || {
  echo "=== creating env Python 3.7"
  /opt/miniconda/bin/conda create --yes --name python37 python=3.7 anaconda
  chown -R anaconda:tools /opt/envs/python37
  touch "${TRACKING_DIR}/.env-python3"
}

[[ -f "${TRACKING_DIR}/.env-r" ]] || {
  echo "=== creating env R"
  /opt/miniconda/bin/conda create --yes --name r r-essentials r-base
  chown -R anaconda:tools /opt/envs/r
  touch "${TRACKING_DIR}/.env-r"
}


# h2o
[[ -f "${TRACKING_DIR}/.h2o" ]] || {
  echo "=== installing h2o standalone"
  # https://www.h2o.ai/download/#h2o
  H2O_VERSION="3.26.0.2"
  H2O_PACKAGE="h2o-${H2O_VERSION}.zip"
  H2O_URL="http://h2o-release.s3.amazonaws.com/h2o/rel-yau/2/${H2O_PACKAGE}"
  wget -q  "${H2O_URL}" -O "${TMP_DIR}/${H2O_PACKAGE}"
  unzip "${TMP_DIR}/${H2O_PACKAGE}" -d /opt/
  rm -rf "${TMP_DIR}/${H2O_PACKAGE}"
  ln -s /opt/h2o-${H2O_VERSION} /opt/h2o
  touch "${TRACKING_DIR}/.h2o"
}

[[ -f "${TRACKING_DIR}/.web" ]] || {
  mkdir -p /opt/web
  utils/index.html.dd > /opt/web/index.html
}


# sparkling water ( TODO spark )
[[ -f "${TRACKING_DIR}/.h2o-sparkling-water" ]] || {
  echo "=== installing h2o sparkling water"
  # https://www.h2o.ai/download/#h2o
  H2OSW_VERSION="3.26.2-2.4"
  H2OSW_PACKAGE="sparkling-water-${H2OSW_VERSION}.zip"
  H2OSW_URL="https://s3.amazonaws.com/h2o-release/sparkling-water/spark-2.4/${H2OSW_VERSION}/${H2OSW_PACKAGE}"
  wget -q  "${H2OSW_URL}" -O "${TMP_DIR}/${H2OSW_PACKAGE}"
  unzip "${TMP_DIR}/${H2OSW_PACKAGE}" -d /opt/h2o-sparkling-water-${H2OSW_VERSION}
  rm -rf "${TMP_DIR}/${H2OSW_PACKAGE}"
  ln -s /opt/h2o-sparkling-water-${H2OSW_VERSION} /opt/h2o-saprkling-water
  touch "${TRACKING_DIR}/.h2o-sparking-water"
}

[[ -f "${TRACKING_DIR}/.web" ]] || {
  utils/index.html.dd > web/index.html
  touch "${TRACKING_DIR}/.web"
}

[[ -z "${TMP_DIR}" ]] || rm -rf "${TMP_DIR}"

echo "end of install-tools $( date )"
