BASEDIR=$(readlink -f $0 | xargs dirname)

# anaconda
ANACONDA_VERSION="Anaconda3-2019.07-Linux-x86_64.sh"
ANACONDA_URL="https://repo.anaconda.com/archive/${ANACONDA_VERSION}"
wget -q  "${ANACONDA_URL}"  -O miniconda.sh
mkdir /opt
bash ./miniconda.sh -b -p /opt/miniconda
/opt/miniconda/bin/conda update -y conda

# mlflow
/opt/miniconda/bin/conda env create --file ${BASEDIR}/conda-mlflow.yml

mkdir ./mlruns

# utils
snap install tree
