#!/usr/bin/env bash

set -ex

WHEELHOUSE=/wheelhouse
mkdir /src
pip install wheel

for pkg in ${WHEEL_PKGS} ; do
  cd /src
  pip download --no-deps $pkg -d /src/
  unp /src/${pkg}*.tar.gz && rm /src/${pkg}*.tar.gz
  cd ${pkg}*
  pip wheel . -w ${WHEELHOUSE}/tmp
  mv ${WHEELHOUSE}/tmp/${pkg}* ${WHEELHOUSE}/
  rm -rf ${WHEELHOUSE}/tmp
done

pip download --no-deps torch==1.7.1+cpu torchvision==0.8.2+cpu torchaudio==0.7.2 \
  -f https://download.pytorch.org/whl/torch_stable.html -d ${WHEELHOUSE}/ 
