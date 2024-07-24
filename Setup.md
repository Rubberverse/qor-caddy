# 😺 Setup guide

In here you can learn how to effortlessly use our image in your infrastructure or your project, whatever really. In case something is not clear then let me know but this should be a fully working guide to making it just work.

Below in warning box, you will see every major change that may result in breakage or configuration options being different being listed. These are here for your own information and might help you with understanding when the problem might've started!

>[!WARNING]
> Major changes occured during those versions, you might have to modify your current Caddyfiles or environmental variables in order to accomodate for them

- v0.12 and above: Test multi-architecture builds using Go Cross-Compilation and building out the base images with `qemu-server`
- v0.15.0 and above: Container will now run rootlessly, expect some breakage or some functions not working as intended (so far seems to be fine though)
- v0.18.1 and above: Reduction in included modules, only cherry picked modules are staying in order to reduce bloat and potential security issues due to dependencies/or module itself
- v0.19.1 and above: `ADAPTER_TYPE` environmental variable was dropped. If you still need the functionality, look into passing a parameter with `EXTRA_ARGUMENTS` instead

## 🦕 Quadlet (experimental, recommended)

>[!NOTE]
> This requires Podman version 5.1.0+

This setup is for rootless quadlet deployment, it is currently used in production by me and works great. Plus, you gain advantage of having automatic updates with Podman! (just make sure to turn on the timer)


If you're installing it from nix package manager, make sure to move systemd files from nix users' directory to respective system directiories `/lib/systemd/system-generators`, `/lib/systemd/system`, `/lib/systemd/user-generators`, `/lib/systemd/user` then reload your daemon for **both rootful and rootless** - `sudo systemctl daemon-reload` and `systemctl --user daemon-reload`. Only then you will have a working Quadlet generator.

1. Create following directiories in your `${HOME}` directory - `mkdir -p AppData\qor-caddy\data AppData\qor-caddy\config`
2. If you haven't done it yet, create following directiories inside `~/.config` - `mkdir -p containers/systemd/qor-caddy`
3. Change your directory to `~/.config/containers/systemd/qor-caddy`
4. Create a new blank file called `qor-caddy.container` then edit it with `nano qor-caddy.container`. Replace `your_user` with the name of your rootless user.
5. Save and exit it, reload systemd daemon with `systemctl --user daemon-reload`
6. Start the service with `systemctl --user start qor-caddy.service`

```.service
[Container]
Image=docker.io/mrrubberducky/qor-caddy:latest-alpine
ContainerName=qor-caddy
Volume=/home/your_user/AppData/qor-caddy/Caddyfile:/app/configs/Caddyfile:ro
# It will look cleaner if you do .volume instead of Mounts
Mount=type=bind,source=/home/your_user/AppData/qor-caddy/data,destination=/app/.local/share/caddy,U=true
Mount=type=bind,source=/home/your_user/AppData/qor-caddy/config,destination=/app/.config/caddy,U=true
Environment=CONFIG_PATH=/app/configs
Environment=CADDY_ENVIRONMENT=prod
# DNS challenge fails with pasta, rootlessport (?)
Network=host
NoNewPrivileges=true
AutoUpdate=registry
```

## 🐳 With docker-compose (recommended)

>[!NOTE]
> 1. You will need to create the following directory caddy-appdata will bind to, otherwise it will fail with `special device <location> does not exist`
> 2. You will need to allow your rootless user on your host to map below 1000, either by editing sysctl or redirecting port 80 to 8080
> 3. For container user privileged port binding, a sysctl addition is required (via compose)

1. Create following docker-compose.yaml below

```yaml
version: "3.8"
services:
  qor-caddy:
    # For GitHub Container Registry: image: ghcr.io/rubberverse/qor-caddy:latest-alpine
    image: docker.io/mrrubberducky/qor-caddy:latest
    volumes:
    # Directories container can write to:
    # /srv, /srv/www, /app, /app/logs, /app/.config, /app/.local
      - ${HOME}/qor-caddy/Caddyfile:/app/configs/Caddyfile
      - caddy-appdata:/app/.local/share/caddy
      - caddy-config:/app/.config/caddy
      - caddy-logs:/app/logs
    environment:
      # Available types: prod, test. Prod doesn't make use of automatic config reload, test does. It is generally not recommended to have dynamic config reload in production, as said by Caddy wiki.
      - CADDY_ENVIRONMENT=PROD
      # Any valid path inside of the container. Map a volume with the config file to this location
      - CONFIG_PATH=/app/configs/Caddyfile
    # Required if you want to bind ports below privileged port range (1000 by default) with rootless container user
    #sysctls:
    #  - net.ipv4.ip_unprivileged_port_start=80
    # Recommended for crowdsec-caddy so you get proper ip resolving, also possible to accomplish it with pasta but it makes it more annoying to setup
    # network_mode: "host"
    ports:
      - "80:80"
      - "443:443"
    # If using host networking, remove this
    networks:
      - qor-caddy

# If using host networking, remove this
networks:
  qor-caddy:

# Certificate and config persistence
# Remember to create those configs before hand otherwise you'll run into issues while trying to deploy
volumes:
  caddy-config:
   driver_opts:
      type: none
      device: /home/youruser/AppData/qor-caddy/config
      o: bind,rw
  caddy-appdata:
    driver_opts:
      type: none
      device: /home/youruser/AppData/qor-caddy/data
      o: bind,rw
  # It is recommended to use a log parser like Crowdsec for security
  caddy-logs:
```

2. Run `docker-compose -f docker-compose.yaml up -d` afterwards and it should be ready


## ✍️ Manually, without docker-compose

1. Pull the image - `podman pull docker.io/mrrubberducky/qor-caddy:latest-alpine`
2. Create volumes for storing certs and logs
3. Run the image

```bash
# You can specify any location you want, as long as you chown it so container user can write to it
podman volume create \
  --driver local \
  --opt type=none \
  --opt device=/home/youruser/AppData/qor-caddy/data \
  --opt o=bind,rw \
qor-caddy-appdata

podman volume create \
  --driver local \
  --opt type=ext4 \
  --opt device=/home/youruser/AppData/qor-caddy/config \
  --opt o=bind,rw \
qor-caddy-config
```

```bash
podman run \
  --detach \
  --env CADDY_ENVIRONMENT=PROD \
  --env CONFIG_PATH=/app/configs/Caddyfile \
  --volume /home/ducky/qor-caddy/configs/Caddyfile:/app/configs/Caddyfile \
  --volume qor-caddy-appdata:/app/.local/share/caddy \
  --volume qor-caddy-config:/app/.config/caddy \
  --publish 80:80 \
  --publish 443:443 \
  --sysctls net.ipv4.ip_unprivileged_port_start=80 \
docker.io/mrrubberducky/qor-caddy:latest-alpine
```

## From source

Will be rewritten soon, need to make a clean Dockerfile for manual building. There was one before but now it's considered legacy so no support for it from my side, however you can still use that one if you want. It will be a tad dated though.

## 📨 Using Environmental variables in Caddyfile

You can pass any variable you want (ex. Cloudflare API Token for Cloudflare DNS) to the image using either `--e` flag with `docker run` or `environment:` on docker-compose.yaml. Caddy will see them and recognize them as long as they're in `{$brackets}` prefixed by a dollar sign.

>[!NOTE]
> Environmental variables are unsupported for `JSON` format

This is a example of how you can do it

```caddyfile
# Caddyfile /app/configs/Caddyfile
{
        # Global Caddy configuration
        admin localhost:2019
        http_port 80
        https_port 443
}

dashboard.my-domain.com {
        tls {
                dns cloudflare {$CF_API_TOKEN}
        }
        reverse_proxy homepage:3000
}
```

```yaml
version: "3.8"
services:
  qor-caddy:
    image: docker.io/mrrubberducky/qor-caddy:latest
    user: 1001:1001
    # For GitHub Container Registry: image: ghcr.io/rubberverse/qor-caddy:latest
    volumes:
    # Directories container can write to:
    # /srv, /srv/www, /app, /app/logs, /app/.config, /app/.local
      - ${HOME}/qor-caddy/Caddyfile:/app/configs/Caddyfile
      - caddy-appdata:/app/.local/share/caddy
      - caddy-config:/app/.config/caddy
      - caddy-logs:/app/logs
    environment:
      - CF_API_TOKEN=blabla
      - CADDY_ENVIRONMENT=PROD
      - ADAPTER_TYPE=caddyfile
      - CONFIG_PATH=/app/configs/Caddyfile
    # Only needed on Alpine variant if you plan to have the container bind to ports below 1000
    # sysctls:
    #   - net.ipv4.ip_unprivileged_port_start=80
    ports:
      - "80:80"
      - "443:443"
    networks:
      - qor-caddy

networks:
  qor-caddy:

# Certificate and config persistence
volumes:
  caddy-config:
  caddy-appdata:
    driver_opts:
      type: none
      device: /home/youruser/caddy-data
      o: bind,rw
  caddy-logs:
```

## 🗺️ Mapping your own directory with certificates into the container

Let's say you have a ACME client running on your OPNsense or locally in your organization and your web server device gets certificates from it

1. Add it as a volume to the container
2. Run container and reference it in Caddyfile like so, do **not** add a whole certificates folder as a volume bind as it will cause issues for the container itself and certificate grabbing

```yaml
(...)
volumes:
- ${HOME}/certificates/yourdomain.tld:/app/certificates/sub.domain.tld
```

```caddyfile
mydomain.tld {
  tls /app/certificates/fullchain.pem /app/certificates/key.pem
  reverse_proxy my_service:3000
}
```

ℹ️ You can also make use of environmental variables in step above just to not have to repeat this everytime. 

⚠️ It might be worthwhile to look into alternative secure way to pull this off.
