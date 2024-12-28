## 🦆 Rubberverse container images

![qor-caddy version](https://img.shields.io/badge/Image_Version-v1.2.9-purple) ![caddy version](https://img.shields.io/badge/Caddy_Version-v2.9.0_beta.3-brown
) ![qor-caddy pulls](https://img.shields.io/docker/pulls/mrrubberducky/qor-caddy)

📦 **Currently supported build(s)**: `latest-alpine`, `v1.2.9-alpine`, "Gooseberry", built upon `Caddy v2.9.0-beta.3`

♻️ **Update Policy**: On new Beta, Release Canditate and Stable release of Caddy, not building against `master` branch. (Previous) Stable build will be kept up-to-date if current Caddy build is still in Beta or RC state.

🛡️ **Security Policy**: Everytime there's a patched CVE that arises on the horizon. Unfixable Debian low severity CVEs are not taken into consideration! (or overall CVEs with no fixed versions available of the package yet)

## Version Tag information

| 🐳 Image(s) | 📁 Tag(s) | 📓 Description | 💻 Architecture |
|----------|--------|-------------|---------------|
| `ghcr.io/Rubberverse/qor-caddy:latest-alpine` | `latest-alpine`, `$VERSION-alpine` | Lower file-size, runs as `caddy` user and uses `alpine:edge` image as it's base | x86_64 |
| `ghcr.io/Rubberverse/qor-caddy:latest-debian` | `latest-debian`, `$VERSION-debian` | Bigger file-size, runs as `caddy` user and uses `debian:bookworm-slim` image as it's base | x86_64 |

❓ `$VERSION`, ex. `v1.2.9-alpine`:

Images use following versioning schema -> vX.Y.Z

- X: Image revision
- Y: Image major changes
- Z: Image minor changes, version bumps & fixes

## ⚙️ List of modules included with this build of Caddy

| 🔧 Name + URL | 🪛 Short Description |
|------------|-------------------|
| [Porkbun](https://github.com/caddy-dns/porkbun) | Provides DNS management capabilites for [Porkbun](https://porkbun.com) |
| ⚠️ [GoDaddy](https://github.com/caddy-dns/godaddy) | Provides DNS management capabilites for [GoDaddy](https://godaddy.com) |
| ⚠️ [Namecheap](https://github.com/caddy-dns/namecheap) | Provides DNS management capabilites for [Namecheap](https://namecheap.com) |
| [Cloudflare](https://github.com/caddy-dns/cloudflare) | Provides DNS management capabilites for [Cloudflare](https://cloudflare.com) |
| [Vercel](https://github.com/caddy-dns/vercel) | Provides DNS management capabilites for [Vercel](https://vercel.com) |
| [DDNSS](https://github.com/caddy-dns/ddnss) | Provides DNS management capabilities for [DDNSS.de](https://ddnss.de) |
| [MailInABox](https://github.com/caddy-dns/mailinabox) | Provides DNS management capabilities for [MailInABox](https://mailinabox.email/) |
| [Coraza WAF for Caddy](https://github.com/corazawaf/coraza-caddy) | High-Performance Web Application Firewall for Caddy, experimental - ❗ INCOMPATIBLE WITH WEBSOCKETS ❗ |
| [Caddy Crowdsec Bouncer](https://github.com/hslatman/caddy-crowdsec-bouncer) | Bouncer for [Crowdsec](https://www.crowdsec.net/), an collaborative security engine. Needs a valid Crowdsec installation |
| [Layer4](https://github.com/hslatman/caddy-crowdsec-bouncer/layer4) | Provides extra filtering capabilites for Layer 4 applications with Crowdsec Caddy Bouncer & Improved routing capabilities |
| [Caddy Rate Limit](github.com/mholt/caddy-ratelimit) | Implements rate limiting slightly similar to nginx rate limit in Caddy |
| [Caddy Umami](https://github.com/jonaharagon/caddy-umami) | Easily set-up umami analytics on any website, straight from Caddy, requires a self-hosted or cloud [umami.is](https://umami.is) instance |
| [Caddy DynamicDNS](https://github.com/mholt/caddy-dynamicdns) | Keeps your DNS pointed to your machine using Caddy |
| [Caddy Combine IP Ranges](https://github.com/fvbommel/caddy-combine-ip-ranges) | Allows combination of `trusted_proxies` directives |
| [Caddy DNS IP Range](https://github.com/fvbommel/caddy-dns-ip-range) | Checks against locally running cloudflared DNS and updates the IP addresses |
| [Caddy Cloudflare IPs](https://github.com/WeidiDeng/caddy-cloudflare-ip) | Periodically checks Cloudflare IP ranges and updates them |

⚠️ - Check relevant GitHub issues in case you experience problems: [GoDaddy](https://github.com/Rubberverse/qor-caddy/issues/15) and [Namecheap](https://github.com/Rubberverse/qor-caddy/issues/16)

## Environmental variables

| 💲 Env | 📓 Description | 🇼🇫 Value |
|-----|-------------|---------|
| ❗ `CONFIG_PATH`   | Points Caddy to the configuration file, must be a valid path where the file is present. It is recommended to map a volume with the config file in `/app/configs` | `empty by default`
| `CADDY_ENVIRONMENT` | Controls what type of environment Caddy is in. If it's in testing, automatic config reload is permitted, if not then it's not. If this value is empty, it will fallback to `PROD` | `PROD` or `TEST` |
| `EXTRA_ARGUMENTS`   | You can pass here any extra runtime flag/launch parameter to the Caddy binary, useful for some extra specific options when running as `TEST` environment. This variable can be empty if none are desired | `empty by default`

❗ - Required

## 📂 User-owned directories

`caddy` user inside the container owns following directories: 

- `/app` - Home directory for `caddy` user
- `/srv/www` - for `alpine` based images, you must still set `U=true` in order to fix up permissions inside mounted sites
- `/var/www` - for `debian` based images, you must still set `U=true` in order to fix up permissions inside mounted sites

## 🔨 Usage

1. Mount a `Caddyfile`, or `caddy.json` to `/app/configs`
2. Set `CONFIG_PATH` environmental variable so it points at `/app/configs/Caddyfile`, or `/app/configs/caddy.json`
3. Run the image
4. Profit

## 🛠️ Extended Usage

If you ever used Caddy, it's about the same. You'll mostly be sitting in Caddyfile configuring things and what not. It is however recommended to enable [admin endpoint](https://caddyserver.com/docs/caddyfile/options#admin) as that will allow you to issue commands such as `caddy reload` to the container and many other commands such as `caddy test`.

⚠️ **Keep in mind**: Volume mounted configuration files will still need a container restart if you re-created the configuration file during it.

You can find out the configuration I personally use along with this image at [MrRubberDucky/rubberverse.xyz](https://github.com/MrRubberDucky/rubberverse.xyz/blob/main/Generic/Configurations/caddy/Caddyfile) repository. Just click that hyperlink and it will take you directly to it.

It makes use of following modules in the image: Cloudflare DNS, Crowdsec Caddy Bouncer, Caddy Analytics, Caddy DNS IP Range, Caddy Cloudflare IPs, Caddy Combine IP Ranges and also Caddy-specific features such as environmental variables, log files, admin endpoint, proxy protocol etc.

Consider giving it a look if you're stumped on how to use some of these modules.

## Deployment Methods

- [Rootless Quadlet via Podman, recommended](https://github.com/Rubberverse/qor-caddy/blob/main/Setup.md#-quadlet-experimental-recommended)
- [Docker Compose, recommended](https://github.com/Rubberverse/qor-caddy/blob/main/Setup.md#-with-docker-compose-recommended)
- [docker run command](https://github.com/Rubberverse/qor-caddy/blob/main/Setup.md#%EF%B8%8F-manually-without-docker-compose)
- [Customized image from source (WIP)](https://github.com/Rubberverse/qor-caddy/blob/main/Setup.md#from-source)

## 🥰 Contributing

Feel free to do so if you feel like something is wrong, just explain why as I'm still taking jabs at Dockerfile so I might not understand few things still. It might be better to make a issue first though.
