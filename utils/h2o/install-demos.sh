#!/bin/bash
# run as h2o

# tutos

pushd $PWD

cd /data/aidemos/projects/

mkdir -p h2o/{h2opy-demos,h2o-hello}

pushd $PWD

cd /data/aidemos/projects/h2o/h2o-hello
cat <<H2O_DD
import h2o
h2o.init()
h2o.demo("glm")
H2O_DD > hello.py

popd

pushd $PWD

cd /data/aidemos/projects/h2o/h2opy-demos
git init
git remote add origin -f https://github.com/h2oai/h2o-3.git
git config core.sparseCheckout true
echo "h2o-py/demos" >> .git/info/sparseCheckout
git pull origin master

popd

popd
