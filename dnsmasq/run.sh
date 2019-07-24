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
for range in $(bashio::config 'dhcprange|keys'); do
    START=$(bashio::config "dhcprange[${range}].start")
    END=$(bashio::config "dhcprange[${range}].end")
    MASK=$(bashio::config "dhcprange[${range}].mask")
    DELAY=$(bashio::config "dhcprange[${range}].delay")
    echo "dhcp-range=${START},${END},${MASK},${DELAY}" >> "${CONFIG}"
    echo "dhcp-leasefile=/data/dnsmasq.leases" >> "${CONFIG}"
done

# Create dhcp hosts
for host in $(bashio::config 'dhcphost|keys'); do
    MAC=$(bashio::config "dhcphost[${host}].mac")
    IP=$(bashio::config "dhcphost[${host}].ip")

    echo "dhcp-host=${MAC},${IP}" >> "${CONFIG}"
done

# Create dhcp options
for option in $(bashio::config 'dhcpoption|keys'); do
    ITEM=$(bashio::config "dhcpoption[${option}].item")
    IP=$(bashio::config "dhcpoption[${option}].ip")

    echo "dhcp-option=${ITEM},${IP}" >> "${CONFIG}"
done

# run dnsmasq
bashio::log.info "Starting dnsmasq..."
cat "${CONFIG}"
exec dnsmasq -C "${CONFIG}" -z < /dev/null
