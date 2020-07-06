ARG DEBIAN_DATE
FROM debian:stretch-${DEBIAN_DATE}-slim

RUN apt update -y && apt install -y python3-pip && \
    apt remove -y gcc && apt autoremove -y
