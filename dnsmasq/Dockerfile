ARG BUILD_FROM
FROM $BUILD_FROM

# Add env
ENV LANG C.UTF-8

# Setup base
RUN apk add --no-cache dnsmasq

# Copy data
COPY run.sh /
RUN chmod a+x /run.sh

WORKDIR /data
COPY dnsmasq.leases /data/
RUN chmod a+rw /data/dnsmasq.leases

COPY dnsmasq.conf /etc/
CMD [ "/run.sh" ]
