function ghostty-tab --description 'Open a new Ghostty tab with an optional command'
    set -l cmd $argv[1]
    set -l dir $HOME
    if set -q argv[2]
        set dir $argv[2]
    end

    if test -n "$cmd"
        printf '%s' $cmd >"$TMPDIR/.ghostty_cmd"
    end

    open -a Ghostty $dir
end
