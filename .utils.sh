#!/usr/bin/env bash

# ============================================
# Shared utilities for install.sh and update.sh
# ============================================

# OS detection
IS_MACOS=false
IS_LINUX=false
if [[ "$OSTYPE" == "darwin"* ]]; then
    IS_MACOS=true
elif [[ "$OSTYPE" == "linux"* ]]; then
    IS_LINUX=true
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration — resolve from the directory containing this file
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Logging functions
log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

# Create symbolic links
create_symlinks() {
    log "Creating symbolic links..."

    # Ensure target directories exist before symlinking
    mkdir -p "$HOME/.claude/commands"
    mkdir -p "$HOME/.config"
    mkdir -p "$HOME/.ssh"
    mkdir -p "$HOME/.ssh/sockets"

    # Define symlinks as source:target pairs
    local symlink_pairs=(
        "$DOTFILES_ROOT/.zshrc:$HOME/.zshrc"
        "$DOTFILES_ROOT/.zshenv:$HOME/.zshenv"
        "$DOTFILES_ROOT/.starship:$HOME/.config/starship.toml"
        "$DOTFILES_ROOT/.ssh/config:$HOME/.ssh/config"
        "$DOTFILES_ROOT/.ghostty:$HOME/.config/ghostty"
        "$DOTFILES_ROOT/.claude/CLAUDE.md:$HOME/.claude/CLAUDE.md"
        "$DOTFILES_ROOT/.claude/settings.json:$HOME/.claude/settings.json"
        "$DOTFILES_ROOT/.claude/statusline-command.sh:$HOME/.claude/statusline-command.sh"
        # "$DOTFILES_ROOT/.claude/commands:$HOME/.claude/commands"
    )

    # Create conditional symlinks for private configs (only if they exist)
    local private_configs=(
        "$DOTFILES_ROOT/.zshrc.local:$HOME/.zshrc.local"
        "$DOTFILES_ROOT/.ssh/config.local:$HOME/.ssh/config.local"
        "$DOTFILES_ROOT/.ssh/config.work:$HOME/.ssh/config.work"
    )

    # Process private configs
    for pair in "${private_configs[@]}"; do
        local source="${pair%:*}"
        local target="${pair#*:}"

        if [[ -f "$source" ]]; then
            log "Creating symlink for private config: $(basename "$source")"
            # Remove existing file/symlink
            [[ -e "$target" || -L "$target" ]] && rm -f "$target"
            # Create symlink
            ln -sf "$source" "$target"
        fi
    done

    for pair in "${symlink_pairs[@]}"; do
        local source="${pair%:*}"
        local target="${pair#*:}"

        if [[ ! -e "$source" ]]; then
            warning "Source file not found: $source"
            continue
        fi

        # Create parent directory if needed
        local target_dir="$(dirname "$target")"
        if [[ ! -d "$target_dir" ]]; then
            mkdir -p "$target_dir"
        fi

        # Remove existing target if it's a symlink
        if [[ -L "$target" ]]; then
            rm "$target"
        fi

        # Create symlink
        ln -sf "$source" "$target"
        log "Created symlink: $target -> $source"
    done

    success "Symbolic links created"
}

# Install Homebrew packages
install_packages() {
    log "Installing Homebrew packages..."

    if [[ -f "$DOTFILES_ROOT/.brewfile" ]]; then
        if $IS_LINUX; then
            # Filter out cask entries (macOS-only) for Linux
            grep -v '^cask[[:space:]]' "$DOTFILES_ROOT/.brewfile" | brew bundle --file=-
        else
            brew bundle --file="$DOTFILES_ROOT/.brewfile"
        fi
    else
        warning "Brewfile not found"
    fi

    success "Packages installed"
}

# Configure MacOS defaults
configure_macos() {
    if ! $IS_MACOS; then
        warning "macOS defaults skipped (not on macOS)"
        return
    fi

    log "Configuring MacOS defaults..."

    # Run detailed MacOS configuration script if it exists
    if [[ -f "$DOTFILES_ROOT/.defaults" ]]; then
        log "Running detailed MacOS configuration..."
        source "$DOTFILES_ROOT/.defaults"
    else
        # Basic configuration if script not found
        mkdir -p "$HOME/Screenshots"
        defaults write com.apple.screencapture location -string "$HOME/Screenshots"
        defaults write com.apple.finder AppleShowAllFiles -bool true
        defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
        defaults write NSGlobalDomain KeyRepeat -int 2
        defaults write NSGlobalDomain InitialKeyRepeat -int 15
        sudo killall Finder 2>/dev/null || true
    fi

    success "MacOS configured"
}
