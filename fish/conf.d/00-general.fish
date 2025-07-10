# Core utilities and settings
set -U fish_greeting ""

# Use builtin astronaut prompt
fish_config prompt choose astronaut

function has
    command -v $argv >/dev/null ^&1
end

# Load environment variables from .profile using bash
# Fish cannot directly source POSIX shell scripts, so we use bash to export them
function _load_profile_env --description "Load environment variables from ~/.profile"
    if test -f ~/.profile
        # Use bash to source .profile and export all environment variables
        # This captures only the export commands and converts them to Fish syntax
        bash -c 'source ~/.profile 2>/dev/null && env' | while read -l line
            set -l kv (string split -m 1 = -- $line)
            if test (count $kv) -eq 2
                set -l key $kv[1]
                set -l value $kv[2]
                # Skip read-only variables like '_' which cannot be set in Fish
                if test "$key" != "_"
                    # Only set if not already set in Fish to avoid overwriting Fish-specific settings
                    if not set -q $key
                        set -gx $key $value
                    end
                end
            end
        end
    end
end

# Load profile environment on startup
_load_profile_env