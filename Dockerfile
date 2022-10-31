# setup build arguments for version of dependencies to use
ARG DOCKER_GEN_VERSION=0.9.0
ARG FOREGO_VERSION=v0.17.0

# Use a specific version of golang to build both binaries
FROM golang:1.18.1-alpine as gobuilder
RUN apk add --no-cache git musl-dev


# Install docker-gen, copied from https://github.com/nginx-proxy/nginx-proxy/blob/main/Dockerfile.alpine

# Build docker-gen from scratch
FROM gobuilder as dockergen

ARG DOCKER_GEN_VERSION

RUN git clone https://github.com/nginx-proxy/docker-gen \
   && cd /go/docker-gen \
   && git -c advice.detachedHead=false checkout $DOCKER_GEN_VERSION \
   && go mod download \
   && CGO_ENABLED=0 go build -ldflags "-X main.buildVersion=${DOCKER_GEN_VERSION}" ./cmd/docker-gen \
   && go clean -cache \
   && mv docker-gen /usr/local/bin/ \
   && cd - \
   && rm -rf /go/docker-gen

# Install Forego, copied from https://github.com/nginx-proxy/nginx-proxy/blob/main/Dockerfile.alpine

# Build forego from scratch
FROM gobuilder as forego

ARG FOREGO_VERSION

RUN git clone https://github.com/nginx-proxy/forego/ \
   && cd /go/forego \
   && git -c advice.detachedHead=false checkout $FOREGO_VERSION \
   && go mod download \
   && CGO_ENABLED=0 go build -o forego . \
   && go clean -cache \
   && mv forego /usr/local/bin/ \
   && cd - \
   && rm -rf /go/forego

# Build our image
FROM mitmproxy/mitmproxy:6.0.2

LABEL maintainer="artemkloko <artemkloko@gmail.com>"

# Because forego requires bash
RUN apk add --no-cache bash dnsmasq

# Install Forego + docker-gen
COPY --from=forego /usr/local/bin/forego /usr/local/bin/forego
COPY --from=dockergen /usr/local/bin/docker-gen /usr/local/bin/docker-gen

ADD dnsmasq.tmpl /etc/dnsmasq.tmpl
ADD dnsmasq-reload /usr/local/bin/dnsmasq-reload
