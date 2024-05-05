## 🛠️ Build Arguments

Here you can see most, if not all build arguments that are available during build time that you can use to configure the final image to your liking. Here's a example bullet point list of what you can configure

- Image Registry to pull from
- Specific Image version to pull
- Repository URL and specific version to pull from when it comes to Alpine Linux packages
- `xcaddy` and `caddy` version
- What modules will be built using `xcaddy`
- Container User and it's UID

The actual build arguments and short explanation can be found below

### Non-Image Specific

This part occurs before a image gets pulled from registry

- `IMAGE_REGISTRY`

From what registry to pull our image from

ex. docker.io, ghcr.io, quay.io

⚠️ Needs to be a valid registry where golang image is present

### Alpine Single-Arch & Multi-Arch Dockerfile

This is ran both during Alpine Builder stage and Alpine Dockerfile creation. Based upon choices here, extra needed packages will be fetched from different repository mirror.

- `IMAGE_ALPINE_VERSION`

Apart of `$IMAGE_REPOSITORY`, pulls specific version of Alpine Linux image from the image repository specified before

ex. ``v3.19``

- `ALPINE_REPO_URL`

Used in every `apk add` statement, allows specifying a mirror repository that will be used to pull the required packages from

ex. `https://dl-cdn.alpinelinux.org/alpine`

- `ALPINE_REPO_VERSION`

Used in every `apk add` statement, allows specifying repository version so you can use edge repository on

ex. `v3.19`, `v3.18`, `edge`

### Caddy Build

This occurs during building phase where `array-helper.sh` is summoned to parse `XCADDY_MODULES` into a command which then builds out Caddy with specific modules

- `GO_XCADDY_VERSION`

Passed to `go install`, will grab this specific version of `xcaddy`

- GO_CADDY_VERSION

Used by `xcaddy` to pull certain `Caddy` version while building

- XCADDY_MODULES

Passed to `array-helper.sh` script which parses it and builds out `xcaddy build` command with modules listed here. Modules should be seperated by space and be valid links to module repository.

### Post Build

Ran at the very end of both `Alpine` and `Debian` variant of the Dockerfiles. 

- `CONT_USER`

Creates a container user with name specified

- `CONT_UID`

Creates a container user with following UID specified