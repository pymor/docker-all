#!/usr/bin/env bash

set -exu

git clone https://github.com/pymor/pymor /tmp/src
cd /tmp/src
pip install .[full,docs,ci]
python -c "from pymor.basic import *"
python -c "from Qt.QtWidgets import *"
python -c "from dolfinx import *"
python -c "from dolfin import *"
python -c "from ngsolve import *"
