#!/bin/bash

set -e

sudo pip install --no-index --find-links=/io/ pymor[full]
cd /tmp
xvfb-run -a py.test --pyargs pymortests -c /usr/local/src/installed_pytest.ini
