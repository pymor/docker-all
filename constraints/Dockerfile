FROM pymor/python_PYVER:VERTAG as builder
# libopenblas-dev cmake: needed for slycot install (wheel building)
# mpi-default-dev: for mpi4py install/wheel
RUN pip install pypi-oldest-requirements>=2020.4.2 && \
  apt update && \
  apt install -y libopenblas-dev mpi-default-dev make g++ gfortran cmake

COPY requirements* /requirements/

COPY constraints.bash /usr/local/bin
RUN constraints.bash

FROM alpine:3.12

COPY --from=builder /requirements/ /requirements/
RUN apk add bash
VOLUME "/output"
ENTRYPOINT []
CMD ["cp", "-ra", "/requirements", "/output"]
