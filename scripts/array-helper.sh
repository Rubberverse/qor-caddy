#!/bin/bash
printf "[array-helper] Pre-eliminary checking of environmental variables - Pass 1/2\n"

if ! [ "${CADDY_MODULES}" = "" ]; then
    printf "[array-helper - Check 1] PASSED\n"
else
    printf "[array-helper - Check #1] FAILED: Empty value supplied for CADDY_MODULES\n"
    printf "[array-helper - Check #1] FAILED: If this is intentional, pass 0 to CADDY_MODULES environmental variable to build Caddy without modules\n"
    exit 2
fi

printf "[array-helper] Pre-eliminary checking of environmental variables - Pass 2/2\n"
if ! [ "${GO_CADDY_VERSION}" = "" ] ; then
    printf "[array-helper - Check #2] PASSED]\n"
else
    printf "[array-helper - Check #2] FAILED: Empty value supplied for CADDY_TAG_VERSION\n"
    printf "[array-helper - Check #2] WARNING: Build process will fallback to master branch which may not build successfully\n"
    export GO_CADDY_VERSION=master
fi

printf "[array-helper - init] Initializing variables\n"
FILE_PATH=/usr/app/builder/caddy/main.go
TEMP_FILE=/usr/app/builder/caddy/temp.go
PROCESSED=false

printf "[array-helper - init] Creating necessary files\n"
touch /usr/app/builder/caddy/temp.go

printf "[array-helper - init] Parsing CADDY_MODULES into Array\n"
read -ra CADDY_MODULES_ARRAY <<< "${CADDY_MODULES}"

#printf "[array-helper - debug] Listing variables and file directories\n"
#printf "%b" "FILE_PATH: ${FILE_PATH}\n"
#printf "%b" "TEMP_FILE: ${TEMP_FILE}\n"
#printf "%b" "ARRAY PROCESSED: ${PROCESSED}\n"
#printf "%b" "ARRAY VALUE (first): ${CADDY_MODULES_ARRAY}\n"
#printf "%b" "CADDY_MODULES: ${CADDY_MODULES}\n"
#printf "%b" "CADDY VERSION: ${GO_CADDY_VERSION}\n"
#ls -l /app/caddy

printf "[array-helper - init] Sanity check\n"
echo -n "" > $TEMP_FILE

printf "[array-helper] Adding modules to /app/caddy/main.go\n"
sed -i -e "s|// plug in Caddy modules here|_ \"github.com/caddyserver/caddy/v2\"|g" $FILE_PATH

while IFS= read -r line
do
    if [[ $line == *"	_ \"github.com/caddyserver/caddy/v2\""* ]] && [ "$PROCESSED" = false ]; then
        for module in "${CADDY_MODULES_ARRAY[@]}"
            do
                printf "%b" "\t_ \"$module\"\n" >> $TEMP_FILE
        done        
	PROCESSED=true
    fi

    echo "$line" >> $TEMP_FILE 
done < "$FILE_PATH"

printf "[array-helper] Overwriting main.go with temporary file\n"
mv $TEMP_FILE $FILE_PATH

printf "[array-helper - debug] Show go module\n"
cat $FILE_PATH

printf "\n[array-helper] Pinning Caddy version according to tag, commit or branch\n"
go get github.com/caddyserver/caddy/v2@${GO_CADDY_VERSION}
printf "\n[array-helper] Test\n"
go get github.com/corazawaf/coraza-caddy/v2@2502703e84440c48f4c044e5a88c0c036315fd40

printf "[array-helper] Running go mod tidy to add module requirements and create go.sum\n"
go mod tidy

printf "[array-helper] Continuing with build process\n"

# https://unix.stackexchange.com/a/403401
# https://stackoverflow.com/a/30212526
# v1.0.4 - More than a array-helper at this point...
