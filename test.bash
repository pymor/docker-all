#!/bin/bash

rm -rf venv
virtualenv --python python${REV} venv
. venv/bin/activate
python -c "import pip; print(pip.pep425tags.get_supported())"
python -c 'import distutils.util; print(distutils.util.get_platform())'
pip install -U pip
pip install --pre --no-index -f file://${PWD}/wheelhouse/ wheelhouse/pymor-*-${PYVER}-manylinux1_x86_64.whl
pip install -r pymor/requirements-optional.txt
xvfb-run -a py.test --pyargs pymortests -c ./pymor/.ci/installed_pytest.ini
