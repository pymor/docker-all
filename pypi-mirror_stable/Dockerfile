# EXPERIMENTAL_SYNTAX
FROM python:PYVER
# --no-use-pep517 makes sure scipy and numpy do not install build deps at download time
ENV MIRROR_VERSION=4.0.5 \
  PIP_VERSION=20.3.1 \
  SERVER_ROOT=/pymor \
  PYTORCH_VERSION=1.5.1 \
  XDG_CACHE_HOME=/cache \
  DOWNLOAD="pip download --no-deps -d /pymor/downloads"

RUN MOUNT_CACHE \
  pip install -qq "python-pypi-mirror==${MIRROR_VERSION}"  pip==${PIP_VERSION} \
    pypi-oldest-requirements>=2020.4.1 requests-toolbelt \
  && useradd --shell /bin/bash -u 1000 -o -m -d /data -c "" -m pymor \
  && mkdir ${SERVER_ROOT} \
  && chown pymor ${SERVER_ROOT}

COPY --from=zivgitlab.wwu.io/pymor/docker/pymor/constraints_pyPYVER:VERTAG /requirements/*.txt ${SERVER_ROOT}/requirements/
# non-installable package cannot be downloaded and would error out the whole process
COPY --from=REGISTRY/pymor/ci_wheels_pyPYVER:VERTAG /wheelhouse/*.whl /tmp/
COPY extra_version_downloads.txt /tmp/
RUN MOUNT_CACHE \
  ${DOWNLOAD} /tmp/*whl && rm /tmp/*whl \
  && set -uex \
  && ${DOWNLOAD} -r ${SERVER_ROOT}/requirements/constraints.txt \
  && ${DOWNLOAD} -r /tmp/extra_version_downloads.txt \
  && set -uex \
  && cd ${SERVER_ROOT}/ \
  && pypi-mirror --print-traceback create  -d downloads -m simple \
  && rm -rf /tmp/*


USER pymor
WORKDIR ${SERVER_ROOT}
ENTRYPOINT ["python", "-m", "http.server", "--bind", "0.0.0.0", "8080" ]
