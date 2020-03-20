ARG BUILD_FROM
FROM $BUILD_FROM

# Add env
ENV LANG C.UTF-8

# Setup base
RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing nymphcast-server

# Copy data
COPY run.sh /
RUN chmod a+x /run.sh

#COPY nymphcast_config.ini /etc/
CMD [ "/run.sh" ]
