#!/bin/bash
source /root/.bashrc

echo "Splitting .MODULES into Array, parsing it, building out the command then executing it"
mapfile -t lines < /app/helper/.MODULES
cmd_array=( /app/go/bin/xcaddy build ${GO_CADDY_VERSION} )

for module in "${lines[@]}"; do
    cmd_array+=( --with "$module" )
done

cmd_array+=( --output /usr/bin/caddy )
"${cmd_array[@]}"

# https://unix.stackexchange.com/a/403401
