#!/bin/bash
# tested against  a AWS EC2 instance with a Linux 2 VM (Ubuntu)
# run as root
# requires env-setup/setenv.sh
# requires users h2o, anaconda, mlflow, airflow, jupyter
# requires /opt

echo "INFO - starting install-tools $( date )"

set -eu
trap "{ echo 'ERROR - install failed' ; exit 255; }" SIGINT SIGTERM ERR

#TODO reintergrer setenv
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
  sudo -u h2o rsync -avh "${AIDEMOS_REPO_DIR}/utils/h2o/" /opt/h2o/
  # https://www.h2o.ai/download/#h2o
  H2O_VERSION="3.26.0.2"
  H2O_PACKAGE="h2o-${H2O_VERSION}.zip"
  H2O_URL="http://h2o-release.s3.amazonaws.com/h2o/rel-yau/2/${H2O_PACKAGE}"
  wget -q  "${H2O_URL}" -O "${AIDEMOS_TMP_DIR}/${H2O_PACKAGE}"
  sudo -u h2o unzip "${AIDEMOS_TMP_DIR}/${H2O_PACKAGE}" -d /opt/h2o/
  rm -rf "${AIDEMOS_TMP_DIR}/${H2O_PACKAGE}"
  sudo -u h2o ln -s /opt/h2o/h2o-${H2O_VERSION} /opt/h2o/h2oflowui
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


# mlflow
[[ -f "${AIDEMOS_TRACKING_DIR}/.mlflow" ]] || {
  echo "=== installing mlflow"
  sudo -u mlflow rsync -avh "${AIDEMOS_REPO_DIR}/utils/mlflow/" /opt/mlflow/
  touch "${AIDEMOS_TRACKING_DIR}/.mlflow"
}


# airflow
[[ -f "${AIDEMOS_TRACKING_DIR}/.airflow" ]] || {
  echo "=== installing Airflow"
  sudo -u airflow rsync -avh "${AIDEMOS_REPO_DIR}/utils/airflow/" /opt/airflow/
  echo "=== initializing Airflow database "
  sudo -u airflow tmux new -d -s airflowdb bash -c "cd /opt/airflow; source etc/setenv.sh; airflow initdb 2>&1 | tee -a /var/log/airflow/airflow-initdb.out; touch /var/log/airflow/.airflow-initdb"
  [[ -f /var/log/airflow/.airflow-initdb ]] && echo "=== Airflow database initialization COMPLETED "
  #sudo -u airflow sed -i "s/localhost/${PUBLIC_IP}/" /opt/airflow/airflow/airflow.cfg
  touch "${AIDEMOS_TRACKING_DIR}/.airflow"
}

# jupyter
[[ -f "${AIDEMOS_TRACKING_DIR}/.jupyter" ]] || {
  echo "=== installing jupyter"
  sudo -u jupyter rsync -avh "${AIDEMOS_REPO_DIR}/utils/jupyter/" /opt/jupyter/
  touch "${AIDEMOS_TRACKING_DIR}/.jupyter"
}


sudo -H -u h2o /opt/h2o/h2oflowctl start
sudo -H -u mlflow /opt/mlflow/mlflowctl start
sudo -H -u airflow /opt/airflow/airflowctl start
sudo -H -u jupyter /opt/jupyter/jupyterctl start

export AIDEMOS_TOKEN=$( awk 'BEGIN {FS="="};/token/ {print $2}'  /var/log/aidemos/jupyter/jupyter.out | head -1 )



[[ -f "${AIDEMOS_TRACKING_DIR}/.web" ]] || {
  echo "=== setup webserver"
  mkdir -p /opt/web
  "${AIDEMOS_REPO_DIR}/env-setup/index.html.dd" > /opt/web/index.html
  cp "${AIDEMOS_REPO_DIR}/utils/run-simpleweb.sh" /opt/web/run-simpleweb.sh
  touch "${AIDEMOS_TRACKING_DIR}/.web"
}

/opt/web/run-simpleweb.sh


[[ -z "${AIDEMOS_TMP_DIR}" ]] || rm -rf "${AIDEMOS_TMP_DIR}"

echo "INFO - logs in ${AIDEMOS_TRACKING_DIR}"
echo "INFO - services are accessibles through http://${PUBLIC_IP}/index.html"
echo "INFO - end of install-tools $( date )"
