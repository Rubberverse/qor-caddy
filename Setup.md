## Using the already built multi-arch image

- Starting from version v0.16.0+, the container will run rootlessly
- Starting from version v0.17.0+, container will have a dedicated logging directory the rootless user inside can log to

### With Podman 4.4+ (quadlet deployment)

TODO

### With docker-compose (recommended)

1. Create following file below, remember to add volume either like that or as a persistentvolume, otherwise container will renew certificates on every re-launch which will make Let's Encrypt angry
2. Run docker-compose -f compose.yaml up -d and yeah you're set. 

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
      - ${HOME}/qor-caddy/Caddyfile:/app/configs/Caddyfile
      - caddy-appdata:/app/.local/share/caddy
      - caddy-config:/app/.config/caddy
      # [NYI] - caddy-logs:/app/logs
    environment:
      - CADDY_ENVIRONMENT=PROD
      - ADAPTER_TYPE=caddyfile
      - CONFIG_PATH=/app/configs/Caddyfile
    security_opt:
      - net.ipv4.ip_unprivileged_port_start=0
    ports:
      - "80:8080"
      - "443:8443"
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
      o: bind
```

---

#### Building

## Create your own image from the repository

1. Pull this repository with git `git pull Rubberverse/qor-caddy:master`
2. Edit `template.MODULES` to include plugins you want in your final Caddy binary
3. Run the build with following command below, including all build arguments in case you want to customize with your own repository etc. For more info about them, look [here](https://github.com/Rubberverse/qor-caddy/blob/main/BuildArguments.md)
4. Then just run the built image

```bash
docker build -f Dockerfile \
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

## Using Environmental variables in Caddyfile

You can pass any variable you want (ex. Cloudflare API Token for Cloudflare DNS) to the image using either `--e` flag with `docker run` or `environment:` on docker-compose.yaml. Caddy will see them and recognize them as long as they're in `{$brackets}` prefixed by a dollar sign.

This is a example of how you can do it

```caddyfile
# Caddyfile /app/configs/Caddyfile
{
        # Global Caddy configuration
        admin localhost:2019
        http_port 8080
        https_port 8443
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
    # For GitHub Container Registry: image: ghcr.io/rubberverse/qor-caddy:latest
    volumes:
      - ${HOME}/qor-caddy/Caddyfile:/app/configs/Caddyfile
      - caddy-appdata:/app/.local/share/caddy
      - caddy-config:/app/.config/caddy
    environment:
      - CADDY_ENVIRONMENT=PROD
      - ADAPTER_TYPE=caddyfile
      - CONFIG_PATH=/app/configs/Caddyfile
    ports:
      - "80:8080"
      - "443:8443"
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
      o: bind
```

---

#### Extras

### Mapping your own directory with certificates into the container

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

You can also make use of environmental variables in step above just to not have to repeat this everytime.
