ARG     IMAGE_REPOSITORY=public.ecr.aws/docker/library/debian
ARG     IMAGE_ALPINE_VERSION=trixie-slim

FROM    ${IMAGE_REPOSITORY}:${IMAGE_ALPINE_VERSION} AS builder

ARG     CADDY_MODULES
ARG     GO_CADDY_VERSION
ARG     DEBUG
ARG     CADDY_DEFENDER
ARG     ASN_RANGES
ARG     TARGETOS
ARG     TARGETARCH
ARG     GO_MAIN_FILE=https://raw.githubusercontent.com/caddyserver/caddy/master/cmd/caddy/main.go
ARG     GIT_WORKTREE=/app/worktree
ARG     GOCACHE=/app/go/cache
ARG     CGO_ENABLED=0
ENV     GOOS=$TARGETOS
ENV     GOARCH=$TARGETARCH
ENV     PATH="/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/go/bin:/usr/local/go:/app/go/bin"
ENV     DEBIAN_FRONTEND=noninteractive
# O:R-X,U:---,A:---
COPY    --chmod=0500 /scripts/array-helper.sh /app/helper/array-helper.sh
COPY    --chmod=0500 /scripts/install-go.sh /app/helper/install-go.sh
COPY    /scripts/entrypoint.go /app

WORKDIR /usr/app/builder

RUN apt update \
    && apt upgrade \
    && apt install --no-install-recommends -y \
       jq \
       tar \
       git \
       curl \
       bash \
       openssl \
       ca-certificates \
    && /bin/bash -c /app/helper/install-go.sh \
    && GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -ldflags="-s -w" -trimpath -o /app/go/bin/entrypoint-${TARGETARCH} /app/entrypoint.go \
    && mkdir -p caddy \
    && curl -Lo caddy/main.go ${GO_MAIN_FILE} \
    && go mod init caddy \
    && /bin/bash -c /app/helper/array-helper.sh \
    && GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -ldflags="-s -w" -tags=memoize_builders -trimpath -o /app/go/bin/caddy-${TARGETARCH} ./caddy \
    && apt remove -y \
       jq \
       git \
       curl \
       openssl \
       ca-certificates \
    && apt autoremove -y \
    && rm -rf \
        /tmp \
        /etc/apt \
        /app/git \
        /app/worktree \
        /usr/local/go \
        /usr/app/caddy \
        /var/cache/apt \
        /usr/app/go/cache \
    && rm /app/entrypoint.go \
    && mkdir -p /app/logs

FROM    scratch AS qor-caddy

ARG     TARGETOS
ARG     TARGETARCH

# r-xr-xr-x
COPY    --from=builder --chmod=0555 /app/go/bin/caddy-${TARGETARCH} /app/bin/caddy
COPY    --from=builder --chmod=0555 /app/go/bin/entrypoint-${TARGETARCH} /app/bin/entrypoint
COPY    --from=builder /app/logs /app/logs

WORKDIR /app
USER    1100:1100

ENTRYPOINT ["/app/bin/entrypoint"]
