## What's this repository about?

Singular Dockerfile `Caddy.Dockerfile` that spins up [xcaddy](https://github.com/caddyserver/xcaddy), builds plugins from a list and then runs on a rootful/rootless user inside the container and all by using either (**WIP**) Debian-Slim or Alpine-Linux image as it's base.

> [!WARNING]
> This shouldn't be used in production yet as I had no chance to test it throughoughly. Though if you want to test it, feel free to do so, it's probably fine to use.

## Built images (using Github Actions)

These images include most commonly wanted DNS plugins for following services: Cloudflare, Route53, DuckDNS, AliDNS, GoDaddy, Porkbun, Google Domains, Namecheap, Netlify, Azure, AcmeDNS, Vercel, Namesilo, DDNSS, MailInABox and some popular/useful plugins such as Vulcain, Mercure, ProxyProtocol, CorazaWAF, Layer4 support, Replace Response, Brotli, Teapot Module, DynamicDNS and Caddy-Security. 

Due to this, the size of the final image might be a lot more than you're prepared for, although it shouldn't be too bad. The nature of this repository is so you can do `git pull` and locally build yourself a image with anything you want, it's simple and everything is outlined in How-To's.

*psst*, in order to launch the container after pulling you need to specify two environmental variables - `CADDY_ENVIRONMENT` and `CONFIG_ADAPTER`. CADDY_ENVIRONMENT takes three values - TEST, LOCAL, PROD and CONFIG_ADAPTER takes caddyfile or json as arguments.

## Features
This Dockerfile may use some unconventional methods to achieve it's goals. You've been warned!

- Customizable and very easily modifiable to your own tastes, most things can be changed during build process with build arguments, the rest with environmental variables
- Version agnostic, you can use any specific version of `Caddy` and `Alpine Linux` image, by default it will always be latest version
- Easily build Caddy with any plugin you would ever want just by putting repository links in `templates/template.MODULE`
- Makes use of new and well, probably undocumented `Dockerfile` trickery/workarounds
- If using our built images, it will already have everything you would want, probably. :)

## How-To's

(**WIP**) Available build arguments and how to use them during build - [Build Arguments](github.com/Rubberverse/qor-caddy/main/BuildArguments.MD)

(**WIP**) List of environmental variables can be found [here](https://github.com/Rubberverse/qor-caddy/main/Environment.MD)
