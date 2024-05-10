# Changelog

## v0.18.1
- Built upon Caddy 2.8.0-beta.2

## v0.18.0

- Built upon Caddy 2.8.0-beta.1
- Various `docker-entrypoint.sh` improvements
- Dockerfile reformat and structural changes, better handle cross-compilation for GitHub workflows
- Different GitHub workflow so it builds and pushes both GHCR and Docker Hub images at the same time, to reduce time spent on the workflow
- Fix build process by adding a workaround to `array-script.sh` for Caddy version `v2.7.6`
- Fix user directory ownership being wrongly assigned, was `caddy:root` - now: `caddy:caddy`
- Reduce amount of plugins as otherwise it is hell troubleshooting everything

## v0.17.1 - v0.12
- Obsolete, not recommended using them at all. They run outdated caddy builds, modules and are vulnerable to a lot of security problems, later revisions run rootful too.
