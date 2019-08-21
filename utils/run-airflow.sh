#!/bin/bash
# tested against  a AWS EC2 instance with a Linux 2 VM (Ubuntu)

set -eu
trap "{ echo 'ERROR - MLflow UI failed' ; exit 255; }" SIGINT SIGTERM ERR

# initialize the database


# start the web server, default port is 8080
! tmux has-session -t airflowws 2>/dev/null && {
  echo "=== starting airflow web server"
  tmux new -d -s airflowws bash -c "source /etc/profile.d/conda.sh; conda activate python36; cd /opt/airflow; airflow webserver -p 8080" &
}

# start the scheduler
! tmux has-session -t airflowscheduler 2>/dev/null && {
  echo "=== starting airflow scheduler"
  tmux new -d -s airflowscheduler bash -c "source /etc/profile.d/conda.sh; conda activate python36; cd /opt/airflow; airflow scheduler" &
}

# TODO check airflow for existence

echo "INFO - Airflow started"




