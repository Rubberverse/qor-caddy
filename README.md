## What's this
Singular Dockerfile `Caddy.Dockerfile` that spins up xCaddy, builds modules listed in a file and then runs on a rootless user inside the container. It makes use of Alpine Linux as it's base, allowing you to reap all advantages of file size and performance you're used to! (I have no idea about this license thing but I've been using `MIT` for a while so eh, may as well? Let me know if it's wrong though)

> [!NOTE] 
> This is both data and resource heavy during building process, if you want only Caddy and nothing else, it is recommended to build `vanillaCaddy.Dockerfile` instead which will be up soon on this repository

## Features
This Dockerfile uses some unconventional, cursed and potentially unwanted modifications in order to achieve my primary goals with this image but that said, not all of them are that bad. 

Some are here to make our life easier :>

- Complete removal of root by modifying `/etc/passwd` and limiting permisisons to read-only on it (only for `caddy-local` and `caddy-prod` images)
- Version agnostic, you can use any specific version of Alpine Linux image & Caddy
- Multi-Stage build to optimize storage, nearly 95% reduction in size (once `alpine-builder` image is removed)
- Removal of `ash` shell that comes by default with Alpine Linux, this image uses `bash` instead (2-3 extra MB)
- Rootless by design, container runs as a unprivileged user (exception being `caddy-test` image)
- Build Caddy along with any module you want by inserting repositories of the modules in `template.MODULES`


## Build args
You can pass the following arguments to `podman build`/`docker build ` in order to customize your image further.
- `ALPINE_VERSION` -> Controls what Alpine Version will be used for base image and builder image
- `CADDY_VERSION` -> Passed as a argument to `xcaddy`, builds specific version of Caddy.
- `BUILD_VERSION` -> Internal, for container tagging purposes
- `USER` -> Specify the user that will be created inside the container
- `GROUP`-> Specify the group that will be created inside the container, $USER will be joined to it
- `UID` -> UID of the container user, if you want to avoid permission issues with mounts under linux then it's recommended to set it to your own users' UID
- `GID`-> same as above but replace UID with GID :3

## Super not-tidy-way-to-convey-usage

> [!WARNING] 
> Not really recommended to use this image for production yet!

Eventually I'll get around to updating it properly and then it should be fine.

### Required files

This expects you to have following directories ready with following files that are currently missing from the repo

- `configs/testing.Caddyfile`
- `configs/local.Caddyfile`
- `configs/prod.Caddyfile`

They're just your typical Caddyfiles so they can contain anything - a test site or something else.

You then can pull this repo with github or whatever and run following command to build a image of your choice (I use Podman but Docker should be the same)

### Customization

If you want to customize modules that will be adding during `alpine-builder` stage, modify `template.MODULES` to include any specific module you want. 

**Each repository needs to be on seperate line**, like this:

```ini
# template.MODULES
github.com/caddy-dns/cloudflare
github.com/corazawaf/coraza-caddy
```

> [!NOTE] 
> You can also leave this blank just to build Vanilla Caddy with no extra modules

### Building the image

You can choose between `caddy-test`, `caddy-local` and `caddy-prod` as your target.

```bash
$: podman build -f Caddy.Dockerfile --target caddy-test
```

If you want a more customized build with automatic purge of `alpine-builder` image(s), you can run something similar to this command. 

Every build argument specified before can be used!

```bash
$: podman build -f Caddy.Dockerfile \ 
    --target caddy-test \
    --build-args alpine_version=3.18.5 \
    --build-args user=meowster \
    && podman image prune -f --filter label=stage=alpine-builder
```

Afterwards, clean up the intermediary build image with following command

```bash
$: podman image prune -f --filter label=stage=alpine-builder
```

### Mounting Volumes

If you want to customize anything about the image after building it ex. your own Caddyfile mounted to the container, you can do so by using following directories

`/app/testCaddyfile`, `/app/localCaddyfile`, `/app/prodCaddyfile` - for Caddyfiles, do not mount entire `/app`!

`/srv` - To serve static webpages/sites from container

