#!/bin/bash
echo "Verifying what user is running the image"

if [[ $(whoami) != "root" ]];
    then
        source /app/.bashrc
        echo "You're running this image as $(whoami):$UID that's apart of group $GID"
        echo "This is a internal user that about doesn't have access to much by default"
        echo ""
    else
        echo "[WARNING] It is not recommended to run Web Server software as root, even inside a container"
        echo "You can discard this message if you're on a TESTING Environment"
        source /app/.bashrc
        echo ""
        echo "You're running this image as $(whoami)"
        echo "In order to run as $USER, you will need to re-deploy the container with LOCAL or PROD Environment"
        echo ""
fi

echo "=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+="
echo "  ________  ________  ________         "
echo " |\   __  \|\   __  \|\   __  \        "
echo " \ \  \|\  \ \  \|\  \ \  \|\  \       "
echo "  \ \  \\\  \ \  \\\  \ \   _  _\      "
echo "   \ \  \\\  \ \  \\\  \ \  \\  \|     "
echo "    \ \_____  \ \_______\ \__\\ _\     "
echo "     \|___| \__\|_______|\|__|\|__|    "
echo "           \|__|                       "
echo "                                       "
echo "                  by Mr. Rubber Ducky  "
echo "=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+="
echo "USER: $(whoami):$GROUP, UID and GUID: $UID:$GID"
echo ""
echo "Documentation - https://github.com/MrRubberDucky/rubberverse-dockerfiles/Caddy/README.md"
echo "Cursed & Overkill Solutions, at your doorstep!"
echo "Built from caddy:${CADDY_VERSION}-alpine"

echo ""

# I wonder if there's a better way to do this. Works though so not that big of a issue.
if [[ $CADDY_ENVIRONMENT = "TEST" ]]
    then
        echo "Environment is set to Testing/Development, starting in background and actively listening to config changes"
        echo "Docker interactive session is supported. Map a volume to /var/www/site to publish a site instantly on specified host and port"
        /app/caddy run --config /app/configs/Caddyfile --adapter caddyfile --watch
elif [[ $CADDY_ENVIRONMENT = "LOCAL" ]]
    then
        echo "Environment is set to Local/Localhost, starting in daemon mode"
        echo "Docker interactive session is not supported. Map a volume to /srv or different Caddyfile to /app/configs and restart container"
        /app/caddy run --config /app/configs/Caddyfile --adapter caddyfile
elif [[ $CADDY_ENVIRONMENT = "PROD" ]]
    then
        echo "Environment is set to Production/Live, starting in daemon mode"
        echo "Docker interactive session is not supported. Map a volume to /srv or different Caddyfile to /app/configs and restart container"
        /app/caddy run --config /app/configs/Caddyfile --adapter caddyfile
else
    echo "If you're seeing this, your CADDY_ENVIRONMENT variable is invalid"
    echo "In order to launch this container, you need to assign it a valid value between TEST, LOCAL and PROD"
    echo "Current value of CADDY_ENVIRONMENT -> ${CADDY_ENVIRONEMNT}, expected: TEST, LOCAL or PROD"
    exit -1
fi
