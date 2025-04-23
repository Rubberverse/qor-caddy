## 🦆 Rubberverse Container Images

![Image Tag](https://img.shields.io/github/v/tag/Rubberverse/qor-caddy) | [License](https://img.shields.io/github/license/Rubberverse/qor-caddy)

*"Others stray away from insanity, we embrace it."* - Mr. Rubber Ducky (Simon)

Not sure what to pull? Check currently available [images](https://github.com/Rubberverse/qor-caddy/pkgs/container/qor-caddy).

## Notice

This is a major rewrite of `qor-caddy` that completely changes how it was used compared to now. Before updating, make sure that **you're ready to adapt to them**.

These changes aren't live yet. Some things are subject to change.

## Features

This update was made in 12 hours. My head hurts but that's aside...

- Uses `scratch` image.
- Rootless by default and supports any UID:GID combination without using su-exec, or similar.
- No shell, or any extra utilities that come with distro images.
- docker-entrypoint.sh as executable, thanks to [Bunster]() project. This eliminates need for an shell.
- Ready for cross-compilation, no hard-deps on singular architecture.
- Tightened executable permissions - only read and execute.
- Includes Caddy modules you love.
- Final image only weights 63.5MB, this is a reduction of 66.5MB from Alpine image!

💁‍♂️ Final image can weight even less if you only include necessary modules.

## No shell?

Yup, you've read it right. You won't be able to issue any commands directly into the container because... there's no shell. You should allow access locally for your management interface and reload your configuration that way!

Removal of shell and any extra moving part was done from a security standpoint - the less, the better. This increase security at the cost of usability, you give some, you take some scenario.

## 🔗 Image Tags

| Base    | Tag(s)                         | Arch     | Description                |
|---------|--------------------------------|----------|----------------------------|
| scratch | `latest-alpine`, `alpine-$tag` | `x86_64` | Stable branch Caddy builds |
| scratch | `beta`, `beta-$tag`            | `x86_64` | Beta/RC Caddy builds       |

> [!WARNING]
> `security` tag is discontinued. I don't have time to maintain it, sorry!

Tags follow SemVer versioning

- X: Image revision
- Y: Image major changes
- Z: Image minor changes, minor version bumps, fixes etc.

## 💲 Environmental variables

Required environmental variables are `CONFIG_PATH` and `CADDY_PROD`, rest is optional.

| Variable          | Default Value        |
|-------------------|----------------------|
| `CONFIG_PATH`     | `Empty`              |
| `CADDY_PROD`      | `Fallback to "prod"` |
| `EXTRA_ARGUMENTS` | `Empty`              |

`CONFIG_PATH` should point to a full path where `Caddyfile`, or `caddy.json` residues in. We recommend mounting your configuration files in `/app/configs`!

Here's an example `.env` you can use as a base

```env
CONFIG_PATH=/app/configs/Caddyfile
# Can be prod or test, use prod in production environments!
CADDY_PROD=prod
# Any extra arguments you can pass to caddy run (prod) or caddy start (test), refer to Caddy documentation to know more
EXTRA_ARGUMENTS=""
```

If using Quadlet, you can use the .env above like so

```ini
# SNIPPET
[Container]
(...)
EnvironmentFile=/home/example_user/Environments/.env
Volume=/home/example_user/Caddyfile:/app/configs/Caddyfile
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

| Repo                             | Type                     | Short Desc                                                                    |
|----------------------------------|--------------------------|-------------------------------------------------------------------------------|
| caddy-dns/cloudflare             | DNS Provider             | Manage Cloudflare DNS, useful for DNS-01 challenges                           |
| caddy-dns/dynamicdns             | DynDNS Updater           | Updates Dynamic DNS entries with current host IP address                      |
| corazawaf/coraza-caddy           | Web application firewall | OWASP Coraza Caddy                                                            |
| hslatman/caddy-crowdsec-bouncer  | Web application firewall | https://crowdsec.net, includes Appsec and Layer4 sub-modules                  |
| mholt/caddy-l4                   | Raw TCP/UDP Routing      | Allows Caddy to route Layer 4 traffic                                         |
| mholt/caddy-ratelimit            | Traffic Limiting         | Implements rate limiting similar to Nginx rate limit (WIP)                    |
| jonaharagon/caddy-umami          | Utility                  | Implement Umami Analytics to any website straight from Caddy                  |
| fvpommel/caddy-combine-ip-ranges | Utility / Extension      | Allows combination of trusted_proxies directives                              |
| fvpommel/caddy-dns-ip-range      | Utility / Extension      | Checks against locally running cloudflared DNS and updates their IP addresses |
| WeidiDeng/caddy-cloudflare-ip    | Utility / Extension      | Periodically checks Cloudflare IP ranges and updates them                     |

Any issues involving third-party modules should be reported to the module's respective repository, not to Caddy maintainers. In case the issue comes from my image, create an issue about it here!
## 🛠️ Usage

If you ever used Caddy, it's about the same. Most of your time will be spent sitting in your `Caddyfile` or `caddy.json`. You'll want to enable admin endpoint and reload your configuration file by issuing `podman exec -t qor-caddy /app/bin/caddy reload -c /app/configs/Caddyfile` instead of restarting your container. [Caddy Docs quick-link](https://caddyserver.com/docs/caddyfile/options#admin)

> [!WARNING]
> Volume mounted configuration files will still need a container restart if you re-created the configuration file when it was on. So in case something seems fishy, restart your container. You'll know instantly in case config file is wrong ;)

Here's some helpful links to get you head-started with Caddy as your Web Server. On your own time, you can learn even more advanced things that Caddy can do!

- [Getting started @ Caddy docs](https://caddyserver.com/docs/getting-started)
- [Quick-starts @ Caddy docs](https://caddyserver.com/docs/quick-starts)
- [Caddyfile Reference @ Caddy docs](https://caddyserver.com/docs/caddyfile)
- My own Caddyfiles: [WAN](https://github.com/MrRubberDucky/Homelab/blob/main/WAN/Caddy/Caddyfile) and [LAN](https://github.com/MrRubberDucky/Homelab/blob/main/LAN/Caddy/Caddyfile). 

I make use of plenty of moduels from here so you can take a lookie. Though they're updated once in a while.

## 🥰 Contributing

Feel free to contribute if you feel like something is wrong, needs changing or other various reasons. Though I would appreciate it if you created a GitHub issue first to talk about it! (Just so we can be on the same table)
