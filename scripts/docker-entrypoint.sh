#!/bin/sh

# Colors
cend='\033[0m'
darkorange='\033[38;5;208m'
pink='\033[38;5;197m'
purple='\033[38;5;135m'
green='\033[38;5;41m'
blue='\033[38;5;99m'

isProdOrTest() {
case "$(echo "$CADDY_ENVIRONMENT" | tr '[:upper:]' '[:lower:]')" in
    prod) return 0 ;;
    test) return 1 ;;
    *) return 2 ;;
esac
}

isAdapterTypeValid() {
case "$(echo "ADAPTER_TYPE" | tr '[:upper:]' '[:lower:]')" in
    caddyfile)  return 0 ;;
    json) return 1 ;;
    yaml) return 2 ;;
    *) return 3 ;;
esac
}

if isProdOrTest "$CADDY_ENVIRONMENT" = 0 -z 1; then
    printf "%b" "[✨ " "$purple" "Startup" "$cend" "] ✅ Your environmental variables are valid\n"
else
    printf "%b" "[❌ " "$pink" "Error" "$cend" "] ⛔ Your CADDY_ENVIRONMENT environmental variable is invalid!\n"
    printf "%b" "⚠️ Only " "$green" "valid" "$cend" " types are prod or test (case insensitive)\n"
    printf "😕 Confused? Read our Documentation! https://github.com/qor-caddy/blob/main/SetupTroubleshooting.md \n"
    exit 1
fi

if isAdapterTypeValid "$ADAPTER_TYPE" = 0 -a "$ADAPTER_TYPE" = 1 -a "$ADAPTER_TYPE" = 2; then
    printf "%b" "[✨ " "$purple" "Startup" "$cend" "] ✅ ADAPTER_TYPE is valid!\n"
else
    printf "%b" "[⚠️ " "$darkorange" "Warning" "$cend" "] ❔ Potentially invalid ADAPTER_TYPE value\n"
    printf "💥 THIS CHECK IS CURRENTLY BROKEN!!! TODO: Fix\n"
    printf "😕 Confused? Read our Documentation! https://github.com/qor-caddy/blob/main/SetupTroubleshooting.md \n"
fi

if [ -n "$CONFIG_PATH" ]; then
    printf "%b" "[✨ " "$purple" "Startup" "$cend" "] ✅ CONFIG_PATH appears to be valid\n"
    printf "🙂 If you experience issues, make sure to point it to /apps/config/Caddyfile or similar\n"
    printf "😌 It should be generally fine no matter where you point it as long as you have a volume mapped to that location with your configuration\n"
    printf "😕 Confused? Read our Documentation! https://github.com/qor-caddy/blob/main/SetupTroubleshooting.md \n"
else
    printf "%b" "[❌ " "$pink" "Error" "$cend" "] ⛔ Your CONFIG_PATH is empty! It is required to launch the container successfully! 🙈\n"
    printf "➡️ Please fix it and relaunch the container\n"
    printf "😕 Confused? Read our Documentation! https://github.com/qor-caddy/blob/main/SetupTroubleshooting.md \n"
    exit 2
fi

printf "%b" "$darkorange" " ______        _     _                                             \n(_____ \      | |   | |                                            \n _____) )_   _| |__ | |__  _____  ____ _   _ _____  ____ ___ _____ \n|  __  /| | | |  _ \|  _ \| ___ |/ ___) | | | ___ |/ ___)___) ___ |\n| |  \ \| |_| | |_) ) |_) ) ____| |    \ V /| ____| |  |___ | ____|\n|_|   |_|____/|____/|____/|_____)_|     \_/ |_____)_|  (___/|_____)\n" "$cend";
printf "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-\n"
printf "%b" "🗒️ " "$blue" "Setup Guide " "$cend" "- https://github.com/rubberverse/qor-caddy/Setup.md \n"
printf "%b" "📁 " "$green" "Repository " "$cend" "- https://github.com/rubberverse/qor-caddy \n"
printf "🦆 No more bash!\n"

printf "ℹ️ If your container stops abruptly after pre-launch, please make sure you have skip_install_trust in your Caddyfile\n"
printf "Without it, Caddy will attempt to install certificates to root store which might either crash the container or just spam the log with attempts\n"

if isProdOrTest "$CADDY_ENVIRONMENT" = 0; then 
    printf "%b" "[✨" " $green" "Pre-Launch" "$cend" "] Launching Caddy - The Ultimate Server with Automatic HTTPS\n"
    printf "ℹ️ You're launching in LOCAL/PROD environment. Config won't be dynamically reloaded!\n"
    exec /app/caddy run --config "${CONFIG_PATH}" --adapter "${ADAPTER_TYPE}"
elif isProdOrTest "$CADDY_ENVIRONMENT" = 1; then
    printf "%b" "[✨" " $green" "Pre-Launch" "$cend" "] Launching Caddy - The Ultimate Server with Automatic HTTPS\n"
    printf "ℹ️ You're launching in TEST environment. Config will be dynamically reloaded!\n"
    /app/caddy start --config "${CONFIG_PATH}" --adapter "${ADAPTER_TYPE}" --watch
    exec tail -f /dev/null
else
    printf "%b" "[❌ " "$pink" "Error" "$cend" "] ⛔ Image failed to launch\n"
    printf "➡️ This is usually caused by a broken shell script or image\n"
    printf "➡️ Please create a GitHub Issue so I can look into it!\n"
    exit 2
fi