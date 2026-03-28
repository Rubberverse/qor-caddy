# Helper scripts

Just scripts that help do some boring stuff inside the builder image. They're re-usable across my projects and I find them better than putting whole shell script into Dockerfile/Containerfile itself.

As of `v0.19`, building process was revamped to not make use of `xcaddy` and instead it uses `main.go` present in Caddy's repository instead. Was done mostly as a challenge for myself while I was learning bash scripting and I guess while not that great, it works quite well.

## install-go.sh

Pulls latest version of Go for your architecture from [go.dev](https://go.dev) + sets git `safe.directory` to `*`, which means 'any location is considered safe'. Worksaround a problem during go pull / build where git operations fail as it doesn't see build-time directories as trusted.

For now, this only runs in Debian-based runners, and may fail pulling some architectures. If one isn't available from go.dev, then it will fail. Needs a bit of normalization to make it work better.

Requires: `jq`, `dpkg --print-architecture`, `awk`, `tar`, `git` and `curl`. You may need to install `jq`, `git` and `curl` separately.

## array-helper.sh

To put it simply, it turns build argument `CADDY_MODULES` into something more useful for us. It also takes care of all the little steps that solutions such as `xcaddy` would handle for us without breaking a sweat. You may run into occassional build error with this but it mostly boils down to outdated dependencies on X module, so it clashes with more up-to-date dependency on Y module. The fix for that is to let the X module maintainer know of such incompatibility and maybe even help them update their dependencies to latest version.

Same script can be used to build "vanilla" Caddy without any extra third-party modules. You can also build against virtually any version, even `master` if you're so inclined. This script been evolving for around a year, maybe a year and a half by now and I'm happy with how it turned out. It works well. The point of it was to have something that allows me to control the build process till the very last step.

`v1.2` added ability to pull `caddy-defender` and configure extra options for it. By default, setting `CADDY_DEFENDER=1` will build caddy-defender module with TOR ranges, ASN is provided but it currently doesn't work, so don't use it.

1. Checks environment variables before starting (build args)
2. Parses `$CADDY_MODULES` into an array
3. Appends extra modules from the newly created `$CADDY_MODULES_ARR` into `main.go`
4. Pins Caddy version from `$GO_CADDY_VERSION` using `go get`
5. **IF** `$CADDY_DEFENDER=1`: Pulls `caddy-defender` from JasonLovesDoggo's GitHub repository and sets it as a local import
6. Runs `go mod tidy` to add module requirements and generate `go.sum`
7. **IF** `$CADDY_DEFENDER=1`: Fetches TOR relays and optionally ASN ranges of your choice for `caddy-defender` and saves them.

## entrypoint.go

Rewritten version of `docker-entrypoint.sh` in Go. It checks environment variables, cleans them up, sanitizes them then just runs the Caddy binary. It's no longer used in the images and only left here as an example. You need to build it statically and then copy it over to your final image.
