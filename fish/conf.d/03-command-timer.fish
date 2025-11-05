# Command timing for long-running notifications
set -g CMD_START_TIME 0
set -g CMD_NOTIFICATION_THRESHOLD 180  # 3 minutes in seconds

# Whitelist of long-running commands that should trigger notifications
set -g CMD_TIMER_WHITELIST brew npm yarn pnpm pip pip3 poetry bundle rails docker docker-compose kubectl helm terraform ansible-playbook make cmake ninja cargo go gradle mvn pytest tox rake rsync uv python python3 torchrun accelerate deepspeed huggingface-cli conda mamba pipx sbatch srun sleep

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
            
            # Extract the first word (command name) to check against whitelist
            set -l cmd_name (string split ' ' $command)[1]
            
            # Only notify when the command starts with a whitelisted word
            set -l is_whitelisted false
            for whitelisted in $CMD_TIMER_WHITELIST
                if string match -q "$whitelisted*" $cmd_name
                    set is_whitelisted true
                    break
                end
            end

            if $is_whitelisted
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
