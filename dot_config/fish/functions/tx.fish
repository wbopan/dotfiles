function tx --description 'Run commands in tmux session named after current directory'
    if set -q TMUX
        return 0
    end

    if not set -q argv[1]
        tmux new -As (basename $PWD)
    else
        set -l window_name "run_{$argv[1]}_"(random)
        tmux new-session -s $window_name "$argv; $SHELL"
    end
end
