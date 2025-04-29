#!/bin/sh
export GO_VERSION=$(curl https://go.dev/dl/?mode=json | jq -r '.[0].version' )
curl -Lo golang.tar.gz go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz
tar -C /usr/local -xzf golang.tar.gz
rm golang.tar.gz
git config --global --add safe.directory '*'