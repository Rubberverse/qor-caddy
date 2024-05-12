## 🛠️ Build Arguments

Here you can see most, if not all build arguments that are available during build time that you can use to configure the final image to your liking. Here's a example bullet point list of what you can configure


The actual build arguments and short explanation can be found below

### Repository / Download Managment

- `ALPINE_REPO_URL`

Alpine package mirror repository, can either be main one or a mirror. As long as it's valid and Alpine package manager can pull from it.

Default: `https://dl-cdn.alpinelinux.org/alpine`

- `ALPINE_REPO_VERSION`

Full version that's present in package repository to pull packages from

Default: `v3.19`, can be changed to `edge` if so inclined!

- `REMOTE_URL`

Remote URL of a place that stores the `main.go` file that's used to build Caddy with extra modules

Default: `https://raw.githubusercontent.com/caddyserver/caddy/master/cmd/caddy/main.go`

### Arguments passed to array-helper.sh

Little script that does a bit of work in making the dream work. Parses the environmental variable into array, modifies the `main.go` file and so on.

- `CADDY_MODULES`

List of modules you want to compile with, these modules can't have version affixed to them ex. `github.com/rubberverse/test@version` and can't have trailing `https://` at the front.

Default: `""`, script expects at least value that's `0` or `"module1 module2"`.

Do not add quotation marks around module names as they'll be added automatically via the script!

- `GO_CADDY_VERSION`

Pin-points a specific Caddy release and builds against it, it is very **not** recommended to leave it at default as it might not even build and even if it does, it probably won't be suitable for production use.

Default: `master`

### Arguments passed to builder

This part is used when `go build` is ran, which is right after `array-helper.sh` finishes doing it's work.

- `GO_BUILD_FLAGS`

You can add some extra flags here that will be used during `go build` process. This may or may not work well and it's not possible to use this in order to configure `-ldflags` value as it's forced. (As to why, for some reason build process just broke when it was in environmental variable)

Default: `-trimpath`

- Platform-specific `TARGETOS` and `TARGETARCH`

Those are automatically made to reflect your host in case no argument is specified. Otherwise you can specify target operating system and architecture from here, Go will use cross-compilation to create your binary.

These can be passed to the builder using `--os` and `--platform` alike. 

Might not be present in `sarch` variants!

### Working directories (for alpine-builder stage)

- `GOCACHE`

Here are the cache files stored from Go, that's implying that Go even cares about environmental variables and doesn't write them somewhere else.

Default: `/app/go/cache`

- `GIT_WORKTREE`

Specifies where git creates it's worktree

Default: `/app/worktree`

