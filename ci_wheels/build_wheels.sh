#!/usr/bin/env bash

set -ex

WHEELHOUSE=/wheelhouse
mkdir /src
pip install wheel

for pkg in slycot mpi4py ; do
  cd /src
  pip download --no-deps $pkg -d /src/
  unp /src/${pkg}*.tar.gz && rm /src/${pkg}*.tar.gz
  cd ${pkg}*
  pip wheel . -w ${WHEELHOUSE}/tmp
  mv ${WHEELHOUSE}/tmp/${pkg}* ${WHEELHOUSE}/
  rm -rf ${WHEELHOUSE}/tmp
done
