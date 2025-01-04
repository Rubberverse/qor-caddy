ARG IMAGE_REPOSITORY=docker.io/library
ARG IMAGE_ALPINE_VERSION=edge

FROM --platform=$BUILDPLATFORM $IMAGE_REPOSITORY/alpine:$IMAGE_ALPINE_VERSION AS alpine-builder

WORKDIR /usr/app/builder

ARG TARGETOS
ARG TARGETARCH
ARG CADDY_MODULES
ARG GO_CADDY_VERSION

ARG ALPINE_REPO_URL=https://dl-cdn.alpinelinux.org/alpine \
    ALPINE_REPO_VERSION=edge \
    GIT_WORKTREE=/app/worktree \
    GO_MAIN_FILE=https://raw.githubusercontent.com/caddyserver/caddy/master/cmd/caddy/main.go \
    GOCACHE=/app/go/cache \
    CGO_ENABLED=0

ENV GOOS=$TARGETOS \
    GOARCH=$TARGETARCH

COPY --chmod=0755 ../scripts/array-helper.sh \ 
    /app/helper/array-helper.sh

RUN apk upgrade --no-cache \
    && apk add --no-cache --virtual build_ess --repository=${ALPINE_REPO_URL}/${ALPINE_REPO_VERSION}/main \
        jq \
        git \
        tar \
        bash \
        curl \
        ca-certificates \
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
    && GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -ldflags '-w s' -trimpath -tags=memoize_builders -o /app/go/bin/caddy-${TARGETARCH} ./caddy \
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

FROM --platform=$TARGETPLATFORM $IMAGE_REPOSITORY/alpine:$IMAGE_ALPINE_VERSION AS qor-caddy
WORKDIR /app

ARG ALPINE_REPO_URL=https://dl-cdn.alpinelinux.org/alpine \
    ALPINE_REPO_VERSION=edge \
    CONT_SHELL="/bin/sh" \
    CONT_USER=caddy \
    CONT_UID=1001

ARG TARGETARCH

LABEL stage=qor-caddy

COPY --from=alpine-builder --chmod=0755 /app/go/bin/caddy-$TARGETARCH /app/bin/caddy
COPY --chmod=755 ../scripts/docker-entrypoint.sh /app/scripts/docker-entrypoint.sh
LABEL org.opencontainers.image.source https://github.com/Rubberverse/qor-caddy

RUN apk update \
    && apk upgrade --no-cache \
    && apk add --no-cache --repository=${ALPINE_REPO_URL}/${ALPINE_REPO_VERSION}/main \
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
        /srv/www \
    && chown -R "$CONT_UID":"$CONT_UID" \
        /app \
        /srv/www \
    && rm -rf \
        /var/cache/apk

USER caddy

ENTRYPOINT /app/scripts/docker-entrypoint.sh
