MAINTAINER MrRubberDucky <contact@rubberverse.xyz>

ARG CADDY_VERSION=2.7.6
ARG ALPINE_VERSION=3.19.0
ARG BUILD_VERSION=0.10
ARG USER=caddy
ARG GROUP=caddy
ARG UID=1001
ARG GID=1001
ARG GOPATH=/app/go
ARG GOBIN=/usr/bin/go
ARG HOME=/app
ARG SHELL=/bin/bash

FROM docker.io/library/alpine:${ALPINE_VERSION} AS alpine-builder
WORKDIR /
LABEL stage=alpine-builder

ARG CADDY_VERSION
ARG ALPINE_VERSION
ARG BUILD_VERSION
ARG USER
ARG GROUP
ARG UID
ARG GID
ARG GOPATH
ARG GOBIN
ARG HOME
ARG SHELL

RUN apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community \
    bash \
    envsubst \
    git \
    # It couldn't find it otherwise and this works quite well so meh
    && apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing \ 
        xcaddy \
        ca-certificates

COPY --chmod=0755 scripts/array-helper.sh /app/scripts/array-helper.sh
COPY scripts/template.MODULES /app/scripts/.MODULES

COPY templates/template.bashrc /app/.bashrc
RUN envsubst "$CADDY_VERSION" > /app/.bashrc \
    && envsubst "$UID" > /app/.bashrc \
    && envsubst "$GID" > /app/.bashrc \
    && envsubst "$USER" > /app/.bashrc \
    && envsubst "$GROUP" > /app/.bashrc \
    && envsubst "$HOME" > /app/.bashrc \
    && envsubst "$SHELL" > /app/.bashrc \
    && envsubst "$GOPATH" > /app/.bashrc \
    && envsubst "$GOBIN" > /app/.bashrc

RUN ["/bin/bash", "-c", "/app/scripts/array-helper.sh"]

RUN mv /etc/passwd /etc/passwd2 \
    && tail -n +2 /etc/passwd2 > /etc/passwd \
    && rm /etc/passwd2 \
    && chmod 444 /etc/passwd

RUN rm \
    /app/scripts/array-helper.sh \
    /app/scripts/.MODULES \
    && rm -rf /app/go

FROM docker.io/library/alpine:${ALPINE_VERSION} AS alpine-base
WORKDIR /app
ARG USER
ARG GROUP
ARG SHELL
ARG UID
ARG GID
LABEL stage=alpine-base

RUN apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community \
    bash \
    # envsubst - to insert variables into templates
    envsubst \
    # nss - for self-signed certificate generation
    nss \
    && apk update --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing \
    ca-certificates

RUN addgroup \
    --gid $GID \
    --system \
    "$GROUP"

RUN adduser \
    --home "/app" \
    --shell "$SHELL" \
    --ingroup "$GROUP" \
    --uid "$UID" \
    --no-create-home \
    --disabled-password \
    "$USER"

RUN rm /bin/ash \
    && chmod 444 /etc/passwd \
    && chown $USER:$GROUP /srv

# Entrypoint and needed files
COPY --chmod=0755 scripts/docker-entrypoint.sh /app/scripts/docker-entrypoint.sh
COPY --from=alpine-builder --chmod=755 /app/caddy /app/caddy
COPY --from=alpine-builder --chown=1001:1001 /app/.bashrc /app/.bashrc
COPY --from=alpine-builder /etc/passwd /app/passwd

# Caddyfiles
COPY configs/testing.Caddyfile /app/testCaddyfile
COPY configs/local.Caddyfile /app/localCaddyFile
COPY configs/prod.Caddyfile /app/prodCaddyFile

WORKDIR /app/scripts

# ================================
# Caddy-Test Build
# =================================
FROM alpine-base AS caddy-test
ENV CADDY_ENVIRONMENT=TEST
LABEL stage=caddy-test

RUN envsubst "$CADDY_ENVIRONMENT" > /app/.bashrc

EXPOSE 80
EXPOSE 443
EXPOSE 443/udp
EXPOSE 2019

ENTRYPOINT /app/scripts/docker-entrypoint.sh

# ================================
# Caddy-Local Build
# =================================
FROM alpine-base AS caddy-local
ARG USER
ARG GROUP

ENV CADDY_ENVIRONMENT=LOCAL
LABEL stage=caddy-local

RUN envsubst "$CADDY_ENVIRONMENT" > /app/.bashrc \
    && rm /etc/passwd

COPY --from=alpine-base --chmod=0444 /app/passwd /etc/passwd
USER $USER:$GROUP

EXPOSE 80
EXPOSE 443
EXPOSE 443/udp
EXPOSE 2019

WORKDIR /app
ENTRYPOINT /app/scripts/docker-entrypoint.sh

# ================================
# Caddy-Production Build
# =================================
FROM alpine-base AS caddy-prod
ARG USER
ARG GROUP

ENV CADDY_ENVIRONMENT=PROD
LABEL stage=caddy-prod

RUN envsubst "$CADDY_ENVIRONMENT" > /app/.bashrc \
    && rm /etc/passwd

COPY --from=alpine-base --chmod=0444 /app/passwd /etc/passwd
USER $USER:$GROUP

EXPOSE 80
EXPOSE 443
EXPOSE 443/udp
EXPOSE 2019

WORKDIR /app
ENTRYPOINT /app/scripts/docker-entrypoint.sh