## 🛠️ Build Arguments

**Non-Image Specific**

- IMAGE_REGISTRY

From what registry to pull our image from, ex. docker.io, ghcr.io, quay.io



**Alpine Dockerfile**

- IMAGE_ALPINE_VERSION

Apart of $IMAGE_REPOSITORY, pulls specific version of Alpine Linux image from the image repository specified before

- ALPINE_REPO_URL

Used in every `apk add` statement, allows specifying a mirror repository that will be used to pull the required packages from

- ALPINE_REPO_VERSION

Used in every `apk add` statement, allows specifying repository version so you can use edge repository on ex. v3.19(.1)

**Build Time**

- GO_XCADDY_VERSION

Passed to `go install`, will grab this specific version of `xcaddy`

- GO_CADDY_VERSION

Used by `xcaddy` to pull certain `Caddy` version while building

- XCADDY_MODULES

Passed to `array-helper.sh` script which parses it and builds out `xcaddy build` command with modules listed here. Modules should be seperated by space and be valid links to module repository.

**Post Build**

- CONT_USER

Creates a container user with name specified

- CONT_UID

Creates a container user with following UID specified