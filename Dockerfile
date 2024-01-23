# =============================================================================
# 1. ALPINE BUILDER STAGE
# =============================================================================

ARG IMAGE_REPOSITORY=docker.io/library
ARG IMAGE_ALPINE_VERSION=latest

FROM ${IMAGE_REPOSITORY}/alpine:${IMAGE_ALPINE_VERSION} AS alpine-builder
WORKDIR /app

# For clean-up, each stage is labeled
LABEL stage=alpine-builder
LABEL maintainer MrRubberDucky <contact@rubberverse.xyz>

ARG IMAGE_REPOSITORY=docker.io/library                      \
    IMAGE_ALPINE_VERSION=latest                             \
    ALPINE_REPO_URL=https://dl-cdn.alpinelinux.org/alpine   \
    ALPINE_REPO_VERSION=v3.19                               \
    GO_XCADDY_VERSION=latest                                \
    GO_CADDY_VERSION=latest                                 \
    CONT_SHELL=/bin/bash                                    \
    CONT_HOME=/app                                          \
    CONT_USER=caddy                                         \
    CONT_GROUP=web                                          \
    CONT_UID=1001                                           \
    CONT_GID=1001                                           \
    GOPATH=/app/go                                          \
    GOCACHE=/app/go/cache                                   \
    GIT_DIR=/app/git                                        \
    GIT_WORKTREE=/app/worktree

COPY --chmod=0755 scripts/array-helper.sh   \ 
    /app/helper/array-helper.sh

COPY templates/template.bashrc         \ 
    /app/template.bashrc

COPY templates/template.MODULES             \ 
    /app/helper/.MODULES

RUN echo "Installing dependencies" \
    && apk add --no-cache --virtual build_ess --repository=${ALPINE_REPO_URL}/${ALPINE_REPO_VERSION}/main \
        gettext-envsubst    \
        bash                \
        git                 \
        ca-certificates     \
        go                  \
    && echo "Building xcaddy from source"                                       \
    && go install github.com/caddyserver/xcaddy/cmd/xcaddy@${GO_XCADDY_VERSION} \
    && echo "Filling template with our environmental variables"                 \
    && envsubst < /app/template.bashrc > /root/.bashrc                          \
    && echo "Executing array-helper.sh"                                         \
    && /bin/bash -c /app/helper/array-helper.sh                                 \
    && echo "Final clean up"                                                    \
    && apk del --rdepends                                                       \
        build_ess                                                               \
    && rm -rf                                                                   \
        /app/go                                                                 \
        /app/git                                                                \
        /app/worktree

# =============================================================================
# 2. ALPINE BASE STAGE
# =============================================================================

ARG IMAGE_REPOSITORY=docker.io/library                      \
    IMAGE_ALPINE_VERSION=latest

FROM ${IMAGE_REPOSITORY}/alpine:${IMAGE_ALPINE_VERSION} AS qor-caddy
WORKDIR /app

ARG ALPINE_REPO_URL=https://dl-cdn.alpinelinux.org/alpine   \
    ALPINE_REPO_VERSION=v3.19                               \
    CONT_SHELL=/bin/bash                                    \
    CONT_HOME=/app                                          \
    CONT_USER=caddy                                         \
    CONT_GROUP=web                                          \
    CONT_UID=1001                                           \
    CONT_GID=1001

LABEL stage=qor-caddy
LABEL maintainer MrRubberDucky <contact@rubberverse.xyz>

COPY --from=alpine-builder  \
    --chmod=755 /usr/bin/caddy /app/caddy

COPY --from=alpine-builder  \                                           
    --chown=${CONT_UID}:${CONT_GID} /root/.bashrc /app/.bashrc

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
        bash                \
        ca-certificates     \
        openssl=3.1.4-r4    \
    && echo "Adding group"  \
    && addgroup \
        --gid "$CONT_GID"   \
        "$CONT_GROUP"       \
    && echo "Adding user"   \
    && adduser \
        --home "/app/home"       \
        --shell "$CONT_SHELL"    \
        --ingroup "$CONT_GROUP"  \
        --uid "$CONT_UID"        \
        --disabled-password      \
        "$CONT_USER"             \
    && echo "Fixing permissions"                        \
    && chown -R "$CONT_UID":"$CONT_GID" /srv /app       \
    && tail -n +2 /etc/passwd > /app/passwd             \
    && tail -n +2 /etc/shadow > /app/shadow             \
    && echo "Removing things"                           \
    && rm                                               \
        /bin/ash                                        \
        /etc/shadow                                     \
        /etc/passwd                                     \
    && echo "Removing root user (or well breaking it)"  \
    && mv /app/passwd /etc/passwd                       \
    && mv /app/shadow /etc/shadow                       \
    && chmod 400                                        \
        /etc/passwd                                     \
        /etc/shadow

USER ${CONT_UID}:${CONT_GID}

ENTRYPOINT /app/scripts/docker-entrypoint.sh
