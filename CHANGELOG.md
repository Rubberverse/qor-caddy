# Changelog

## v0.19

- Major: Streamline building process so it's similar across our Dockerfiles, drop `xcaddy`
- Major: Build process dependency change, before: `git, bash, go, ca-certificates`, now: `jq, git, tar, bash, curl, file, ca-certificates`
- Minor: Add Target Architecture in the binary name ex. `caddy-arm64`
- Minor: Fetch Go binaries directly from [Go's website](https://go.dev/dl/)
- Fix: multi-architecture builds producing broken artifacts (once again...)
- Patch: Always run `apk upgrade`, `apt upgrade` on building step on Debian & Alpine images
- Repository: Update documentation
- Caddy binary version: 2.8.0-beta.2

## v0.18.1

- Caddy version: Caddy 2.8.0-beta.2

## v0.18.0

- Caddy version: 2.8.0-beta.1
- Various `docker-entrypoint.sh` improvements
- Dockerfile reformat and structural changes, better handle cross-compilation for GitHub workflows
- Different GitHub workflow so it builds and pushes both GHCR and Docker Hub images at the same time, to reduce time spent on the workflow
- Fix build process by adding a workaround to `array-script.sh` for Caddy version `v2.7.6`
- Fix user directory ownership being wrongly assigned, was `caddy:root` - now: `caddy:caddy`
- Reduce amount of plugins as otherwise it is hell troubleshooting everything

## v0.17.1 - v0.12

- Obsolete, not recommended using them at all. They run outdated caddy builds, modules and are vulnerable to a lot of security problems, later revisions run rootful too.
