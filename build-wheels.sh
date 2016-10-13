#!/bin/bash
set -e -x

# Install a system package required by our library
yum install -y atlas-devel openmpi-devel

# enable mpi4py compilation
export MPICC=/usr/lib64/openmpi/1.4-gcc/bin/mpicc

# Compile wheels
PYBIN=/opt/python/${PYVER}/bin
WHEEL_DIR=/io/wheelhouse
REQ=/io/requirements.txt
if [[ -f /io/requirements_${PYVER}.txt ]] ; then
    REQ=/io/requirements_${PYVER}.txt
fi
${PYBIN}/pip install -r ${REQ}
${PYBIN}/pip wheel /io/pymor/ -w ${WHEEL_DIR}/

# Bundle external shared libraries into the wheels
for whl in ${WHEEL_DIR}/pymor*.whl; do
    auditwheel repair $whl -w ${WHEEL_DIR}/
done

# Install packages and test
${PYBIN}/pip install --pre --no-index -f file://${WHEEL_DIR} ${WHEEL_DIR}/pymor-*${PYVER}-manylinux*.whl
${PYBIN}/py.test --pyargs pymortests -c /io/pymor/.installed_pytest.ini
