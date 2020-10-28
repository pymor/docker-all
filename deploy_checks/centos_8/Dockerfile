ARG CENTOS_VERSION
FROM centos:${CENTOS_VERSION}

RUN yum install -y python3 && \
  pip3 install pip==19.0

COPY pip.conf /etc/
