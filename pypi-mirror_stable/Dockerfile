# EXPERIMENTAL_SYNTAX
FROM python:PYVER
# --no-use-pep517 makes sure scipy and numpy do not install build deps at download time
ENV MIRROR_VERSION=4.0.5 \
  PIP_VERSION=20.2.4 \
  SERVER_ROOT=/pymor \
  PYTORCH_VERSION=1.5.1 \
  XDG_CACHE_HOME=/cache \
  DOWNLOAD="pip download --no-deps --no-use-pep517 -d /pymor/downloads"

RUN MOUNT_CACHE \
  pip install -qq "python-pypi-mirror==${MIRROR_VERSION}"  pip==${PIP_VERSION} \
    pypi-oldest-requirements>=2020.4.1 requests-toolbelt \
  && useradd --shell /bin/bash -u 1000 -o -m -d /data -c "" -m pymor \
  && mkdir ${SERVER_ROOT} \
  && chown pymor ${SERVER_ROOT}

COPY PYVER/*.txt ${SERVER_ROOT}/requirements/
# non-installable package cannot be downloaded and would error out the whole process
# pytorch needs special casing due to --follow url
# openblas is needed for python 3.9 until numpy has a wheel
# for slycot: scikit-build
COPY --from=docker.io/pymor/pytorch_pyPYVER:1.6 /io/wheelhouse/torch*.whl /tmp/
RUN MOUNT_CACHE \
  ${DOWNLOAD} /tmp/torch*whl && rm /tmp/torch*whl \
  && set -uex ; \
  apt update && apt install -y libopenblas-base \
  && pip install scikit-build \
  && ${DOWNLOAD} -r ${SERVER_ROOT}/requirements/constraints.txt \
  && set -uex \
  && cd ${SERVER_ROOT}/ \
  && pypi-mirror --print-traceback create  -d downloads -m simple \
  && rm -rf /tmp/*

USER pymor
WORKDIR ${SERVER_ROOT}
ENTRYPOINT ["python", "-m", "http.server", "--bind", "0.0.0.0", "8080" ]
