ARG BASE
FROM ${BASE}

COPY requirements* /requirements/

# fenics and pymor-deallii packages need to be filtered from the freeze command since they're already installed
# in the constrainer base image and cannot be installed from pypi
RUN cd /requirements/ \
  && (for fn in *.txt ; do \
    pip install -r ${fn} ; \
  done || exit 1)\
  && pip freeze | grep -v pymess | grep -v fenics | grep -v pymor-dealii  > /requirements/constraints.txt

RUN pip install pypi-oldest-requirements>=2020.4.1

RUN cd /requirements/ \
  && (for fn in *.txt ; do \
    pip uninstall -y -r ${fn} && \
    pip install pypi-oldest-requirements>=2020.4.1 setuptools && \
    pypi_minimal_requirements_pinned ${fn} oldest_${fn} && \
    pip install -r oldest_${fn} ; \
  done || exit 1) \
  && pip freeze | grep -v pymess | grep -v fenics | grep -v pymor-dealii  > /requirements/oldest_constraints.txt
