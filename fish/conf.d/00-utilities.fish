# Core utilities and settings
set -U fish_greeting ""

function has
    command -v $argv >/dev/null ^&1
end