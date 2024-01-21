## What's this
Singular Dockerfile `Caddy.Dockerfile` that spins up [xcaddy](https://github.com/caddyserver/xcaddy), builds plugins from a list and then runs on a rootful/rootless user inside the container. 

It makes use of Alpine Linux as it's base, allowing you to reap all advantages of file size and performance you're used to!

> [!NOTE] 
> This is both data and resource heavy during building process, if you want only Caddy and nothing else, it is recommended to build `vanillaCaddy.Dockerfile` instead which will be up soon on this repository

## Why was this created?
Ah, it's hard to answer this but I'll try my best. 

**First**, this was created because I gotten tired of Caddy containers that were just at best a singular extra plugin and nothing else with no real way to extend it aside from modifying their own Dockerfile. Which at that point you're better off throwing something up yourself with how much you would need to change.

**Secondly**, I wanted something that I could use to spin up specifc Caddy instances with exact plugins that I would want during build time. 

**Third-ly**, I wanted to learn Dockerfile format by throwing myself into deep water. Somewhat worked out, I think?

**Thus**, QoR-Caddy was born, a project that aims to be version agnostic and make it as easy as just pasting links into a file and then building out the image from Dockerfile without having to modify **anything** about it.

Everything on container side is already set-up and ready for you to build your own customized Caddy instance.

## Features
This Dockerfile may use some unconventional methods to achieve it's goals. You've been warned!

- Customizable and very easily modifiable to your own tastes, most things can be changed during build process with build arguments, the rest with environmental variables
- Version agnostic, you can use any specific version of `Caddy` and `Alpine Linux` image
- Easily build Caddy with any plugin you would ever want just by putting repository links in `templates/template.MODULE`
- Makes use of new and well, probably undocumented `Dockerfile` trickery/workarounds

---

## Build Arguments
You can pass the following arguments to `podman build`/`docker build ` in order to customize your image further.

`ALPINE_VERSION` -> Alpine container image version. Defaults to `3.19.0`

`CADDY_VERSION` -> Caddy Web Server version, it will be built using `xcaddy`. Defaults to `2.7.0`

`BUILD_VERSION` -> QoR-Caddy container version. Defaults to `0.10`

`SHELL` -> Shell environmental variable, this is so bash and other software doesn't get confused. Defaults to `/bin/bash`

`USER` -> Container user that will be created. Defaults to `caddy`

`GROUP` -> Container user's group that will be created. It is created first then container user is joined towards it. Defaults to `web`

`HOME` -> Container user's Home directory. Defaults to `/app`

`UID` -> Container's User ID. To avoid permission issues, map it to your host users UID. Defaults to `1001`

`GID` -> Container's Group ID. To avoid permission issues, map it to your hosts group ID. Defaults to `1001`

`GOPATH` -> Place where Go will store most of it's stuff. Defaults to `/app/go`

`GOCACHE` -> Place where Go will store it's build/module cache. Defaults to `/app/cache`

`GITDIR` -> Place where Git will store it's pulls and what not. Defaults to `/app/git`

`GITWORKTREE` -> Place where Git will store it's work tree. Defaults to `/app/tree`

---

## Super not-tidy-way-to-convey-usage

> [!WARNING] 
> This is work-in-progress, not recommended to use it on production as I haven't had chance to throughoughly test it yet

Eventually I'll get around to updating it properly and then it should be fine.

### Required files

You'll need everything in this repo in order to succesfully build this image, so it is recommended to just pull this repository with git or similar.

### Customization

If you want to customize modules that will be adding during `alpine-builder` stage, modify `templates/template.MODULES` to include any specific module you want. 

**Each repository needs to be on seperate line**, like this:

```ini
# template.MODULES
github.com/caddy-dns/cloudflare
github.com/corazawaf/coraza-caddy
```

> [!NOTE] 
> You can also leave this blank just to build Vanilla Caddy with no extra modules

### Building the image

Building the image might take a bit due to building of Caddy and plugins. The speed will depend on how fast your CPU is at doing such tasks!

Please ensure that additionally you have **at least** 2GB of free space to temporarily allocate for building process that will happen on `alpine-builder` stage!

**Stock, no modifications**

Build target should be `qor-caddy`, otherwise it will build just the builder.

```bash
$: podman build -f Caddy.Dockerfile --target qor-caddy
```

**Intermediary Image clean-up example**

If you want to get rid of intermediary images and free up ~350MB then run following command instead

```bash
$: podman build -f Caddy.Dockerfile \ 
    --target qor-caddy \
    && podman image prune -f --filter label=stage=alpine-builder
```

**Build Argument example**

This just shows how you can pass build arguments to `podman build` / `docker build`

```bash
$: podman build -f Caddy.Dockerfile \
    --build-args alpine_version=3.18.5 \
    --build-args user=meowster \
    && podman image prune -f --filter lalbe=stage=alpine-builder
```

### Mounting Volumes

If you want to customize anything about the image after building it ex. your own Caddyfile mounted to the container, you can do so by using following directories

- `/app/configs/Caddyfile`

Mount your own Caddyfile into the container (recommended)

- `/srv`

You can use this directory to dynamically serve pages or static content. It's owned by container user.

### Environmental Variables

There are some environmental variables that are **required** and without them, container will fail to launch. Those variables are

- `ADAPTER_CONFIG`

This is for Caddy, it specifies what config adapter it should be using. If you plan on using Caddyfiles, just specify this as `caddyfile`

- `CADDY_ENVIRONMENT`

Needed for docker-entrypoint.sh script, based on the environment it will selectively launch you into a certain session. For example, `TEST` would launch the container as the `root` user and enable config watching so your modifications to Caddyfile would always be reflected.

---

## Unrelated

I have no idea about this software license thing but I've been using `MIT` for a while so eh, may as well? Let me know if it's wrong though as I'm not well versed in this.


