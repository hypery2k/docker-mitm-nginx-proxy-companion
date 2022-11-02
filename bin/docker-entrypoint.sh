#!/bin/sh

set -o errexit
set -o pipefail
set -o nounset

# start mitmproxy in background
screen -d -m mitmproxy -p${PROXY_PORT}

# The following part was modified to generate Procfile with the commands
# needed to run by forego
echo "dnsmasq: docker-gen -watch -only-exposed -notify \"dnsmasq-reload -u root\" /etc/dnsmasq.tmpl /etc/dnsmasq.conf" > Procfile
forego start -r