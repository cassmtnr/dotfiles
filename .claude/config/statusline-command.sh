#!/usr/bin/env bash
# Claude Code statusline — portable, no runtime dependency beyond jq

set -euo pipefail

# Colors (using $'...' so escapes resolve at assignment, not at output time)
RST=$'\033[0m'
CYAN=$'\033[36m'
MAGENTA=$'\033[35m'
BLUE=$'\033[34m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'

# Read JSON from stdin (Claude Code pipes session data)
INPUT="$(cat)"

# Parse fields with jq
CWD="$(echo "$INPUT" | jq -r '.workspace.current_dir // .cwd // ""')"
PROJECT="$(basename "$CWD")"
SESSION_ID="$(echo "$INPUT" | jq -r '.session_id // empty')"
SESSION_NAME="$(echo "$INPUT" | jq -r '.session_name // empty')"
REMAINING="$(echo "$INPUT" | jq -r '.context_window.remaining_percentage // empty')"
MODEL="$(echo "$INPUT" | jq -r '.model.display_name // empty')"

# Line 1: [user] project [on branch]
LINE1=""
if [[ -n "${SSH_CONNECTION:-}" ]]; then
    LINE1+="${BLUE}$(whoami)${RST} "
fi
LINE1+="${CYAN}${PROJECT}${RST}"

BRANCH="$(git branch --show-current 2>/dev/null || git rev-parse --short HEAD 2>/dev/null || true)"
if [[ -n "$BRANCH" ]]; then
    LINE1+=" on ${MAGENTA}🌱 ${BRANCH}${RST}"
fi

# Line 2: session + context + model
PARTS=""
if [[ -n "$SESSION_ID" ]]; then
    if [[ -n "$SESSION_NAME" ]]; then
        PARTS+="${MAGENTA}${SESSION_NAME} · sid: ${SESSION_ID}${RST}"
    else
        PARTS+="${MAGENTA}sid: ${SESSION_ID}${RST}"
    fi
fi

if [[ -n "$REMAINING" ]]; then
    RND="${REMAINING%%.*}"
    if (( RND < 20 )); then
        CTX_COLOR="$RED"
    elif (( RND < 50 )); then
        CTX_COLOR="$YELLOW"
    else
        CTX_COLOR="$GREEN"
    fi
    [[ -n "$PARTS" ]] && PARTS+=" "
    PARTS+="${CTX_COLOR}[ctx: ${RND}%]${RST}"
fi

if [[ -n "$MODEL" ]]; then
    [[ -n "$PARTS" ]] && PARTS+=" "
    PARTS+="[${CYAN}${MODEL}${RST}]"
fi

echo "$LINE1"
echo "$PARTS"
