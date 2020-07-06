ARG DEBIAN_DATE
FROM debian:bullseye-${DEBIAN_DATE}-slim

RUN apt update -y && apt install -y python3-pip && \
    apt remove -y gcc && apt autoremove -y
COPY pip /usr/local/bin/pip
COPY pip.conf /etc/
