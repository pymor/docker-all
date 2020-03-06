ARG PYVER=3.7
FROM python:${PYVER}

ENV MIRROR_VERSION=4.0.2 \
  PIP_VERSION=20.0.1 \
  SERVER_ROOT=/pymor
RUN pip install "python-pypi-mirror==${MIRROR_VERSION}"  pip==${PIP_VERSION} pypi-oldest-requirements>=2020.4.1 \
      requests-toolbelt \
  && useradd --shell /bin/bash -u 1000 -o -m -d /data -c "" -m pymor \
  && mkdir ${SERVER_ROOT} \
  && chown pymor ${SERVER_ROOT}


# needs repeat after FROM
ARG PYVER

COPY requirements*.txt constraints_py${PYVER}.txt ${SERVER_ROOT}/requirements/
# file url downloads for mess cannot be constrained and would error out the whoe process
RUN cd ${SERVER_ROOT}/requirements \
  && (for fn in req*.txt ; do \
    (grep pymess ${fn} > only_mess) ; \
    grep -v pymess ${fn} | grep -v fenics | grep -v pymor-dealii > filtered_req ; \
  done)

RUN set -e ; cd ${SERVER_ROOT}/requirements \
  && for fn in req*.txt ; do \
    pip download -d ../downloads -r filtered_req -c constraints_py${PYVER}.txt && \
    echo 'done part 1 ************************************* ' ${fn} && \
    pip download -d ../downloads -r only_mess && \
    echo 'done part 2 ************************************* ' ${fn} && \
    pypi_minimal_requirements_pinned ${fn} pinned && \
    cat pinned | sort | uniq > pinned_u && cat pinned_u && \
    pip download -d ../downloads -r pinned_u && \
    echo 'done part 3 ************************************* '${fn} ; \
  done
RUN cd ${SERVER_ROOT}/ \
  && pypi-mirror create -d downloads -m simple \
  && rm -rf /tmp/*

USER pymor
WORKDIR ${SERVER_ROOT}
ENTRYPOINT ["python", "-m", "http.server", "--bind", "0.0.0.0", "8080" ]
