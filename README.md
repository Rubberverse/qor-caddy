## Rubberverse container images

This repository contains Dockerfiles specific for building and running `qor-caddy` image. It's our customized image that runs builds Caddy with custom modules (also known as plugins) and is maintained by MrRubberDucky (same username on Discord)

This image bundles following moduels by default, in order to know how to use them, consider checking out their repositories. If you would like a extra module you need to be added to this image, create a Issue with [FEATURE REQUEST] in the title.

>[!NOTE]
> Google Domain DNS plugin is removed as of v0.17.0 due to Google Domains being axed by Google and every domain registered under it going under Squarespace. On a side note, Layer4 module is still here, just bundled under Caddy Crowdsec Bouncer

- [Cloudflare DNS](https://github.com/caddy-dns/cloudflare)
- [Route53 DNS](https://github.com/caddy-dns/route53)
- [DuckDNS](https://github.com/caddy-dns/duckdns)
- [AliDNS](https://github.com/caddy-dns/alidns)
- [GoDaddy DNS](https://github.com/caddy-dns/godaddy)
- [Porkbun DNS](https://github.com/caddy-dns/porkbun)
- [Gandi DNS](https://github.com/caddy-dns/gandi)
- [Namecheap DNS](https://github.com/caddy-dns/namecheap)
- [Netlify DNS](https://github.com/caddy-dns/netlify)
- [Azure DNS](https://github.com/caddy-dns/azure)
- [AcmeDNS](https://github.com/caddy-dns/acmedns)
- [Namesilo DNS](https://github.com/caddy-dns/namesilo)
- [DDNNSS](https://github.com/caddy-dns/ddnnss)
- [MailInABox DNS](https://github.com/caddy-dns/mailinabox)
- [Dynamic DNS](https://github.com/mholt/caddy-dynamicdns)
- [Coraza WAF for Caddy](https://github.com/corazawaf/coraza-caddy)
- [Caddy Security](https://github.com/greenpau/caddy-security)
- [Teapot Module](https://github.com/hairyhenderson/caddy-teapot-module)
- [Vulcain for Caddy](https://github.com/vulcain/caddy)
- [Mercure for Caddy](https://github.com/mercure/caddy)
- [Replace Response](https://github.com/caddyserver/replace-response)
- [Caddy Crowdsec Bouncer](https://github.com/hslatman/caddy-crowdsec-bouncer)

## What each image tag/dockerfile represents

- Dockerfile-Debian, Dockerfile-Alpine, `latest-debian`, `latest-alpine` -> Standard QoR-Caddy images, they're what's pushed to GitHub Container Registry and Docker Registry
- Dockerfile-Helper, `latest-helper-dev` -> This image is used to build multi-architecture artifacts for images
- Dockerfile-itxcaddy, `latest-itxcaddy` -> Interactive xcaddy environment, by default does nothing. Comes bundled with `array-helper.sh` script that will parse XCADDY_MODULES environmental variable and run xcaddy command
- Dockerfile-nxcaddy, `latest-nxcaddy` -> Non-interactive variant of xcaddy environment, this expects you to provide modules via XCADDY_MODULES and all it will do is build Caddy with it. Less useful than `itxcaddy` but it's whole purpose is to easily create your own Caddy binary

## Image versioning

Images use following versioning:
vY.XX.ZZ

- Y includes version type, 0 is considered "beta"
- XX Includes Major & Minor changes
- ZZ Includes Patches

They will always be one higher than the previous ex. if a patch releases and prev version was v0.16.0, the next one will be v0.16.1.

**Exception being** anything past version v0.30.0 will change to v1.00.0 "release"

## Building your own image

>[!NOTE]
> Available build arguments can be found [here](https://github.com/rubberverse/blob/main/build.md)

1. Either merge both `Dockerfile-Helper` and Dockerfile-OS together or build them seperately. Keep in mind that Dockerfile-Helper is split for the sake of speeding up GitHub workflow, otherwise it used qemu which was dreadfully slow so you may need to change the Dockerfile a bit till it works.
2. Build the image by passing following build command 
3. Run the image

```bash
podman build -f Dockerfile-Alpine --build-args XCADDY_MODULES="github.com/caddy-dns/cloudflare github.com/hslatman/caddy-crowdsec-bouncer"
```

## Troubleshooting

Please look at https://github.com/rubberverse/troubleshoot/qor-caddy.md

## Contributing

Feel free to do so if you feel like something is wrong, just explain why as I'm still taking jabs at Dockerfile so I might not understand few things still. It might be better to make a issue first though.
