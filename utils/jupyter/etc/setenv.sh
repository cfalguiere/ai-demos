
set -eu
trap "{ echo 'ERROR - jupyter setenv FAILED' ; exit 255; }" SIGINT SIGTERM ERR

source env-setup/setenv.sh;
source /etc/profile.d/conda.sh;
conda activate python36;

echo "INFO - jupyter etenv COMPLETED"
