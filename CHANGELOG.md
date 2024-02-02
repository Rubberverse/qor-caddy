# Release

**Currently supported build**: v0.17.0 "Blueberry" (rolling release)

#### v0.17.0 codename "Blueberry" (supported)
- Split `alpine-builder` into a seperate Helper image to speed up GitHub cross-compilation workflow
- Fix various inconsistencies in entrypoint and array-helper scripts
- Correctly set capabilities so you no longer need to pass extra flags to the container
- Extra builder optimization(s)
- Introduce alternative tagging, drop `latest` and instead introduce `latest-debian` and `latest-alpine`
- More architectures are supported now, primarly support for riscv64 and mips64le is back again
- No longer including default Caddyfile with the image, mount your own at following location: `app/configs/Caddyfile`
- Addition of Caddy Crowdsec Bouncer, Removal of Google-Domains DNS (reason: service deprecation by Google, domains were transferred to Squarespace)
- Rewrite README.md so it makes sense and isn't just a bloat of words on your screen

#### v0.16.0 codename "Cranberry" (EOL - no support)
- Revert: Created a dedicated logging directory in /apps/logs and serve directory /srv/www
- Created a dedicated logging directory in `/app/logs`
- Remove dependency from `bash`, script is now POSIX and should run on busybox `ash` shell that Alpine Linux uses. That said `bash` is also removed from the image now.
- Add more error checking and more understandable fault messages in entrypoint script
- Do not create a group
- Update and Upgrade apk repositories instead of manually fetching version we need
- Set capabilities on qor-caddy stage (they get lost after copying over from alpine-builder) 
- No longer need to pass `sysctl` to container

#### v0.15.0 codename "Huckleberry" (EOL - no support)
- Rebase version v0.31.0 -> v0.15.0 (tags were all over the place if I'm being honest)
- Normal versioning from now on, v0.15.0 increasing 0.1x.0 and up so ex. v0.11, v0.12, ..., v0.20.0
- Cross Compilation for GitHub workflow (speeds up build time tremendolously)
- Created a dedicated logging directory in /apps/logs and serve directory /srv/www
- Use this if you still want a bash shell (and older script)
- Deprecated (no support will be provided for it)

### v0.12.0 codename "Gooseberry" (EOL - no support)
- Initial working rootful version
- Deprecated (no support will be provided for it)

# Pre-Release

#### v0.17.1-dev
- [Workflow] Fix out of space error when building multi-arch helper image
- [Workflow] Improve workflow logic although it still could be better, although I'm clueless on how to do it cleanly :/
- [Dockerfile] Split `alpine-builder` image for GitHub workflow so it can cross-compile at full speed
- [Dockerfile] Fix inconsistencies, ARGs being lost on build steps, caps not being applied and similar
- [Dockerfile] Turn ARGs into ENVs on xcaddy dockerfiles
- [Scripts] Fix sanity and error checking for array-helper.sh and docker-entrypoint.sh, also clean up formatting on them
- [Image] Optimize for storage space, well to the best of the extend. Modules alone bloat up the size to 145ish MB for Alpine Image and 245MBish for Debian Image

...and probably other things I forgot to document here. Look I'm tired, I've been working on this non-stop to ensure it works as best as it could.

#### v0.17.0-dev
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
