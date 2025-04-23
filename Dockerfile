ARG IMAGE_REPOSITORY=docker.io/library
ARG IMAGE_ALPINE_VERSION=edge

FROM $IMAGE_REPOSITORY/alpine:$IMAGE_ALPINE_VERSION AS alpine-builder

WORKDIR /usr/app/builder

ARG CADDY_MODULES
ARG GO_CADDY_VERSION

ARG TARGETOS=linux
ARG TARGETARCH=amd64
ARG ALPINE_REPO_URL=https://dl-cdn.alpinelinux.org/alpine
ARG ALPINE_REPO_VERSION=edge
ARG GO_MAIN_FILE=https://raw.githubusercontent.com/caddyserver/caddy/master/cmd/caddy/main.go
ARG GIT_WORKTREE=/app/worktree
ARG GOCACHE=/app/go/cache
ARG CGO_ENABLED=0

ENV GOOS=$TARGETOS \
    GOARCH=$TARGETARCH

# O:R-X,U:---,A:---
COPY --chmod=0500 /scripts/array-helper.sh /app/helper/array-helper.sh
COPY --chmod=0500 /scripts/install-deps.sh /app/helper/install-deps.sh
COPY /scripts/sleep.go /app/sleep.go

ENV PATH="/usr/bin:/bin:/sbin:/usr/local/go/bin:/usr/local/go:/app/go/bin"

# Update binaries from edge version so we don't end up with outdated dash or ca-certificates later
RUN apk update \
    && apk upgrade --no-cache \
    && apk add --no-cache --virtual build_ess --repository=${ALPINE_REPO_URL}/${ALPINE_REPO_VERSION}/main \
        jq \
        tar \
        git  \
        curl \
        bash \
        openssl \
    # This is not in build_essentials due to us needing them later
    && apk add --no-cache --repository=${ALPINE_REPO_URL}/${ALPINE_REPO_VERSION}/main \
        ca-certificates \
    # Installs latest Go and setups path
    && /app/helper/install-deps.sh \
    && mkdir -p caddy \
    # We use this as a base to build Caddy, modules are appened into this file
    && curl -Lo caddy/main.go ${GO_MAIN_FILE} \
    && go mod init caddy \
    # Builds go modules and pins version
    && /app/helper/array-helper.sh \
    # This command builds out the actual caddy binary
    && GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -ldflags="-s -w" -trimpath -o /app/go/bin/caddy-${TARGETARCH} ./caddy \
    # Remove build essentials and purge the rest
    && apk del --rdepends \
        build_ess \
    && rm -rf \
        /tmp \
        /app/git \
        /app/worktree \
        /usr/local/go \
        /usr/app/caddy \
        /var/cache/apk \
        /usr/app/go/cache

# Add dummy passwd file that will be used for scratch image
RUN echo "caddy:x:1001:1001::/app:/app/bin/dash" > /app/passwd \
    && mkdir -p /app/logs

FROM ghcr.io/yassinebenaid/bunster:v0.12.1 AS bunster-noshell

COPY /scripts/docker-entrypoint.sh /app/scripts/docker-entrypoint.sh
RUN bunster build /app/scripts/docker-entrypoint.sh -o /app/bin/docker-entrypoint-compiled

# Ultimate insanity
# I've never tried doing just scratch before so all workarounds you see here, they're intentional
# It's a scratch image, it has nothing in it!
FROM scratch AS qor-caddy
WORKDIR /app

# Set OCI labels
LABEL org.opencontainers.image.authors Mr. Rubber Ducky (Simon)
LABEL org.opencontainers.image.url https://github.com/Rubberverse/qor-caddy
LABEL org.opencontainers.image.source https://github.com/Rubberverse/qor-caddy
LABEL org.opencontainers.image.licenses MIT
LABEL org.opencontainers.image.vendor Rubberverse
LABEL org.opencontainers.image.source https://github.com/Rubberverse/qor-caddy
LABEL org.containers.image.title Quackers of Rubberverse - Caddy (qor-caddy)
LABEL org.containers.image.description Rootless and Distroless Caddy image built with extra modules

ARG TARGETOS=linux
ARG TARGETARCH=amd64

# Add binaries from build stage
COPY --from=alpine-builder --chmod=0505 /app/go/bin/caddy-$TARGETARCH /app/bin/caddy
COPY --from=alpine-builder --chmod=0505 /app/go/bin/sleep-$TARGETARCH /app/bin/sleep
COPY --from=alpine-builder --chmod=0505 /app/go/bin/goawk-$TARGETARCH /app/bin/goawk

# ca-certificates directory from build stage for proper certificate vetting
COPY --from=alpine-builder /usr/share/ca-certificates /usr/share/ca-certificates
COPY --from=alpine-builder /app/logs /app/logs
COPY --from=alpine-builder /app/passwd /etc/passwd

# Entrypoint script
COPY --from=bunster-noshell --chmod=0505 /app/bin/docker-entrypoint-compiled /app/bin/docker-entrypoint-compiled

USER 1001:1001
ENTRYPOINT ["/app/bin/docker-entrypoint-compiled"]