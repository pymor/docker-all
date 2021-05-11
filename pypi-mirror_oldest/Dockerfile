# EXPERIMENTAL_SYNTAX
FROM python:PYVER
# --no-use-pep517 makes sure scipy and numpy do not install build deps at download time
ENV MIRROR_VERSION=4.0.5 \
  PIP_VERSION=21.1.1 \
  SERVER_ROOT=/pymor \
  PYTORCH_VERSION=1.5.1 \
  XDG_CACHE_HOME=/cache \
  DOWNLOAD="/tmp/venv/bin/pip download --no-deps --no-use-pep517 -d /pymor/downloads" \
  PIP="/tmp/venv/bin/pip"

RUN MOUNT_CACHE \
  pip install -qq "python-pypi-mirror==${MIRROR_VERSION}"  pip==${PIP_VERSION} \
      requests-toolbelt virtualenv\
  && useradd --shell /bin/bash -u 1000 -o -m -d /data -c "" -m pymor \
  && mkdir ${SERVER_ROOT} \
  && chown pymor ${SERVER_ROOT} \
  && virtualenv /tmp/venv

COPY --from=zivgitlab.wwu.io/pymor/docker/pymor/constraints_pyPYVER:VERTAG /requirements/*.txt ${SERVER_ROOT}/requirements/
# non-installable package cannot be downloaded and would error out the whole process
COPY --from=REGISTRY/pymor/ci_wheels_pyPYVER:VERTAG /wheelhouse/*.whl /tmp/
RUN MOUNT_CACHE \
  ${DOWNLOAD} /tmp/*whl && rm /tmp/*whl \
  && set -uex \
  && ${DOWNLOAD} -r  ${SERVER_ROOT}/requirements/oldest_constraints.txt \
  && cd ${SERVER_ROOT}/ \
  && pypi-mirror create -d downloads -m simple \
  && rm -rf /tmp/*

USER pymor
WORKDIR ${SERVER_ROOT}
EXPOSE 8080
ENTRYPOINT ["python", "-m", "http.server", "--bind", "0.0.0.0", "8080" ]
