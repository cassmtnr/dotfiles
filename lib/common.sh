#!/usr/bin/env bash

# ============================================
# Shared foundation for install.sh and update.sh
# OS detection, logging, Homebrew PATH, NVM, menus
# ============================================

# Variables defined here are consumed by the scripts that source this file
# shellcheck disable=SC2034

# OS detection
IS_MACOS=false
IS_LINUX=false
if [[ "$OSTYPE" == "darwin"* ]]; then
    IS_MACOS=true
elif [[ "$OSTYPE" == "linux"* ]]; then
    IS_LINUX=true
fi

# Human-readable OS label for the setup banners
os_label() {
    if $IS_MACOS; then
        local ver
        ver="$(sw_vers -productVersion 2>/dev/null || true)"
        echo "macOS${ver:+ $ver}"
    elif $IS_LINUX; then
        # Read the distro name without executing /etc/os-release
        local name=""
        name="$(grep -m1 '^PRETTY_NAME=' /etc/os-release 2>/dev/null | cut -d= -f2- | tr -d '"')" || name=""
        echo "Linux${name:+ ($name)}"
    else
        echo "unknown OS"
    fi
}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Repo root — this file lives in lib/, so go up one directory
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Logging functions
log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

# Source NVM into the current shell (idempotent)
# --no-use skips nvm's auto-activation: a cwd .nvmrc for an uninstalled Node
# version makes it return nonzero, aborting the install under set -e.
# setup_nodejs (lib/install.sh) activates a version explicitly; install_ai_clis
# (lib/ai.sh) falls back to the default alias. || warning: any other failure
# while sourcing an external script must not abort the install either.
source_nvm() {
    export NVM_DIR="$HOME/.nvm"
    if [[ -n "${HOMEBREW_PREFIX:-}" && -s "${HOMEBREW_PREFIX:-}/opt/nvm/nvm.sh" ]]; then
        # shellcheck source=/dev/null
        source "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" --no-use || warning "nvm.sh failed to load"
    elif [[ -s "$NVM_DIR/nvm.sh" ]]; then
        # shellcheck source=/dev/null
        source "$NVM_DIR/nvm.sh" --no-use || warning "nvm.sh failed to load"
    fi
}

# Put brew on PATH and export HOMEBREW_PREFIX etc. if installed but not yet
# loaded (fresh shells haven't sourced .zshrc, so brew's shellenv isn't in
# effect). Returns 1 if brew is not installed or broken — a binary whose
# `shellenv` fails (e.g. a half-deleted install) must not count as installed.
# Probe list kept in sync with .zshenv's HOMEBREW_PREFIX detection.
ensure_brew_path() {
    local shellenv_out
    if command -v brew &> /dev/null; then
        # Already loaded (interactive shells export HOMEBREW_PREFIX in .zshenv)
        [[ -n "${HOMEBREW_PREFIX:-}" ]] && return 0
        # On PATH (e.g. via /etc/paths.d) but shellenv not in effect yet
        if shellenv_out="$(brew shellenv 2>/dev/null)"; then
            eval "$shellenv_out"
            return 0
        fi
        # brew on PATH is broken — fall through to the probe loop
    fi
    # Standard prefixes first (fast, bottle-backed), then the no-admin
    # ~/.homebrew fallback (untar install — see install_homebrew)
    local brew_bin
    for brew_bin in /opt/homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/brew "$HOME/.homebrew/bin/brew"; do
        if [[ -x "$brew_bin" ]] && shellenv_out="$("$brew_bin" shellenv 2>/dev/null)"; then
            eval "$shellenv_out"
            return 0
        fi
    done
    return 1
}

# Restore the terminal after choose_many (echo/canonical mode + cursor).
# Relies on dynamic scope: fires while choose_many (which owns saved_stty) is
# still on the call stack, both directly and from its trap.
_choose_restore() {
    if [[ -n "${saved_stty:-}" ]]; then
        stty "$saved_stty" < /dev/tty 2> /dev/null || true
    fi
    printf '\033[?25h' >&2   # show cursor
}

# Checkbox menu with arrow-key navigation. Args: prompt, then "value:label"
# pairs. Keys: up/down (or k/j) move, Space toggles, 'a' toggles all, Enter
# confirms, q/Esc cancels. Prints the selected VALUES to stdout, one per line
# (the menu is drawn to stderr; keys are read from /dev/tty). Cancel prints
# nothing. Caller must ensure a TTY. Pure bash 3.2, zero dependencies:
# no namerefs, no fractional `read -t`, no ESC[6n cursor query.
choose_many() {
    local prompt="$1"; shift
    local options=("$@") n=$# selected=() i cursor=0 first=1 cancelled=0

    if [[ $n -eq 0 ]]; then return 0; fi
    for ((i = 0; i < n; i++)); do selected[i]=0; done

    # Save terminal state; restore on normal return, Ctrl-C, or kill
    local saved_stty
    saved_stty=$(stty -g < /dev/tty)
    trap '_choose_restore; exit 130' INT TERM
    trap '_choose_restore' EXIT
    stty -echo < /dev/tty
    printf '\033[?25l' >&2   # hide cursor

    printf '%s  \033[2m(up/down move · space toggle · a all · enter confirm · q cancel)\033[0m\n' \
        "$prompt" >&2

    local key rest label box
    while true; do
        # Redraw the option lines in place (move the cursor back up after the
        # first draw — no cursor-position query needed)
        if [[ $first -eq 1 ]]; then first=0; else printf '\033[%dA' "$n" >&2; fi
        for ((i = 0; i < n; i++)); do
            label="${options[$i]#*:}"
            if [[ ${selected[$i]} -eq 1 ]]; then box='x'; else box=' '; fi
            if [[ $i -eq $cursor ]]; then
                printf '\r\033[K\033[7m > [%s] %s \033[0m\n' "$box" "$label" >&2
            else
                printf '\r\033[K   [%s] %s\n' "$box" "$label" >&2
            fi
        done

        IFS= read -rsn1 key < /dev/tty || { cancelled=1; break; }
        case "$key" in
            ''|$'\n'|$'\r') break ;;                              # Enter = confirm
            $'\x1b')                                              # arrow keys or bare Esc
                # -t 1 (integer — bash 3.2 has no fractional timeout); arrows
                # deliver their 2 bytes instantly, a bare Esc waits then cancels
                read -rsn2 -t 1 rest < /dev/tty 2> /dev/null || rest=''
                case "$rest" in
                    '[A'|'OA') cursor=$(( (cursor - 1 + n) % n )) ;;  # up (normal/app mode)
                    '[B'|'OB') cursor=$(( (cursor + 1) % n )) ;;      # down
                    '')        cancelled=1; break ;;                  # bare Esc = cancel
                esac ;;
            k|K) cursor=$(( (cursor - 1 + n) % n )) ;;
            j|J) cursor=$(( (cursor + 1) % n )) ;;
            ' ') selected[cursor]=$(( 1 - ${selected[$cursor]} )) ;;
            a|A)                                                  # toggle all on/off
                local all=1
                for ((i = 0; i < n; i++)); do
                    if [[ ${selected[$i]} -eq 0 ]]; then all=0; fi
                done
                for ((i = 0; i < n; i++)); do selected[i]=$(( 1 - all )); done ;;
            q|Q) cancelled=1; break ;;
        esac
    done

    _choose_restore
    trap - INT TERM EXIT

    if [[ $cancelled -eq 1 ]]; then return 0; fi
    for ((i = 0; i < n; i++)); do
        if [[ ${selected[$i]} -eq 1 ]]; then printf '%s\n' "${options[$i]%%:*}"; fi
    done
    return 0
}
