# Changelog

This changelog is updated everytime I feel like it, not a lot of things is going to get changed anymore so should be pretty tame for the time being.

## v0.20.0

- Minor: Add Porkbun DNS module (caddy-dns/porkbun)
- Minor: Add Umami Caddy module (jonaharagon/caddy-umami)

## v0.19.5

- Patch: Update dependencies to fix following CVEs: CVE-2024-24790, CVE-2024-24789

## v0.19.4 (retag: v0.19.3)

- Version Bump: Caddy v2.8.4

## v0.19.3

- Version Bump: Caddy v2.8.0

## v0.19.2

- Patch: Update dependencies to fix following CVEs: CVE-2023-42365
- Version Bump: Caddy v2.8.0-rc.1

## v0.19.1 

- Fix: Remove `ADAPTER_TYPE` and don't force it as a parameter, allows usage of caddy.json
- Version Bump: Caddy v2.8.0-beta.2

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
