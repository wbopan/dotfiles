# Show current 1Password CLI integration status
function op-status --description "Show 1Password integration status"
    echo "1Password status"

    if command -v op >/dev/null 2>&1
        echo "  op CLI: installed"
        if op account get >/dev/null 2>&1
            if command -v jq >/dev/null 2>&1
                set -l account_info (op account get --format=json 2>/dev/null | jq -r '.email // .user_uuid // "unknown account"')
                echo "  signed in: yes ($account_info)"
            else
                echo "  signed in: yes"
                echo "  (install jq for detailed account info)"
            end
        else
            echo "  signed in: no"
        end
    else
        echo "  op CLI: not installed"
    end

    set -l profile_file ~/.profile
    set -l export_count 0
    if test -f "$profile_file"
        set export_count (grep -c "^export" "$profile_file" 2>/dev/null)
        if test $status -ne 0
            set export_count 0
        end
    end
    echo "  profile exports: $export_count"
end
