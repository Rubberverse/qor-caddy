## Rubberverse container images

**Currently supported build(s)**: v0.18-alpine, v0.18-debian "Raspberry" (rolling release)

This repository contains Dockerfiles specific for building and running `qor-caddy` image. It's our customized image that builds Caddy with custom modules (also known as plugins) and is maintained by MrRubberDucky (same username on Discord)

This image bundles following moduels by default, in order to know how to use them, consider checking out their repositories. If you would like a extra module you need to be added to this image, create a Issue with [FEATURE REQUEST] in the title.

>[!NOTE]
> Google Domain DNS plugin is removed as of v0.17.0 due to Google Domains being axed by Google and every domain registered under it going under Squarespace. On a side note, Layer4 module is still here, just bundled under Caddy Crowdsec Bouncer

✨ - v0.18 additions

**DNS**
- [AcmeDNS](https://github.com/caddy-dns/acmedns)
- [AliDNS](https://github.com/caddy-dns/alidns)
- [Azure](https://github.com/caddy-dns/azure)
- [Cloudflare](https://github.com/caddy-dns/cloudflare)
- [DDNNSS](https://github.com/caddy-dns/ddnnss)
- [DuckDNS](https://github.com/caddy-dns/duckdns)
- [Gandi](https://github.com/caddy-dns/gandi)
- [GoDaddy](https://github.com/caddy-dns/godaddy)
- ✨ [ionos](https://github.com/caddy-dns/ionos)
- [MailInABox](https://github.com/caddy-dns/mailinabox)
- [Namecheap](https://github.com/caddy-dns/namecheap)
- [Namesilo](https://github.com/caddy-dns/namesilo)
- [Netlify](https://github.com/caddy-dns/netlify)
- ✨ [OVHcloud/ovh](github.com/caddy-dns/ovh)
- [Porkbun](https://github.com/caddy-dns/porkbun)
- ✨ [Tencent Cloud](https://github.com/caddy-dns/tencentcloud)
- [Route53](https://github.com/caddy-dns/route53)
- ✨ [Vultr](github.com/caddy-dns/vultr)


**Security**

- [Caddy Security](https://github.com/greenpau/caddy-security)
- [Coraza WAF for Caddy](https://github.com/corazawaf/coraza-caddy)
- [Caddy Crowdsec Bouncer](https://github.com/hslatman/caddy-crowdsec-bouncer)

**Extra Features**

- [Dynamic DNS](https://github.com/mholt/caddy-dynamicdns)
- [Mercure for Caddy](https://github.com/mercure)
- [Replace Response](https://github.com/caddyserver/replace-response)
- [Vulcain for Caddy](https://github.com/vulcain)

**Service-specific**

- ✨ [Caddy Cloudflare IP CIDRs](github.com/WeidiDeng/caddy-cloudflare-ip), this one is for whitelisting Cloudflare IP ranges via trusted_proxies directive

**Misc** - uncategorized, mostly for fun stuff. Maybe with a hint of nostalgia for the old times.

- ✨ [Caddy Hit Counter](github.com/mholt/caddy-hitcounter)

## Using the image

Guide can be found here: https://github.com/Rubberverse/qor-caddy/blob/main/Setup.md

..or alternatively, a quick docker-compose:

```yaml
version: "3.8"
services:
  qor-caddy:
    image: docker.io/mrrubberducky/qor-caddy:latest-alpine
    # For GitHub Container Registry: image: ghcr.io/rubberverse/qor-caddy:latest-alpine
    user: 1001:1001
    volumes:
    # /srv/www, /app, /app/logs, /app/.config, /app/.local
      - ${HOME}/qor-caddy/Caddyfile:/app/configs/Caddyfile
      - qor-caddy-appdata:/app/.local/share/caddy
      - qor-caddy-config:/app/.config/caddy
      - qor-caddy-logs:/app/logs
    environment:
    # Can either be prod or test
      - CADDY_ENVIRONMENT=prod
    # Config adapter type that Caddy understands, can either be caddyfile or json
      - ADAPTER_TYPE=caddyfile
    # Path to the configuration file, make sure to mount it in previous step to this location
      - CONFIG_PATH=/app/configs/Caddyfile
    # Pass extra arguments to Caddy Run or Start command (Prod starts via run, Test starts via start)
    # https://caddyserver.com/docs/command-line#caddy-run
    # https://caddyserver.com/docs/command-line#caddy-start
      - EXTRA_ARGUMENTS=""
    # Required on Alpine Linux containers in order to bind below privileged port range 80 to 1000
    # sysctls:
    #   - net.ipv4.ip_unprivileged_port_start=80
    ports:
      - "80:80"
      - "443:443"
    # It is recommended to use network_mode: host or similar instead, otherwise Source IP will be lost
    # For a web server, you probably want them to be a thing. On Podman you can use slirp4netns (awful speeds + no ipv6 support) 
    # or pasta (passt, a bit buggy but works well)
    networks:
      - qor-caddy

networks:
  qor-caddy:

# Certificate and config persistence
volumes:
  qor-caddy-config:
      driver_opts:
      type: none
      device: /home/youruser/AppData/caddy-config
      o: bind,rw
  qor-caddy-appdata:
    driver_opts:
      type: none
      device: /home/youruser/AppData/caddy-data
      o: bind,rw
  # It is recommended to use a log parser like Crowdsec for extra security
  # You can remount logs volume to Crowdsec and connect your qor-caddy instance via Caddy Bouncer
  qor-caddy-logs:
```

## What each image tag/dockerfile represents

> [!WARNING]
> It is recommended to pull Debian image only if you need a certain architecture that's not provided by Alpine variant. Mostly due to the fact that Debian images are chonkier compared to Alpine ones, might reach 240MB+ with Debian.

| Directory | Tag(s) | Description | Architectures |
|-----------|------|-------------|-----------------------------------------------------|
| caddy-dfs-CC | latest-debian, latest-alpine, latest-helper-dev | Built QoR-Caddy image with modules shown above. Dockerfiles are seperated for GitHub Cross-Compilation support with golang | x86_64, x86, ARM64v8, ARMv7, ARMv5, mips64le, powerpc64le, s390x |
| caddy-dfs-sarch | latest-debian, latest-alpine | Full Dockerfile that doesn't rely on GitHub Actions | Host Dependant |
| xcaddy | xcaddy-interactive, xcaddy-noninteractive | Interactive and non-interactive xcaddy builders that are made to quickly build Caddy with any modules | x86_64 |

Legend:

- dfs: **d**ocker**f**ile**s**
- CC: cross-compile
- sarch: single-arch, no cc

## Image versioning

Images use following versioning:
vY.XX.ZZ

- Y includes version type, 0 is considered "beta" or "semi-stable"
- XX Includes Major Changes
- ZZ Includes Minor Changes & Patches

They will always be one higher than the previous ex. if a patch releases and prev version was v0.16.0, the next one will be v0.16.1.

**Exception being** anything past version v0.30.0 will change to v1.00.0 "release"

## Building your own image

>[!NOTE]
> Available build arguments can be found [here](https://github.com/Rubberverse/qor-caddy/blob/main/BuildArguments.md)

1. Either merge both `Dockerfile-Helper` and Dockerfile-OS together or build them seperately. Keep in mind that Dockerfile-Helper is split for the sake of speeding up GitHub workflow, otherwise it used qemu which was dreadfully slow so you may need to change the Dockerfile a bit till it works.
2. Build the image by passing following build command 
3. Run the image

```bash
podman build -f Dockerfile-Alpine --build-args XCADDY_MODULES="github.com/caddy-dns/cloudflare github.com/hslatman/caddy-crowdsec-bouncer"
```

## Troubleshooting

Please look at https://github.com/rubberverse/troubleshoot/blob/main/qor-caddy.md

## Contributing

Feel free to do so if you feel like something is wrong, just explain why as I'm still taking jabs at Dockerfile so I might not understand few things still. It might be better to make a issue first though.

XCADDY_MODULES="github.com/caddy-dns/cloudflare github.com/caddy-dns/route53 github.com/caddy-dns/duckdns github.com/caddy-dns/alidns github.com/caddy-dns/godaddy github.com/caddy-dns/gandi github.com/caddy-dns/porkbun github.com/caddy-dns/namecheap github.com/caddy-dns/netlify github.com/caddy-dns/azure github.com/caddy-dns/acmedns github.com/caddy-dns/vercel github.com/caddy-dns/namesilo github.com/caddy-dns/ddnss github.com/caddy-dns/mailinabox github.com/mholt/caddy-dynamicdns github.com/corazawaf/coraza-caddy/v2  github.com/greenpau/caddy-security github.com/dunglas/vulcain/caddy github.com/dunglas/mercure/caddy github.com/caddyserver/replace-response github.com/hslatman/caddy-crowdsec-bouncer/http github.com/hslatman/caddy-crowdsec-bouncer/layer4 github.com/WeidiDeng/caddy-cloudflare-ip github.com/caddy-dns/vultr github.com/mholt/caddy-hitcounter github.com/caddy-dns/tencentcloud github.com/caddy-dns/ovh github.com/caddy-dns/ionos github.com/caddy-dns/linode"