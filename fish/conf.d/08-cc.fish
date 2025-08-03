# Hook handler for CC notifications
function cc_hook_handler
    # Read JSON input from stdin
    set -l json_input (cat 2>/dev/null || echo '{}')
    
    # Extract information silently
    set -l hook_type (echo $json_input | jq -r '.hook_type // "unknown"' 2>/dev/null || echo "unknown")
    set -l tool_name (echo $json_input | jq -r '.tool_name // "unknown"' 2>/dev/null || echo "unknown")
    set -l description (echo $json_input | jq -r '.tool_input.description // "No description"' 2>/dev/null || echo "No description")
    
    # Send notification
    notify "CC: Waiting for Input" "Awaiting your response"
    
    return 0
end

# Auto-configure CC hooks
function cc_setup_hooks
    set -l settings_file "$HOME/.claude/settings.json"
    set -l hooks_config '{
        "hooks": {
            "Notification": [{
                "matcher": "*", 
                "hooks": [{
                    "type": "command",
                    "command": "fish -c \"cc_hook_handler\""
                }]
            }]
        }
    }'
    
    # Ensure .claude directory exists
    mkdir -p "$HOME/.claude" 2>/dev/null
    
    # Check if settings file exists
    if test -f "$settings_file"
        # Check if our specific hooks are already configured
        set -l has_cc_hooks (jq '.hooks.Notification[]? | select(.hooks[]?.command | contains("cc_hook_handler"))' "$settings_file" 2>/dev/null | grep -q . && echo "true" || echo "false")
        
        if test "$has_cc_hooks" = "false"
            # Check if hooks section exists at all
            set -l has_hooks (jq 'has("hooks")' "$settings_file" 2>/dev/null || echo "false")
            
            if test "$has_hooks" = "false"
                # Merge hooks into existing settings
                if jq ". + $hooks_config" "$settings_file" > "$settings_file.tmp" 2>/dev/null && mv "$settings_file.tmp" "$settings_file" 2>/dev/null
                    echo "CC hooks configured in settings.json"
                end
            else
                # Settings has hooks but not our cc_hook_handler
                if jq '.hooks.Notification += [{"matcher": "*", "hooks": [{"type": "command", "command": "fish -c \"cc_hook_handler\""}]}]' "$settings_file" > "$settings_file.tmp" 2>/dev/null && mv "$settings_file.tmp" "$settings_file" 2>/dev/null
                    echo "CC hooks added to existing settings.json"
                end
            end
        end
    else
        # Create new settings file with hooks
        if echo $hooks_config | jq '.' > "$settings_file" 2>/dev/null
            echo "Created CC settings with hooks"
        end
    end
end

# Run setup automatically on shell startup (only if settings exists without our hooks)
cc_setup_hooks
