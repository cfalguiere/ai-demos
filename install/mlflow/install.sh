BASEDIR=$(readlink -f $0 | xargs dirname)

# prereq
apt install snapd

# anaconda
echo "INFO - install Anaconda"
mkdir -p /opt
cd $_
ANACONDA_VERSION="Anaconda3-2019.07-Linux-x86_64.sh"
ANACONDA_URL="https://repo.anaconda.com/archive/${ANACONDA_VERSION}"
wget -q  "${ANACONDA_URL}"  -O miniconda.sh
bash ./miniconda.sh -b -p /opt/miniconda
/opt/miniconda/bin/conda update -y conda

# mlflow
echo "INFO - install MLFlow"
/opt/miniconda/bin/conda env create --file ${BASEDIR}/conda-mlflow.yml
mkdir -p /opt/mlflow/mlruns

echo "INFO - install Completed"

rm /opt/miniconda.sh 
