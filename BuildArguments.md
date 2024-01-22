## Build Arguments

You can use following arguments during building phase of the image, they're more or so self-explonatory from the name. They're all build-time arguments but they're also available as a reference later on from the container itself.

| Argument         | Description                                                                                                                      |
|------------------|----------------------------------------------------------------------------------------------------------------------------------|               
| `ALPINE_VERSION` | Default: `edge`. Builds the image using specific version of Alpine Linux image.                                                  |
| `CADDY_VERSION`  | Default: `latest`. Builds Caddy binary during xcaddy building process                                                            |
| `SHELL`          | Default: `/bin/bash`. Controls what shell user and scripts will use                                                              |
| `HOME`           | Default: `/app`. Sets ${HOME} environmental variable for container user                                                          |
| `USER`           | Default: `caddy`. Used during user creation, can be anything. Will resolve to `${CONT_USER}` inside the container                |
| `GROUP`          | Default: `web`. Used during group creation, can be anything. Will resolve to `${CONT_GROUP}` inside the container                |
| `UID`            | Default: `1001`. Used during user creation. Suggest to set this to whatever matches your host user to avoid permission issues.   |
| `GID`            | Default: `1001`. Used during group creation. Suggest to set this to whatever matches your host group to avoid permission issues. |
| `GITDIR`         | Default: `/app/git`. Sets working directory for `git` to that location                                                           |
| `GITWORKTREE`    | Default: `/app/git`. Sets work tree directory for `git` to that location                                                         |
| `GOCACHE`        | Default: `/app/git`. Sets module cache for `go` to that location                                                                 |
