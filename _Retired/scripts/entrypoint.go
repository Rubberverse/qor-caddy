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
	
    configPath = filepath.Clean(os.Getenv("CONFIG_PATH"))
    deployType = strings.ToLower(os.Getenv("DEPLOY_TYPE"))
    launchArgs = os.Getenv("EXTRA_ARGS")
	
    fileInfo, fileStatus := os.Stat(configPath)
    if fileStatus != nil {
        fmt.Println(`
            [config_path]
            Invalid value supplied for CONFIG_PATH: '$configPath'
			You should point this to a full path inside the container ex.
			CONFIG_PATH=/app/configs/Caddyfile
        `, configPath)
		os.Exit(2)
    }
    if fileInfo.IsDir() {
        fmt.Println(`
            [config_path] 
            Your environment variable points to a directory!
            It should point to a configuration file instead.
			ex. CONFIG_PATH=/app/configs/Caddyfile
		`, configPath)
        os.Exit(2)
    }
    fmt.Println(`
    RubberverseRubberverseRubberverseRubberverseRubberverseRubberverseRubberverseRubberverseRubberverse
                    You can change the world. Don't let anyone tell you otherwise.
    RubberverseRubberverseRubberverseRubberverseRubberverseRubberverseRubberverseRubberverseRubberverse

	[Tip] You can always reload Caddy configuration by running following command: 
	podman exec qor-caddy /app/bin/caddy reload -c $configPath
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
