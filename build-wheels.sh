#!/bin/bash
set -e -x

# Install a system package required by our library
yum install -y atlas-devel

# we do not build wheels for:
# cPython 2.6 - pymor's incompatible with it
# cPython 3.3 - there's no scipy wheel for it
# Compile wheels

WHEEL_DIR=/io/wheelhouse

for PYBIN in /opt/python/cp3{4,5}*/bin /opt/python/cp27*/bin; do
    ${PYBIN}/pip install -r /io/requirements.txt
    ${PYBIN}/pip wheel /io/pymor/ -w ${WHEEL_DIR}/
done

# Bundle external shared libraries into the wheels
for whl in ${WHEEL_DIR}/pymor*.whl; do
    auditwheel repair $whl -w ${WHEEL_DIR}/
done

# Install packages and test
for PYBIN in /opt/python/cp3{4,5}*/bin /opt/python/cp27*/bin; do
    ${PYBIN}/pip install -vvv --pre --no-index -f file://${WHEEL_DIR} pymor
    (cd $HOME; ${PYBIN}/py.test pymor)
done
