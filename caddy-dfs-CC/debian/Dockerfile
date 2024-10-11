ARG IMAGE_REPOSITORY=docker.io/library
ARG IMAGE_ALPINE_VERSION=bookworm-slim

FROM --platform=$BUILDPLATFORM $IMAGE_REPOSITORY/debian:$IMAGE_ALPINE_VERSION AS debian-builder
WORKDIR /app

ARG TARGETOS
ARG TARGETARCH

ARG GO_MAIN_FILE=https://raw.githubusercontent.com/caddyserver/caddy/master/cmd/caddy/main.go \
    GO_CADDY_VERSION=v2.8.0-beta.2 \
    GOCACHE=/app/go/cache \
    GOOS $TARGETOS \
    GOARCH $TARGETARCH \
    GIT_WORKTREE=/app/worktree \
    CGO_ENABLED=0 \
    CADDY_MODULES=""

COPY --chmod=0755 ../scripts/array-helper.sh \ 
    /app/helper/array-helper.sh

# build deps: jq, git, tar, bash, curl
RUN apt-get update; apt-get upgrade -y; apt install -y \
        jq \
        git \
        tar \
        bash \
        curl \
        file \
        ca-certificates \
    && export GO_VERSION=$(curl https://go.dev/dl/?mode=json | jq -r '.[0].version' ) \
    && curl -LO go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf "${GO_VERSION}".linux-amd64.tar.gz \
    && rm "${GO_VERSION}".linux-amd64.tar.gz \
    && export PATH=${PATH}:/usr/local/go/bin:/app/go/bin \
    && git config --global --add safe.directory '*' \
    && mkdir -p caddy \
    && curl -L "${GO_MAIN_FILE}" -o caddy/main.go \
    && cd caddy \
    && go mod init caddy \
    && /app/helper/array-helper.sh \
    && GOOS="${TARGETOS}" GOARCH="${TARGETARCH}" go build -o /app/go/bin/caddy-"${TARGETARCH}" -a -trimpath -ldflags '-s -w' ./ \
    && file /app/go/bin/caddy-"${TARGETARCH}" \
    && apk del --rdepends \
        build_ess \
    && rm -rf /app/go/cache /app/git /tmp /app/caddy /usr/local/go /app/worktree

FROM --platform=$TARGETPLATFORM docker.io/library/debian:bookworm-slim AS qor-caddy
WORKDIR /app

ENV DEBIAN_FRONTEND=noninteractive
ARG CONT_USER=caddy \
    CONT_SHELL=/bin/sh \
    CONT_UID=1001

ARG TARGETARCH

COPY --from=debian-builder --chmod=0755 /app/go/bin/caddy-$TARGETARCH /app/bin/caddy
COPY --chmod=0755 ../scripts/docker-entrypoint.sh /app/scripts/docker-entrypoint.sh

RUN apt-get update; apt-get upgrade -y; apt install -y \
        ca-certificates \
        openssl \
    && useradd \
        --home-dir "/app" \
        --shell "$CONT_SHELL" \
        --uid "$CONT_UID" \
        --no-create-home \
        "$CONT_USER" \
    && mkdir -p /var/www/ \
    && chown -R "$CONT_UID":"$CONT_UID" /var/www /app \
    && rm -rf /var/cache/apt

USER caddy

ENTRYPOINT /app/scripts/docker-entrypoint.sh
