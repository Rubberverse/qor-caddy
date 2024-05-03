#!/bin/bash
if [ "x$GO_CADDY_VERSION" = "x" ]; then
    printf "[array-helper - warn] Empty value supplied for GO_CADDY_VERSION\n"
    printf "[array-helper - warn] Falling back to latest tag\n"
    export GO_CADDY_VERSION=latest
fi

if [ "x$XCADDY_MODULES" = "x" ]; then
    printf "[array-helper - error] Empty value supplied for XCADDY_MODULES\n"
    printf "[array-helper - error] If this is intentional, pass 0 to XCADDY_MODULES environmental variable to build Caddy without modules\n"
    exit 1
elif [ "$XCADDY_MODULES" = "0" ]; then
    printf "[array-helper] User wants to build vanilla/stock Caddy (without extra modules)\n[array-helper] This process may take a while\n\n"
    exec /app/go/bin/xcaddy build ${GO_CADDY_VERSION}
fi

printf "[array-helper] Parsing XCADDY_MODULES into an array\n"
read -ra env_arr <<<"$XCADDY_MODULES"

printf "[array-helper] Building out the command and then running it\n[array-helper] This process may take a while\n\n"
cmd_array=( /app/go/bin/xcaddy build ${GO_CADDY_VERSION} )

for module in "${env_arr[@]}"; do
    cmd_array+=( --with "$module" )
done

cmd_array+=( --output /app/bin/caddy )
"${cmd_array[@]}"

# https://unix.stackexchange.com/a/403401
# https://stackoverflow.com/a/30212526