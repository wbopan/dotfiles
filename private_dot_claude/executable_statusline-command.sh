#!/usr/bin/env bash

input=$(cat)

# --- colors (Starship-style bright terminal colors) ---
RST="\033[0m"
GRAY="\033[38;5;245m"
BOLD="\033[1m"
CYAN="\033[1;36m"        # bold bright cyan (directory)
GREEN="\033[1;32m"       # bold bright green (git branch)
YELLOW="\033[1;33m"      # bold bright yellow (warning/duration)
RED="\033[1;31m"         # bold bright red (danger)
PURPLE="\033[1;35m"      # bold bright purple (hostname)

# --- nerd font icons (UTF-8 byte sequences for bash 3.2 compat) ---
ICON_CTX=$(printf '\xF3\xB0\x8A\x9A')    # 󰊚 U+F029A nf-md-gauge
ICON_HOST=$(printf '\xEF\x84\x88')      #  U+F108 desktop
ICON_FOLDER=$(printf '\xEF\x81\xBB')    #  U+F07B folder
ICON_BRANCH=$(printf '\xEE\x82\xA0')    #  U+E0A0 git branch
ICON_CLOCK=$(printf '\xEF\x80\x97')     #  U+F017 clock

# --- hostname ---
host=$(hostname -s)

# --- context window progress bar ---
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
input_tokens=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // empty')
if [ -n "$used_pct" ]; then
  used_int=$(printf "%.0f" "$used_pct")
  filled=$(( used_int / 10 ))
  empty=$(( 10 - filled ))
  filled_bar=""
  empty_bar=""
  for i in $(seq 1 $filled); do filled_bar="${filled_bar}━"; done
  for i in $(seq 1 $empty);  do empty_bar="${empty_bar}─"; done
  # Color based on usage
  if [ "$used_int" -lt 50 ]; then
    bar_color="$GREEN"
  elif [ "$used_int" -lt 80 ]; then
    bar_color="$YELLOW"
  else
    bar_color="$RED"
  fi
  # Format token count as compact string (e.g. 23k, 128k)
  if [ -n "$input_tokens" ] && [ "$input_tokens" != "null" ]; then
    token_k=$(( input_tokens / 1000 ))
    token_label="${token_k}k"
  else
    token_label="?k"
  fi
  ctx_part="${bar_color}${ICON_CTX} [${filled_bar}${GRAY}${empty_bar}${bar_color}]${RST} ${bar_color}${token_label}${RST}"
else
  ctx_part="${GRAY}${ICON_CTX} [──────────]${RST}"
fi

# --- git branch ---
git_branch=$(echo "$input" | jq -r '.workspace.current_dir // empty')
if [ -n "$git_branch" ]; then
  branch=$(git -C "$git_branch" symbolic-ref --short HEAD 2>/dev/null)
fi

# --- short cwd ---
cwd=$(echo "$input" | jq -r '.cwd // empty')
short_cwd=$(echo "$cwd" | sed "s|$HOME|~|")
short_cwd=$(echo "$short_cwd" | awk -F'/' '{
  OFS="/";
  if (NF <= 3) { print; next }
  result=$1;
  for (i=2; i<NF; i++) { result = result "/" substr($i,1,1) }
  result = result "/" $NF;
  print result
}')

# --- session duration ---
transcript=$(echo "$input" | jq -r '.transcript_path // empty')
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
  ctime=$(stat -f %B "$transcript" 2>/dev/null || stat -c %W "$transcript" 2>/dev/null)
  now=$(date +%s)
  elapsed=$(( now - ctime ))
  if [ "$elapsed" -lt 60 ]; then
    session_dur="<1m"
  elif [ "$elapsed" -lt 3600 ]; then
    session_dur="$(( elapsed / 60 ))m"
  else
    session_dur="$(( elapsed / 3600 ))h$(( (elapsed % 3600) / 60 ))m"
  fi
else
  session_dur="?"
fi

# --- git diff stat ---
project_dir=$(echo "$input" | jq -r '.workspace.project_dir // empty')
if [ -n "$project_dir" ]; then
  diff_stat=$(git -C "$project_dir" diff --shortstat HEAD 2>/dev/null | grep -oE '[0-9]+ insertion|[0-9]+ deletion' | awk '
    /insertion/ { ins=$1 }
    /deletion/  { del=$1 }
    END { printf "(+%s,-%s)", ins+0, del+0 }
  ')
fi
[ -z "$diff_stat" ] && diff_stat="(+0,-0)"

# --- assemble (starship style: icons + prepositions, no pipes) ---
printf "%b" "$ctx_part"
printf " ${GRAY}·${RST} ${PURPLE}${ICON_HOST} %s${RST}" "$host"
if [ -n "$branch" ]; then
  printf " ${GRAY}on${RST} ${GREEN}${ICON_BRANCH} %s${RST}" "$branch"
fi
printf " ${GRAY}in${RST} ${CYAN}${ICON_FOLDER} %s${RST}" "$short_cwd"
if [ "$diff_stat" != "(+0,-0)" ]; then
  printf " ${YELLOW}%s${RST}" "$diff_stat"
fi
printf " ${GRAY}took ${ICON_CLOCK} %s${RST}" "$session_dur"
