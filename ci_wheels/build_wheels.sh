#!/usr/bin/env bash

set -ex

WHEELHOUSE=/wheelhouse
mkdir /src
pip install wheel

for pkg in ${WHEEL_PKGS} ; do
  cd /src
  if [[ "${pkg}" == "vtk" ]] ; then
    wget -qO /src/${pkg}.tar.gz https://www.vtk.org/files/release/9.0/VTK-9.0.3.tar.gz
    unp /src/${pkg}.tar.gz
    mkdir /tmp/build
    cd /tmp/build
    cmake /src/VTK-* -DVTK_WHEEL_BUILD=ON -DVTK_PYTHON_VERSION=3
    make
  else
    pip download --no-binary :all: --no-deps $pkg -d /src/
    unp /src/${pkg}*.tar.gz && rm /src/${pkg}*.tar.gz
    cd ${pkg}*
  fi
  pip wheel --use-feature=in-tree-build . -w ${WHEELHOUSE}/tmp
  mv ${WHEELHOUSE}/tmp/${pkg}* ${WHEELHOUSE}/
  rm -rf ${WHEELHOUSE}/tmp
done

pip download --no-deps torch==1.8.1+cpu torchvision==0.9.1+cpu torchaudio==0.8.1 \
  -f https://download.pytorch.org/whl/torch_stable.html -d ${WHEELHOUSE}/
