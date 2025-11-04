# Sync environment variables from 1Password into ~/.profile
function op-sync --description "Sync environment variables from 1Password to ~/.profile"
    if not command -v op >/dev/null 2>&1
        echo "1Password CLI (op) not found. Install via your package manager (e.g. 'brew install 1password-cli')."
        return 1
    end

    echo "Checking current 1Password status..."
    op-status

    if not op account get >/dev/null 2>&1
        echo "Signing in to 1Password..."
        set -l signin_output (op signin 2>/dev/null)
        if test $status -ne 0
            echo "Sign in failed."
            return 1
        end
        eval $signin_output
    end

    set -l env_file "$HOME/.config/fish/.env"

    if not test -f "$env_file"
        echo "Environment file not found: $env_file"
        return 1
    end

    echo "Syncing secrets from 1Password..."

    set -l injected_content
    if not set injected_content (op inject --in-file "$env_file" 2>/dev/null)
        echo "Failed to inject secrets from 1Password"
        return 1
    end

    set -l managed_section "# BEGIN 1PASSWORD - AUTO MANAGED"
    set managed_section $managed_section "# Generated: "(date)
    set managed_section $managed_section $injected_content
    set managed_section $managed_section "# END 1PASSWORD - AUTO MANAGED"

    set -l profile_file ~/.profile
    set -l existing_content
    if test -f "$profile_file"
        set existing_content (cat "$profile_file")
    end

    # Find existing markers
    set -l begin_line -1
    set -l end_line -1
    if test (count $existing_content) -gt 0
        for i in (seq 1 (count $existing_content))
            if string match -q "# BEGIN 1PASSWORD*" "$existing_content[$i]"
                set begin_line $i
            else if string match -q "# END 1PASSWORD*" "$existing_content[$i]"
                set end_line $i
                break
            end
        end
    end

    # Build new profile content
    set -l new_content
    if test $begin_line -gt 0 -a $end_line -gt 0
        if test $begin_line -gt 1
            for i in (seq 1 (math $begin_line - 1))
                set new_content $new_content "$existing_content[$i]"
            end
        end
        set new_content $new_content $managed_section
        if test $end_line -lt (count $existing_content)
            for i in (seq (math $end_line + 1) (count $existing_content))
                set new_content $new_content "$existing_content[$i]"
            end
        end
    else
        set new_content $existing_content
        if test (count $existing_content) -gt 0
            set new_content $new_content ""
        end
        set new_content $new_content $managed_section
    end

    printf "%s\n" $new_content > "$profile_file"
    chmod 600 "$profile_file"

    echo "Synced "(count (string split "\n" "$injected_content"))" environment variables to ~/.profile"

    echo "Loading new environment variables..."
    _load_profile_env
    echo "Environment variables loaded successfully"

    echo "Checking 1Password status after sync..."
    op-status
end
