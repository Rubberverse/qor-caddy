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
