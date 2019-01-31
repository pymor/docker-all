#!/bin/bash -l
set -e -x

# do not build from dirty git unless DIRTY_BUILD evaluates to true
pushd /io/pymor
if [[ $(git rev-parse --show-toplevel 2>/dev/null) = "$PWD" ]] ; then
    [[ ${DIRTY_BUILD} ]] || git diff --exit-code ':(exclude)setup.cfg'
fi
popd

# Compile wheels

# pre-downloading deps makes testing easier, use full set here
${PYBIN}/pip download -q -d ${WHEEL_DIR}/ -r /io/pymor/requirements-optional.txt
# installing requirements assures working setup.py scripts
sudo ${PYBIN}/pip install -q -r /io/pymor/requirements.txt

${PYBIN}/pip wheel /io/pymor/ -w ${WHEEL_DIR}/

# Bundle external shared libraries into the wheels
for whl in ${WHEEL_DIR}/pymor*.whl; do
    auditwheel repair $whl -w ${WHEEL_DIR}/
done

