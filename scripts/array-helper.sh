#!/usr/bin/env bash
# Version: 2.0
# References:
# https://stackoverflow.com/a/44606194
# https://stackoverflow.com/a/30212526
# https://unix.stackexchange.com/a/403401

# Functions
prepare_defender() {
    git clone https://github.com/JasonLovesDoggo/caddy-defender.git caddy-defender
    echo 'replace pkg.jsn.cam/caddy-defender => ./caddy-defender' >> go.mod
    cd caddy-defender || exit
    go run ranges/main.go --fetch-tor
    cd ..
}

echo "${CADDY_MODULES}"

# Actual script
# +x causes some weird fuckery and it starts always amounting to true for some reason?
[ -z "${CADDY_MODULES:-}" ] && export CADDY_MODULES="none"
[ -z "${CADDY_VERSION:-}" ] && export CADDY_VERSION=master

BUILD=/usr/app/builder/caddy
PFILE="${BUILD}/main.go"
TFILE="${BUILD}/temp.go"
PROCESSED=false

sed -i -e 's|// plug in Caddy modules here|   _ "github.com/caddyserver/caddy/v2"|' "$PFILE"

if [ "${CADDY_MODULES}" != "none" ]; then
    touch "${TFILE}"
    read -ra CADDY_MODULES_ARRAY <<< "${CADDY_MODULES}"
    echo -n "" > "${TFILE}"
    # while done loop combined into for loop to process all elements of array
        while IFS= read -r LINE
            do
                if [[ "${LINE}" == *'   _ "github.com/caddyserver/caddy/v2"'* ]] && [[ "${PROCESSED}" == false ]]; then
                    for MODULE in "${CADDY_MODULES_ARRAY[@]}"
                        do
                            printf '\t_ "%s"\n' "$MODULE" >> "$TFILE"
                            echo "$MODULE"
                        done
                    PROCESSED=true
                fi
            printf '%s\n' "$LINE" >> "$TFILE"
        done < "${PFILE}"
    # Overwrite main.go with temporary file
    mv -f "${TFILE}" "${PFILE}"
fi

# Pinning Caddy version to tag, commit or branch
go get github.com/caddyserver/caddy/v2@"${CADDY_VERSION}"
cat "${PFILE}"

# Special module configurations
if [ -z "${CADDY_DEFENDER:-}" ]; then echo "CADDY_DEFENDER is not set, skipping."; else prepare_defender; fi

go mod init caddy
go mod tidy
