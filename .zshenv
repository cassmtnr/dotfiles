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

# Keep Homebrew cask installs user-owned on macOS. Cask's appdir default is a
# flat /Applications regardless of HOMEBREW_PREFIX — a user-level prefix does
# NOT imply user-level apps — so without this, casks land in /Applications and
# ask for admin. Mirrored in ensure_brew_path (lib/common.sh) for install.sh,
# which runs under bash and never sources this file.
if [[ "$OSTYPE" == "darwin"* ]]; then
    export HOMEBREW_CASK_OPTS="${HOMEBREW_CASK_OPTS:---appdir=$HOME/Applications --fontdir=$HOME/Library/Fonts}"
fi

# :-/opt/homebrew fallback: with HOMEBREW_PREFIX unset, $HOMEBREW_PREFIX/bin
# would expand to literal /bin and front-load it ahead of ~/.local/bin
# brew before /usr/local/bin: stale Intel binaries must not shadow ARM brew
# no (N) on ~/.local/bin: install.sh creates it after the shell starts —
# the entry must survive shells opened before the directory exists
typeset -U path
path=(
    ${HOMEBREW_PREFIX:-/opt/homebrew}/bin(N)
    ${HOMEBREW_PREFIX:-/opt/homebrew}/sbin(N)
    /usr/local/bin
    $HOME/.local/bin
    $path
)

# nvm's default-version bin. `npm install -g` puts its binaries here (claude,
# gemini on Linux), and nothing else reaches them: sourcing nvm.sh leaves
# `nvm current` at "system" on both platforms, so the directory never joins
# PATH and every global install looks like it failed. Read the alias file
# rather than sourcing nvm — one read per shell instead of an `nvm use`.
# Appended, so it cannot shadow brew. (N) drops it when the alias names a
# version that is not installed, or points at another alias.
if [[ -r "$NVM_DIR/alias/default" ]]; then
    _nvm_default="$(<"$NVM_DIR/alias/default")"
    path=($path $NVM_DIR/versions/node/v${_nvm_default#v}/bin(N))
    unset _nvm_default
fi

export PATH
