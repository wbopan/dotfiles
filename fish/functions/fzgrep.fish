# Interactive ripgrep + fzf helper for quickly filtering files or file contents
function fzgrep --description 'Interactive file/content search via fzf + ripgrep'
    set -l query ""
    if set -q argv[1]
        set query (string join " " $argv)
    end

    set -l fzf_args
    if test -n "$query"
        set fzf_args --query "$query"
    end

    command fzf $fzf_args \
        --multi --ansi --no-sort --phony \
        --height=40% --border --layout=reverse \
        --bind 'start:reload:rg --files | awk -v t=name "{print t \"\t\" \$0}"' \
        --bind 'change:reload:begin; rg --files | rg -S -F -- {q} | awk -v t=name "{print t \"\t\" \$0}"; rg -l -S -F -- {q} | awk -v t=content "{print t \"\t\" \$0}"; end | awk -F "\t" "!seen[\$2]++"' \
        --delimiter '\t' --with-nth=2 \
        --preview 'if test -n "{q}"; rg -n --no-heading --color=always -- {q} {2} | bat --style=plain --color=always --file-name {2}; else; bat --style=plain --color=always --line-range :200 {2}; end' \
        --preview-window 'right,60%,border' \
    | cut -f2
end
