#!/bin/bash

set -e

sudo pip install -U pip pytest setuptools
sudo pip install /io/pymor-*-${PYVER}-manylinux1_x86_64.whl
cd /tmp
xvfb-run -a py.test --pyargs pymortests -c /usr/local/src/installed_pytest.ini
