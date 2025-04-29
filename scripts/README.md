# Helper scripts, Go source code and other crap

As of `v0.19`, building process was revamped to not make use of `xcaddy` and instead it uses `main.go` present in Caddy's repository instead. This allows for better control over building than what `xcaddy` could provide us with, even if arguably minimal.

## install-go.sh

Pulls latest Go version from their website and downloads it, extracts and moves it to `/usr/local/bin/go`. It also sets safe.directory in git to a wildcard, meaning 'any', to workaround some problems during building.

## array-helper.sh

`array-helper.sh` is a poor-man's version of `xcaddy`. In other words, it does about the same as xcaddy but in bash script form while also missing 50% of it's features. However, it still works about how you would expect it to and in a manner that's (somewhat) lightweight!

Here's what it does in a nice compact numbered list

1. Checks if environmental variables are valid before starting
2. Creates necessary variables and files that are only used during build process
3. Parses environmental variable CADDY_MODULES into an array
4. Modifies `main.go` to include modules from array
5. Pins Caddy version using `go get`

## entrypoint.go

This is just rewritten `docker-entrypoint.sh` into Go that was also cleaned up along the way. It makes sure that environmental variables are set correctly, cleans them up and sanitizes them then just runs Caddy binary.

Container doesn't have a shell and we need to somehow execute the actual binary after checking for certain things, so this is a way to work around that problem.

