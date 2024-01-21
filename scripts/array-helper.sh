#!/bin/bash
source /app/.bashrc

mapfile -t lines < /app/helper/.MODULES
cmd_array=( xcaddy build ${CADDY_VERSION} )

for module in "${lines[@]}"; do
    cmd_array+=( --with "$module" )
done

cmd_array+=( --output /usr/bin/caddy )
"${cmd_array[@]}"

# https://unix.stackexchange.com/a/403401
