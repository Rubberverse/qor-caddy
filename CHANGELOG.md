## v0.17.0-dev
- [Dockerfile] Remove echo comments
- [Dockerfile] Set ARG TARGETARCH properly
- [Dockerfile] Use edge image for Alpine Linux image
- [Dockerfile] Properly reuse ARG across Dockerfile
- [Build] Set capabilities on alpine-builder stage
- [Build] Apply optimizations to all go build xyz
- [Build] Don't chmod uselessly on alpine-builder stage
- [Build] Drop dependency on modifying the file, now modules are passed via ENV variable
- [Files] Stop including test Caddyfile, prompt users to mount their own instead
- [Files] Don't Modify /etc/shadow /etc/passwd
- [Scripts] Safety checks for array-helper.sh
- [Image] Add debian variant
- [Image] Retag latest to latest-alpine, latest-debian

## v0.16.0
- Revert: Created a dedicated logging directory in /apps/logs and serve directory /srv/www
- Created a dedicated logging directory in `/app/logs`
- Remove dependency from `bash`, script is now POSIX and should run on busybox `ash` shell that Alpine Linux uses. That said `bash` is also removed from the image now.
- Add more error checking and more understandable fault messages in entrypoint script
- Do not create a group
- Update and Upgrade apk repositories instead of manually fetching version we need
- Set capabilities on qor-caddy stage (they get lost after copying over from alpine-builder) 
- No longer need to pass `sysctl` to container

## v0.15.0
- Rebase version v0.31.0 -> v0.15.0 (tags were all over the place if I'm being honest)
- Normal versioning from now on, v0.15.0 increasing 0.1x.0 and up so ex. v0.11, v0.12, ..., v0.20.0
- Cross Compilation for GitHub workflow (speeds up build time tremendolously)
- Created a dedicated logging directory in /apps/logs and serve directory /srv/www
- Use this if you still want a bash shell (and older script)

## v0.12.0
- Initial working rootful version
- Deprecated (no support will be provided for it)
