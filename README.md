## Rubberverse container images

![qor-caddy version](https://img.shields.io/badge/Image_Version-v0.19.3-purple) ![caddy version](https://img.shields.io/badge/Caddy_Version-v2.8.0-brown
) ![qor-caddy pulls](https://img.shields.io/docker/pulls/mrrubberducky/qor-caddy)

**Currently supported build(s)**: v0.19.3-alpine, v0.19.3-debian "Silvanberry" (rolling release), built upon v2.8.0

This repository contains ready-to-use multi-platform images for Caddy built using [GitHub actions](https://github.com/Rubberverse/qor-caddy/blob/main/.github/workflows/build.yaml). Binaries themselves are built using Caddy's [main.go](https://github.com/caddyserver/caddy/blob/master/cmd/caddy/main.go), you can see the Dockerfile used for that [here](https://github.com/Rubberverse/qor-caddy/blob/main/caddy-dfs-CC/Dockerfile-Helper)

**Modules Included**

- [Cloudflare](https://github.com/caddy-dns/cloudflare) 
- [DuckDNS](https://github.com/caddy-dns/duckdns)
- [GoDaddy](https://github.com/caddy-dns/godaddy)
- [NameCheap](https://github.com/caddy-dns/namecheap)
- [Vercel](https://github.com/caddy-dns/vercel)
- [DDNSS](https://github.com/caddy-dns/ddnss)
- [MailInABox](github.com/caddy-dns/mailinabox)
- [Coraza WAF for Caddy](https://github.com/corazawaf/coraza-caddy)
- [Caddy Crowdsec Bouncer](https://github.com/hslatman/caddy-crowdsec-bouncer)
- [Dynamic DNS](https://github.com/mholt/caddy-dynamicdns)
- [Caddy Cloudflare IP CIDRs](github.com/WeidiDeng/caddy-cloudflare-ip), this one is for whitelisting Cloudflare IP ranges via trusted_proxies directive

## 🐳 For Docker Hub

| Image(s) | Tag(s) | Description | Architectures | ⚠️ |
|----------|--------|-------------|---------------|----|
| qor-caddy | latest-alpine, [version]-alpine | Lower file-size, uses Alpine image as it's base | x86_64, x86, ARM64 | ARMv7, ARMv6, powerpc64le, riscv64, s390x | 
| qor-caddy | latest-debian, [version]-debian | Bigger file-size, uses Debian image as it's base | x86_64, x86, ARM64 | ARMv7, ARMv5, powerpc64le, mips64le, s390x |

⚠️ **We can't guarantee full compatibility for every single architecture**

Sadly, my testing capabilities are limited to ARM64 and x86_64, I technically have a ARMv6 device somewhere but don't have proper tools to properly prepare it for testing. General consensus is, ARM builds and x86 builds should work fine, the rest of the architectures are provided as-is but would still be helpful hearing about potential issues while running my image on those architectures.

## ⚪ For GitHub

| Directory | Tag(s) | Description | Architectures |
|-----------|------|-------------|-----------------------------------------------------|
| 📁 caddy-dfs-CC | latest-debian, latest-alpine, cc-caddy-binary | Built QoR-Caddy image with modules shown above. Dockerfiles are seperated for GitHub Cross-Compilation support with golang | x86_64, x86, ARM64v8, ARMv7, ARMv6, ARMv5, riscv64, mips64le, powerpc64le, s390x |
| 📁 caddy-dfs-sarch | latest | Merged together Dockerfile-Helper + Dockerfile-Alpine /or Dockerfile-Debian that doesn't depend on GitHub actions | Host dependant |
| 📁 legacy/xcaddy | xcaddy-interactive, xcaddy-noninteractive | Interactive and non-interactive xcaddy builders that are made to quickly build Caddy with any modules | Host dependant |

Legend:

- dfs: **d**ocker**f**ile**s**
- CC: cross-compile
- sarch: single-arch, no cc

❔ `cc-caddy-binary` is built from Dockerfile-Helper in caddy-dfs-CC directory
❔ `legacy` folder includes all prior work and scripts that were used to build previous versions of `qor-caddy` images. 

## Image versioning

Images use following versioning:
vX.YZ.HH

- XX includes version type, 0 is considered "beta" or "semi-stable"
- YY includes Major changes
- ZZ includes Minor changes
- HH includes Patches, Version bumps & Fixes

They will always be one higher than the previous ex. if a patch releases and prev version was v0.16.0, the next one will be v0.16.1.

**Exception being** anything past version v0.30.0 will change to v1.0.0 "release"

## Environmental variables

| Env | Description | Value |
|-----|-------------|---------|
| `CADDY_ENVIRONMENT` | Controls what type of environment Caddy is in. If it's in testing, automatic config reload is permitted, if not then it's not. If this value is empty, it will fallback to `PROD` | `PROD` or `TEST` |
| `CONFIG_PATH` | Points Caddy to the configuration file, must be a valid path where the file is present. It is recommended to map a volume with the config file in `/app/configs` | `/app/configs/Caddyfile`
| `EXTRA_ARGUMENTS` | You can pass here any extra runtime flag/launch parameter to the Caddy binary, useful for some extra specific options when running as `TEST` environment. This variable can be empty if none are desired | ` `

Since v0.19.1, `ADAPTER_TYPE` has been dropped from being required. This was due to very smol oversight where you would be unable to use normal caddy.json if this was set to anything. In case you still need the functionality, it's recommended to make use of `EXTRA_ARGUMENTS` instead

## Docker Compose

See [here](https://github.com/Rubberverse/qor-caddy/blob/main/Setup.md#-with-docker-compose-recommended)

## Building your own image

See [here](https://github.com/Rubberverse/qor-caddy/blob/main/Setup.md#from-source)

## Troubleshooting

See [here](https://github.com/rubberverse/troubleshoot/blob/main/qor-caddy.md)

## Usage

If you ever used Caddy, it's about the same. You'll mostly be sitting in Caddyfile configuring things and what not. It is however recommended to enable [admin endpoint](https://caddyserver.com/docs/caddyfile/options#admin) as that will allow you to issue commands such as `caddy reload` to the container and many other commands such as `caddy test`.

When it comes to usage of extra modules included here, you should seek that out yourself as I feel like they've already done pretty nice job of documenting their own usage on their repositories. Though, [Setup.md](https://github.com/Rubberverse/qor-caddy/blob/main/Setup.md#-extras) might have configuration examples

In order to reload a configuration file, you can run `podman exec -t CONTAINERNAME /app/bin/caddy -c /app/configs/Caddyfile` (replace `podman` with `docker` in case you're running Docker)

## Contributing

Feel free to do so if you feel like something is wrong, just explain why as I'm still taking jabs at Dockerfile so I might not understand few things still. It might be better to make a issue first though - [Github repository](https://github.com/Rubberverse/qor-caddy)
