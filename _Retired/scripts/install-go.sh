#!/bin/sh
export GO_VERSION=$(curl https://go.dev/dl/?mode=json | jq -r '.[0].version' )
dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"
curl -Lo golang.tar.gz https://go.dev/dl/${GO_VERSION}.linux-${dpkgArch}.tar.gz
tar -C /usr/local -xzf golang.tar.gz
rm golang.tar.gz
git config --global --add safe.directory '*'
