ARG PYVER
FROM pymor/python:$PYVER

MAINTAINER René Milk <rene.milk@wwu.de>

ADD wheeltester.bash entrypoint.sh /usr/local/bin/
ADD installed_pytest.ini /usr/local/src/

RUN apt update && apt install -y gosu sudo xvfb gmsh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/local/bin/wheeltester.bash"]

