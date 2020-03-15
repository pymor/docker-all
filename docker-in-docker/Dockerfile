FROM docker:stable
MAINTAINER René Fritze <rene.fritze@wwu.de>

RUN apk --update add openssh-client rsync git file bash python3 curl make \
 && pip3 install --no-cache ruamel.yaml==0.15.100 jinja2 jupyter-repo2docker docker-compose
