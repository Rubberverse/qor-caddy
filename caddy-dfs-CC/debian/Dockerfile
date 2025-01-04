ARG IMAGE_REPOSITORY=docker.io/library
ARG IMAGE_ALPINE_VERSION=bookworm-slim

FROM --platform=$BUILDPLATFORM $IMAGE_REPOSITORY/debian:$IMAGE_ALPINE_VERSION AS debian-builder

WORKDIR /usr/app/builder

ARG TARGETOS
ARG TARGETARCH
ARG CADDY_MODULES
ARG GO_CADDY_VERSION

ARG GIT_WORKTREE=/app/worktree \
    GO_MAIN_FILE=https://raw.githubusercontent.com/caddyserver/caddy/master/cmd/caddy/main.go \
    GOCACHE=/app/go/cache \
    CGO_ENABLED=0

ENV GOOS=$TARGETOS \
    GOARCH=$TARGETARCH \
    DEBIAN_FRONTEND="noninteractive"

COPY --chmod=0755 ../scripts/array-helper.sh \ 
    /app/helper/array-helper.sh

RUN apt-get update \
    && apt-get upgrade -y \
    && apt install -y \
        jq \
        git \
        tar \
        bash \
        curl \
        ca-certificates \
	openssl \
    && export \
        GO_VERSION=$(curl https://go.dev/dl/?mode=json | jq -r '.[0].version' ) \
    && curl -Lo golang.tar.gz \
        go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz \
    && tar -C /usr/local \
        -xzf golang.tar.gz \
    && rm \
        golang.tar.gz \
    && export \
        PATH=${PATH}:/usr/local/go/bin:/app/go/bin \
    && git config \
        --global \
        --add safe.directory '*' \
    && mkdir -p \
        caddy \
    && curl -Lo caddy/main.go \
        ${GO_MAIN_FILE} \
    && go mod init caddy \
    && /app/helper/array-helper.sh \
    && GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -ldflags="-s -w" -trimpath -o /app/go/bin/caddy-${TARGETARCH} ./caddy \
    # Not removing any packages here because apt hard-deps everything so it would fail :)
    && rm -rf \
        /tmp \
        /app/git \
        /app/worktree \
        /usr/local/go \
        /usr/app/caddy \
        /var/cache/apt \
        /usr/app/go/cache

FROM --platform=$TARGETPLATFORM $IMAGE_REPOSITORY/debian:$IMAGE_ALPINE_VERSION AS qor-caddy
WORKDIR /app

ARG CONT_SHELL="/bin/sh" \
    CONT_USER=caddy \
    CONT_UID=1001

ARG TARGETARCH

ENV DEBIAN_FRONTEND="noninteractive"
LABEL org.opencontainers.image.source https://github.com/Rubberverse/qor-caddy

COPY --from=debian-builder --chmod=0755 /app/go/bin/caddy-$TARGETARCH /app/bin/caddy
COPY --chmod=755 ../scripts/docker-entrypoint.sh /app/scripts/docker-entrypoint.sh

RUN apt-get update \
    && apt-get upgrade -y \
    && apt install -y \
        ca-certificates \
        openssl \
    && adduser \
        --home "/app" \
        --shell "$CONT_SHELL" \
        --uid "$CONT_UID"  \
        --disabled-password \
        --no-create-home \
        "$CONT_USER" \
    && mkdir -p \
        /app/logs \
        /var/www \
    && chown -R "$CONT_UID":"$CONT_UID" \
        /app \
        /var/www \
    && rm -rf \
        /var/cache/apt

USER caddy

ENTRYPOINT /app/scripts/docker-entrypoint.sh
