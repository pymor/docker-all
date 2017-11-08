#!/bin/bash
set -e -x

# Compile wheels

# pre-downloading deps makes testing easier, use full set here
${PYBIN}/pip download -d ${WHEEL_DIR}/ -r /io/pymor/requirements-optional.txt
# installing requirements assures working setup.py scripts
sudo ${PYBIN}/pip install -r /io/pymor/requirements.txt

${PYBIN}/pip wheel /io/pymor/ -w ${WHEEL_DIR}/

# Bundle external shared libraries into the wheels
for whl in ${WHEEL_DIR}/pymor*.whl; do
    auditwheel repair $whl -w ${WHEEL_DIR}/
done

