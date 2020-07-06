ARG DEBIAN_DATE
FROM debian:buster-${DEBIAN_DATE}-slim

RUN apt update -y && apt install -y python3-pip && \
    apt remove -y gcc && apt autoremove -y
