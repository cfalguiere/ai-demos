#!/bin/bash
# tested against  a AWS EC2 instance with a Linux 2 VM (Ubuntu)

set -eu
trap "{ echo 'ERROR - MLflow UI failed' ; exit 255; }" SIGINT SIGTERM ERR

# initialize the database

# TODO skip init - reentrance
! tmux has-session -t airflowdb 2>/dev/null && {
  echo "=== initializing airflow database "
  tmux new -d -s airflowdb bash -c "conda activate python37; airflow initdb" 
  echo "=== airflow database initialization airflow done "
}

# start the web server, default port is 8080
! tmux has-session -t airflowws 2>/dev/null && {
  echo "=== starting airflow web server"
  tmux new -d -s mlflowui bash -c "conda activate python37; airflow webserver -p 8080" &
}

# start the scheduler
! tmux has-session -t airflowscheduler 2>/dev/null && {
  echo "=== starting airflow scheduler"
  tmux new -d -s mlflowui bash -c "conda activate python37; airflow scheduler" &
}

# TODO check airflow for existence

echo "INFO - Airflow started"




