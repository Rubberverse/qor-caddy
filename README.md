## What's this repository about?

Singular Dockerfile `Caddy.Dockerfile` that spins up [xcaddy](https://github.com/caddyserver/xcaddy), builds plugins from a list and then runs on a rootful/rootless user inside the container and all by using Alpine-Linux image as it's base. 

**BTW**, You need to pass `CADDY_ENVIRONMENT` and `ADAPTER_CONFIG` environmental variables to the container on launch otherwise it will fail. For more information about environmental variables, look at **How-To's** below.

> [!WARNING]
> This shouldn't be used in production yet as I had no chance to test it throughoughly. Though if you want to test it, feel free to do so, it's probably fine to use.

## Who is this for
- Lazy people (me, you're not lazy if you're here)
- People (also known as humans)
- People who don't have time (I sell clocks)
- People who have time (I buy clocks)
- Aliens (as a bribe)
- Pigeon that's spying on you in your window (recommendation: buy some window privacy films)

In other words, it's just here to make somebody's life easier testing their own Caddy plugins or maybe make it easier to go into production by including essential (imo) plugins into the mix. Also I guess if you want something that should never become old unless Caddy falls into obscrunity itself, or maybe the whole trend of contenarization dies because a new thing dropped etc. *You get the point* so I will not blabber here much.

## Features

**Image built by GitHub Actions**
- Various plugins for certain DNS providers by default - Cloudflare, Route53, DuckDNS, AliDNS, Gandi, Porkbun, Namecheap, Google Domains, Netlify, AcmeDNS, Vercel, Namesilo, DDNNSS, MailInAbox
- Useful plugins such as CorazaWAF, Caddy-DynamicDNS, Caddy2-ProxyProtocol, Caddy-Security, Caddy-Teapot-Module, Vulcain, Mercure, Replace Response and Caddy-Brotli
- Multi-Architecture Image, supports amd64, i386, arm64v8, amrv7, armv6, ppc64le, riscv64 and s390x
- Rootless user inside the container
- Built against Alpine Linux `edge` and `latest` Caddy

**Dockerfile itself**
- Build your own Caddy binary with any plugin you want by adding repository links in `template.MODULES` (without `https://`)
- Not bound to any version specifically, you can specify your own Alpine Linux image version and Caddy version using build arguments
- Specify your own user, group, uid and gid inside the final image with build arguments
- Makes use of Dockerfile trickery and workarounds to achieve lower image size - `alpine-builder` image is only 49MB big after building and `qor-caddy` is 92.7MB+ (due to Caddy binary being chonky post-build)

## How-To's

Available build arguments and how to use them during build - [Build Arguments](https://github.com/Rubberverse/qor-caddy/blob/main/BuildArguments.md)

(**WIP**) List of environmental variables can be found [here](https://github.com/Rubberverse/qor-caddy/main/Environment.MD)
