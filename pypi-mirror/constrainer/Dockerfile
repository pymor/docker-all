ARG BASE
FROM ${BASE}

COPY requirements* /requirements/
RUN cd /requirements/ \
  && (for fn in /requirements/*.txt ; do \
    pip install -r ${fn} ; \
  done || exit 1)\
  && pip freeze > /requirements/constraints.txt

ENTRYPOINT ["cat", "/requirements/constraints.txt"]
