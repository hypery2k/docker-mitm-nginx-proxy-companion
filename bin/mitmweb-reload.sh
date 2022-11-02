#!/usr/bin/env sh

# This was copied from https://github.com/jderusse/docker-dns-gen/blob/master/dnsmasq-reload

killall mitmweb
su - mitmproxy -c "/usr/bin/mitmweb -q"