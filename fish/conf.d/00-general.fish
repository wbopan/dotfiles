# Core utilities and settings
set -U fish_greeting ""

# Use builtin astronaut prompt
fish_config prompt choose astronaut

function has
    command -v $argv >/dev/null ^&1
end