#!/bin/bash
set -e -x

# Install a system package required by our library
yum install -y atlas-devel openmpi-devel

# enable mpi4py compilation
export MPICC=/usr/lib64/openmpi/1.4-gcc/bin/mpicc

# Compile wheels

WHEEL_DIR=/io/wheelhouse
${PYBIN}/pip install -r /io/requirements.txt
${PYBIN}/pip wheel /io/pymor/ -w ${WHEEL_DIR}/

# Bundle external shared libraries into the wheels
for whl in ${WHEEL_DIR}/pymor*.whl; do
    auditwheel repair $whl -w ${WHEEL_DIR}/
done

# Install packages and test
${PYBIN}/pip install -vvv --pre --no-index -f file://${WHEEL_DIR} pymor
(cd $HOME; ${PYBIN}/py.test pymor)
