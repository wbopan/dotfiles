# 1Password CLI Integration
# Manages environment variables using 1Password secret references

function op-sync --description "Sync environment variables from 1Password to ~/.profile"
    # Check if op CLI is available
    if not command -v op >/dev/null 2>&1
        echo "❌ 1Password CLI (op) not found. Install with: fish_deps install op"
        return 1
    end

    # Check if user is signed in, if not, attempt to sign in
    if not op account get >/dev/null 2>&1
        echo "🔐 Not signed in to 1Password. Attempting to sign in..."
        
        # Use eval to properly handle the op signin output
        if not eval (op signin)
            echo "❌ Failed to sign in to 1Password"
            return 1
        end
        
        echo "✅ Successfully signed in to 1Password"
    end

    # Get the .env file from fish config directory
    set -l env_file "$HOME/.config/fish/.env"

    # Check if .env file exists
    if not test -f "$env_file"
        echo "❌ Environment file not found: $env_file"
        return 1
    end

    echo "🔄 Syncing secrets from 1Password..."

    # Inject secrets using op inject
    set -l injected_content
    if not set injected_content (op inject --in-file "$env_file" 2>/dev/null)
        echo "❌ Failed to inject secrets from 1Password"
        return 1
    end

    # Prepare the managed section
    set -l managed_section "# BEGIN 1PASSWORD - AUTO MANAGED"
    set managed_section $managed_section "# Generated: "(date)
    set managed_section $managed_section $injected_content
    set managed_section $managed_section "# END 1PASSWORD - AUTO MANAGED"

    # Read existing profile content
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
        # Replace existing managed section
        # Add content before managed section
        if test $begin_line -gt 1
            for i in (seq 1 (math $begin_line - 1))
                set new_content $new_content "$existing_content[$i]"
            end
        end
        # Add new managed section
        set new_content $new_content $managed_section
        # Add content after managed section
        if test $end_line -lt (count $existing_content)
            for i in (seq (math $end_line + 1) (count $existing_content))
                set new_content $new_content "$existing_content[$i]"
            end
        end
    else
        # Append managed section
        set new_content $existing_content
        if test (count $existing_content) -gt 0
            set new_content $new_content ""  # Add blank line if profile has content
        end
        set new_content $new_content $managed_section
    end

    # Write new profile
    printf "%s\n" $new_content > "$profile_file"
    chmod 600 "$profile_file"

    echo "✅ Successfully synced "(count (string split "\n" "$injected_content"))" environment variables to ~/.profile"
    
    # Source the updated profile
    echo "🔄 Loading new environment variables..."
    source ~/.profile
    echo "✅ Environment variables loaded successfully"
end

function op-status --description "Show 1Password integration status"
    echo "🔍 1Password Integration Status"
    echo "=============================="
    
    # Check op CLI
    if command -v op >/dev/null 2>&1
        echo "  ✅ 1Password CLI installed"
        
        # Check sign-in status
        if op account get >/dev/null 2>&1
            set -l account_info (op account get --format=json 2>/dev/null | jq -r '.email // .user_uuid // "Unknown"')
            echo "  ✅ Signed in as: $account_info"
        else
            echo "  ❌ Not signed in to 1Password"
        end
    else
        echo "  ❌ 1Password CLI not installed"
    end

    # Check .env file
    set -l env_file "$HOME/.config/fish/.env"
    if test -f "$env_file"
        set -l secret_count (grep -c "^export.*=op://" "$env_file" 2>/dev/null || echo "0")
        echo "  ✅ Environment file found with $secret_count secret references"
    else
        echo "  ❌ Environment file not found: $env_file"
    end

    # Check profile
    if test -f ~/.profile
        if grep -q "# BEGIN 1PASSWORD" ~/.profile 2>/dev/null
            set -l last_sync (grep "# Generated:" ~/.profile 2>/dev/null | tail -n1 | sed 's/# Generated: //')
            echo "  ✅ Profile has managed secrets (last sync: $last_sync)"
        else
            echo "  ⚠️  Profile exists but no managed secrets found"
        end
    else
        echo "  ⚠️  Profile file does not exist"
    end
end

# Auto-sync on first setup
function _op_auto_sync_check
    # Check if profile already has managed section
    if test -f ~/.profile; and grep -q "# BEGIN 1PASSWORD" ~/.profile 2>/dev/null
        return
    end

    # Only run if op is available and user is signed in
    if not command -v op >/dev/null 2>&1; or not op account get >/dev/null 2>&1
        return
    end

    # Check if .env file has any secret references
    set -l env_file "$HOME/.config/fish/.env"
    if not test -f "$env_file"; or not grep -q "^export.*=op://" "$env_file" 2>/dev/null
        return
    end

    echo "🔐 1Password auto-sync: First time setup detected"
    echo "   📝 Found secret references in .env file"
    echo "   🚀 Run 'op-sync' to sync your environment variables"
    echo "   💡 This will happen automatically once you run op-sync for the first time"
end

# Run auto-sync check on shell startup
_op_auto_sync_check