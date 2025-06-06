has devcontainer; and function dcc
    # List of devcontainer subcommands
    set devcontainer_commands up set-up build run-user-commands read-configuration outdated upgrade features templates exec
    
    # Check if .devcontainer/devcontainer.json exists in current directory
    # If not, use default config from ~/.config/devcontainer/devcontainer.json
    set devcontainer_args
    if test -f .devcontainer/devcontainer.json
        set devcontainer_args --workspace-folder .
    else if test -f $HOME/.config/devcontainer/devcontainer.json
        set devcontainer_args --workspace-folder . --config $HOME/.config/devcontainer/devcontainer.json
    else
        set devcontainer_args --workspace-folder .
    end
    
    # Check if devcontainer is running (for exec commands and non-management commands)
    function is_devcontainer_running
        devcontainer exec $devcontainer_args echo "checking" >/dev/null 2>&1
    end
    
    if test (count $argv) -eq 0
        devcontainer $devcontainer_args
    else if test "$argv[1]" = "claude"
        # Check if devcontainer is running before executing claude
        if not is_devcontainer_running
            echo "Devcontainer not running. Starting it first..."
            devcontainer up $devcontainer_args
        end
        devcontainer exec $devcontainer_args claude --dangerously-skip-permissions $argv[2..]
    else if contains "$argv[1]" $devcontainer_commands
        devcontainer $argv[1] $devcontainer_args $argv[2..]
    else
        # For other commands (which use exec), check if devcontainer is running
        if not is_devcontainer_running
            echo "Devcontainer not running. Starting it first..."
            devcontainer up $devcontainer_args
        end
        devcontainer exec $devcontainer_args $argv
    end
end