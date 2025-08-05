# Custom functions

# General notification function using ntfy
function notify
    set -l title $argv[1]
    set -l message $argv[2]
    
    # Send notification with proper title and message separation
    # Enable Markdown formatting for proper line breaks
    curl -s \
        -H "Title: $title" \
        -H "X-Markdown: yes" \
        -d "$message" \
        ntfy.sh/wenbo-R2osKWmlKv7gQh2m > /dev/null 2>&1
end

# Command timing for long-running notifications
set -g CMD_START_TIME 0
set -g CMD_NOTIFICATION_THRESHOLD 180  # 3 minutes in seconds

# Blacklist of interactive commands that should not trigger notifications
set -g CMD_TIMER_BLACKLIST vim nvim vi less more man htop top nano emacs ssh tmux screen git fzf ranger mc mutt weechat irssi node ipython fish bash zsh mysql psql mongo redis-cli claude tx

function __cmd_timer_start --on-event fish_preexec
    set -g CMD_START_TIME (date +%s)
end

function __cmd_timer_end --on-event fish_postexec
    # Capture the status immediately
    set -l last_status $status

    if test $CMD_START_TIME -gt 0
        set -l end_time (date +%s)
        set -l duration (math $end_time - $CMD_START_TIME)
        
        # Only notify if duration exceeds threshold AND command wasn't interrupted
        # Exit status 130 = Ctrl+C (SIGINT), 131 = Ctrl+\ (SIGQUIT)
        if test $duration -ge $CMD_NOTIFICATION_THRESHOLD -a $last_status -ne 130 -a $last_status -ne 131
            set -l minutes (math "floor($duration / 60)")
            set -l seconds (math "$duration % 60")
            set -l command $argv[1]
            
            # Extract the first word (command name) to check against blacklist
            set -l cmd_name (string split ' ' $command)[1]
            
            # Skip notification if command is in blacklist
            if not contains $cmd_name $CMD_TIMER_BLACKLIST
                # Truncate command if too long for notification
                if test (string length $command) -gt 80
                    set command (string sub -l 77 $command)"..."
                end
                
                notify "Command Completed" "`$command` finished ($last_status) after $minutes m $seconds s"
            end
        end
        
        set -g CMD_START_TIME 0
    end
end

# tx function - tmux session management
function tx
    if test -n "$TMUX"
        return 0
    end

    if test (count $argv) -eq 0
        tmux new -As (basename $PWD)
    else
        set window_name "run_$argv[1]_"(random)
        tmux new-session -s $window_name "$argv; $SHELL"
    end
end

# sshtmux function - SSH to host and create/attach tmux session with timestamp
function sshtmux --description "SSH to host and create/attach tmux session with timestamp"
    if test (count $argv) -eq 0
        echo "Usage: sshtmux HOST"
        return 1
    end
    
    set host $argv[1]
    ssh -t $host tmux new -As "s-$(date +%H%M%S)"
end

# dcc function - DevContainer CLI wrapper with enhanced features
has devcontainer; and function dcc
    # Check for --dryrun flag
    set dryrun false
    set filtered_argv
    for arg in $argv
        if test "$arg" = "--dryrun"
            set dryrun true
        else
            set filtered_argv $filtered_argv $arg
        end
    end
    set argv $filtered_argv
    
    # Detect container runtime (prefer podman over docker)
    set docker_path ""
    if type -q podman
        set docker_path "--docker-path=podman"
    else if type -q docker
        set docker_path "--docker-path=docker"
    end
    
    # List of devcontainer subcommands
    set devcontainer_commands up set-up build run-user-commands read-configuration outdated upgrade features templates exec
    
    # Set workspace folder for devcontainer
    set devcontainer_args --workspace-folder .
    
    # Helper function to execute or print commands based on dryrun flag
    function run_or_print
        if test "$dryrun" = "true"
            echo "[DRYRUN] $argv"
        else
            eval $argv
        end
    end
    
    # Check if devcontainer is running (for exec commands and non-management commands)
    function is_devcontainer_running
        if test "$dryrun" = "true"
            echo "[DRYRUN] devcontainer exec $docker_path $devcontainer_args echo \"checking\" >/dev/null 2>&1"
            return 1  # Assume not running in dryrun mode
        else
            devcontainer exec $docker_path $devcontainer_args echo "checking" >/dev/null 2>&1
        end
    end
    
    if test (count $argv) -eq 0
        run_or_print devcontainer $docker_path $devcontainer_args
    else if test "$argv[1]" = "claude"
        # Check if devcontainer is running before executing claude
        if not is_devcontainer_running
            if test "$dryrun" = "true"
                echo "[DRYRUN] Devcontainer not running. Starting it first..."
            else
                echo "Devcontainer not running. Starting it first..."
            end
            run_or_print devcontainer up $docker_path $devcontainer_args
        end
        run_or_print devcontainer exec $docker_path $devcontainer_args claude --dangerously-skip-permissions $argv[2..-1]
    else if contains "$argv[1]" $devcontainer_commands
        # Add git mount only for 'up' command when in a git worktree
        set command_args $devcontainer_args
        if test "$argv[1]" = "up"; and git rev-parse --is-inside-work-tree >/dev/null 2>&1
            set common_git_dir (git rev-parse --git-common-dir 2>/dev/null)
            echo "Found common git dir: $common_git_dir, adding mount"
            if test -n "$common_git_dir" -a "$common_git_dir" != ".git"
                # This is a worktree, add mount for the common git directory
                set command_args $command_args --mount "type=bind,source=$common_git_dir,target=$common_git_dir"
            end
        end
        run_or_print devcontainer $argv[1] $docker_path $command_args $argv[2..-1]
    else
        # For other commands (which use exec), check if devcontainer is running
        if not is_devcontainer_running
            if test "$dryrun" = "true"
                echo "[DRYRUN] Devcontainer not running. Starting it first..."
            else
                echo "Devcontainer not running. Starting it first..."
            end
            run_or_print devcontainer up $docker_path $devcontainer_args
        end
        run_or_print devcontainer exec $docker_path $devcontainer_args $argv
    end
end