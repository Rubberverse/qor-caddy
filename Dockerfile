# =============================================================================
# 1. ALPINE BUILDER STAGE
# =============================================================================

ARG ALPINE_VERSION=latest

FROM docker.io/library/alpine:${ALPINE_VERSION} AS alpine-builder
WORKDIR /app

# For clean-up, each stage is labeled
LABEL stage=alpine-builder
LABEL maintainer MrRubberDucky <contact@rubberverse.xyz>

ARG ALPINE_VERSION=latest   \
    CADDY_VERSION=latest    \
    BUILD_VERSION=0.10      \
    SHELL=/bin/bash         \
    GOPATH=/app/go          \
    USER=caddy              \
    GROUP=web               \
    HOME=/app               \
    UID=1001                \
    GID=1001                \
    GITDIR=/app/git         \
    GOCACHE=/app/cache      \
    GITWORKTREE=/app/tree

COPY --chmod=0755 scripts/array-helper.sh /app/helper/array-helper.sh
COPY templates/templatebuild.bashrc /app/temp.bashrc
COPY templates/template.MODULES /app/helper/.MODULES

RUN echo "Installing dependencies" \
    && apk add --no-cache --virtual build_community --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community \
        bash            \
        git             \
        envsubst        \
    && apk add --no-cache --virtual build_testing --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing \
        xcaddy          \
        ca-certificates \
    && envsubst < /app/temp.bashrc > /app/.bashrc   \
    && /bin/bash -c /app/helper/array-helper.sh     \
    && apk del --rdepends   \
        build_community     \
        build_testing       \
    && rm -rf /app

# =============================================================================
# 2. ALPINE BASE STAGE
# =============================================================================

FROM docker.io/library/alpine:${ALPINE_VERSION} AS qor-caddy
WORKDIR /app

LABEL stage=qor-caddy
LABEL maintainer MrRubberDucky <contact@rubberverse.xyz>

ARG ALPINE_VERSION=3.19.0   \
    CADDY_VERSION=2.7.6     \
    BUILD_VERSION=0.10      \
    SHELL=/bin/bash         \
    GOPATH=/app/go          \
    USER=caddy              \
    GROUP=web               \
    HOME=/app               \
    UID=1001                \
    GID=1001

COPY --from=alpine-builder --chmod=755 /usr/bin/caddy /app/caddy
COPY --chmod=755 scripts/docker-entrypoint.sh /app/scripts/docker-entrypoint.sh
COPY templates/template.bashrc /app/template.bashrc
COPY configs/Caddyfile /app/configs/Caddyfile

EXPOSE 80
EXPOSE 443
EXPOSE 443/udp
EXPOSE 2019

RUN echo "Installing dependencies, setting up users etc." \
    && apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community \
        bash                \
    && apk add --no-cache --virtual env_set --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community \
        envsubst            \
    && apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing \
        ca-certificates     \
    && addgroup \
        --gid "$GID"        \
        --system            \
        "$GROUP"            \
    && adduser \
        --home "/app/home"  \
        --shell "$SHELL"    \
        --ingroup "$GROUP"  \
        --uid "$UID"        \
        --disabled-password \
        "$USER"             \
    && adduser \
        "$USER"             \
        netdev              \
    && chown -R "$USER":"$GROUP" /srv /app              \
    && envsubst < /app/template.bashrc > /app/.bashrc   \
    && rm /bin/ash /app/template.bashrc                 \
    && apk del --rdepends env_set

ENTRYPOINT /app/scripts/docker-entrypoint.sh
