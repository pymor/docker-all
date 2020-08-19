set -ex
# fenics and pymor-deallii packages need to be filtered from the freeze command since they're already installed
# in the constrainer base image and cannot be installed from pypi

cd /requirements/
for fn in requirements*.txt ; do
    pip install --no-cache-dir -r ${fn}
done

pip freeze --all | grep -v pymess | grep -v fenics | grep -v pymor-dealii \
  > /requirements/constraints.txt

cd /requirements/
for fn in *.txt ; do
    pypi_minimal_requirements_pinned ${fn} oldest_${fn}
done

cd /requirements/
virtualenv /tmp/venv_old
for fn in oldest_require*.txt ; do
    /tmp/venv_old/bin/pip install --no-cache-dir -r ${fn}
done

/tmp/venv_old/bin/pip freeze --all | grep -v pymess | grep -v fenics | grep -v pymor-dealii \
  > /requirements/oldest_constraints.txt
