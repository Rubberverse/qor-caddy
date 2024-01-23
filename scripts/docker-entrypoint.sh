#!/bin/bash
source /app/.bashrc

# Colors
NO_FORMAT="\033[0m"
C_DARKORANGE="\033[38;5;208m"
C_DEEPPINK2="\033[38;5;197m"
C_MEDIUMPURPLE2="\033[38;5;135m"
C_SPRINGGREEN3="\033[38;5;41m"
C_SLATEBLUE1="\033[38;5;99m"


function isGracefulExit() {
    if [[ $EXITCODE = 0 ]]; then
        echo "Caddy successfully stopped"
        echo "Fixing up permissions"
        chown -R ${CONT_USER}:${CONT_GROUP} /app
    else
        echo "Caddy forcefully stopped with exit code ${EXITCODE}"
        exit -5
        fi
}

function isEnvironmentValid() {
    if ! [[ $CADDY_ENVIRONMENT =~ %(TEST|PROD|test|prod)$ && $ADAPTER_TYPE =~ %(caddyfile|json|yaml)$ ]]; then
        echo -e "[✨ ${C_MEDIUMPURPLE2}Startup${NO_FORMAT}] ✅ Your environmental variables are valid"
    else
        echo -e "[❌ ${C_DEEEPINK2}Error${NO_FORMAT}] One or both of the environmental variables has failed the check"
        echo "CADDY_ENVIRONMENT: ${CADDY_ENVIRONMENT}, ADAPTER_TYPE: ${ADAPTER_TYPE}"
        echo "Valid values for CADDY_ENVIRONMENT: TEST, PROD"
        echo "Valid values for ADAPTER_TYPE: caddyfile, json, yaml"
        echo -e "${C_DEEPPINK2}This doesn't check for CONFIG_PATH variable!"
        exit -1
    fi
}

function environmentPreLaunch() {
    if [[ $CADDY_ENVIRONMENT != "TEST" && $(whoami) != "root" ]]; then
        echo -e "[✨ ${C_SPRINGGREEN3}Pre-Launch${NO_FORMAT}] Starting Caddy, your current Environment reflects in-prod/prod setup"
        echo "Caddy won't watch over the config and won't run in background in this mode"
        /app/caddy run --config ${CONFIG_PATH} --adapter ${ADAPTER_TYPE}
    elif [[ $CADDY_ENVIRONMENT == "TEST" && $(whoami) == "root" ]]; then
        echo "Starting Caddy, your current Environment reflects in-dev/testing setup"
        echo "Caddy will watch over the config and will start in the background"
        echo "It is recommended to make use of the interactive session"
        /app/caddy start --config ${CONFIG_PATH} --adapter ${ADAPTER_TYPE}
        tail -f /dev/null
    else
        echo "Image error, tell maintainer to fix this"
        exit -127
    fi
}

echo -e "[✨ ${C_MEDIUMPURPLE2}Startup${NO_FORMAT}] Checking validity of environmental variables"
isEnvironmentValid

echo -e "[✨ ${C_MEDIUMPURPLE2}Startup${NO_FORMAT}] Proceeding with initialization"

if [[ $(whoami) == "root" && $CADDY_ENVIRONMENT != "TEST" ]]; then
    echo -e "[✨ ${C_MEDIUMPURPLE2}Init 1/3${NO_FORMAT}] Starting Caddy to generate certificates  "
    /app/caddy start --config /app/configs/Caddyfile --adapter caddyfile        \
        && echo "Ordering Caddy to install certificates into root store..."     \
        && /app/caddy trust
        
    echo -e "[✨ ${C_MEDIUMPURPLE2}Init 2/3${NO_FORMAT}] Stopping Caddy..."
    /app/caddy stop
        
    EXITCODE=$?
    isGracefulExit

    echo -e "[✨ ${C_MEDIUMPURPLE2}Init 3/3${NO_FORMAT}] Switching user and exiting script for root user"
    su -s /bin/bash -c /app/scripts/docker-entrypoint.sh ${CONT_USER}
    exit 99 || true
else
    echo -e "[✨ ${C_SPRINGGREEN3}Pre-Launch${NO_FORMAT}] User changed or different environment: ${CADDY_ENVIRONMENT}, skipping initialization"
fi

echo -e "${C_DARKORANGE}"
echo -e "______        _     _                                              ";
echo -e "(_____ \      | |   | |                                            ";
echo -e " _____) )_   _| |__ | |__  _____  ____ _   _ _____  ____ ___ _____ ";
echo -e "|  __  /| | | |  _ \|  _ \| ___ |/ ___) | | | ___ |/ ___)___) ___ |";
echo -e "| |  \ \| |_| | |_) ) |_) ) ____| |    \ V /| ____| |  |___ | ____|";
echo -e "|_|   |_|____/|____/|____/|_____)_|     \_/ |_____)_|  (___/|_____)";
echo -e "${NO_FORMAT}";
echo "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
echo -e "[✨ ${C_SLATEBLUE1}Debug${NO_FORMAT}] Environmental variables for debugging listed below"
echo "USER: $(whoami), GROUP: ${CONT_GROUP} | UID: ${CONT_UID}, GID ${CONT_GID} | BASE IMAGE: ${IMAGE_ALPINE_VERSION}"
echo "🗒️ Documentation - https://github.com/Rubberverse/qor-caddy/README.md"
echo "Now actually a bit more reliable..."
echo ""
environmentPreLaunch
