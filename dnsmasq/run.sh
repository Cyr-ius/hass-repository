#!/usr/bin/env bashio
set -e

CONFIG="/etc/dnsmasq.conf"

bashio::log.info "Configuring dnsmasq..."

if $(bashio::config 'logqueries');then
    echo "log-queries" >> "${CONFIG}"
fi

# Add domain range
for domain in $(bashio::config 'domain'); do
    echo "domain=${domain}" >> "${CONFIG}"
    echo "local=/${domain}/" >> "${CONFIG}"
    echo "domain-needed" >> "${CONFIG}"
    echo "expand-hosts" >> "${CONFIG}"
    echo "bogus-priv" >> "${CONFIG}"
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
    RANGE=$(bashio::config "dhcprange[${range}].range")
    
    echo "dhcp-range=${RANGE}" >> "${CONFIG}"
done

# Create dhcp hosts
for host in $(bashio::config 'dhcphost|keys'); do
    MAC=$(bashio::config "dhcphost[${host}].mac")
    VALUE=$(bashio::config "dhcphost[${host}].value")

    echo "dhcp-host=${MAC},${VALUE}" >> "${CONFIG}"
done

# Create dhcp options
for option in $(bashio::config 'dhcpoption|keys'); do
    OPTION=$(bashio::config "dhcpoption[${option}].option")
    VALUE=$(bashio::config "dhcpoption[${option}].value")

    echo "dhcp-option=${OPTION},${VALUE}" >> "${CONFIG}"
done

if bashio::var.has_value "${RANGE}";then
    echo "dhcp-leasefile=/data/dnsmasq.leases" >> "${CONFIG}"
    echo "dhcp-authoritative" >> "${CONFIG}"
fi

if $(bashio::config 'enablera');then
    echo "enable-ra" >> "${CONFIG}"
    RAPARAM=$(bashio::config 'raparam')
    if bashio::var.has_value "${RAPARAM}";then
        echo "ra-param=${RAPARAM}" >> "${CONFIG}"
    fi
fi

if  $(bashio::config 'debug');then
    bashio::log.info "Viewing dnsmasq config"
    bashio::log.info "----------------------"    
    cat "${CONFIG}"
    bashio::log.info "----------------------"
fi

# run dnsmasq
bashio::log.info "Starting dnsmasq..."
exec dnsmasq -C "${CONFIG}" -z < /dev/null
