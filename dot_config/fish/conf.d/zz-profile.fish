# Source environment variables from ~/.env (managed by chezmoi, age-encrypted)

if test -f ~/.env
    while read -l line
        string match -qr '^\s*#' -- $line; and continue
        string match -qr '^\s*$' -- $line; and continue
        string match -qr '^export ' -- $line; or continue

        set -l assignment (string replace -r '^export ' '' -- $line)
        set -l key (string replace -r '=.*' '' -- $assignment)
        set -l val (string replace -r '^[^=]*=' '' -- $assignment)
        set val (string trim -c '"' -- $val)
        set val (string trim -c "'" -- $val)

        set -gx $key $val
    end <~/.env
end
