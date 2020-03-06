ARG BASE
FROM ${BASE}

COPY requirements* /requirements/

# fenics and pymor-deallii packages need to be filtered from the freeze command since they're already installed
# in the constrainer base image and cannot be installed from pypi
RUN cd /requirements/ \
  && (for fn in /requirements/*.txt ; do \
    pip install -r ${fn} ; \
  done || exit 1)\
  && pip freeze | grep -v pymess | grep -v fenics | grep -v pymor-dealii  > /requirements/constraints.txt

ENTRYPOINT ["cat", "/requirements/constraints.txt"]
