#!/bin/bash
# https://unix.stackexchange.com/a/403401
source /app/.bashrc

# Read lines from .MODULES into shell array $lines[array number]
mapfile -t lines < /app/scripts/.MODULES

# Create the command
# Beginning - Start of the command
cmd_array=( xcaddy build v${CADDY_VERSION} )
# Middle For loop (ex. --with $module[1] --with $module[2] etc.), repeats as long as there's content in the file
for module in "${lines[@]}"; do
    cmd_array+=( --with "$module" )
done
# End
cmd_array+=( --output /app/caddy )

# Involve the command
"${cmd_array[@]}"