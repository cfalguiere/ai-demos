#!/bin/bash
# run as h2o

# tutos

pushd $PWD

cd /data/aidemos/

mkdir -p h2o/{h2opy-demos,h2o-hello}

pushd $PWD

cd /data/aidemos/h2o/h2o-hello
cat > hello.py <<H2O_DD
import h2o
h2o.init()
h2o.demo("glm")
H2O_DD

popd

pushd $PWD

cd /data/aidemos/h2o/h2opy-demos
git init
git remote add origin https://github.com/h2oai/h2o-3.git
git config core.sparseCheckout true
echo "h2o-py/demos/" > .git/info/sparseCheckout
#git fetch --depth 1 origin tag master
#git checkout master
git pull --depth 1 origin master

popd

popd
