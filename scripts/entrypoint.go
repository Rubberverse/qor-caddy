package main
import (
    "fmt"
    "os"
    "os/exec"
    "path/filepath"
    "strings"
)

func main() {
    var configPath, launchArgs, deployType string

	if len(os.Args) > 1 && os.Args[1] == "--reload" {
        reloadCaddyConfig()
        return
    }

    // CONFIG_PATH, normalize path
    configPath = filepath.Clean(os.Getenv("CONFIG_PATH"))
    // DEPLOY_TYPE, convert value to lowercase
    deployType = strings.ToLower(os.Getenv("DEPLOY_TYPE"))
    // EXTRA_ARGS
    launchArgs = os.Getenv("EXTRA_ARGS")

    fmt.Println("[ ✨ Init ] Powered by Rubber Ducks. Starting checks...")
    fileInfo, err := os.Stat(configPath)
    // Error handling in case it's blank
    if err != nil {
        fmt.Println(`
            [config_path]
            Invalid value supplied for CONFIG_PATH: '%s'
            Make sure to point it to a configuration mounted inside the container!
        `, configPath)
    }
    // Check if it's just a directory, otherwise continue
    if fileInfo.IsDir() {
        fmt.Println(`
            [config_path] 
            Your environment variable points to a directory!
            It should point to a configuration file instead.`, configPath)
        os.Exit(2)
    } else {
        fmt.Println("[config_path] Supplied env is valid!")
    }

    // ASCII art + information
    fmt.Println(`
    --------------------------------------------------------------------------------------------

    ██▀███   █    ██  ▄▄▄▄    ▄▄▄▄   ▓█████  ██▀███   ██▒   █▓▓█████  ██▀███    ██████ ▓█████  
    ▓██ ▒ ██▒ ██  ▓██▒▓█████▄ ▓█████▄ ▓█   ▀ ▓██ ▒ ██▒▓██░   █▒▓█   ▀ ▓██ ▒ ██▒▒██    ▒ ▓█   ▀  
    ▓██ ░▄█ ▒▓██  ▒██░▒██▒ ▄██▒██▒ ▄██▒███   ▓██ ░▄█ ▒ ▓██  █▒░▒███   ▓██ ░▄█ ▒░ ▓██▄   ▒███    
    ▒██▀▀█▄  ▓▓█  ░██░▒██░█▀  ▒██░█▀  ▒▓█  ▄ ▒██▀▀█▄    ▒██ █░░▒▓█  ▄ ▒██▀▀█▄    ▒   ██▒▒▓█  ▄  
    ░██▓ ▒██▒▒▒█████▓ ░▓█  ▀█▓░▓█  ▀█▓░▒████▒░██▓ ▒██▒   ▒▀█░  ░▒████▒░██▓ ▒██▒▒██████▒▒░▒████▒ 
    ░ ▒▓ ░▒▓░░▒▓▒ ▒ ▒ ░▒▓███▀▒░▒▓███▀▒░░ ▒░ ░░ ▒▓ ░▒▓░   ░ ▐░  ░░ ▒░ ░░ ▒▓ ░▒▓░▒ ▒▓▒ ▒ ░░░ ▒░ ░ 
    ░▒ ░ ▒░░░▒░ ░ ░ ▒░▒   ░ ▒░▒   ░  ░ ░  ░  ░▒ ░ ▒░   ░ ░░   ░ ░  ░  ░▒ ░ ▒░░ ░▒  ░ ░ ░ ░  ░
    ░░   ░  ░░░ ░ ░  ░    ░  ░    ░    ░     ░░   ░      ░░     ░     ░░   ░ ░  ░  ░     ░   
    ░        ░      ░       ░         ░  ░   ░           ░     ░  ░   ░           ░     ░  ░

                    You can change the world. Don't let anyone tell you otherwise.
    ---------------------------------------------------------------------------------------------
    ✨ Repository, Guides and Issues can be seen here: https://github.com/rubberverse/qor-caddy
    ⚠️ You won't be able to execute shell commands. If you want to reload config, run /app/bin/reload

    📁 Shoutouts to maintainers of Go, Caddy and Caddy modules! You guys do awesome job and I <3 your work!
    `)

    if deployType != "test" {
        fmt.Println("Launching Caddy in production environment...")
        cmd := exec.Command("/app/bin/caddy", "run", "--config", configPath, launchArgs)
        cmd.Stdout = os.Stdout
        cmd.Stderr = os.Stderr
        // Error checking in case of binary start-up failure
        if err := cmd.Run(); err != nil {
            fmt.Printf("Unexpected error has occured while starting Caddy!\n%v\n", err)
            os.Exit(2)
        }
    } else {
        fmt.Println("Launching Caddy in testing environment...")
        cmd := exec.Command("/app/bin/caddy", "start", "--config", configPath, launchArgs)
        cmd.Stdout = os.Stdout
        cmd.Stderr = os.Stderr
        // This is mostly to catch configuration failures and print them out instead of failing silently.
        if err := cmd.Run(); err != nil {
            fmt.Printf("Unexpected error has occured while starting Caddy!\n%v\n", err)
            os.Exit(2)
        }
    }
}

func reloadCaddyConfig() {
	configPath := filepath.Clean(os.Getenv("CONFIG_PATH"))
	cmd := exec.Command("/app/bin/caddy", "reload", "--config", configPath)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	if err := cmd.Run(); err != nil {
		fmt.Printf("Failed to reload Caddy configuration: %v\n", err)
	}
	fmt.Println("Caddy configuration reloaded successfully!")
}