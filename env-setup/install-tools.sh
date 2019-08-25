#!/bin/bash
# tested against  a AWS EC2 instance with a Linux 2 VM (Ubuntu)
# run as root
# requires env-setup/setenv.sh
# requires users h2o, anaconda, mlflow, airflow, jupyter
# requires /opt

echo "INFO - starting install-tools $( date )"

set -eu
trap "{ echo 'ERROR - install failed' ; exit 255; }" SIGINT SIGTERM ERR

# variables set by caller through setenv
env | grep "AIDEMOS"

mkdir -p "${AIDEMOS_TRACKING_DIR}"
chgrp tools "${AIDEMOS_TRACKING_DIR}"
chmod g+w "${AIDEMOS_TRACKING_DIR}"

mkdir -p "${AIDEMOS_TMP_DIR}"
chgrp tools "${AIDEMOS_TMP_DIR}"
chmod g+w "${AIDEMOS_TMP_DIR}"

cd $AIDEMOS_TMP_DIR

# anaconda
[[ -f "${AIDEMOS_TRACKING_DIR}/.anaconda" ]] || {
  echo "=== installing anaconda"

  ANACONDA_VERSION="Anaconda3-2019.07-Linux-x86_64.sh"
  ANACONDA_URL="https://repo.anaconda.com/archive/${ANACONDA_VERSION}"
  wget -q  "${ANACONDA_URL}"  -O "${AIDEMOS_TMP_DIR}/miniconda.sh"
  sudo -u anaconda bash "${AIDEMOS_TMP_DIR}/miniconda.sh" -b -p /opt/miniconda
  rm -rf "${AIDEMOS_TMP_DIR}/miniconda.sh"
  /opt/miniconda/bin/conda --version
  sudo -u anaconda /opt/miniconda/bin/conda update -y conda
  sudo -u anaconda cp "${AIDEMOS_REPO_DIR}/env-setup/admin-condarc" /opt/miniconda/.condarc
  # chown -R anaconda:tools /opt/miniconda
  ln -s /opt/miniconda/etc/profile.d/conda.sh /etc/profile.d/conda.sh
  touch "${AIDEMOS_TRACKING_DIR}/.anaconda"
}

[[ -f "${AIDEMOS_TRACKING_DIR}/.env-python3" ]] || {
  echo "=== creating env Python 3.6"
  sudo -H -u anaconda /opt/miniconda/bin/conda env create --file "${AIDEMOS_REPO_DIR}/env-setup/conda-python36.yml"
  #chown -R anaconda:tools /opt/envs/python36
  touch "${AIDEMOS_TRACKING_DIR}/.env-python3"
}

[[ -f "${AIDEMOS_TRACKING_DIR}/.env-r" ]] || {
  echo "=== creating env R"
  sudo -H -u anaconda /opt/miniconda/bin/conda create --yes --name r r-essentials r-base
  #chown -R anaconda:tools /opt/envs/r
  touch "${AIDEMOS_TRACKING_DIR}/.env-r"
}


# h2o
[[ -f "${AIDEMOS_TRACKING_DIR}/.h2o" ]] || {
  echo "=== installing h2o standalone"
  # https://www.h2o.ai/download/#h2o
  H2O_VERSION="3.26.0.2"
  H2O_PACKAGE="h2o-${H2O_VERSION}.zip"
  H2O_URL="http://h2o-release.s3.amazonaws.com/h2o/rel-yau/2/${H2O_PACKAGE}"
  wget -q  "${H2O_URL}" -O "${AIDEMOS_TMP_DIR}/${H2O_PACKAGE}"
  sudo -u h2o unzip "${AIDEMOS_TMP_DIR}/${H2O_PACKAGE}" -d /opt/
  rm -rf "${AIDEMOS_TMP_DIR}/${H2O_PACKAGE}"
  sudo -u h2o ln -s /opt/h2o-${H2O_VERSION} /opt/h2o
  sudo -u h2o cp "${AIDEMOS_REPO_DIR}/utils/run-h2owebui.sh" /opt/h2o/
  touch "${AIDEMOS_TRACKING_DIR}/.h2o"
}

# sparkling water ( TODO spark )
[[ -f "${AIDEMOS_TRACKING_DIR}/.h2o-sparkling-water" ]] || {
  echo "=== installing h2o sparkling water"
  # https://www.h2o.ai/download/#h2o
  H2OSW_VERSION="3.26.2-2.4"
  H2OSW_PACKAGE="sparkling-water-${H2OSW_VERSION}.zip"
  H2OSW_URL="https://s3.amazonaws.com/h2o-release/sparkling-water/spark-2.4/${H2OSW_VERSION}/${H2OSW_PACKAGE}"
  wget -q  "${H2OSW_URL}" -O "${AIDEMOS_TMP_DIR}/${H2OSW_PACKAGE}"
  sudo -u h2o unzip "${AIDEMOS_TMP_DIR}/${H2OSW_PACKAGE}" -d /opt/h2o-sparkling-water-${H2OSW_VERSION}
  rm -rf "${AIDEMOS_TMP_DIR}/${H2OSW_PACKAGE}"
  sudo -u h2o ln -s /opt/h2o-sparkling-water-${H2OSW_VERSION} /opt/h2o-saprkling-water
  touch "${AIDEMOS_TRACKING_DIR}/.h2o-sparkling-water"
}

[[ -f "${AIDEMOS_TRACKING_DIR}/.web" ]] || {
  echo "=== setup webserver"
  mkdir -p /opt/web
  "${AIDEMOS_REPO_DIR}/env-setup/index.html.dd" > /opt/web/index.html
  cp "${AIDEMOS_REPO_DIR}/utils/run-simpleweb.sh" /opt/web/run-simpleweb.sh
  touch "${AIDEMOS_TRACKING_DIR}/.web"
}


# mlflow
[[ -f "${AIDEMOS_TRACKING_DIR}/.mlflow" ]] || {
  echo "=== installing mlflow"
  sudo -u mlflow mkdir -p /opt/mlflow
  sudo -u mlflow cp "${AIDEMOS_REPO_DIR}/utils/run-mlflowui.sh" /opt/mlflow/run-mlflowui.sh
  touch "${AIDEMOS_TRACKING_DIR}/.mlflow"
}


# airflow
[[ -f "${AIDEMOS_TRACKING_DIR}/.airflow" ]] || {
  echo "=== installing airflow"
  sudo -u airflow mkdir -p /opt/airflow
  sudo -u airflow cp "${AIDEMOS_REPO_DIR}/utils/run-airflow.sh" /opt/airflow/run-airflow.sh
  echo "=== initializing airflow database "
  sudo -u airflow tmux new -d -s airflowdb bash -c "source /etc/profile.d/conda.sh; conda activate python36; cd /opt/airflow/; airflow initdb 2>&1 | tee ${AIDEMOS_TRACKING_DIR}/airflow-initdb.out; touch ${AIDEMOS_TRACKING_DIR}/.airflow-initdb"
  [[ -f "${AIDEMOS_TRACKING_DIR}/.airflow-initdb" ]] && echo "=== airflow database initialization airflow done "
  #sudo -u airflow sed -i "s/localhost/${PUBLIC_IP}/" /opt/airflow/airflow/airflow.cfg
  touch "${AIDEMOS_TRACKING_DIR}/.airflow"
}

# jupyter
[[ -f "${AIDEMOS_TRACKING_DIR}/.jupyter" ]] || {
  echo "=== installing jupyter"
  sudo -u jupyter mkdir -p /opt/jupyter
  sudo -u jupyter rsync -avh "${AIDEMOS_REPO_DIR}/utils/jupyter/" /opt/jupyter/
  touch "${AIDEMOS_TRACKING_DIR}/.jupyter"
}

/opt/web/run-simpleweb.sh

sudo -H -u h2o /opt/h2o/run-h2owebui.sh
sudo -H -u mlflow /opt/mlflow/run-mlflowui.sh
sudo -H -u airflow /opt/airflow/run-airflow.sh
sudo -H -u /opt/jupyter/jupyterctl start

[[ -z "${AIDEMOS_TMP_DIR}" ]] || rm -rf "${AIDEMOS_TMP_DIR}"

echo "INFO - logs in ${AIDEMOS_TRACKING_DIR}"
echo "INFO - services are accessibles through http://${PUBLIC_IP}/index.html"
echo "INFO - end of install-tools $( date )"
