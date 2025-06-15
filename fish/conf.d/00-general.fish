# Core utilities and settings
set -U fish_greeting ""

# Use builtin astronaut prompt
fish_config prompt choose astronaut

function has
    command -v $argv >/dev/null ^&1
end

# Source .profile for environment variables (including 1Password secrets)
test -f ~/.profile; and source ~/.profile