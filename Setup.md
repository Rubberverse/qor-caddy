## 😺 Using the already built multi-arch image

- ⚠️ Starting from version v0.16.0+, the container will run rootlessly (breakage may insure, report issues here!)

### 🦕 With Podman 4.4+ (quadlet rootless deployment)

TODO

### 🐳 With docker-compose (recommended)

1. Create following docker-compose.yaml below

>[!WARNING]
> You will need to create the following directory caddy-data will bind to, otherwise it will fail with `special device <location> does not exist`

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
      - CADDY_ENVIRONMENT=PROD
      - ADAPTER_TYPE=caddyfile
      - CONFIG_PATH=/app/configs/Caddyfile
    # It is required to have this so rootless user can bind to ports below 1000 and solve cert challenges
    security_opt:
      - net.ipv4.ip_unprivileged_port_start=80
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
  # It is recommended to use a log parser like Crowdsec for security
  caddy-logs:
```

2. Run `docker-compose -f docker-compose.yaml up -d` afterwards and it should be ready

### ✍️ Manually (not really recommended but you do you)

1. Pull the image

`podman pull docker.io/mrrubberducky/qor-caddy:latest`

2. Create volumes for storing certs and logs

```bash
podman volume create \
  --driver local \
  --opt type=none \
  --opt device=/home/ducky/qor-caddy/appdata \
  --opt o=bind,rw \
qor-caddy-appdata

podman volume create \
  --driver local \
  --opt type=ext4 \
  --opt device=/home/ducky/qor-caddy/logs \
  --opt o=bind,rw \
qor-caddy-logs
```

3. Run the image

```bash
podman run \
  --detach \
  --env CADDY_ENVIRONMENT=PROD \
  --env ADAPTER_TYPE=caddyfile \
  --env CONFIG_PATH=/app/configs/Caddyfile \
  --volume /home/ducky/qor-caddy/configs/Caddyfile:/app/configs/Caddyfile \
  --volume qor-caddy-appdata:/app/.local/share/caddy \
  --volume qor-caddy-logs:/app/logs \
  --publish 8080:80 \
  --publish 4443:443 \
  --sysctl net.ipv4.ip_unprivileged_port_start=80 \
docker.io/mrrubberducky/qor-caddy:latest
```
---

#### 🛠️ Building

## 😎 Create your own image from the repository

1. Pull this repository with git `git pull Rubberverse/qor-caddy:master`
2. Edit `template.MODULES` to include plugins you want in your final Caddy binary

```ini
# DIR: qor-caddy/templates/template.MODULES
github.com/caddy-dns/cloudflare
github.com/caddy-dns/route53
```

3. Run the build with following command below, including all build arguments in case you want to customize with your own repository etc. For more info about them, look [here](https://github.com/Rubberverse/qor-caddy/blob/main/BuildArguments.md)

```bash
podman build -f Dockerfile \
  --build-arg IMAGE_REPOSITORY=docker.io/library \
  --build-arg IMAGE_ALPINE_VERSION=latest \
  --build-arg ALPINE_REPO_URL=https://dl-cdn.alpinelinux.org/alpine \
  --build-arg ALPINE_REPO_VERSION=v3.19 \
  --build-arg GO_XCADDY_VERSION=latest \
  --build-arg GO_CADDY_VERSION=latest \
  --build-arg CONT_SHELL=/bin/bash \
  --build-arg CONT_HOME=/app \
  --build-arg CONT_USER=caddy \
  --build-arg CONT_GROUP=web \
  --build-arg CONT_UID=1001 \
  --build-arg CONT_GID=1001
```

4. Then just run the built image either via docker-compose, quadlet or with `podman run`

---

#### 🐈 Extras

## 📨 Using Environmental variables in Caddyfile

You can pass any variable you want (ex. Cloudflare API Token for Cloudflare DNS) to the image using either `--e` flag with `docker run` or `environment:` on docker-compose.yaml. Caddy will see them and recognize them as long as they're in `{$brackets}` prefixed by a dollar sign.

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
    # It is required to have this so rootless user can bind to ports below 1000 and solve cert challenges
    security_opt:
      - net.ipv4.ip_unprivileged_port_start=80
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

### 🗺️ Mapping your own directory with certificates into the container

Let's say you have a ACME client running on your OPNsense or locally in your organization and your web server device gets certificates from it

1. Add it as a volume to the container
2. Run container and reference it in Caddyfile like so

```yaml
(...)
volumes:
- ${HOME}/certificates/yourdomain.tld:/app/certificates
```

```caddyfile
mydomain.tld {
  tls /app/certificates/fullchain.pem /app/certificates/key.pem
  reverse_proxy my_service:3000
}
```

ℹ️ You can also make use of environmental variables in step above just to not have to repeat this everytime. 

⚠️ It might be worthwhile to look into alternative secure way to pull this off.
