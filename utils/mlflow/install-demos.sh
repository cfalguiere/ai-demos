#!/bin/bash
# run as mlflow

# tutos

pushd $PWD

cd /data/aidemos/

mkdir -p mlflow

pushd $PWD

# tutos
mkdir -p /data/aidemos/mlflow
git clone https://github.com/mlflow/mlflow mlflowquickstart

popd


popd
