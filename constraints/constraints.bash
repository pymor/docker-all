#!/usr/bin/env bash
set -exo pipefail
# fenics and pymor-deallii packages need to be filtered from the freeze command since they're already installed
# in the constrainer base image and cannot be installed from pypi

REQUIREMENTS="requirements.txt requirements-ci.txt requirements-optional.txt requirements-docker-other.txt"

# these are copied from the pymor/ci_wheels image
pip install /ci_wheels/*whl

cd /requirements/
for fn in ${REQUIREMENTS} ; do
    PARG="-r ${fn} ${PARG}"
done
pip install ${PARG}

for fn in ${REQUIREMENTS} ; do
    check_reqs.py ${fn}
done

pip freeze --all | grep -v fenics | grep -v dolfin |grep -v dealii \
  > /requirements/constraints.txt

cd /requirements/
for fn in ${REQUIREMENTS} ; do
    pypi_minimal_requirements_pinned ${fn} oldest_${fn}
done

cd /requirements/
virtualenv /tmp/venv_old

/tmp/venv_old/bin/pip install /ci_wheels/*whl
for fn in oldest_require*.txt ; do
    VARG="-r ${fn} ${VARG}"
done
/tmp/venv_old/bin/pip install ${VARG}
# currently cannot work due to file-by-file processing of pypi_minimal_requirements_pinned
# for fn in oldest_require*.txt ; do
#     check_reqs.py ${fn}
# done


# torch is still excluded here since it cannot be installed from pypi
/tmp/venv_old/bin/pip freeze --all | grep -v fenics | grep -v torch | grep -v dolfin |grep -v dealii \
  > /requirements/oldest_constraints.txt
