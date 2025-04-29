#!/bin/bash
printf "\n[array-helper] Pre-eliminary checking of build arguments...\n"

if ! [ "${CADDY_MODULES}" = "" ]; then
    printf "\n[Validate1] Pass - Non-empty value was supplied\n"
else
    printf "\n[Validate1] Failure - Empty value supplied for CADDY_MODULES\n"
    printf "\n[Validate1] If this is intentional, pass 0 to CADDY_MODULES environmental variable to build Caddy without modules\n"
    exit 2
fi

if ! [ "${GO_CADDY_VERSION}" = "" ] ; then
    printf "\n[Validate2] Pass - Non-empty value was supplied\n"
else
    printf "\n[Validate2] Failure - Empty value supplied for CADDY_TAG_VERSION\n"
    printf "\n[Validate2] Build process will fallback to master branch which may not build successfully\n"
    export GO_CADDY_VERSION=master
fi

printf "\n[Init] Setting environmental variables...\n"
FILE_PATH=/usr/app/builder/caddy/main.go
TEMP_FILE=/usr/app/builder/caddy/temp.go
PROCESSED=false

printf "\n[Init] Creating temporary temp.go file...\n"
touch /usr/app/builder/caddy/temp.go

printf "\n[Init] Parsing CADDY_MODULES into array...\n"
read -ra CADDY_MODULES_ARRAY <<< "${CADDY_MODULES}"

printf "%b" "\n[DBG] Listing variables and file directories...\n"
printf "%b" "\n[DBG] File Path: ${FILE_PATH}\n"
printf "%b" "\n[DBG] Temporary File: ${TEMP_FILE}\n"
printf "%b" "\n[DBG] Was Array processed? - ${PROCESSED}\n"
printf "%b" "\n[DBG] First Value in Array - ${CADDY_MODULES_ARRAY}\n"
printf "%b" "\n[DBG] Modules: ${CADDY_MODULES}\n"
printf "%b" "\n[DBG] Caddy Version: ${GO_CADDY_VERSION}\n"
printf "%b" "\n[DBG] Listing directory contents of /app/caddy\n"
ls -l /app/caddy

printf "\n[Init] Checking for blank temporary file...\n"
echo -n "" > $TEMP_FILE

printf "\n[array-helper] Replacing a line using sed inside main.go to Caddy go package instead...\n"
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

printf "[array-helper] Overwriting main.go with temporary file...\n"
mv $TEMP_FILE $FILE_PATH

printf "[DBG] Showing go module file...\n"
cat $FILE_PATH

printf "\n[array-helper] Pinning Caddy version according to tag, commit or branch\n"
go get github.com/caddyserver/caddy/v2@${GO_CADDY_VERSION}
printf "\n[array-helper] Pinning mholt/caddy-l4 version according to tag, commit or branch\n"
go get github.com/mholt/caddy-l4@87e3e5e2c7f986b34c0df373a5799670d7b8ca03
printf "[array-helper] Running go mod tidy to add module requirements and create go.sum\n"
go mod tidy
printf "[array-helper] Continuing with build process\n"

# https://unix.stackexchange.com/a/403401
# https://stackoverflow.com/a/30212526
# v1.0.6 - Hotfix
