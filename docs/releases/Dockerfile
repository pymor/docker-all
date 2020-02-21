FROM pymor/demo:0.4 as demo04

COPY build_docs.bash /home/pymor/
RUN /home/pymor/build_docs.bash 0.4.x

FROM pymor/demo:0.5 as demo05

COPY build_docs.bash /home/pymor/
RUN /home/pymor/build_docs.bash 0.5.x

FROM pymor/demo:2019.2 as demo2019.2

COPY build_docs.bash /home/pymor/
USER root
RUN pip install pymor-nb2plots
USER pymor
RUN /home/pymor/build_docs.bash 2019.2.x

FROM alpine:latest

COPY --from=demo04 /home/pymor/docs/ /docs/
COPY --from=demo05 /home/pymor/docs/ /docs/
COPY --from=demo2019.2 /home/pymor/docs/ /docs/

RUN ls -hl /docs/
