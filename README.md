## Rubberverse container images

**Currently supported build(s)**: v0.18.1-alpine, v0.18.1-debian "Cloudberry" (rolling release), built upon v2.8.0-beta.2

This repository contains Dockerfiles and helper scripts for building Caddy from source by making use of `xcaddy`. 

If you're interested with what our Caddy images come by default, here's a list. Click on the names to visit their repositories and learn more on how to use them and what not.

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

## What each image tag/dockerfile represents

> [!WARNING]
> It is recommended to pull Debian image only if you need a certain architecture that's not provided by Alpine variant. Mostly due to the fact that Debian images are chonkier compared to Alpine ones, might reach 240MB+ with Debian.

| Directory | Tag(s) | Description | Architectures |
|-----------|------|-------------|-----------------------------------------------------|
| caddy-dfs-CC | latest-debian, latest-alpine, cc-caddy-binary | Built QoR-Caddy image with modules shown above. Dockerfiles are seperated for GitHub Cross-Compilation support with golang | x86_64, x86, ARM64v8, ARMv7, ARMv5, mips64le, powerpc64le, s390x |
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

**Exception being** anything past version v0.30.0 will change to v1.0.0 "release"

## Building your own image

See [Setup.md](https://github.com/Rubberverse/qor-caddy/blob/main/Setup.md)

## Troubleshooting

Please look at https://github.com/rubberverse/troubleshoot/blob/main/qor-caddy.md

## Contributing

Feel free to do so if you feel like something is wrong, just explain why as I'm still taking jabs at Dockerfile so I might not understand few things still. It might be better to make a issue first though.
