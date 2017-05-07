# Builds an image for Apache Kafka 0.10.2.1
#
# The openjdk:8-alpine base image runs OpenJDK 8 installed atop the
# alpine:3.5 official image. Docker's official Java images are
# OpenJDK-only currently and the Kafka project recommend using
# Oracle Java for production for optimal performance.
# This image is therefore mostly for open-source projects.

FROM openjdk:8-alpine
MAINTAINER Jean Bruno JAUVIN <jeanbjauvin@gmail.com>

ENV KAFKA_VERSION=0.10.2.1 \
  KAFKA_SCALA_VERSION=2.12 \
  KAFKA_HOME=/kafka \
  JMX_PORT=7203

RUN mkdir /kafka /data /logs \
  && apk add --no-cache --virtual wget bash \
  && wget -q -O - http://www.us.apache.org/dist/${KAFKA_VERSION}/kafka_${KAFKA_SCALA_VERSION}-${KAFKA_VERSION}.tgz | tar -xzf - -C /tmp \
  && mv /tmp/kafka_* ${KAFKA_HOME} \
  && rm /tmp/kafka_* \
  && addgroup -S kafka \
  && adduser -h /kafka -G kafka -S -H -s /sbin/nologin kafka \
  && chown -R kafka:kafka /kafka /data /logs

ADD config /kafka/config
ADD start.sh /start.sh

USER kafka

ENV PATH /kafka/bin:$PATH
WORKDIR /kafka

EXPOSE 9092 ${JMX_PORT}
VOLUME [ "/data", "/logs" ]

CMD [ "/start.sh" ]
