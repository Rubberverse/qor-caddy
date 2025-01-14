## 🦆 Rubberverse Container Images

![Image Tag](https://img.shields.io/github/v/tag/Rubberverse/qor-caddy) ![Caddy Version](https://img.shields.io/badge/Caddy_Version-v2.9.1-brown) ![Docker Pulls](https://img.shields.io/docker/pulls/mrrubberducky/qor-caddy) ![License](https://img.shields.io/github/license/Rubberverse/qor-caddy)

📦 **Supported Tags**: `latest-alpine`, `$versionTagFromAbove-alpine`, `latest-debian`, `$versionTagFromAbove-debian` "Gooseberry"

♻️ **Updates**: When there's a new Stable/RC/Beta release of Caddy. Extensions get updated anytime there's a serious update happening on them, usually it's pretty rare. Not building against `master` branch of Caddy, or extensions if it can be avoided. Though sometimes it's a necessity to give users better experience as `master` branch may include fixes that aren't in (dated) release.

🛡️ **Security**: Trying to monitor my images and fix CVEs that have a patch available, along with keeping the image itself and it's dependencies up-to-date. Aside from that, Dockerfile and image itself should make use of best practices so that should reduce potential issues (hopefully)

## ⚠️ Docker Hub Registry is deprecated

Update your `docker-compose.yaml` or Quadlet units to make use of GitHub Container Registry instead - `ghcr.io/rubberverse/qor-caddy`.

## 🔗 Image Tags

| Distro       | Tag(s)                           | Architecture | Description                                           |
|--------------|----------------------------------|--------------|-------------------------------------------------------|
| Alpine Linux | `latest-alpine`, `v0.0.0-alpine` | `x86_64`     | Small image size, otherwise identical to Debian image |
| Debian       | `latest-debian`, `v0.0.0-debian` | `x86_64`     | Big image size, otherwise identical to Alpine image   |

We used to have a pretty weird version scheme, now we have SemVer versioning - vX.Y.Z

- X: Image revision
- Y: Image major changes
- Z: Image minor changes, version bumps, fixes etc.

## 💲 Environmental variables

These apply for both Debian and Alpine Linux variants of `qor-caddy` image.

| Env               | Required? | Default Value |
|-------------------|-----------|--------------|
| `CONFIG_PATH`     | 🟢 Yes    | `""`         |
| `CADDY_PROD`      | 🟠 Opt    | `PROD`       |
| `EXTRA_ARGUMENTS` | 🟠 Opt    | `""`         |

You're expected to mount an `Caddyfile`, or `caddy.json` into any path into the container, you should do `/app/configs/` since it's easier to remember, then point `CONFIG_PATH` to the full path to the configuration file **inside** of the container. Small example can be seen below.

```ini
[Container]
(...)
Volume=${HOME}/AppData/1_CONFIGS/Caddyfile:/app/configs/Caddyfile
Environment=CONFIG_PATH=/app/configs/Caddyfile
```

## Deploying

Quadlet unit, only supported on Podman +v5.2.1

1. Copy [qor-caddy.container](https://github.com/Rubberverse/qor-caddy/blob/main/qor-caddy.container) from this repository and put it in `~/.config/containers/systemd`
2. Edit it to your own liking, there are comments inside of it to guide you around
3. Reload systemctl daemon with `systemctl --user daemon-reload`
4. Deploy the Quadlet unit by starting the service - `systemctl --user start qor-caddy`

Docker Compose:

TODO

## ⚙️ List of third-party Caddy modules

These modules can be removed at any time and for any reason, they're mostly here to just serve a purpose for me. If I happen to switch technologies or something similar, I generally tend to remove things I don't need as it makes it easier to manage.

| GitHub Repository                                                                            | Type                     | Short Description                                              |
|----------------------------------------------------------------------------------------------|--------------------------|----------------------------------------------------------------|
| [caddy-dns/porkbun](https://github.com/caddy-dns/porkbun)                                    | DNS Provider             | Manage Porkbun DNS records, useful for ACME DNS challenges     |
| [caddy-dns/cloudflare](https://github.com/caddy-dns/cloudflare)                              | DNS Provider             | Manage Cloudflare DNS records, ditto                           |
| [caddy-dns/vercel](https://github.com/caddy-dns/vercel)                                      | DNS Provider             | Manage Vercel DNS records, ditto                               |
| [corazawaf/coraza-caddy](https://github.com/corazawaf/coraza-caddy)                          | Web Application Firewall | Provides WAF capabilities for Caddy (OWASP Coraza), incompatible with websockets 🍰⭐⚠️ | 
| [hslatman/caddy-crowdsec-bouncer](https://github.com/hslatman/caddy-crowdsec-bouncer)        | Security                 | Blocks malicious traffic based on decisions made by [Crowdsec](https://crowdsec.net/), requires locally running Crowdsec agent 🍔 |
| [hslatman/caddy-crowdsec-bouncer/appsec](https://github.com/hslatman/caddy-crowdsec-bouncer/tree/main/appsec)  | Web Application Firewall | Appsec HTTP handler for Crowdsec Appsec component, requires locally running Crowdsec agent 🍔⚠️             |
| [mholt/caddy-l4](https://github.com/mholt/caddy-l4)                                          | Routing                  | Gives Layer 4 routing capabilities to Caddy                    |
| [mholt/caddy-ratelimit](https://github.com/mholt/caddy-ratelimit)                                    | Rate Limit               | Implements rate limiting slightly similar to Nginx rate limit in Caddy |
| [jonaharagon/caddy-umami](https://github.com/jonaharagon/caddy-umami)                        | Helper                   | Easily implement Umami Analytics on any of your websites straight from Caddy 🍣 |
| [fvbommel/caddy-combine-ip-ranges](https://github.com/fvbommel/caddy-combine-ip-ranges)      | Utility                  | Allows combination of `trusted_proxies` directives |
| [fvbommel/caddy-dns-ip-range](https://github.com/fvbommel/caddy-dns-ip-range)                | Utility                  | Checks against locally running `cloudflared` DNS and updates the IP addresses |
| [WeidiDeng/caddy-cloudflare-ip](https://github.com/WeidiDeng/caddy-cloudflare-ip)            | Utility                  | Periodically checks Cloudflare IP ranges and updates them |

🍰 - Proxy websocket requests first before Coraza in order to avoid trouble. 

⭐ - Any project relying on non-buffered responses is going to be incompatible due to Coraza being unable to toggle off buffered responses (fix is in progress for this) - maybe safe to say that it touches most NextJS projects that rely on unbuffered responses.

🍔 - [Appsec component installation](https://docs.crowdsec.net/docs/appsec/installation/), [Crowdsec Agent installation](https://docs.crowdsec.net/docs/getting_started/install_crowdsec/), [Example Quadlet deployment (rootless)](https://github.com/MrRubberDucky/rubberverse.xyz/tree/main/Quadlet/LIVE/Crowdsec), keep in mind that you will need to probably create directories yourself before you can launch it with a non-privileged container user.

⚠️ - **Do not** use Crowdsec Appsec in combination with Coraza WAF. It's basically like running two WAFs at that point, a huge resource waste. Either use one or the other, don't combine Coraza & Appsec.

🍣 - Requires self-hosted [umami.is](https://umami.is) instance or cloud variant of it hosted on their own infrastructure.

Any issues involving third-party modules should be reported to the module's respective repository, not to Caddy maintainers. In case the issue comes from my image, leave an GitHub issue here.

## 📂 Container user owned directories

`caddy` user inside the container owns following directories: 

- `/app` - Home directory for `caddy` user.
- `/app/bin` - Stores `caddy` binary.
- `/app/configs` - Stores Caddy configuration files, if used.
- Alpine: `/srv/www`, for serving static files. Need to use `U` in your Volume mount in order to chown your files as container user.
- Debian: `/var/www`, for serving static files. Need to use `U` in your Volume mount in order to chown your files as container user.

## 🛠️ Usage

If you ever used Caddy, it's about the same. Most of your time will be spent sitting in your `Caddyfile` or `caddy.json`. You'll want to enable admin endpoint and reload your configuration file by issuing `podman exec -t qor-caddy /app/bin/caddy reload -c /app/configs/Caddyfile` instead of restarting your container. [Caddy Docs quick-link](https://caddyserver.com/docs/caddyfile/options#admin)

> [!WARNING]
> Volume mounted configuration files will still need a container restart if you re-created the configuration file when it was on. So in case something seems fishy, restart your container. You'll know instantly in case config file is wrong ;)

Here's some helpful links to get you head-started with Caddy as your Web Server. On your own time, you can learn even more advanced things that Caddy can do!

- [Getting started @ Caddy docs](https://caddyserver.com/docs/getting-started)
- [Quick-starts @ Caddy docs](https://caddyserver.com/docs/quick-starts)
- [Caddyfile Reference @ Caddy docs](https://caddyserver.com/docs/caddyfile)
- [My own Caddyfile, updated rarely so may not always be up-to-date](https://github.com/MrRubberDucky/rubberverse.xyz/blob/main/Generic/Configurations/caddy/Caddyfile)

Keep in mind that mine is going to be messy as it makes use of most of the modules listed here, though it may be helpful in case you want to quickly learn how to use a module.

## 🥰 Contributing

Feel free to contribute if you feel like something is wrong, needs changing or other various reasons. Though I would appreciate it if you created a GitHub issue first to talk about it! (Just so we can be on the same table)
