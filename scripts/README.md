# Helper scripts

Just scripts that help do some boring stuff inside the builder image. They're re-usable across my projects and I find them better than putting whole shell script into Dockerfile/Containerfile itself.

As of `v0.19`, building process was revamped to not make use of `xcaddy` and instead it uses `main.go` present in Caddy's repository instead. Was done mostly as a challenge for myself while I was learning bash scripting and I guess while not that great, it works quite well.

## install-go.sh

Pulls latest version of Go for your architecture from [go.dev](https://go.dev). They're official pre-built binaries to my knowledge. It also sets git `safe.directory` to be a wildcard which means 'any location is considered safe'. This is to workaround problems during build, primarly git failing as it considers `/app` not a safe directory. (or whatever the problem was, I don't remember)

This script will run in Debian-based runners and probably won't be able to properly pull some architectures. Needs some normalization, eventually I'll update it to do it better. It makes use of `jq`, `dpkg --print-architecture`, `awk`, `tar`, `git` and `curl`

## array-helper.sh

`array-helper.sh` is a poor-man's version of `xcaddy`. It kinda does the same thing as `xcaddy` but in bash script form. Kinda. It's still somewhat the same... maybe.

The ability to pull caddy-defender and configure it was added in `v1.2` of the script. This will only take effect if `$CADDY_DEFENDER` equals `1`, otherwise it's skipped. Passing `CADDY_DEFENDER=1` implies you want to build your own version of the module.

1. Checks environment variables (aka. build arguments) before starting
2. Parses `CADDY_MODULES` environment variable into an array
3. Appends extra modules from `CADDY_MODULES_ARR` into `main.go`
4. Pins Caddy version from `GO_CADDY_VERSION` using `go get`
5. (optional) Manually pulls `caddy-defender` from JasonLovesDoggo's GitHub repository and sets it as a local import
6. Runs `go mod tidy` to add module requirements and generate `go.sum`
7. (optional) Fetches TOR relays and ASN ranges of your choice for `caddy-defender`

## entrypoint.go

Rewritten version of `docker-entrypoint.sh` in Go. It checks environment variables, cleans them up, sanitizes them then just runs the Caddy binary.

As to why not just have the normal `docker-entrypoint.sh` script, that wouldn't work here as I'm using `scratch` image as runner. `scratch` is exactly that - scratch image. It's empty, has no interactive/non-interactive user shell so container simply exploded if it tried to run it. There's also a helper function in it that's pretty pointless but you can use it to reload caddyfile configuration. You can run it by running ex. `podman exec -t qor-caddy /app/entrypoint --reload /app/config/caddyfile` (Runs `/app/bin/caddy reload -c $configPath`, just run that instead.)

*Unfortunately* I've used a bit of LLM help for this one. An eventual clean-up of it is under-way.
