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

printf "\n[Init] Checking for blank temporary file...\n"
echo -n "" > $TEMP_FILE

printf "\n[array-helper] Replacing a line using sed inside main.go to Caddy go package instead...\n"
sed -i -e "s|// plug in Caddy modules here|_ \"github.com/caddyserver/caddy/v2\"|g" $FILE_PATH

printf "%b" "\n[array-helper] Appending modules from array to main.go..."
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

printf "[array-helper] Overwriting main.go with temporary file...\n"
mv -f $TEMP_FILE $FILE_PATH

printf "[DBG] Showing go module file...\n"
cat $FILE_PATH

printf "\n[array-helper] Pinning Caddy version according to tag, commit or branch\n"
go get github.com/caddyserver/caddy/v2@${GO_CADDY_VERSION}
printf "\n[array-helper] Pulling caddy-defender\n"
git clone https://github.com/JasonLovesDoggo/caddy-defender.git caddy-defender
printf "\n[array-helper] Append local path for caddy-defender\n"
echo 'replace pkg.jsn.cam/caddy-defender => ./caddy-defender' >> go.mod
printf "\n[array-helper] Running go mod tidy to add module requirements and create go.sum\n"
go mod tidy
printf "\n[array-helper] Adding extra ASNs for caddy-defender\n"
printf "\n[array-helper] OVH,Tencent,Scaleway,Scala,Namecheap,LiquidWeb,Linode,IONOS,Hostinger,Hetzner,DigitalOcean,Contabo\n"
cd caddy-defender
go run ranges/main.go --fetch-tor --asn "AS16276,AS35540,AS45090,AS12876,AS29447,AS54265,AS40476,AS22612,AS32244,AS6188,AS22558,AS40819,AS53824,AS201682,AS63949,AS48337,AS8560,AS51862,AS47583,AS204915,AS24940,AS213230,AS212317,AS14061,AS39690,AS62567,AS133165,AS135340,AS200130,AS201229,AS202018,AS202109,AS205301,AS393406,AS394362,AS40021,AS51167,AS141995"
cd ..
printf "[array-helper] Continuing with build process\n"

# https://unix.stackexchange.com/a/403401
# https://stackoverflow.com/a/30212526
# v1.0.6 - Hotfix
