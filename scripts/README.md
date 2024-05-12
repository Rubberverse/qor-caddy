# Helper scripts and Image entrypoint

As of `v0.19`, building process was revamped to not make use of `xcaddy` and instead it uses `main.go` present in [Caddy's repository]() instead. This allows for better control over building than what `xcaddy` could provide us with, even if arguably minimal.

## array-helper.sh

`array-helper.sh` is a poor-man's version of `xcaddy`. In other words, it does about the same as xcaddy but in bash script form while also missing 50% of it's features. However, it still works about how you would expect it to and in a manner that's (somewhat) lightweight!

Here's what it does in a nice compact numbered list

1. Checks if environmental variables are valid before starting
2. Creates necessary variables and files that are only used during build process
3. Parses environmental variable CADDY_MODULES into an array
4. Modifies `main.go` to include modules from array
5. Pins Caddy version using `go get`

## docker-entrypoint.sh

`docker-entrypoint.sh` is a entrypoint script for our image. It does about your usual, checks validity of some environmental variables and does stuff based on it.

Since this whole project ended up becoming somewhat overcomplicated the more I started working on it, the more a need for a entrypoint script became a necessity as various requirements have been introdued and what not.

