ARG     IMAGE_REPOSITORY=public.ecr.aws/docker/library/alpine
ARG     IMAGE_ALPINE_VERSION=edge

FROM    ${IMAGE_REPOSITORY}:${IMAGE_ALPINE_VERSION} AS alpine-builder

WORKDIR /usr/app/builder

ARG     CADDY_MODULES
ARG     GO_CADDY_VERSION

# Buildah has tendency to ignore build args if they're nested...
ARG     TARGETOS=linux
ARG     TARGETARCH=amd64
ARG     ALPINE_REPO_URL=https://dl-cdn.alpinelinux.org/alpine
ARG     ALPINE_REPO_VERSION=edge
ARG     GO_MAIN_FILE=https://raw.githubusercontent.com/caddyserver/caddy/master/cmd/caddy/main.go
ARG     GIT_WORKTREE=/app/worktree
ARG     GOCACHE=/app/go/cache
ARG     CGO_ENABLED=0

ENV     GOOS=$TARGETOS \
        GOARCH=$TARGETARCH

# O:R-X,U:---,A:---
COPY    --chmod=0500 /scripts/array-helper.sh /app/helper/array-helper.sh
COPY    --chmod=0500 /scripts/install-go.sh /app/helper/install-go.sh
COPY    /scripts/entrypoint.go /app

ENV     PATH="/usr/bin:/bin:/sbin:/usr/local/go/bin:/usr/local/go:/app/go/bin"

RUN apk update \
    && apk upgrade --no-cache \
    && apk add --no-cache --virtual build_ess --repository=${ALPINE_REPO_URL}/${ALPINE_REPO_VERSION}/main \
        jq \
        tar \
        git  \
        curl \
        bash \
        openssl \
    && apk add --no-cache --repository=${ALPINE_REPO_URL}/${ALPINE_REPO_VERSION}/main \
        ca-certificates \
    && /app/helper/install-go.sh \
    && GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -ldflags="-s -w" -trimpath -o /app/go/bin/entrypoint-${TARGETARCH} /app/entrypoint.go \
    && mkdir -p caddy \
    && curl -Lo caddy/main.go ${GO_MAIN_FILE} \
    && go mod init caddy \
    && /app/helper/array-helper.sh \
    && GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -ldflags="-s -w" -trimpath -o /app/go/bin/caddy-${TARGETARCH} ./caddy \
    && apk del --rdepends \
        build_ess \
    && rm -rf \
        /tmp \
        /app/git \
        /app/worktree \
        /usr/local/go \
        /usr/app/caddy \
        /var/cache/apk \
        /usr/app/go/cache \
    && rm /app/entrypoint.go \
    && mkdir -p /app/logs

FROM    scratch AS qor-caddy
WORKDIR /app

# Set OCI labels
LABEL   org.opencontainers.image.authors Mr. Rubber Ducky (Simon)
LABEL   org.opencontainers.image.url https://github.com/Rubberverse/qor-caddy
LABEL   org.opencontainers.image.source https://github.com/Rubberverse/qor-caddy
LABEL   org.opencontainers.image.licenses MIT
LABEL   org.opencontainers.image.vendor Rubberverse
LABEL   org.opencontainers.image.source https://github.com/Rubberverse/qor-caddy
LABEL   org.containers.image.title Quackers of Rubberverse - Caddy (qor-caddy)
LABEL   org.containers.image.description Rootless and Distroless Caddy image built with extra modules

ARG     TARGETARCH=amd64

COPY    --from=alpine-builder --chmod=0505 /app/go/bin/caddy-${TARGETARCH} /app/go/bin/entrypoint-${TARGETARCH} /app/bin
COPY    --from=alpine-builder /usr/share/ca-certificates /usr/share/ca-certificates
COPY    --from=alpine-builder /app/logs /app/logs

USER 1001:1001
ENTRYPOINT ["/app/bin/entrypoint"]
