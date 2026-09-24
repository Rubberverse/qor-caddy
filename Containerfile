#       Builder image
FROM    public.ecr.aws/docker/library/debian:trixie-slim AS builder

ARG     CADDY_MODULES
ARG     CADDY_VERSION
ARG     CADDY_DEFENDER

ARG     GO_MAIN_FILE=https://raw.githubusercontent.com/caddyserver/caddy/master/cmd/caddy/main.go \
        GOCACHE=/app/go/cache \
        GOOS=$TARGETOS \
        GOARCH=$TARGETARCH \
        DEBIAN_FRONTEND=noninteractive \
        CGO_ENABLED=0

#       U:R-X,G:---,O:---
COPY    --chmod=0500 /scripts/array-helper.sh /app/helper/array-helper.sh

WORKDIR /usr/app/builder

RUN     apt update \
        && apt upgrade -y \
        && apt install --no-install-recommends -y \
            jq tar git curl bash golang-go openssl ca-certificates \
        && git config --global --add safe.directory '*' \
        && mkdir -p caddy \
        && curl -Lo caddy/main.go ${GO_MAIN_FILE} \
        && /app/helper/array-helper.sh \
        && go build -ldflags="-s -w" -trimpath -o /app/go/bin/caddy-${TARGETARCH} ./caddy \
        && mkdir -p /app/logs /app/templates \
        && curl -Lo /app/templates/browse.html https://raw.githubusercontent.com/glowinthedark/caddy-file-server-browse-extension/refs/heads/master/browse.html \
        && apt remove -y \
            jq git curl golang-go openssl ca-certificates \
        && apt autoremove -y \
        && rm -rf /tmp /etc/apt /app/git /app/worktree /usr/local/go /usr/app/caddy /var/cache/apt /usr/app/go/cache /usr/app/builder/golang.tar.gz

#       Runner image
FROM    scratch AS qor-caddy

#       UGO:R-X
COPY    --from=builder --chmod=0555 /app/go/bin/caddy-${TARGETARCH} /app/bin/caddy
COPY    --from=builder --chmod=0555 /app/templates /app/templates
#       U:RWX,GO:R-X
COPY    --from=builder --chmod=0755 /app/logs /app/logs

WORKDIR /app
USER    1100:1100

ENTRYPOINT ["/app/bin/caddy"]
CMD        ["-c /app/configs/Caddyfile"]
