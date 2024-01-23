## Using the already built multi-arch image

**NOTE** As of v0.11.0, riscv64 platform is not supported due to Alpine Linux stable image not supporting it itself. Once they start supporting it, builds will be back for this platform!

### With docker-compose

1. Create following file below
2. Run docker-compose -f compose.yaml up -d

```yaml
version: "3.8"
services:
  qor-caddy:
    image: docker.io/mrrubberducky/qor-caddy:latest
    # For GitHub Container Registry: image: ghcr.io/rubberverse/qor-caddy:latest
  volumes:
    - ${HOME}/qor-caddy/Caddyfile:/app/configs/Caddyfile
  environment:
    - CADDY_ENVIRONMENT=PROD
    - ADAPTER_TYPE=caddyfile
    - CONFIG_PATH=/app/configs/Caddyfile
  ports:
    - "80:8080"
    - "443:8443"
  networks:
    - qor-caddy

network:
  qor-caddy:
```

### Manually

1. Pull the image with `docker pull docker.io/mrrubberducky/qor-caddy:latest` or `docker pull ghcr.io/rubberverse/qor-caddy:latest`
2. Run it with `docker run -d -e CADDY_ENVIRONMENT=PROD -e ADAPTER_TYPE=caddyfile -e CONFIG_PATH=/app/configs/Caddyfile mrrubberducky/qor-caddy`, replace mrrubberducky with rubberverse if using GitHub Container Registry image
3. See if it runs with `docker ps -a`

## Building your own customized image

1. Pull this repository with git `git pull Rubberverse/qor-caddy:master`
2. Edit `template.MODULES` to include plugins you want in your final Caddy binary
3. Run the build with following command below, including all build arguments in case you want to customize with your own repository etc. For more info about them, look [here](https://github.com/Rubberverse/qor-caddy/blob/main/BuildArgs.md)
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
