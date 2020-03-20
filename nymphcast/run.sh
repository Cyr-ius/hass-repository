#!/usr/bin/env bashio
set -e

CONFIG="nymphcast_config.ini"

bashio::log.info "Configuring NymphCast..."

# run nymphcast
bashio::log.info "Starting NymphCast..."
exec nymphcast_server -C "${CONFIG}" < /dev/null
