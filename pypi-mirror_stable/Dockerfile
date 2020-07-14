FROM python:PYVER

ENV MIRROR_VERSION=4.0.2 \
  PIP_VERSION=20.1.1 \
  SERVER_ROOT=/pymor \
  PYTORCH_VERSION=1.5.1 \
  DOWNLOAD="pip download --no-cache-dir -d /pymor/downloads"
RUN pip install --no-cache -qq "python-pypi-mirror==${MIRROR_VERSION}"  pip==${PIP_VERSION} \
    pypi-oldest-requirements>=2020.4.1 \
      requests-toolbelt \
  && useradd --shell /bin/bash -u 1000 -o -m -d /data -c "" -m pymor \
  && mkdir ${SERVER_ROOT} \
  && chown pymor ${SERVER_ROOT}


COPY requirements/*.txt ${SERVER_ROOT}/requirements/
# non-installable package cannot be downloaded and would error out the whoe process
# pytorch needs special casing due to --follow url
RUN cd ${SERVER_ROOT}/requirements \
  && ${DOWNLOAD} pip \
  && (for fn in req*.txt ; do \
    set +e ; \
    grep -v fenics ${fn} | grep -v pymor-dealii > filtered_req ; \
    set -e ; \
    ${DOWNLOAD} -r filtered_req -c ${SERVER_ROOT}/requirements/PYVER_constraints.txt ; \
  done) \
  && cd ${SERVER_ROOT}/ \
  && ${DOWNLOAD} torch==${PYTORCH_VERSION}+cpu -f https://download.pytorch.org/whl/torch_stable.html \
    -c ${SERVER_ROOT}/requirements/PYVER_constraints.txt \
  && pypi-mirror create -d downloads -m simple \
  && rm -rf /tmp/*

USER pymor
WORKDIR ${SERVER_ROOT}
ENTRYPOINT ["python", "-m", "http.server", "--bind", "0.0.0.0", "8080" ]
