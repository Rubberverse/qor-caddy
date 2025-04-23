#!/bin/sh
# =================== Export current golang version to GO_VERSION variable
export GO_VERSION=$(curl https://go.dev/dl/?mode=json | jq -r '.[0].version' )
# =================== Printing for info
printf "%b" "\n[install-deps] Script launch. Installs ${GO_VERSION} and sets up goawk.\n"
# =================== Grabbing Go
printf "%b" "\n[Part1] Pulling latest archive for Go ${GO_VERSION}\n"
curl -Lo golang.tar.gz go.dev/dl/${GO_VERSION}.${TARGETOS}-${TARGETARCH}.tar.gz
printf "%b" "\n[Part1] Extracting it to /usr/local then removing archive\n"
tar -C /usr/local -xzf golang.tar.gz
rm golang.tar.gz
# =================== Git safe.directory workaround
printf "%b" "\n[Part2] Setting safe.directory for git command to any (wildcard)\n"
git config --global --add safe.directory '*'
# =================== goawk build
printf "%b" "\n[Part3] Getting latest version of goawk...\n"
git clone https://github.com/benhoyt/goawk.git -b master /app/goawk
ls -l /app/goawk
printf "%b" "\n[Part3] Building goawk using go build...\n"
GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -C /app/goawk -ldflags="-s -w" -trimpath -o /app/go/bin/goawk-${TARGETARCH} /app/goawk
printf "%b" "\n[Part3] Removing source directory...\n"
rm -rf /app/goawk
# =================== sleep.go build
printf "%b" "\n[Part4] Building simple sleep executable (/scripts/sleep.go)\n"
GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -ldflags="-s -w" -trimpath -o /app/go/bin/sleep-${TARGETARCH} /app/sleep.go
printf "%b" "\n[Part4] Removing source file...\n"
rm /app/sleep.go
# =================== Script end
printf "%b" "\n Script completed \n"