FROM ubuntu:20.10
RUN apt-get update && \
    apt-get install -y motion mosquitto-clients tini

RUN mkdir /data

COPY entrypoint.sh /entrypoint.sh
COPY motion.conf /config/motion.conf

ENTRYPOINT ["/entrypoint.sh"]
