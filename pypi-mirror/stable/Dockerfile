ARG PYVER=3.7
FROM python:${PYVER}

ENV MIRROR_VERSION=4.0.2 \
  PIP_VERSION=20.0.1 \
  SERVER_ROOT=/pymor
RUN pip install "python-pypi-mirror==${MIRROR_VERSION}"  pip==${PIP_VERSION} \
  && useradd --shell /bin/bash -u 1000 -o -m -d /data -c "" -m pymor \
  && mkdir ${SERVER_ROOT} \
  && chown pymor ${SERVER_ROOT}

USER pymor

# needs repeat after FROM
ARG PYVER

COPY requirements*.txt constraints_py${PYVER}.txt ${SERVER_ROOT}/requirements/
RUN cd ${SERVER_ROOT}/ \
  && (for fn in ${SERVER_ROOT}/requirements/*.txt ; do \
    pip download -d downloads -r ${fn} -c ${SERVER_ROOT}/requirements/constraints_py${PYVER}.txt ; \
  done || exit 1) \
  && pypi-mirror create -d downloads -m simple

WORKDIR ${SERVER_ROOT}
ENTRYPOINT ["python", "-m", "http.server", "--bind", "0.0.0.0", "8080" ]
