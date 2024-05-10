## 😺 Using the already built multi-arch image

[⚠️] Starting from version v0.15.0, the container will run rootlessly (breakage may happen, report issues here in case something doesn't work!)

### 🐳 With docker-compose (recommended)

1. Create following docker-compose.yaml below

>[!WARNING]
> 1. You will need to create the following directory caddy-appdata will bind to, otherwise it will fail with `special device <location> does not exist`
> 2. You will need to allow your rootless user on your host to map below 1000, either by editing sysctl or redirecting port 80 to 8080
> 3. For container privileged port binding, a sysctl addition is required

```yaml
version: "3.8"
services:
  qor-caddy:
    image: docker.io/mrrubberducky/qor-caddy:latest
    user: 1001:1001
    # For GitHub Container Registry: image: ghcr.io/rubberverse/qor-caddy:latest-alpine
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
    sysctls:
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

---

### ✍️ Manually, without docker-compose

1. Pull the image - `podman pull docker.io/mrrubberducky/qor-caddy:latest-alpine`
2. Create volumes for storing certs and logs
3. Run the image

```bash
# You can specify any location you want, as long as you chown it so container user can write to it
podman volume create \
  --driver local \
  --opt type=none \
  --opt device=/home/youruser/qor-caddy/appdata \
  --opt o=bind,rw \
qor-caddy-appdata

podman volume create \
  --driver local \
  --opt type=ext4 \
  --opt device=/home/youruser/qor-caddy/logs \
  --opt o=bind,rw \
qor-caddy-logs
```

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
  --sysctls net.ipv4.ip_unprivileged_port_start=80
docker.io/mrrubberducky/qor-caddy:latest-alpine
```

---

### From source

1. Clone this repository `git clone https://github.com/Rubberverse/qor-caddy.git`
2. Navigate to caddy-dfs-sarch
3. Copy ../scripts to caddy-dfs-sarch `cp -r ../scripts .`
4. Check out available build arguments by reading `BuildArguments.md` either here or locally
5. Build the image out with `podman build -f Dockerfile-Alpine`, make sure to add Build Arguments you want to use at the end of that command
6. Run the image with `podman run -e CADDY_ENVIRONMENT=PROD -e CONFIG_PATH=/app/configs/Caddyfile -e ADAPTER_TYPE=caddyfile -d <id> -v ./Caddyfile:/app/configs/Caddyfile:ro`

---

#### 🐈 Extras

### 📨 Using Environmental variables in Caddyfile

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

---

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
