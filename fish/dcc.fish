has devcontainer; and function dcc
    # Detect container runtime (prefer podman over docker)
    set container_runtime ""
    if type -q podman
        set container_runtime "--container-runtime=podman"
    else if type -q docker
        set container_runtime "--container-runtime=docker"
    end
    
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
        devcontainer exec $container_runtime $devcontainer_args echo "checking" >/dev/null 2>&1
    end
    
    if test (count $argv) -eq 0
        devcontainer $container_runtime $devcontainer_args
    else if test "$argv[1]" = "claude"
        # Check if devcontainer is running before executing claude
        if not is_devcontainer_running
            echo "Devcontainer not running. Starting it first..."
            devcontainer up $container_runtime $devcontainer_args
        end
        devcontainer exec $container_runtime $devcontainer_args claude --dangerously-skip-permissions $argv[2..]
    else if contains "$argv[1]" $devcontainer_commands
        # Add git mount only for 'up' command when in a git worktree
        set command_args $devcontainer_args
        if test "$argv[1]" = "up"; and git rev-parse --is-inside-work-tree >/dev/null 2>&1
            set common_git_dir (git rev-parse --git-common-dir 2>/dev/null)
            if test -n "$common_git_dir" -a "$common_git_dir" != ".git"
                # This is a worktree, add mount for the common git directory
                set command_args $command_args --mount "type=bind,source=$common_git_dir,target=$common_git_dir"
            end
        end
        devcontainer $argv[1] $container_runtime $command_args $argv[2..]
    else
        # For other commands (which use exec), check if devcontainer is running
        if not is_devcontainer_running
            echo "Devcontainer not running. Starting it first..."
            devcontainer up $container_runtime $devcontainer_args
        end
        devcontainer exec $container_runtime $devcontainer_args $argv
    end
end