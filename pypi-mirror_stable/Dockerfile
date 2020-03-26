ARG PYVER=3.7
ARG VER
FROM pymor/constraints_py${PYVER}:${VER} as constraints

FROM python:${PYVER}

ENV MIRROR_VERSION=4.0.2 \
  PIP_VERSION=20.0.2 \
  SERVER_ROOT=/pymor
RUN pip install --no-cache -qq "python-pypi-mirror==${MIRROR_VERSION}"  pip==${PIP_VERSION} \
    pypi-oldest-requirements>=2020.4.1 \
      requests-toolbelt \
  && useradd --shell /bin/bash -u 1000 -o -m -d /data -c "" -m pymor \
  && mkdir ${SERVER_ROOT} \
  && chown pymor ${SERVER_ROOT}


# needs repeat after FROM
ARG PYVER

COPY --from=constraints /requirements/*.txt ${SERVER_ROOT}/requirements/
# non-installable package cannot be downloaded and would error out the whoe process
RUN cd ${SERVER_ROOT}/requirements \
  && (for fn in req*.txt ; do \
    set +e ; \
    grep -v fenics ${fn} | grep -v pymor-dealii > filtered_req ; \
    set -e ; \
    pip download -d ../downloads -r filtered_req -c ${SERVER_ROOT}/requirements/constraints.txt ; \
  done)
RUN cd ${SERVER_ROOT}/ \
  && pypi-mirror create -d downloads -m simple \
  && rm -rf /tmp/*

USER pymor
WORKDIR ${SERVER_ROOT}
ENTRYPOINT ["python", "-m", "http.server", "--bind", "0.0.0.0", "8080" ]
