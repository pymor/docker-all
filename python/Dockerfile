FROM pymor/python_builder_PYVER:VERTAG as python_builder

FROM debian:buster-slim

ENV DEBIAN_FRONTEND=noninteractive \
    APTINSTALL="apt-get install -qq -y --no-install-recommends" \
    PIP_INSTALL="pip install --no-cache-dir -qq" \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    LANGUAGE=C.UTF-8
COPY --from=python_builder /usr/local/ /usr/local/
# python's configured to use system's expat and ffi libs
RUN echo "C.UTF-8 UTF-8" > /etc/locale.gen && \
	apt update -qq \
	&& ${APTINSTALL} libexpat1 libffi6 \
	libbz2-1.0 \
	libc6 \
	libcurl4 \
	libdb5.3 \
	libevent-2.1-6 \
	libgdbm6 \
	libglib2.0 \
	libjpeg62-turbo \
	liblzma5 \
	libncurses5 \
	libncursesw5 \
	libpng16-16 \
	libreadline7  \
	libsqlite3-0  \
	libssl1.1 \
	libfreetype6 \
	tcl \
	tk \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV MAKE_PROCS=2
CMD ["python3"]
