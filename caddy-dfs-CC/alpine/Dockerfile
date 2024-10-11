ARG IMAGE_REPOSITORY=docker.io/library
ARG IMAGE_ALPINE_VERSION=edge

FROM --platform=$BUILDPLATFORM $IMAGE_REPOSITORY/alpine:$IMAGE_ALPINE_VERSION AS alpine-builder
WORKDIR /app

ARG TARGETOS=linux
ARG TARGETARCH

ARG ALPINE_REPO_URL=https://dl-cdn.alpinelinux.org/alpine \
    GO_MAIN_FILE=https://raw.githubusercontent.com/caddyserver/caddy/master/cmd/caddy/main.go \
    GO_CADDY_VERSION=v2.8.0-beta.2 \
    ALPINE_REPO_VERSION=v3.19 \
    GOCACHE=/app/go/cache \
    GOOS $TARGETOS \
    GOARCH $TARGETARCH \
    GIT_WORKTREE=/app/worktree \
    CGO_ENABLED=0 \
    CADDY_MODULES=""

COPY --chmod=0755 ../scripts/array-helper.sh \ 
    /app/helper/array-helper.sh

RUN apk upgrade --no-cache \
    && apk add --no-cache --virtual build_ess --repository=${ALPINE_REPO_URL}/${ALPINE_REPO_VERSION}/main \
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
    && GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -trimpath -o /app/go/bin/caddy-${TARGETARCH} ./ \
    && file /app/go/bin/caddy-"${TARGETARCH}" \
    && apk del --rdepends \
        build_ess \
    && rm -rf /app/go/cache /app/git /tmp /app/caddy /usr/local/go /app/worktree

FROM --platform=$TARGETPLATFORM docker.io/library/alpine:edge AS qor-caddy
WORKDIR /app

ARG ALPINE_REPO_URL=https://dl-cdn.alpinelinux.org/alpine \
    ALPINE_REPO_VERSION=edge \
    CONT_USER=caddy \
    CONT_SHELL="/bin/sh" \
    CONT_UID=1001

ARG TARGETARCH

LABEL stage=qor-caddy

COPY --from=alpine-builder --chmod=0755 /app/go/bin/caddy-$TARGETARCH /app/bin/caddy
COPY --chmod=755 ../scripts/docker-entrypoint.sh /app/scripts/docker-entrypoint.sh

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
    && mkdir -p /app/logs /srv/www \
    && chown -R "$CONT_UID":"$CONT_UID" /app /srv/www

USER caddy

ENTRYPOINT /app/scripts/docker-entrypoint.sh
