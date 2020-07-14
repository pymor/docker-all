FROM pymor/python_PYVER:VERTAG as builder
# libopenblas-dev: needed for slycot install (wheel building)
# mpi-default-dev: for mpi4py install/wheel
RUN pip install pypi-oldest-requirements>=2020.4.1 && \
  apt update && \
  apt install -y libopenblas-dev mpi-default-dev

COPY requirements* /requirements/

# fenics and pymor-deallii packages need to be filtered from the freeze command since they're already installed
# in the constrainer base image and cannot be installed from pypi
RUN cd /requirements/ \
  && (for fn in requirements*.txt ; do \
    pip install --no-cache-dir -r ${fn} ; \
  done || exit 1)\
  && pip freeze --all | grep -v pymess | grep -v fenics | grep -v pymor-dealii  \
    > /requirements/PYVER_constraints.txt \
  && cd /requirements/ \
  && (for fn in *.txt ; do \
    pypi_minimal_requirements_pinned ${fn} PYVER_oldest_${fn} ; \
  done || exit 1) \
  && cd /requirements/ \
  && virtualenv /tmp/venv_old \
  && (for fn in PYVER_oldest_require*.txt ; do \
    /tmp/venv_old/bin/pip install --no-cache-dir -r ${fn} ; \
  done || exit 1) \
  && /tmp/venv_old/bin/pip freeze --all | grep -v pymess | grep -v fenics | grep -v pymor-dealii  \
    > /requirements/PYVER_oldest_constraints.txt

FROM alpine:3.12

COPY --from=builder /requirements/ /requirements/
VOLUME "/output"
ENTRYPOINT []
CMD ["cp", "-ra", "/requirements", "/output"]
