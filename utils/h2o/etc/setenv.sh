
set -eu
trap "{ echo 'ERROR - h2o setenv FAILED' ; exit 255; }" SIGINT SIGTERM ERR

source env-setup/setenv.sh

echo "INFO - h2o setenv COMPLETED"
