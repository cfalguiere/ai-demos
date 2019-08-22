#!/bin/bash
# tested against  a AWS EC2 instance with a Linux 2 VM (Ubuntu)
# run as root

echo "INFO - starting install-tools $( date )"

set -eu
trap "{ echo 'ERROR - install failed' ; exit 255; }" SIGINT SIGTERM ERR

TRACKING_DIR="/var/log/aidemos/setup"
mkdir -p "${TRACKING_DIR}"
chgrp tools "${TRACKING_DIR}"
chmod g+w "${TRACKING_DIR}"
echo "TRACKING_DIR=$TRACKING_DIR"

TMP_DIR="/tmp/aidemos/install"
mkdir -p "${TMP_DIR}"
chgrp tools "${TMP_DIR}"
chmod g+w "${TMP_DIR}"
echo "WORK_DIR=$TMP_DIR"

REPO_DIR="/var/git-repos/ai-demos"

mkdir -p /opt/
chgrp tools /opt/
chmod g+w /opt/

cd $TMP_DIR

# anaconda
[[ -f "${TRACKING_DIR}/.anaconda" ]] || {
  echo "=== installing anaconda"

  ANACONDA_VERSION="Anaconda3-2019.07-Linux-x86_64.sh"
  ANACONDA_URL="https://repo.anaconda.com/archive/${ANACONDA_VERSION}"
  wget -q  "${ANACONDA_URL}"  -O "${TMP_DIR}/miniconda.sh"
  sudo -u anaconda bash "${TMP_DIR}/miniconda.sh" -b -p /opt/miniconda
  rm -rf "${TMP_DIR}/miniconda.sh"
  /opt/miniconda/bin/conda --version
  sudo -u anaconda /opt/miniconda/bin/conda update -y conda
  sudo -u anaconda cp "${REPO_DIR}/env-setup/admin-condarc" /opt/miniconda/.condarc
  # chown -R anaconda:tools /opt/miniconda
  ln -s /opt/miniconda/etc/profile.d/conda.sh /etc/profile.d/conda.sh
  touch "${TRACKING_DIR}/.anaconda" 
}

[[ -f "${TRACKING_DIR}/.env-python3" ]] || {
  echo "=== creating env Python 3.6"
  sudo -H -u anaconda /opt/miniconda/bin/conda env create --file "${REPO_DIR}/env-setup/conda-python36.yml"
  #chown -R anaconda:tools /opt/envs/python36
  touch "${TRACKING_DIR}/.env-python3"
}

[[ -f "${TRACKING_DIR}/.env-r" ]] || {
  echo "=== creating env R"
  sudo -H -u anaconda /opt/miniconda/bin/conda create --yes --name r r-essentials r-base
  #chown -R anaconda:tools /opt/envs/r
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
  sudo -u h2o unzip "${TMP_DIR}/${H2O_PACKAGE}" -d /opt/
  rm -rf "${TMP_DIR}/${H2O_PACKAGE}"
  sudo -u h2o ln -s /opt/h2o-${H2O_VERSION} /opt/h2o
  sudo -u h2o cp "${REPO_DIR}/utils/run-h2owebui.sh" /opt/h2o/
 
  touch "${TRACKING_DIR}/.h2o"
}

# sparkling water ( TODO spark )
[[ -f "${TRACKING_DIR}/.h2o-sparkling-water" ]] || {
  echo "=== installing h2o sparkling water"
  # https://www.h2o.ai/download/#h2o
  H2OSW_VERSION="3.26.2-2.4"
  H2OSW_PACKAGE="sparkling-water-${H2OSW_VERSION}.zip"
  H2OSW_URL="https://s3.amazonaws.com/h2o-release/sparkling-water/spark-2.4/${H2OSW_VERSION}/${H2OSW_PACKAGE}"
  wget -q  "${H2OSW_URL}" -O "${TMP_DIR}/${H2OSW_PACKAGE}"
  sudo -u h2o unzip "${TMP_DIR}/${H2OSW_PACKAGE}" -d /opt/h2o-sparkling-water-${H2OSW_VERSION}
  rm -rf "${TMP_DIR}/${H2OSW_PACKAGE}"
  sudo -u h2o ln -s /opt/h2o-sparkling-water-${H2OSW_VERSION} /opt/h2o-saprkling-water
  touch "${TRACKING_DIR}/.h2o-sparkling-water"
}

[[ -f "${TRACKING_DIR}/.web" ]] || {
  echo "=== setup webserver"
  mkdir -p /opt/web
  "${REPO_DIR}/env-setup/index.html.dd" > /opt/web/index.html
  cp "${REPO_DIR}/utils/run-simpleweb.sh" /opt/web/run-simpleweb.sh
  touch "${TRACKING_DIR}/.web"
}


# mlflow 
[[ -f "${TRACKING_DIR}/.mlflow" ]] || {
  echo "=== installing mlflow"
  sudo -u mlflow mkdir -p /opt/mlflow
  sudo -u mlflow cp "${REPO_DIR}/utils/run-mlflowui.sh" /opt/mlflow/run-mlflowui.sh
  touch "${TRACKING_DIR}/.mlflow"
}


# airflow 
[[ -f "${TRACKING_DIR}/.airflow" ]] || {
  echo "=== installing airflow"
  sudo -u airflow mkdir -p /opt/airflow
  sudo -u airflow cp "${REPO_DIR}/utils/run-airflow.sh" /opt/airflow/run-airflow.sh
  echo "=== initializing airflow database "
  sudo -u airflow tmux new -d -s airflowdb bash -c "source /etc/profile.d/conda.sh; conda activate python36; cd /opt/airflow/; airflow initdb 2>&1 | tee ${TRACKING_DIR}/airflow-initdb.out; touch ${TRACKING_DIR}/.airflow-initdb"
  [[ -f "${TRACKING_DIR}/.airflow-initdb" ]] && echo "=== airflow database initialization airflow done "
  touch "${TRACKING_DIR}/.airflow"
}

# jupyter
[[ -f "${TRACKING_DIR}/.jupyter" ]] || {
  echo "=== installing jupyter"
  sudo -u jupyter mkdir -p /opt/jupyter
  sudo -u jupyter cp "${REPO_DIR}/utils/run-jupyter.sh" /opt/jupyter/run-jupyter.sh
  touch "${TRACKING_DIR}/.jupyter"
}

/opt/web/run-simpleweb.sh

sudo -H -u h2o /opt/h2o/run-h2owebui.sh
sudo -H -u mlflow /opt/mlflow/run-mlflowui.sh
sudo -H -u airflow /opt/airflow/run-airflow.sh
sudo -H -u jupyter /opt/jupyter/run-jupyter.sh

[[ -z "${TMP_DIR}" ]] || rm -rf "${TMP_DIR}"

echo "INFO - end of install-tools $( date )"
