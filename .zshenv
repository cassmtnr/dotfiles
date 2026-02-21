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
export EDITOR="${EDITOR:-vim}"
export VISUAL="${VISUAL:-code}"
export PAGER="${PAGER:-less}"

# Node.js memory optimization
export NODE_OPTIONS="--max-old-space-size=8192"

# Homebrew paths (macOS and Linux)
if [[ -f "/opt/homebrew/bin/brew" ]]; then
    export HOMEBREW_PREFIX="/opt/homebrew"
elif [[ -f "/usr/local/bin/brew" ]]; then
    export HOMEBREW_PREFIX="/usr/local"
elif [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
    export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
fi

# Path construction
typeset -U path
path=(
    /usr/local/bin
    $HOMEBREW_PREFIX/bin(N)
    $HOMEBREW_PREFIX/sbin(N)
    $HOME/.local/bin(N)
    $HOME/.config/yarn/global/node_modules/.bin(N)
    $path
)

export PATH