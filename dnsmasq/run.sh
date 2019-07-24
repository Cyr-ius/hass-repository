#!/usr/bin/env bashio
set -e

CONFIG="/etc/dnsmasq.conf"

bashio::log.info "Configuring dnsmasq..."
# Add domain range
for domain in $(bashio::config 'domain'); do
    echo "domain=${domain}" >> "${CONFIG}"
    echo "local=/${domain}/" >> "${CONFIG}"
    echo "domain-needed" >> "${CONFIG}"
    echo "expand-hosts" >> "${CONFIG}"
done

# Add default forward servers
for server in $(bashio::config 'defaults'); do
    echo "server=${server}" >> "${CONFIG}"
done

# Create domain forwards
for forward in $(bashio::config 'forwards|keys'); do
    DOMAIN=$(bashio::config "forwards[${forward}].domain")
    SERVER=$(bashio::config "forwards[${forward}].server")

    echo "server=/${DOMAIN}/${SERVER}" >> "${CONFIG}"
done

# Create static hosts
for host in $(bashio::config 'hosts|keys'); do
    HOST=$(bashio::config "hosts[${host}].host")
    IP=$(bashio::config "hosts[${host}].ip")

    echo "address=/${HOST}/${IP}" >> "${CONFIG}"
done

# Create dhcp range
for range in $(bashio::config 'dhcp-range|keys'); do
    START=$(bashio::config "dhcp-range[${range}].start")
    END=$(bashio::config "dhcp-range[${range}].end")
    MASK=$(bashio::config "dhcp-range[${range}].mask")
    DELAY=$(bashio::config "dhcp-range[${range}].delay")
    echo "dhcp-range=${START},${END},${MASK},${DELAY}" >> "${CONFIG}"
    echo "dhcp-leasefile=/etc/dnsmasq.leases" >> "${CONFIG}"
    echo "dhcp-autoritative" >> "${CONFIG}"
done

# Create dhcp hosts
for host in $(bashio::config 'dhcp-host|keys'); do
    MAC=$(bashio::config "dhcp-host[${host}].mac")
    IP=$(bashio::config "dhcp-host[${host}].ip")

    echo "dhcp-host=${MAC},${IP}" >> "${CONFIG}"
done

# Create dhcp options
for option in $(bashio::config 'dhcp-option|keys'); do
    ITEM=$(bashio::config "dhcp-option[${option}].item")
    IP=$(bashio::config "dhcp-option[${option}].ip")

    echo "dhcp-option=${ITEM},${IP}" >> "${CONFIG}"
done

# run dnsmasq
bashio::log.info "Starting dnsmasq..."
exec dnsmasq -C "${CONFIG}" -z < /dev/null
