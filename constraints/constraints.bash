#!/usr/bin/env bash
set -exo pipefail
# fenics and pymor-deallii packages need to be filtered from the freeze command since they're already installed
# in the constrainer base image and cannot be installed from pypi

REQUIREMENTS="requirements.txt requirements-ci.txt requirements-optional.txt requirements-docker-other.txt"
pip install /usr/local/share/torch*whl

cd /requirements/
for fn in ${REQUIREMENTS} ; do
    pip install -r ${fn}
done

pip freeze --all | grep -v pymess | grep -v fenics | grep -v torch | grep -v dolfin |grep -v dealii \
  > /requirements/constraints.txt

cd /requirements/
for fn in ${REQUIREMENTS} ; do
    pypi_minimal_requirements_pinned ${fn} oldest_${fn}
done

cd /requirements/
virtualenv /tmp/venv_old

/tmp/venv_old/bin/pip install /usr/local/share/torch*whl
for fn in oldest_require*.txt ; do
    /tmp/venv_old/bin/pip install --use-deprecated=legacy-resolver -r ${fn}
done

/tmp/venv_old/bin/pip freeze --all | grep -v pymess | grep -v fenics | grep -v torch | grep -v dolfin |grep -v dealii \
  > /requirements/oldest_constraints.txt
