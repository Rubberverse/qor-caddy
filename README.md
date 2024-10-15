## Rubberverse container images

![qor-caddy version](https://img.shields.io/badge/Image_Version-v0.21.1-purple) ![caddy version](https://img.shields.io/badge/Caddy_Version-v2.9.0_beta.2-brown
) ![qor-caddy pulls](https://img.shields.io/docker/pulls/mrrubberducky/qor-caddy)

**Currently supported build(s)**: v0.21.1-alpine "Gooseberry", built upon v2.9.0-beta.2

**Update Policy**: On new Beta, Release Canditate and Stable release of Caddy, not building against `master` branch. 

**Security Policy**: Everytime there's a patched CVE that arises on the horizon.

This repository contains ready-to-use multi-platform images for Caddy built using [GitHub actions](https://github.com/Rubberverse/qor-caddy/blob/main/.github/workflows/build.yaml). 

Multi-Architecture binares are built using Go cross-compilation, Images themselves are finalized using `qemu-server`. We are making use of `main.go` which is modified during build-time to include modules that we need. It can be seen on [Caddy repository](https://github.com/caddyserver/caddy/blob/master/cmd/caddy/main.go). 

Exact build command is `GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o /app/go/bin/caddy-${TARGETARCH} -trimpath ./ \`

[alpine/Dockerfile](https://github.com/Rubberverse/qor-caddy/blob/main/caddy-dfs-CC/alpine/Dockerfile) | [debian/Dockerfile](https://github.com/Rubberverse/qor-caddy/blob/main/caddy-dfs-CC/debian/Dockerfile) | [array-helper.sh](https://github.com/Rubberverse/qor-caddy/blob/main/scripts/array-helper.sh) | [docker-entrypoint.sh](https://github.com/Rubberverse/qor-caddy/blob/main/scripts/docker-entrypoint.sh)

**Modules Included**

| Name + URL | Type | Short Description |
|------------|------|-------------------|
| [Porkbun](https://github.com/caddy-dns/porkbun) | DNS Provider | Provides DNS management capabilites for [Porkbun](https://porkbun.com) |
| [GoDaddy](https://github.com/caddy-dns/godaddy) | DNS Provider | Provides DNS management capabilites for [GoDaddy](https://godaddy.com) |
| [Namecheap](https://github.com/caddy-dns/namecheap) | DNS Provider | Provides DNS management capabilites for [Namecheap](https://namecheap.com) |
| [Cloudflare](https://github.com/caddy-dns/cloudflare) | DNS Provider | Provides DNS management capabilites for [Cloudflare](https://cloudflare.com) |
| [Vercel](https://github.com/caddy-dns/vercel) | DNS Provider | Provides DNS management capabilites for [Vercel](https://vercel.com) |
| [DDNSS](https://github.com/caddy-dns/ddnss) | DNS Provider | Provides DNS management capabilities for [DDNSS.de](https://ddnss.de) |
| [MailInABox](https://github.com/caddy-dns/mailinabox) | DNS Provider | Provides DNS management capabilities for [MailInABox](https://mailinabox.email/) |
| [Coraza WAF for Caddy](https://github.com/corazawaf/coraza-caddy) | Security | High-Performance Web Application Firewall for Caddy |
| [Caddy Crowdsec Bouncer](https://github.com/hslatman/caddy-crowdsec-bouncer) | Security | Bouncer for Crowdsec, makes decisions and denies connections in case IP is banned |
| [Layer4](https://github.com/hslatman/caddy-crowdsec-bouncer/layer4) | Security | Provides extra filtering capabilites for Layer 4 applications with Caddy Bouncer |
| [Caddy DynamicDNS](https://github.com/mholt/caddy-dynamicdns) | Utility | Keeps your DNS pointed to your machine |
| [Caddy Umami](https://github.com/jonaharagon/caddy-umami) | Utility | Umami analytics on any site without needing to modify or add extra scripts to your site |
| [Caddy DNS IP Range](https://github.com/fvbommel/caddy-dns-ip-range) | Utility | Checks against locally running cloudflared DNS and updates the IP addresses
| [Caddy Cloudflare IPs](https://github.com/WeidiDeng/caddy-cloudflare-ip) | Utility | Periodically checks Cloudflare IP ranges and updates them |
| [Caddy Combine IP Ranges](https://github.com/fvbommel/caddy-combine-ip-ranges) | Utility | Allows combination of `trusted_proxies` directive |

---

## 🐳 For Docker Hub

| Image(s) | Tag(s) | Description | Architectures |
|----------|--------|-------------|---------------|
| mrrubberducky/qor-caddy | latest-alpine, [version]-alpine | Lower file-size, uses Alpine image as it's base | x86_64 |

Debian images are going to be generally more bulky compared to ex. Alpine. Only use if you really want to, the only difference is that both build & final image process use their respective distros to achieve the same result in the end. 

Dropped support for other architectures, not too popular and probably been producing broken binaries because something causes the other thing to not work and I'm too lazy to find out why again. Worked fine before, no longer does again :>

---

## Image versioning

Images use following versioning:
vX.YZ.HH

- XX includes version type, 0 is considered "beta" or "semi-stable"
- YY includes Major changes
- ZZ includes Minor changes
- HH includes Patches, Version bumps & Fixes

They will always be one higher than the previous ex. if a patch releases and prev version was v0.16.0, the next one will be v0.16.1.

## Environmental variables

| Env | Description | Value |
|-----|-------------|---------|
| [**REQ**] `CONFIG_PATH` | Points Caddy to the configuration file, must be a valid path where the file is present. It is recommended to map a volume with the config file in `/app/configs` | `empty by default`
| **[OPT]** `CADDY_ENVIRONMENT` | Controls what type of environment Caddy is in. If it's in testing, automatic config reload is permitted, if not then it's not. If this value is empty, it will fallback to `PROD` | `PROD` or `TEST` |
| **[OPT]** `EXTRA_ARGUMENTS` | You can pass here any extra runtime flag/launch parameter to the Caddy binary, useful for some extra specific options when running as `TEST` environment. This variable can be empty if none are desired | `empty by default`

## User-owned directories

Caddy user inside the container owns following directories: 

- `/app`
- `/srv/www` - for `alpine` based images
- `/var/www` - for `debian` based images

## Usage

If you ever used Caddy, it's about the same. You'll mostly be sitting in Caddyfile configuring things and what not. It is however recommended to enable [admin endpoint](https://caddyserver.com/docs/caddyfile/options#admin) as that will allow you to issue commands such as `caddy reload` to the container and many other commands such as `caddy test`.

When it comes to usage of extra modules included here, you should seek that out yourself as I feel like they've already done pretty nice job of documenting their own usage on their repositories. Though, [Setup.md](https://github.com/Rubberverse/qor-caddy/blob/main/Setup.md#-extras) might have configuration examples

In order to reload a configuration file, you can run `podman exec -t CONTAINERNAME /app/bin/caddy -c /app/configs/Caddyfile` (replace `podman` with `docker` in case you're running Docker)

Short tl;dr:

1. Mount a `Caddyfile` or `caddy.json` to `/app/configs`
2. Change `CONFIG_PATH` environmental variable so it points to your `Caddyfile` or `caddy.json` - **needs to be full path** ex. `CONFIG_PATH=/app/configs/Caddyfile`
3. Run the image
4. ???
5. Profit 

## Configuration Example

You can find out the configuration I personally use along with this image at [MrRubberDucky/rubberverse.xyz](https://github.com/MrRubberDucky/rubberverse.xyz/blob/main/Generic/Configurations/caddy/Caddyfile) repository. Just click that hyperlink and it will take you directly to it.

It makes use of following modules in the image: Cloudflare DNS, Crowdsec Caddy Bouncer, Caddy Analytics, Caddy DNS IP Range, Caddy Cloudflare IPs, Caddy Combine IP Ranges and also Caddy-specific features such as environmental variables, log files, admin endpoint etc.

Consider giving it a look if you're stumped on how to use some of these modules.

## Deployment Methods

- [Rootless Quadlet via Podman, recommended](https://github.com/Rubberverse/qor-caddy/blob/main/Setup.md#-quadlet-experimental-recommended)
- [Docker Compose, recommended](https://github.com/Rubberverse/qor-caddy/blob/main/Setup.md#-with-docker-compose-recommended)
- [docker run command](https://github.com/Rubberverse/qor-caddy/blob/main/Setup.md#%EF%B8%8F-manually-without-docker-compose)
- [Customized image from source (WIP)](https://github.com/Rubberverse/qor-caddy/blob/main/Setup.md#from-source)

## Troubleshooting

See [here](https://github.com/rubberverse/troubleshoot/blob/main/qor-caddy.md)

## Contributing

Feel free to do so if you feel like something is wrong, just explain why as I'm still taking jabs at Dockerfile so I might not understand few things still. It might be better to make a issue first though - [Github repository](https://github.com/Rubberverse/qor-caddy)
