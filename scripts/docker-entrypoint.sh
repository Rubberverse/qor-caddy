#!/bin/bash
source /app/.bashrc

case ${CADDY_ENVIRONMENT} in
    TEST|LOCAL|PROD) echo "Your CADDY_ENVIRONMENT is VALID" ;;
    *) echo "Your CADDY_ENVIRONMENT is INVALID, please fix it and relaunch the container!" \
        && exit -3 ;;
esac

if [[ $(whoami) == root && $CADDY_ENVIRONMENT != "TEST" ]]
    then
        echo "==============================================================================="
        echo "Init - Starting Caddy as root then instantly stopping it to grab certificates  "
        echo "==============================================================================="
        /app/caddy start --config /app/configs/Caddyfile --adapter caddyfile \
            && echo "Ordering Caddy to install certificates into root store..." \
            && /app/caddy trust
        
        echo "Stopping caddy..."
        /app/caddy stop
        
        EXITCODE=$?

        if [[ $EXITCODE = 0 ]]
            then
                echo "Caddy exited properly! Fixing up folder permissions..."
                chown -R ${CONT_USER}:${CONT_GROUP} /app
            else
                echo "Caddy failed to stop properly (exit_code didn't match 0)"
            exit -5
        fi

        echo "==============================================================================="
        echo "Init - Switching users                                                         "
        echo "==============================================================================="
        echo "DEBUG: Variable Dump"
        cat /app/.bashrc
        echo ""
        su -s /bin/bash -c /app/scripts/docker-entrypoint.sh ${CONT_USER}
        exit 99 || true
    else
        echo "Your CADDY_ENVIRONMENT is ${CADDY_ENVIRONMENT}, skipping Init."
fi

echo "=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+";
echo " ________   ________   ________     ";
echo "|\   __  \ |\   __  \ |\   __  \    ";
echo "\ \  \|\  \\ \  \|\  \\ \  \|\  \   ";
echo " \ \  \\\  \\ \  \\\  \\ \   _  _\  ";
echo "  \ \  \\\  \\ \  \\\  \\ \  \\  \| ";
echo "   \ \_____  \\ \_______\\ \__\\ _\ ";
echo "    \|___| \__\\|_______| \|__|\|__|";
echo "          \|__|                     ";
echo "                                    ";
echo "                                    ";
echo "                    by MrRubberDucky";
echo "=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+";
echo "USER: $(whoami), GROUP: ${CONT_GROUP} | UID: ${CONT_UID}, GID ${CONT_GID}"
echo ""
echo "Documentation - https://github.com/Rubberverse/qor-caddy/README.md"
echo "Cursed & Overkill Solutions, at your doorstep!"
echo "Built from alpine:${ALPINE_VERSION}, Build ${BUILD_VERSION}"
echo ""


if [[ $CADDY_ENVIRONMENT != "TEST" && $(whoami) != "root" ]]
    then
        echo "Launching Caddy, your current Environment reflects in-prod/prod setup   "
        echo "Config watching is disabled for local/prod builds                       "
        /app/caddy run --config /app/configs/Caddyfile --adapter ${ADAPTER_TYPE}
    else
        echo "Caddy is launching in TESTING Environment.                              "
        echo "Config watching is enabled for debug/testing builds                     "
        /app/caddy run --config /app/configs/Caddyfile --adapter ${ADAPTER_TYPE} --watch
fi
