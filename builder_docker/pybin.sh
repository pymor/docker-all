#!/bin/sh

PYVER=$(python -c 'pyversions={"2.7":"cp27-cp27mu", "3.5":"cp35-cp35m", "3.6":"cp36-cp36m"}\
    ;import os;print(pyversions[os.environ["PYTHON_VERSION"]])')
export PYVER
PYBIN=/opt/python/${PYVER}/bin
export PYBIN
echo "HUHU"
