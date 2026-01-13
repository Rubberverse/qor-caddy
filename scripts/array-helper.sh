#!/bin/bash
printf "\n[array-helper] Pre-eliminary checking of build arguments...\n"

if ! [ "${CADDY_MODULES}" = "" ]; then
    printf "\n[VL1] Pass - Non-empty value was supplied for CADDY_MODULES"
else
    printf "\n[VL1] Empty value supplied for CADDY_MODULES, pass 0 if you want to build vanilla Caddy.\nScript will now exit."
    exit 2
fi

if ! [ "${GO_CADDY_VERSION}" = "" ] ; then
    printf "\n[VL2] Pass - Non-empty value was supplied for GO_CADDY_VERSION"
else
    printf "\n[VL2] Empty value supplied for GO_CADDY_VERSION, pass master if you want to specifically build master branch.\nScript will now exit."
    exit 2
fi

FILE_PATH=/usr/app/builder/caddy/main.go
TEMP_FILE=/usr/app/builder/caddy/temp.go
PROCESSED=false

touch /usr/app/builder/caddy/temp.go

printf "\nParsing CADDY_MODULES into array...\n"
read -ra CADDY_MODULES_ARRAY <<< "${CADDY_MODULES}"
echo -n "" > $TEMP_FILE

if [[ ${DEBUG} ]]; then
    printf "%b" "\n[DBG] Listing variables and file directories...\n"
    printf "%b" "\n[DBG] File Path: ${FILE_PATH}\n"
    printf "%b" "\n[DBG] Temporary File: ${TEMP_FILE}\n"
    printf "%b" "\n[DBG] Was Array processed? - ${PROCESSED}\n"
    printf "%b" "\n[DBG] First Value in Array - ${CADDY_MODULES_ARRAY}\n"
    printf "%b" "\n[DBG] Modules: ${CADDY_MODULES}\n"
    printf "%b" "\n[DBG] Caddy Version: ${GO_CADDY_VERSION}\n"
fi

sed -i -e "s|// plug in Caddy modules here|_ \"github.com/caddyserver/caddy/v2\"|g" $FILE_PATH

printf "%b" "\n[array-helper] Appending modules from array to main.go..."
while IFS= read -r line
do
    if [[ $line == *"   _ \"github.com/caddyserver/caddy/v2\""* ]] && [ "$PROCESSED" = false ]; then
        for module in "${CADDY_MODULES_ARRAY[@]}"
            do
                printf "%b" "\t_ \"$module\"\n" >> $TEMP_FILE
        done
        PROCESSED=true
    fi
    echo "$line" >> $TEMP_FILE
done < "$FILE_PATH"

printf "\n[array-helper] Overwriting main.go with temporary file...\n"
mv -f $TEMP_FILE $FILE_PATH

if [[ ${DEBUG} ]]; then
        cat $FILE_PATH
fi

printf "\n[array-helper] Pinning Caddy version according to tag, commit or branch"
go get github.com/caddyserver/caddy/v2@${GO_CADDY_VERSION}

if [[ ${CADDY_DEFENDER} ]]; then
        printf "\n[array-helper] Pulling caddy-defender"
        git clone https://github.com/JasonLovesDoggo/caddy-defender.git caddy-defender
        echo 'replace pkg.jsn.cam/caddy-defender => ./caddy-defender' >> go.mod
fi

printf "\n[array-helper] Running go mod tidy to add module requirements and create go.sum\n"
go mod tidy

if [[ ${CADDY_DEFENDER}} ]] && [[ ${ASN_RANGES} ]]; then
        cd caddy-defender
        go run ranges/main.go --fetch-tor --asn ${ASN_RANGES}
        cd ..
fi

printf "[array-helper] Continuing with build process\n"

# https://unix.stackexchange.com/a/403401
# https://stackoverflow.com/a/30212526
# v1.1.0 - Speciality for caddy-defender
