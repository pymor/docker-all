#!/bin/bash
set -e -x

if [ -z ${PYVER+x} ]; then
    PYVER="cp34-cp34m"
fi

# Compile wheels
PYBIN=/opt/python/${PYVER}/bin
WHEEL_DIR=/io/wheelhouse

sudo ${PYBIN}/pip install -r /io/pymor/requirements.txt

${PYBIN}/pip wheel /io/pymor/ -w ${WHEEL_DIR}/

# Bundle external shared libraries into the wheels
for whl in ${WHEEL_DIR}/pymor*.whl; do
    auditwheel repair $whl -w ${WHEEL_DIR}/
done

