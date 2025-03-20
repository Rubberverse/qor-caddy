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

| GitHub Repository                | Type          | Short Description                                          |
|----------------------------------|---------------|------------------------------------------------------------|
| caddy-dns/porkbun                | DNS Provider  | Manage Porkbun DNS records[^1]    |
| caddy-dns/cloudflare             | DNS Provider  | Manage Cloudflare DNS records[^1] |
| caddy-dns/vercel                 | DNS Provider  | Manage Vercel DNS records[^1]     |
| corazawaf/coraza-caddy           | Security, WAF[^2] | OWASP Coraza Caddy provides WAF capabilities to Caddy, 100% compatible with OWASP Coreruleset and Modsecurity syntax[^3] |
| hslatman/caddy-crowdsec-bouncer  | Security, WAF[^2] | Block malicious traffic based on decisions made by [Crowdsec](https://crowdsec.net) from your parsed logs[^4] My image includes both Appsec and Layer4 modules for this module. |
| mholt/caddy-l4                   | Routing, Traffic Shaping | Allow Caddy to route far more than just HTTP/HTTPS, in fact allow it to route Layer 4 traffic. |
| mholt/caddy-ratelimit            | Traffic limiting | Implements rate limiting slightly similar to Nginx rate limit in Caddy, work-in-progress module. |
| jonaharagon/caddy-umami          | Utility | Easily implement Umami Analytics to any of your websites straight from Caddy[^5] |
| fvpommel/caddy-combine-ip-ranges | Utility | Allows cominbation of `trusted_proxies` directives | 
| fvpommel/caddy-dns-ip-range      | Utility | Checks against locally running `cloudflared` DNS and updates the IP addresses |
| WeidiDeng/caddy-cloudflare-ip    | Utility | Periodically checks Cloudflare IP ranges and updates them |

`latest-security`, `security-$versionTagFromAbove` includes `greenpau/caddy-security` as an extra module.

[^1]: Useful for DNS-01 Challenges
[^2]: WAF stands for Web Application Firewall
[^3]: Incompatible with Websockets. Additionally also incompatible with NextJS apps relying on real-time connection due to bugged response buffering, track upstream Coraza/Coraza repository in order to learn more.
[^4]: Requires locally running Crowdsec agent or LAPI. Appsec is incompatible with websockets and may also not be compatible with real-time NextJS apps due to response buffering. However if you're not using Appsec, Crowdsec is compatible with everything out of the box.
[^5]: Requires self-hosted umami.is instance or Cloud

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
