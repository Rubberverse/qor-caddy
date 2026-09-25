## 🦆 Rubberverse Container Images

![Image Tag](https://img.shields.io/github/v/tag/Rubberverse/qor-caddy) ![License](https://img.shields.io/github/license/Rubberverse/qor-caddy)

Not sure what to pull? Check currently available [images](https://github.com/Rubberverse/qor-caddy/pkgs/container/qor-caddy).

## Features

- Scratch runner
- Rootless container user with UID and GID of `1100`
- No container rootful init such as `su-exec`, `gosu` or `s6-overlay`
- Build process does not make use of [xcaddy](), instead it uses a [homemade bash script]()
- [Includes third-party Caddy modules](https://github.com/Rubberverse/qor-caddy?tab=readme-ov-file#list-of-third-party-caddy-modules)
- Easy to spin up your own image, just pass two build time arguments (or one!)

## Image tags

| Base    | Tag(s)                                         | Arch     | Description                									 |
|---------|------------------------------------------------|----------|--------------------------------------------------------------|
| scratch | `latest`, `ShortSHA256Commit`                  | `x86_64` | Stable branch Caddy builds /w third-party modules 			 |
| scratch | `latest-vanilla`, `vanilla-ShortSHA256Commit`  | `x86_64` | Stable branch vanilla Caddy build (no 3p modules)            |

They may sometimes change, randomly have a module removed or added. Don't depend too much for them, you're recommended to instead `git clone` this and spin up your own image.

## Usage

//TODO

I mean you can just pull it and use it like normal Caddy image. The binary is in `/app/bin/caddy` and `/app/configs/Caddyfile` is where it expects configuration by default. You can override container's `CMD` with `Exec=` in quadlet configuration. There is no need to add any capabilities, in fact you should drop them all by default with this image.

Caddy will create it's own configuration files inside `/app/.local` and `/app/.config`, logs should be written to `/app/logs` to keep consistency with the rest of the image and because rootless container user actually owns this directory and has read-write-execute rights on it.

`/app/templates/browse.html` is where the `file_server browse` template residues in. To use it, just pass the template as argument to any `file_server` directive. You can learn more about it in following repository: https://github.com/glowinthedark/caddy-file-server-browse-extension

```Caddyfile
    file_server {
        (...)
        browse /app/templates/browse.html
    }
```

## Structure, dependencies and technicalities

Debian Trixie is used as a builder. Reason for it being that Debian already includes everything one may need in it's apt repositories, I'm very familiar with Debian and for some projects - glibc is just faster that musl libc.

Everything inside `/scripts/` is used during build process, excluding the markdown README.

- `/scripts/array-helper.sh`

Array Helper script checks `${CADDY_MODULES}` and `${CADDY_VERSION}` and sets them back to default values in case they're blank. These default values are `none` for `${CADDY_MODULES}` and `master` for `${CADDY_VERSION}`.

In case `${CADDY_MODULES}` seems valid - it just needs to be value that's not `"none"` - it will proceed with reading it into an array `CADDY_MODULES_ARRAY` which is then iterated over in a `while` loop and all modules are temporarily written to `/usr/app/builder/caddy/temp.go`. After it's done, it will overwrite `main.go` with `temp.go`.

Then it pins Caddy version with `go get`, checks if a variable exists for `${CADDY_DEFENDER}` as that module needs it's own special configuration in case you want TOR relays included into it, and then runs `go mood init caddy` and `go mod tidy`.

In simpler terms, it does some sanity checking, sets some environment variables and then modifies a temporary file that's afterwards forcefully overwrites the main file and does the rest of the preparation to actually build Caddy out.

## Build-time env variables

| Variable           | Default Value        															| Required? 				|
|--------------------|----------------------------------------------------------------------------------|---------------------------|
| `CADDY_MODULES`    | `"none"`                 															| Yes 						|
| `CADDY_VERSION` | `"master"`                																| Yes 						|
| `GO_MAIN_FILE`     | `"https://raw.githubusercontent.com/caddyserver/caddy/master/cmd/caddy/main.go"`	| Yes 						|
| `CADDY_DEFENDER`   | `""`																				| No        				|

### Build Arg: `CADDY_MODULES`

Space-separated list of Caddy modules to build the image with. If you will add more than one module, wrap it in quotation marks. Usage example: `--build-arg=CADDY_MODULES="example.com/org/module1 example.com/org/module2"`

### Build Arg: `CADDY_VERSION`

Pins Caddy to version specified in this variable, otherwise it will just figure it out by itself (and probably download way older version). Usage example: `--build-arg GO_CADDY_VERSION=v2.10.2`

### Build Arg: `GO_MAIN_FILE`

Original `main.go` from Caddy repository. Changing this is **not advised** unless you wanna host it somewhere else. Needs to be an URL that's accessible by builder. Usage example: `--build-arg GO_MAIN_FILE="https://raw.githubusercontent.com/caddyserver/caddy/master/cmd/caddy/main.go"`

### Build Arg: `CADDY_DEFENDER`

Pass any value to this to add `caddy-defender` to the final image. Usage example: `--build-arg CADDY_DEFENDER=1`

## Manually building

It's as simple as doing three easy steps.

1. `git clone https://github.com/rubberverse/qor-caddy`
2. `podman build -f Containerfile -t localhost/qor-caddy:latest --build-arg=CADDY_MOODULES="github.com/caddy-dns/cloudflare github.com/corazawaf/coraza-caddy/v2"`
3. Voila, you now have your own customized Caddy image.

## Useful things to know

I'm a hamburger. (This was made as I wanted to challenge my crappy bash scripting skills)

Bruger. (And also because majority of Caddy images out there don't really provide a standarized directory, so every container was completely different place Caddy web server wrote to.)

Hammed burger. (It works for my use-case and you're generally recommended to use this to build your own image out of this as I change a lot off things sometimes.)

This will be maintained for as long as `rubberverse.xyz` is alive. So far this repository been going strong for two years.

## Where's `docker-compose.yaml`?

Long time ago, I've moved away from Docker to Podman. Initially, I've went the `compose.yaml` route. It was a bit hit or miss, `podman-compose` wasn't 1:1 with the spec and it was overall pretty miserable... that is, until Quadlet system was introduced and I feel in love with it.

As you can probably guess, I've forgotten majority of good conventions, and how to make a good `docker-compose.yaml`, which is why I didn't include it here. Another reason is that I see Docker as generally insecure, daemon always runs with root rights regardless of what you do unlike Podman where there's no daemon and you can run it fully non-root.

You're free to throw up your own compose file, though you won't find it here due to reasons outlined above.

## List of third-party Caddy modules

```bash
- github.com/glowinthedark/caddy-file-server-browse-extension
- github.com/mholt/caddy-ratelimit
- github.com/WeidiDeng/caddy-cloudflare-ip
- github.com/fvbommel/caddy-combine-ip-ranges
- github.com/caddy-dns/cloudflare
- github.com/hslatman/caddy-crowdsec-bouncer/http
- github.com/hslatman/caddy-crowdsec-bouncer/appsec
- github.com/hslatman/caddy-crowdsec-bouncer/layer4
- github.com/mholt/caddy-l4/layer4
- github.com/davidscarth/caddy-geoip
```

Any issues involving third-party modules should be reported to the module's respective repository, not to Caddy maintainers. In case the issue comes from my image, create an issue about it here!
