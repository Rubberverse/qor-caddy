## 🦆 Rubberverse Container Images

![Image Tag](https://img.shields.io/github/v/tag/Rubberverse/qor-caddy) ![License](https://img.shields.io/github/license/Rubberverse/qor-caddy)

Not sure what to pull? Check currently available [images](https://github.com/Rubberverse/qor-caddy/pkgs/container/qor-caddy).


## Features

- Debian builder, scratch runner
- Ready for cross-compilation
- Easy to spin up your own image
- No `s6-overlay`, `gosu` or other rootful container init
- Doesn't use `xcaddy`
- [Includes third-party Caddy modules](https://github.com/Rubberverse/qor-caddy?tab=readme-ov-file#list-of-third-party-caddy-modules)


## Structure + dependencies

Everything inside `/scripts/` is used during build process and it's usage is explained [here](https://github.com/Rubberverse/qor-caddy/tree/main/scripts)

- `/.github/workflows/build-release.yaml`
- `/scripts/array-helper.sh` (dep)
- `/scripts/install-go.sh` (dep)
- `/scripts/entrypoint.go` (dep)
- `Containerfile`

The usual simple bash entrypoint script was turned to `entrypoint.go`, as scratch runner doesn't have any shell, or anything for that matter. This allows slightly more advanced usage while still being more secure compared to typical image.


## Runner env variables

| Variable          | Default Value        | Required? |
|-------------------|----------------------|-----------|
| `CONFIG_PATH`     | `Empty`              | Yes       |
| `DEPLOY_TYPE`     | `"prod"`             | No        |
| `EXTRA_ARGS`      | `Empty`              | No        |

### Env: `CONFIG_PATH`

Needs to point to full path inside the container where `Caddyfile` or `caddy.json` is currently mounted. Example: `CONFIG_PATH=/app/configs/Caddyfile`

### Env: `DEPLOY_TYPE`

Can be `prod` or `dev`. `dev` allows for live configuration reloading, where `prod` doesn't. They also use two distinctive commands that also have different CLI parameters available to them.

### Env: `EXTRA_ARGS`

Mostly useful if `DEPLOY_TYPE=dev`. Allows specifying extra arguments to pass to Caddy before launching it. 


## Build-time env variables

| Variable           | Default Value        															| Required? 				|
|--------------------|----------------------------------------------------------------------------------|---------------------------|
| `CADDY_MODULES`    | `""`                 															| Yes 						|
| `GO_CADDY_VERSION` | `""`                																| Yes 						|
| `GO_MAIN_FILE`     | `"https://raw.githubusercontent.com/caddyserver/caddy/master/cmd/caddy/main.go"`	| Yes 						|
| `CADDY_DEFENDER`   | `""`																				| No        				|
| `ASN_RANGES`       | `""`																				| Only if CADDY_DEFENDER=1 	|
| `DEBUG`            | `""`																				| No                        |
| `TARGETOS`         | Set by builder																	| No						|
| `TARGETARCH`       | Set by builder																	| No						|
| `CGO_ENABLED`		 | `"0"`																			| No        				|
| `PATH`			 | `"/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/go/bin:/usr/local/go:/app/go/bin"`    | No        				|

### Build Arg: `CADDY_MODULES`

Space-seperated list of Caddy modules to build the image with. Pass `0` to this variable if you want to build vanilla Caddy. If you will add more than one module, wrap it in quotation marks. Usage example: `--build-arg=CADDY_MODULES="example.com/org/module1 example.com/org/module2"`

### Build Arg: `GO_CADDY_VERSION`

Pins Caddy to version specified in this variable, otherwise it will just figure it out by itself (and probably download way older version). Usage example: `--build-arg GO_CADDY_VERSION=v2.10.2`

### Build Arg: `GO_MAIN_FILE`

Original `main.go` from Caddy repository. Changing this is not advised unless you wanna host it somewhere else. Needs to be an URL accessible by builder. Usage example: `--build-arg GO_MAIN_FILE="https://raw.githubusercontent.com/caddyserver/caddy/master/cmd/caddy/main.go"`

### Build Arg: `CADDY_DEFENDER`

Pass any value to this to customize how caddy-defender module is built into the container image. Used in later steps to add TOR relays and ASNs of your own choice. Set it to `1` if you're going to use caddy-defender and want to add extra ASNs. Usage example: `--build-arg CADDY_DEFENDER=1`

### Build Arg: `ASN_RANGES`

Put ASN ranges here that will be able to be blocked using caddy-defender later on. Comma seperated list. Usage example: `--build-arg ASN_RANGES="ASN69,ASN420,ASN1337"`

### Build Arg: `DEBUG`

Prints out values of variables as array-helper.sh script continues, aids with debugging. Doesn't do anything else otherwise. The existence of this value is enough to turn it on so set it to anything. Usage example: `--build arg BUILD_DEBUG=balls`

## Manually building

It's as simple as three steps. Add more build args if you need them, customize ones here if you have specific needs otherwise you'll just build a vanilla Caddy image.

1. `git clone https://github.com/rubberverse/qor-caddy`
2. `podman build -f Containerfile -t localhost/qor-caddy:latest --build-arg=CADDY_MODULES="0" --build-arg=CADDY_VERSION=v2.10.1`
3. Voila, you now have your own customized Caddy image.

## Image tags

| Base    | Tag(s)              | Arch     | Description                																	|
|---------|---------------------|----------|------------------------------------------------------------------------------------------------|
| scratch | `latest`, `$tag`    | `x86_64` | Stable branch Caddy builds 																	|
| scratch | `test`              | `x86_64` | Test builds whenever something breaks and I wanna test it quickly. Barely updated, don't use. 	|

They may sometimes change, randomly have a module removed or added. Don't depend too much for them, you're recommended to instead `git clone` this and spin up your own image.

## Using the image via Rootless Podman (Quadlet, Recommended)

1. Copy [Rootless.container](https://github.com/Rubberverse/qor-caddy/blob/main/Rootless.container) from this repository and paste it in `~/.config/containers/systemd/user/Caddy.container`
2. Edit it to your own liking, most is already set-up for you.
3. Reload systemctl user daemon with `systemctl --user daemon-reload`
4. Start the container with `systemctl --user start Caddy`

## Using the image via Rootful Podman (Quadlet)

1. Copy [Rootful.container](https://github.com/Rubberverse/qor-caddy/blob/main/Rootful.container) from this repository and paste it in `/etc/containers/systemd/0/Caddy.container`
2. Edit it to your own liking, most is already setup for you.
3. Reload systemctl daemon with `systemctl daemon-reload`
4. Start the container `systemctl start Caddy`

## Useful things to know

I'm a hamburger. (This was made as I wanted to challenge my crappy bash scripting skills)

Bruger. (And also because majority of Caddy images out there don't really provide a standarized directory, so every container was completely different place Caddy web server wrote to.)

Hammed burger. (It works for my use-case and you're generally recommended to use this to build your own image out of this as I change a lot off things sometimes.)

## List of third-party Caddy modules

```bash
- github.com/mholt/caddy-ratelimit
- github.com/relvacode/caddy-oidc
- github.com/fvbommel/caddy-dns-ip-range
- github.com/WeidiDeng/caddy-cloudflare-ip
- github.com/fvbommel/caddy-combine-ip-ranges
- github.com/corazawaf/coraza-caddy/v2
- github.com/caddy-dns/cloudflare
- pkg.jsn.cam/caddy-defender
- github.com/mholt/caddy-l4/layer4
- github.com/porech/caddy-maxmind-geolocation

```

Any issues involving third-party modules should be reported to the module's respective repository, not to Caddy maintainers. In case the issue comes from my image, create an issue about it here!

