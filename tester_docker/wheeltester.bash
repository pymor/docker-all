#!/bin/bash

python -c "import pip; print(pip.pep425tags.get_supported())"
python -c 'import distutils.util; print(distutils.util.get_platform())'
sudo pip install -U pip
sudo pip install -r /usr/local/src/pymor/requirements-optional.txt
ls -l /io
sudo pip install --no-index --find-links=/io pymor
cd /tmp
xvfb-run -a py.test --pyargs pymortests -c /usr/local/src/pymor/.ci/installed_pytest.ini
