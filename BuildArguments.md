## Build Arguments

You can use following arguments during building phase of the image, they're more or so self-explonatory from the name. They're all build-time arguments but they're also available as a reference later on from the container itself.

| Argument         | Description                                                                                                                      |
|------------------|----------------------------------------------------------------------------------------------------------------------------------|
| `IMAGE_REPOSITORY`     | Default: `docker.io/library` - Where to pull Alpine Linux image from, should be a valid repository link and optionally path |
| `IMAGE_ALPINE_VERSION` | Default: `latest` - Specify a version of Alpine Linux image to pull from the repositry |
| `ALPINE_REPO_URL`      | Default: `https://cdn-dl.alpinelinux.org/alpine` - In case this repo becomes unavailable, you can repoint it to a mirror |
| `ALPINE_REPO_VERSION`  | Default: `v3.19` - Used for repositories, useful if your ALPINE_IMAGE_VERSION is something else other than stable repository ex. edge |
| `GO_XCADDY_VERSION`    | Default: `latest` - Pulls certain version of xcaddy source and builds it using `go install` |
| `GO_CADDY_VERSION`     | Default: `latest`. Builds Caddy binary during xcaddy building process                                                            |
| `CONT_SHELL`           | Default: `/bin/bash`. Controls what shell user and scripts will use                                                              |
| `CONT_HOME`            | Default: `/app`. Sets ${HOME} environmental variable for container user                                                          |
| `CONT_USER`            | Default: `caddy`. Used during user creation, can be anything. Will resolve to `${CONT_USER}` inside the container                |
| `CONT_GROUP`           | Default: `web`. Used during group creation, can be anything. Will resolve to `${CONT_GROUP}` inside the container                |
| `CONT_UID`             | Default: `1001`. Used during user creation. Suggest to set this to whatever matches your host user to avoid permission issues.   |
| `CONT_GID`             | Default: `1001`. Used during group creation. Suggest to set this to whatever matches your host group to avoid permission issues. |
| `GIT_DIR`              | Default: `/app/git`. Sets working directory for `git` to that location                                                           |
| `GIT_WORKTREE`         | Default: `/app/git`. Sets work tree directory for `git` to that location                                                         |
| `GO_BIN_DIR`           | Default: `/app/go` Sets where Go will store it's binaries |
| `GO_CACHE_DIR`         | Default: `/app/go/cache`. Sets module cache for `go` to that location                                                                  |
