#!/bin/bash
set -e -x

if [ -z ${PYVER+x} ]; then
    PYVER="cp34-cp34m"
fi

# Install required system packages
yum install -y atlas-devel openmpi-devel fltk freeglut libpng libjpeg tk tcl xorg-x11-server-Xvfb
rpm -ivh /io/gmsh-r8692-1.el5.x86_64.rpm

# enable mpi4py compilation
export MPICC=/usr/lib64/openmpi/1.4-gcc/bin/mpicc

# Compile wheels
PYBIN=/opt/python/${PYVER}/bin
WHEEL_DIR=/io/wheelhouse
REQ=/io/requirements.txt
if [[ -f /io/requirements_${PYVER}.txt ]] ; then
    REQ=/io/requirements_${PYVER}.txt
fi
# evtk fails to install w/o numpy present
${PYBIN}/pip install numpy
${PYBIN}/pip install -r ${REQ}
${PYBIN}/pip wheel /io/pymor/ -w ${WHEEL_DIR}/

# Bundle external shared libraries into the wheels
for whl in ${WHEEL_DIR}/pymor*.whl; do
    auditwheel repair $whl -w ${WHEEL_DIR}/
done

# Install packages and test
${PYBIN}/pip install --pre --no-index -f file://${WHEEL_DIR} ${WHEEL_DIR}/pymor-*${PYVER}-manylinux*.whl
/io/xvfb-run -a ${PYBIN}/py.test --pyargs pymortests -c /io/pymor/.installed_pytest.ini
