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
for server in $(bashio::config 'dhcp-range'); do
    echo "dhcp-range=${dhcp-range}" >> "${CONFIG}"
    echo "dhcp-leasefile=/etc/dnsmasq.leases" >> "${CONFIG}"
done

# Create dhcp hosts
for mac in $(bashio::config 'macs|keys'); do
    MAC=$(bashio::config "macs[${mac}].mac")
    IP=$(bashio::config "macs[${mac}].ip")

    echo "dhcp-host=${MAC},${IP}" >> "${CONFIG}"
done

# Create dhcp options
for item in $(bashio::config 'items|keys'); do
    ITEM=$(bashio::config "items[${item}].item")
    IP=$(bashio::config "items[${item}].ip")

    echo "dhcp-option=${ITEM},${IP}" >> "${CONFIG}"
done

# run dnsmasq
bashio::log.info "Starting dnsmasq..."
exec dnsmasq -C "${CONFIG}" -z < /dev/null
