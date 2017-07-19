FROM pymor/python:PYTHONREV

MAINTAINER René Milk <rene.milk@wwu.de>

ADD entrypoint.sh /usr/local/bin/
ADD xvfb-run /usr/local/bin/

ADD wheeltester.bash /usr/local/bin/
ADD installed_pytest.ini /usr/local/src/

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/local/bin/wheeltester.bash"]

