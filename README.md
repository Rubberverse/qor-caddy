## What's this repository about?

This repository houses our Dockerfile that spins up xcaddy, builds Caddy along with plugins from a defined list and then runs on a rootless user inside the container. It makes use of Alpine Linux for low image size and some Dockerfile optimizations to not overbloat the final result. It's also version and even repository agnostic so you don't have to worry about anything, everything is customizable with [Build Arguments]()

Plus, it also acts as our modified repository for building our own customized version of Caddy image called `qor-caddy` which includes most commonly wanted plugins and latest version of Caddy. These images are always maintained by MrRubberDucky and while there's no guarantees, they're always updated with latest hotfixes and patches in case any security vulnerability happens, as long as a fix is already available. 

Images are also verified to ensure that they work on my local testing VM so you can always ensure that at minimum plugins will work just fine. No guarantees though.

You're free to use any images here, spin up your own images and overall contribute to this by posting issues, doing pull requests to fix some things etc.

## What's the purpose of this project?
- Lazy people (me)
- People (humans)
- People who don't have time (I sell clocks)
- People who have time (I buy clocks)
- Aliens (as a bribe)
- Pigeon that's spying on you in your window (recommendation: buy some window privacy films)

In other words, it's here to make your life easier. If you were like me and were searching for a Caddy image that had the plugin you need only to find out that in fact, it doesn't work, well... this is a solution to that problem. Maybe you want to test your plugin against a somewhat live-like scenario, it really depends what you're gonna do with this. Creativity and all, up to you.

While there are many, many Docker containers of Caddy, most of them are either abandoned or too personalized/undocumented for production use. This is also why qor-caddy as a project was born.

## What does your custom built Caddy image do?

In terms of features, nothing special but if that would be it, would I be writing this?

Mainly our image runs **rootless** meaning that container user has no privileges, we also additionally do some two modifications that may or may not do something to make escalating them further harder, although that's up for a debate.

They're also **multi-architecture** which for now supports following architectures: amd64, i386, arm64v8, amrv7, armv6, ppc64le and s390x. riscv64 will be supported the moment Alpine Linux has stable packages for it.

Uh... right. It also includes common plugins you would've probably liked to have but didn't want to go through the trouble of manually building caddy from source.

**Plugins included**: Cloudflare, Route53, DuckDNS, AliDNS, Porkbun, Namecheap, Google Domains, Netlify, AcmeDNS, Vercel, Namesilo, DDNNSS, MailInAbox for extra DNS options and Coraza WAF, Caddy-DynamicDNS, Caddy-Security, Vulcain, Mercure, Replace Response, Caddy-Teapot-Module for extra features/security.

## Environment Variables

These are required to have the container launch as of v0.11.0

`CONFIG_PATH` - This is in case you mounted the config somewhere else in the container or using different one than Caddy, by default the location should be `/app/configs/Caddyfile`

`ADAPTER_TYPE` - Specify config adapter type for Caddy to use, should be one of these: `caddyfile`, `json`, `yaml`

`CADDY_ENVIRONMENT` - In what type of environment you will be running this in, it can either be `PROD` or `TEST`. TEST environment will launch the web server as root with config watching.

## How-To's

Available build arguments and how to use them during build - [Build Arguments](https://github.com/Rubberverse/qor-caddy/blob/main/BuildArguments.md)

Setup guide - [here](https://github.com/Rubberverse/qor-caddy/blob/main/Setup.md)

## Some planned Dockerfiles and what not

- `qor-xcaddy`  - Simple interactive container that bundles `git`, `xcaddy` and `ca-certificates` for testing out plugins (~335MB image due to build deps for xcaddy)
- `qor-builder` - Standalone alpine-builder image that can be referenced in your images. probably gonna be a thing idk
- `qor-scaddy`   - As low as possible image size vanilla Caddy image
