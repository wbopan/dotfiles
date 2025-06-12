function sshtmux --description "SSH to host and create/attach tmux session with timestamp"
    if test (count $argv) -eq 0
        echo "Usage: sshtmux HOST"
        return 1
    end
    
    set host $argv[1]
    ssh -t $host tmux new -As "s-$(date +%H%M%S)"
end