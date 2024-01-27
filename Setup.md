## 😺 Using the already built multi-arch image

- ⚠️ Starting from version v0.16.0+, the container will run rootlessly (breakage may happen, report issues here in case something doesn't work!)

### 🦕 With Podman 4.4+ (quadlet rootless deployment)

1. Make sure you have Podman 4.4+ as 4.3- don't have Quadlet support, you can check by typing `podman version`
2. If you're on Debian, you can get up-to-date Podman in a following manner (please keep in mind that this is potentially dangerous, **make sure you're using overlay as your storage before upgrading** as vfs will more than likely wipe everything. You will have to recreate everything either way if your storage.conf is vfs...)

```bash
# From: https://podman.io/docs/installation#debian
sudo mkdir -p /etc/apt/keyrings

# Debian Testing/Bookworm
curl -fsSL https://download.opensuse.org/repositories/devel:kubic:libcontainers:unstable/Debian_Testing/Release.key \
  | gpg --dearmor \
  | sudo tee /etc/apt/keyrings/devel_kubic_libcontainers_unstable.gpg > /dev/null
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/devel_kubic_libcontainers_unstable.gpg]\
    https://download.opensuse.org/repositories/devel:kubic:libcontainers:unstable/Debian_Testing/ /" \
  | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:unstable.list > /dev/null

# Update repository and fetch latest package
sudo apt-get update
sudo apt upgrade

# This is to solve buildah version being wrong
sudo apt remove buildah
sudo apt install buildah
```

3. Create following directory `mkdir -p .config/containers/systemd` (in your users' home folder) and `cd` into it
4. In here we'll create 4 files - qor-appdata.volume, qor-config.volume, qor-logs.volume, quadlet-vps.network and finally, qor-caddy.container with following contents, in order

ℹ️ You can name them however you want

```ini
# qor-appdata.volume
[Volume]
Device=/home/youruser/AppData/qor-caddy/app-data
Driver=local
Options=bind,rw,type=ext4
VolumeName=qor-appdata
```

```ini
# qor-config.volume
[Volume]
Device=/home/youruser/AppData/qor-caddy/config
Driver=local
Options=bind,rw,type=ext4
VolumeName=qor-config
```

```ini
# quadlet-vps.network
[Network]
Subnet=10.10.10.0/24
Gateway=10.10.10.1
Label=app=qor-caddy
```

```ini
# qor-caddy.container
[Unit]
Description=Deploy QoR-Caddy Image

[Container]
Image=docker.io/mrrubberducky/qor-caddy:latest
AutoUpdate=registry
ContainerName=qor-caddy
Network=quadlet-vps.network
DNS=10.10.10.1
EnvironmentFile=.qor-caddy
PublishPort=80:80
PublishPort=443:443
IP=10.10.10.2
# only needed on v0.15.0
#Sysctl=net.ipv4.ip_unprivileged_port_start=0
LogDriver=journald
User=caddy
Volume=/home/youruser/AppData/qor-caddy/Caddyfile:/app/configs/Caddyfile
Volume=qor-appdata.volume:/app/.local/share/caddy
Volume=qor-config.volume:/app/.config/caddy
Volume=qor-logs:/app/logs

[Install]
WantedBy=multi-user.target
```

5. Reload systemctl daemon with `systemctl --user daemon-reload`
6. Run the container with `systemctl --user start qor-caddy.service`

### 🐳 With docker-compose (recommended)

**Starting from v0.16.0**, you no longer need to add a `sysctl` parameter to the container! Versions below **still require it** - v0.15.0 and v0.12.0 (though you can run the last one as root)

1. Create following docker-compose.yaml below

>[!WARNING]
> You will need to create the following directory caddy-appdata will bind to, otherwise it will fail with `special device <location> does not exist`

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
    # Only needed on v0.15.0 and v0.12.0
    #sysctls:
    #  - net.ipv4.ip_unprivileged_port_start=80
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
docker.io/mrrubberducky/qor-caddy:latest
```

> [!WARNING]
> If running version equal or less to v0.15.0, you will need to add a extra parameter to the run command: `--sysctl net.ipv4.ip_unprivileged_port_start=80`. This allows rootless user inside container to bvind to ports below 1000

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

> [!INFO]
> If you get a platform is "" error, remove --platform=$BUILDPLATFORM from Dockerfile references. This however should work normally, at least it does on Podman 4.3+

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
    # Only needed on v0.15.0 and v0.12.0
    #sysctls:
    #  - net.ipv4.ip_unprivileged_port_start=80
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
