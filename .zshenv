# .zshenv - Environment variables (loaded for all shells)
# This file is sourced on all invocations of the shell

# XDG Base Directory Specification
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Core paths
export DOTFILES_ROOT="$HOME/dotfiles"
export ZSH="$HOME/.oh-my-zsh"

# Development paths
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

# Default programs
export EDITOR="${EDITOR:-nano}"
export VISUAL="${VISUAL:-codium}"
export PAGER="${PAGER:-less}"

# Node.js memory optimization
export NODE_OPTIONS="--max-old-space-size=8192"

# Homebrew paths (macOS and Linux)
# Keep in sync with ensure_brew_path in lib/common.sh
if [[ -f "/opt/homebrew/bin/brew" ]]; then
    export HOMEBREW_PREFIX="/opt/homebrew"
elif [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
    export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
elif [[ -f "$HOME/.homebrew/bin/brew" ]]; then
    export HOMEBREW_PREFIX="$HOME/.homebrew"
fi

# Path construction
# :-/opt/homebrew fallback: with HOMEBREW_PREFIX unset, $HOMEBREW_PREFIX/bin
# would expand to literal /bin and front-load it ahead of ~/.local/bin
typeset -U path
path=(
    /usr/local/bin
    ${HOMEBREW_PREFIX:-/opt/homebrew}/bin(N)
    ${HOMEBREW_PREFIX:-/opt/homebrew}/sbin(N)
    $HOME/.local/bin(N)
    $path
)

export PATH
