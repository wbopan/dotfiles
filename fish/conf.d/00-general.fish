# Core utilities and settings
set -U fish_greeting ""

# # Load VSCode shell integration if in VSCode terminal
# VS Code shell integration for fish, including tmux passthrough
if test "$TERM_PROGRAM" = vscode
    # 1) 更稳的 fish 脚本路径（有些环境默认路径不会生效）
    set -l _vsc_fish (code --locate-shell-integration-path fish 2>/dev/null)
    set -l _vsc_vendor (echo $_vsc_fish | sed -e 's|common/scripts/shellIntegration.fish|browser/media/fish_xdg_data/fish/vendor_conf.d/shellIntegration.fish|')
    if test -r "$_vsc_vendor"
        source "$_vsc_vendor"
    else if test -r "$_vsc_fish"
        source "$_vsc_fish"
    end

    # 2) 在 tmux 中发送最小 VS Code 标记，并用 DCS 透传
    function __vsc_tmux_passthrough --argument payload
        set -l esc (printf '\e')
        set -l doubled "$esc$esc"
        set -l safe (string replace -a -- $esc $doubled -- $payload)
        printf '\ePtmux;%s\e\\' $safe
    end

    # 提示开始/结束 + cwd，匹配 VS Code 文档的 A/B/7 序列
    function __vsc_prompt_marks --on-event fish_prompt
        if set -q TMUX
            __vsc_tmux_passthrough (printf '\e]633;A\e\\') # PromptStart
            __vsc_tmux_passthrough (printf '\e]633;B\e\\') # PromptEnd
            __vsc_tmux_passthrough (printf '\e]7;file://%s%s\e\\' (hostname) (pwd)) # CWD
        end
    end

    # 命令执行前后标记（C/D），D 带上退出码
    function __vsc_pre --on-event fish_preexec
        if set -q TMUX
            __vsc_tmux_passthrough (printf '\e]633;C\e\\') # CommandStart
        end
    end
    function __vsc_post --on-event fish_postexec
        if set -q TMUX
            __vsc_tmux_passthrough (printf '\e]633;D;exit=%d\e\\' $status) # CommandFinished
        end
    end
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
                if test "$key" != _
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
