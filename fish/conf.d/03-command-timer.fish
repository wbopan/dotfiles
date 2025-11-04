# Command timing for long-running notifications
set -g CMD_START_TIME 0
set -g CMD_NOTIFICATION_THRESHOLD 180  # 3 minutes in seconds

# Blacklist of interactive commands that should not trigger notifications
set -g CMD_TIMER_BLACKLIST vim nvim vi less more man htop top nano emacs ssh tmux screen git fzf ranger mc mutt weechat irssi node ipython fish bash zsh mysql psql mongo redis-cli codex tx v y

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
            
            # Skip notification if command starts with a blacklisted word
            set -l is_blacklisted false
            for blacklisted in $CMD_TIMER_BLACKLIST
                if string match -q "$blacklisted*" $cmd_name
                    set is_blacklisted true
                    break
                end
            end
            
            if not $is_blacklisted
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
