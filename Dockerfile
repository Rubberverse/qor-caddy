# =============================================================================
# 1. ALPINE BUILDER STAGE
# =============================================================================

ARG IMAGE_REPOSITORY=docker.io/library  \
    IMAGE_ALPINE_VERSION=latest

ARG BUILDPLATFORM

FROM --platform=$BUILDPLATFORM ${IMAGE_REPOSITORY}/alpine:${IMAGE_ALPINE_VERSION} AS alpine-builder
WORKDIR /app

ARG TARGETPLATFORM
ARG TARGETOS
ENV GOOS $TARGETOS
ENV GOARCH $TARGETARCH

# For clean-up, each stage is labeled
LABEL stage=alpine-builder
LABEL maintainer MrRubberDucky <contact@rubberverse.xyz>

ARG IMAGE_REPOSITORY=docker.io/library                      \
    IMAGE_ALPINE_VERSION=latest                             \
    ALPINE_REPO_URL=https://dl-cdn.alpinelinux.org/alpine   \
    ALPINE_REPO_VERSION=v3.19                               \
    GO_XCADDY_VERSION=latest                                \
    GO_CADDY_VERSION=latest                                 \
    GOPATH=/app/go                                          \
    GOCACHE=/app/go/cache                                   \
    GOOS=linux                                              \
    GIT_DIR=/app/git                                        \
    GIT_WORKTREE=/app/worktree

ENV CGO_ENABLED=0 \
    XCADDY_SKIP_CLEANUP=1 \
    XCADDY_GO_BUILD_FLAGS="--trimpath -ldflags '-w -s'"

COPY --chmod=0755 scripts/array-helper.sh \ 
    /app/helper/array-helper.sh

COPY templates/template.MODULES \ 
    /app/helper/.MODULES

RUN set -eux; \
    echo "Installing dependencies" \
    ; apk add --no-cache --virtual build_ess --repository=${ALPINE_REPO_URL}/${ALPINE_REPO_VERSION}/main \
        bash                \
        git                 \
        ca-certificates     \
        go                  \
        curl                \
    ; echo "Building xcaddy from source"                                            \
    ; go install github.com/caddyserver/xcaddy/cmd/xcaddy@${GO_XCADDY_VERSION}      \
    ; echo "Executing array-helper.sh"                                              \
    ; /app/helper/array-helper.sh                                                   \
    ; echo "Final clean up"                                                         \
    ; chmod +x /usr/bin/caddy                                                       \
    ; apk del --rdepends                                                            \
        build_ess                                                                   \
    ; rm -rf                                                                        \
        /app/go                                                                     \
        /app/git                                                                    \
        /tmp

# =============================================================================
# 2. ALPINE BASE STAGE
# =============================================================================

ARG IMAGE_REPOSITORY=docker.io/library                      \
    IMAGE_ALPINE_VERSION=latest

FROM --platform=$TARGETPLATFORM ${IMAGE_REPOSITORY}/alpine:${IMAGE_ALPINE_VERSION} AS qor-caddy
WORKDIR /app

ARG ALPINE_REPO_URL=https://dl-cdn.alpinelinux.org/alpine   \
    ALPINE_REPO_VERSION=v3.19                               \
    CONT_SHELL=/bin/sh                                      \
    CONT_HOME=/app                                          \
    CONT_USER=caddy                                         \
    CONT_UID=1001

LABEL stage=qor-caddy
LABEL maintainer MrRubberDucky <contact@rubberverse.xyz>

COPY --from=alpine-builder  \
    --chmod=755 /usr/bin/caddy /app/caddy

COPY configs/Caddyfile      \ 
    /app/configs/Caddyfile

COPY --chmod=755            \
    scripts/docker-entrypoint.sh /app/scripts/docker-entrypoint.sh

EXPOSE 80
EXPOSE 443
EXPOSE 443/udp
EXPOSE 2019

RUN echo "Installing dependencies" \
    && apk add --no-cache --repository=${ALPINE_REPO_URL}/${ALPINE_REPO_VERSION}/main \
        ca-certificates     \
        openssl             \
    && apk add --no-cache --virtual deps --repository=${ALPINE_REPO_URL}/${ALPINE_REPO_VERSION}/main \
        libcap              \
        libcap-setcap       \
    && echo "Adding user"   \
    && adduser \
        --home "/app"       \
        --shell "$CONT_SHELL"    \
        --uid "$CONT_UID"        \
        --disabled-password      \
        --no-create-home         \
        "$CONT_USER"             \
    && mkdir -p \
        /app/logs                \
    && echo "Fixing permissions"                        \
    && chown -R "$CONT_UID" /srv /app                   \
    && tail -n +2 /etc/passwd > /app/passwd             \
    && tail -n +2 /etc/shadow > /app/shadow             \
    && echo "Removing things"                           \
    && rm                                               \
        /etc/shadow                                     \
        /etc/passwd                                     \
    && echo "Removing root user (or well breaking it)"  \
    && mv /app/passwd /etc/passwd                       \
    && mv /app/shadow /etc/shadow                       \
    && echo "Setting capabilities"                      \
    && setcap 'cap_net_bind_service=+ep' /app/caddy     \
    && apk del --rdepends                               \
        deps                                            \
    && rm -rf /var/cache/apk/*                          \
    && /usr/bin/openssl version -a

USER ${CONT_UID}

ENTRYPOINT /app/scripts/docker-entrypoint.sh
