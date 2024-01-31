#!/bin/bash
if [ -z ${XCADDY_MODULES+1} ]; then
    echo "env XCADDY_MODULES is set"
else
    echo "Empty or non-existent env XCADDY_MODULES, falling back to vanilla build"
    exec /app/go/bin/xcaddy build ${GO_CADDY_VERSION} --output /usr/bin/caddy
fi

read -ra env_arr <<<"$XCADDY_MODULES"
cmd_array=( /app/go/bin/xcaddy build ${GO_CADDY_VERSION} )

for module in "${env_arr[@]}"; do
    cmd_array+=( --with "$module" )
done

cmd_array+=( --output /usr/bin/caddy )
"${cmd_array[@]}"

# https://unix.stackexchange.com/a/403401
# https://stackoverflow.com/a/30212526
