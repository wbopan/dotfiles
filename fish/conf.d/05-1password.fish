# 1Password CLI Integration startup helpers

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

    echo "1Password auto-sync: First time setup detected"
    echo "   Found secret references in .env file"
    echo "   Run 'op-sync' to sync your environment variables"
    echo "   This will happen automatically once you run op-sync for the first time"
end

# Run auto-sync check on shell startup
# Disabled automatic 1Password check on startup to prevent authentication prompts. Run 'op-status' manually to check 1Password integration.
# _op_auto_sync_check
