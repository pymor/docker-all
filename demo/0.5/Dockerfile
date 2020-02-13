FROM pymor/testing_py3.7:0.5

MAINTAINER René Fritze <rene.fritze@wwu.de>

USER root
RUN apt-get update && \
    apt-get install -y libglvnd0  xvfb libgl1-mesa-dri libglu1-mesa  && \
    rm -rf /var/lib/apt/lists/* && \
    useradd --shell /bin/bash -u 1000 -o -c "" -m pymor
RUN pip install "pymor>=0.5.0,<0.6"
USER pymor

RUN pymor-demo --help && python -c "from pymor.basic import *"

ENV LIBGL_DEBUG=verbose
ENTRYPOINT ["/usr/local/bin/pymor-demo"]
CMD ["--help"]
