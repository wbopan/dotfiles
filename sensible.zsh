###############################################################################
# ESSENTIAL ZSH OPTIONS
###############################################################################
# Completion behavior
setopt COMPLETE_IN_WORD    # Complete from both ends of a word
setopt ALWAYS_TO_END       # Move cursor to the end of a completed word
setopt AUTO_MENU           # Show completion menu on successive Tab presses
setopt AUTO_LIST           # Automatically list choices on ambiguous completion
setopt AUTO_PARAM_SLASH    # If completed dir, add trailing slash
unsetopt MENU_COMPLETE     # Don't automatically select first completion entry

# Shell editing behavior
setopt EXTENDED_GLOB       # More powerful globbing
unsetopt FLOW_CONTROL      # Disable Ctrl-S/Ctrl-Q flow control in the terminal

# Additional sensible options
setopt prompt_subst        # Allow command substitution in prompts
setopt autocd              # Enter a directory by just typing its name
setopt noclobber           # Prevent overwriting files with '>'
setopt notify              # Immediate job notification
setopt autopushd           # 'cd' works like 'pushd'
setopt pushdignoredups     # Avoid duplicate entries in the directory stack

###############################################################################
# KEYBINDINGS
###############################################################################
# Emacs-style key bindings (common default)
bindkey -e

# Fix Home/End/Insert/Delete keys in many terminals
typeset -A key
key[Home]=${terminfo[khome]}
key[End]=${terminfo[kend]}
key[Insert]=${terminfo[kich1]}
key[Delete]=${terminfo[kdch1]}
[[ -n "${key[Home]}"   ]] && bindkey "${key[Home]}" beginning-of-line
[[ -n "${key[End]}"    ]] && bindkey "${key[End]}" end-of-line
[[ -n "${key[Insert]}" ]] && bindkey "${key[Insert]}" overwrite-mode
[[ -n "${key[Delete]}" ]] && bindkey "${key[Delete]}" delete-char

# “Esc + m” to copy the previous shell word (an Oh-My-Zsh-inspired binding)
bindkey '^[m' copy-prev-shell-word

# Edit the current command in your $EDITOR (Ctrl-X Ctrl-E), as in Bash
autoload edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

# Reverse menu completion with Shift-Tab
bindkey '^[[Z' reverse-menu-complete

###############################################################################
# HISTORY
###############################################################################
# Large, shared history with minimal duplication
HISTFILE=${HISTFILE:-$HOME/.zsh_history}
HISTSIZE=10000
SAVEHIST=10000
setopt share_history       # Share command history across sessions
setopt append_history      # Append to history file (rather than overwrite)
setopt extended_history    # Record timestamp etc. in history
setopt hist_ignore_dups    # Don't store duplicates
setopt hist_ignore_space   # Ignore commands that start with a space
setopt hist_reduce_blanks  # Strip superfluous blanks

###############################################################################
# MISCELLANEOUS SETTINGS
###############################################################################
# Disable Ctrl-S / Ctrl-Q flow control at the TTY level (alternative approach)
stty stop undef

# Locale: ensure UTF-8 support
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

###############################################################################
# CLEANUP TEMPORARY VARIABLES
###############################################################################
unset _cache_dir _comp_files _zcompdump _zcompcache
