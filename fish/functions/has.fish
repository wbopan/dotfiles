# Check if a command exists on the PATH
function has
    command -v $argv >/dev/null ^&1
end
