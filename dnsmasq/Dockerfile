ARG BUILD_FROM
FROM $BUILD_FROM

# Add env
ENV LANG C.UTF-8

# Setup base
RUN apk add --no-cache dnsmasq

# Copy data
COPY run.sh /
RUN chmod a+x /run.sh
COPY dnsmasq.conf /etc/
COPY dnsmasq.leases /etc/
RUN chmod a+rw /etc/dnsmasq.leases

CMD [ "/run.sh" ]
