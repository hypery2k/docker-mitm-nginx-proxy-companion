#!/bin/sh

set -o errexit
set -o pipefail
set -o nounset


MITMPROXY_PATH="/home/mitmproxy/.mitmproxy"
mkdir -p "$MITMPROXY_PATH"
mkdir -p /var/logs/
chown -R mitmproxy:mitmproxy "$MITMPROXY_PATH"

# The following part was modified to generate Procfile with the commands
# needed to run by forego
echo "mitmproxy: docker-gen -watch -only-exposed -notify \"mitmweb-reload.sh\" /etc/mitm-config.tmpl $MITMPROXY_PATH/config.yaml" > Procfile
echo "dnsmasq: docker-gen -watch -only-exposed -notify \"dnsmasq-reload.sh\" /etc/dnsmasq.tmpl /etc/dnsmasq.conf" >> Procfile
forego start -r