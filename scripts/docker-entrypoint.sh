/app/bin/goawk '
    # Functions start
    function fileExists(path) {
        if ((getline < path) > 0) {
            close(file)
            # If it does, return 1
            return 1
        }
        else {
            close(file)
            # If it doesnt, return 0
            return 0
        }
    }
    function showASCII() {
        print " ██▀███   █    ██  ▄▄▄▄    ▄▄▄▄   ▓█████  ██▀███   ██▒   █▓▓█████  ██▀███    ██████ ▓█████ "
        print "▓██ ▒ ██▒ ██  ▓██▒▓█████▄ ▓█████▄ ▓█   ▀ ▓██ ▒ ██▒▓██░   █▒▓█   ▀ ▓██ ▒ ██▒▒██    ▒ ▓█   ▀ "
        print "▓██ ░▄█ ▒▓██  ▒██░▒██▒ ▄██▒██▒ ▄██▒███   ▓██ ░▄█ ▒ ▓██  █▒░▒███   ▓██ ░▄█ ▒░ ▓██▄   ▒███   "
        print "▒██▀▀█▄  ▓▓█  ░██░▒██░█▀  ▒██░█▀  ▒▓█  ▄ ▒██▀▀█▄    ▒██ █░░▒▓█  ▄ ▒██▀▀█▄    ▒   ██▒▒▓█  ▄ "
        print "░██▓ ▒██▒▒▒█████▓ ░▓█  ▀█▓░▓█  ▀█▓░▒████▒░██▓ ▒██▒   ▒▀█░  ░▒████▒░██▓ ▒██▒▒██████▒▒░▒████▒"
        print "░ ▒▓ ░▒▓░░▒▓▒ ▒ ▒ ░▒▓███▀▒░▒▓███▀▒░░ ▒░ ░░ ▒▓ ░▒▓░   ░ ▐░  ░░ ▒░ ░░ ▒▓ ░▒▓░▒ ▒▓▒ ▒ ░░░ ▒░ ░"
        print "  ░▒ ░ ▒░░░▒░ ░ ░ ▒░▒   ░ ▒░▒   ░  ░ ░  ░  ░▒ ░ ▒░   ░ ░░   ░ ░  ░  ░▒ ░ ▒░░ ░▒  ░ ░ ░ ░  ░"
        print "  ░░   ░  ░░░ ░ ░  ░    ░  ░    ░    ░     ░░   ░      ░░     ░     ░░   ░ ░  ░  ░     ░   "
        print "   ░        ░      ░       ░         ░  ░   ░           ░     ░  ░   ░           ░     ░  ░"
        print "                        ░       ░                      ░                                   "
        print "    You are the only person capable of change. Lead your life the way you want it to go.   "
    }
    BEGIN {
        # Checks value of CADDY_ENVIRONMENT and in case its wrong, resets it to ERR
        envValue = tolower(ENVIRON["CADDY_ENVIRONMENT"])
        if (envValue == "prod") {
            ENVIRON["VAR_ENV"] = 1
        } else if (envValue == "test") {
            ENVIRON["VAR_ENV"] = 2
        } else {
            ENVIRON["VAR_ENV"] = "ERR"
        }
        # Check if CADDY_ENVIRONMENT is valid or not (ex. prod or test)
        if (ENVIRON["VAR_ENV"] != "ERR") {
            print "[ ✨ Pass ] ✅ CADDY_ENVIRONMENT is valid!]"
        } else {
            print "[ ⚠️ Warning ] Invalid or blank CADDY_ENVIRONMENT!", "[ ⚠️ Warning Desc ] Container will fallback to Production launch"
            ENVIRON["VAR_ENV"] = 1
        }
        # Check if config file is mounted
        fileExistsResult = fileExists(ENVIRON["CONFIG_PATH"])
        if (fileExistsResult) {
            print "[ ✨ Pass ] ✅ CONFIG_PATH is valid!"
        } else {
            print "[ ❌ Error ] CONFIG_PATH is invalid!", "[ Error Desc ] This container doesnt start with a default configuration file", "Users are expected to mount it themselves inside /app/configs directory"
            exit(1)
        }
        # Show ASCII art and other
        showASCII()
        print "🗒️ Repository & Guides - https://github.com/rubberverse/qor-caddy"
        print "⚠️ This container has no shell!", "...which means that you wont be able to run commands from it. Its more secure though!"
        print ""
        print "📁 Projects used: Bunster, GoAWK, Caddy, Third-party Caddy modules, Go (programming language)"
        print "✨ Shoutouts to: Maintainers and community of Bunster, GoAWK, Caddy, Caddy modules and Go!"
        print ""
    }
'

if [[ "$VAR_ENV" == "1" ]]; then
    /app/bin/caddy run --config "$CONFIG_PATH" "$EXTRA_ARGS"
    /app/bin/sleep
elif [[ "${VAR_ENV}" == "2" ]]; then
    /app/bin/caddy start --config "$CONFIG_PATH" "$EXTRA_ARGS"
    /app/bin/sleep
else
    /app/bin/caddy run --config "$CONFIG_PATH" "$EXTRA_ARGS"
    /app/bin/sleep
fi
