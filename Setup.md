## Using the already built multi-arch image

**NOTE** As of v0.11.0, riscv64 platform is not supported due to Alpine Linux stable image not supporting it itself. Once they start supporting it, builds will be back for this platform!

### With docker-compose (recommended)

1. Create following file below, remember to add volume either like that or as a persistentvolume, otherwise container will renew certificates on every re-launch which will make Let's Encrypt angry
2. Run docker-compose -f compose.yaml up -d

>[!WARNING]
> You will need to create the following directory caddy-data will bind to, otherwise it will fail with `special device <location> does not exist`

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
      - caddy-logs:/var/log/caddy
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
  caddy-logs:
    driver_opts:
      type: none
      device: /home/youruser/caddy-logs
      o: bind
```

### Manually

1. Pull the image with `docker pull docker.io/mrrubberducky/qor-caddy:latest` or `docker pull ghcr.io/rubberverse/qor-caddy:latest`
2. Run it with `docker run -d -e CADDY_ENVIRONMENT=PROD -e ADAPTER_TYPE=caddyfile -e CONFIG_PATH=/app/configs/Caddyfile mrrubberducky/qor-caddy`, replace mrrubberducky with rubberverse if using GitHub Container Registry image
3. See if it runs with `docker ps -a`

## Building your own customized image

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
