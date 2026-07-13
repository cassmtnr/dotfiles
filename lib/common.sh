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

# Checkbox menu. Args: prompt, then options as "value:label" pairs.
# Toggle entries by number, press Enter to confirm. Prints the selected
# values to stdout, one per line (menu itself goes to stderr).
# Caller must ensure stdin is a TTY.
choose_many() {
    local prompt="$1"; shift
    local options=("$@") selected=() i num
    for i in "${!options[@]}"; do selected[i]=""; done
    while true; do
        echo >&2
        echo "$prompt (toggle by number, Enter to confirm)" >&2
        for i in "${!options[@]}"; do
            printf '  [%s] %d) %s\n' "${selected[$i]:- }" $((i + 1)) "${options[$i]#*:}" >&2
        done
        printf 'Toggle: ' >&2
        # || break: treat EOF (Ctrl-D) as confirm so toggled selections
        # aren't silently discarded
        read -r num || break
        [[ -z "$num" ]] && break
        if [[ "$num" =~ ^[0-9]+$ ]] && (( num >= 1 && num <= ${#options[@]} )); then
            i=$((num - 1))
            if [[ -n "${selected[$i]}" ]]; then selected[i]=""; else selected[i]="x"; fi
        fi
    done
    for i in "${!options[@]}"; do
        [[ -n "${selected[$i]}" ]] && echo "${options[$i]%%:*}"
    done
    return 0
}
