ARG BUILD_FROM
FROM $BUILD_FROM

# Add env
ENV LANG C.UTF-8

# Setup base
RUN apk add --no-cache dnsmasq

# Copy data
COPY data/run.sh /
COPY data/dnsmasq.conf /etc/
COPY data/dnsmasq.leases /data/

RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
