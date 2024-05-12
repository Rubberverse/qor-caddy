#!/bin/sh

# Colors
cend='\033[0m'
darkorange='\033[38;5;208m'
pink='\033[38;5;197m'
purple='\033[38;5;135m'
green='\033[38;5;41m'
blue='\033[38;5;99m'

printf "%b" "[entrypoint] Entrypoint script is launched\n[entrypoint] You're running as $(whoami)\n[entrypoint] Listing directory ownership\n"
ls -ld /app
printf "\n[entrypoint] Continuing...\n"

case "$(echo "$CADDY_ENVIRONMENT" | tr '[:upper:]' '[:lower:]')" in
    prod) export VAR_ENV=1 ;;
    test) export VAR_ENV=2 ;;
    *) export VAR_ENV=ERR ;;
esac

case "$(echo "$ADAPTER_TYPE" | tr '[:upper:]' '[:lower:]')" in
    caddyfile) export VAR_ADAPTER=1 ;;
    json) export VAR_ADAPTER=2 ;;
    yaml) export VAR_ADAPTER=3 ;;
    *) export VAR_ADAPTER=ERR ;;
esac

if test "$VAR_ENV" != ERR; then
    printf "%b" "[✨ " "$purple" "entrypoint - Pass" "$cend" "] ✅ CADDY_ENVIRONMENT is valid!\n"
else
    printf "%b" "[⚠️ " "$darkorange" "entrypoint - Warning" "$cend" "] Invalid value or blank environment for CADDY_ENVIRONMENT\n"
    printf "%b" "[⚠️ " "$darkorange" "entrypoint - Warning" "$cend" "] Container will fallback to Production launch\n"
fi

if test "$VAR_ADAPTER" != ERR; then
    printf "%b" "[✨ " "$purple" "entrypoint - Pass" "$cend" "] ✅ ADAPTER_TYPE is valid!\n"
else
    printf "%b" "[⚠️ " "$darkorange" "entrypoint - Warning" "$cend" "] Potentially invalid ADAPTER_TYPE value\n"
    printf "%b" "[⚠️ " "$darkorange" "entrypoint - Warning" "$cend" "] Container might die on launch if no correct adapter is present for the specified type\n"
    printf "%b" "[⚠️ " "$darkorange" "entrypoint - Warning" "$cend" "] This can be safely ignored if using self-built qor-caddy\n"
fi

if [ -n "$CONFIG_PATH" ] && [ -f "$CONFIG_PATH" ]; then
    printf "%b" "[✨ " "$purple" "entrypoint - Pass" "$cend" "] ✅ CONFIG_PATH is valid!\n"
else
    printf "%b" "[❌ " "$pink" "entrypoint - Error" "$cend" "] No file or path was found in CONFIG_PATH environment variable\n"
    printf "%b" "[❌ " "$pink" "entrypoint - Error" "$cend" "] This image doesn't ship with default configuration\n"
    printf "%b" "[❌ " "$pink" "entrypoint - Error" "$cend" "] Users are expected to mount their own configuration and point CONFIG_PATH environmental variable to it's location\n"
    exit 1
fi

printf "%b" "$darkorange" " ______        _     _                                             \n(_____ \      | |   | |                                            \n _____) )_   _| |__ | |__  _____  ____ _   _ _____  ____ ___ _____ \n|  __  /| | | |  _ \|  _ \| ___ |/ ___) | | | ___ |/ ___)___) ___ |\n| |  \ \| |_| | |_) ) |_) ) ____| |    \ V /| ____| |  |___ | ____|\n|_|   |_|____/|____/|____/|_____)_|     \_/ |_____)_|  (___/|_____)\n" "$cend";
printf "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-\n"
printf "%b" "🗒️ " "$blue" "Setup Guide " "$cend" "- https://github.com/rubberverse/qor-caddy/Setup.md \n"
printf "%b" "📁 " "$green" "GitHub Repository " "$cend" "- https://github.com/rubberverse/qor-caddy \n"
printf "🦆 Third's time the charm\n"

printf "%b" "[⚠️ " "$darkorange" "entrypoint - Warning" "$cend" "] If your container stops abruptly with self-hosted certificates, make sure to put skip_install_trust in your Caddyfile\n"
printf "%b" "[⚠️ " "$darkorange" "entrypoint - Warning" "$cend" "] Without it, Caddy will attempt to install self-signed certificates to root trust store resulting in unexpected things happening\n"

printf "%b" "[✨ " "$purple" "entrypoint - Info" "$cend" "] You can always reload the Caddy configuration in real time by running podman exec -t containerName /app/bin/caddy reload -c <path to config>\n"
printf "%b" "[✨ " "$purple" "entrypoint - Info" "$cend" "] It is recommended to enable local admin endpoint, otherwise you won't be able to execute commands such as above.\n"

if [ "$VAR_ENV" = 1 ] || [ "$VAR_ENV" = 0 ]; then
    printf "%b" "[✨" " $green" "entrypoint" "$cend" "] Starting Caddy\n"
    printf "%b" "[✨" " $green" "entrypoint" "$cend" "] You're launching in Production environment, Caddy will not listen for config changes\n\n"
    exec /app/bin/caddy run --config "${CONFIG_PATH}" --adapter "${ADAPTER_TYPE}" "${EXTRA_ARGUMENTS}"
elif test "$VAR_ENV" = 2; then
    printf "%b" "[✨" " $green" "entrypoint" "$cend" "] Starting Caddy\n"
    printf "%b" "[✨" " $green" "entrypoint" "$cend" "] You're launching in Testing environment, Caddy will listen for config changes\n\n"
    /app/bin/caddy start --config "${CONFIG_PATH}" --adapter "${ADAPTER_TYPE}" --watch "${EXTRA_ARGUMENTS}"
    exec tail -f /dev/null
fi