function ghostty-claude --description 'Open Claude Code in a new Ghostty tab'
    set -l query $argv[1]
    set -l cmd 'clear && claude --dangerously-skip-permissions'

    if test -n "$query"
        set cmd "$cmd "(string escape -- $query)
    end

    set cmd "$cmd && exit"
    ghostty-tab $cmd ~/Repos/workspace
end
