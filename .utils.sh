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
    mkdir -p "$HOME/.config"
    mkdir -p "$HOME/.ssh"
    mkdir -p "$HOME/.ssh/sockets"
    mkdir -p "$HOME/.claude"
    mkdir -p "$HOME/.codex"

    # Ensure VSCodium config directory exists before symlinking
    if $IS_MACOS; then
        mkdir -p "$HOME/Library/Application Support/VSCodium/User"
    elif $IS_LINUX; then
        mkdir -p "$HOME/.config/VSCodium/User"
    fi

    # Protect critical SSH files that must never be overwritten
    local protected_ssh_files=(
        "$HOME/.ssh/authorized_keys"
    )
    for protected in "${protected_ssh_files[@]}"; do
        if [[ -f "$protected" ]]; then
            chmod 600 "$protected"
            log "Protected SSH file preserved: $protected"
        fi
    done

    # Define symlinks as source:target pairs
    local symlink_pairs=(
        "$DOTFILES_ROOT/.zshrc:$HOME/.zshrc"
        "$DOTFILES_ROOT/.zshenv:$HOME/.zshenv"
        "$DOTFILES_ROOT/.starship:$HOME/.config/starship.toml"
        "$DOTFILES_ROOT/.ssh/config:$HOME/.ssh/config"
        "$DOTFILES_ROOT/.ghostty:$HOME/.config/ghostty"
        "$DOTFILES_ROOT/.lazydocker:$HOME/.config/lazydocker"
        # AI CLI — shared content (Claude Code + Codex CLI)
        # Only put files in .ai/common when both CLIs support them.
        "$DOTFILES_ROOT/.ai/common/instructions.md:$HOME/.claude/CLAUDE.md"
        "$DOTFILES_ROOT/.ai/common/instructions.md:$HOME/.codex/instructions.md"
        "$DOTFILES_ROOT/.ai/common/commands:$HOME/.claude/commands"
        "$DOTFILES_ROOT/.ai/common/commands:$HOME/.codex/prompts"
        "$DOTFILES_ROOT/.ai/common/skills:$HOME/.claude/skills"
        "$DOTFILES_ROOT/.ai/common/skills:$HOME/.codex/skills"
        "$DOTFILES_ROOT/.ai/common/hooks:$HOME/.claude/hooks"
        "$DOTFILES_ROOT/.ai/common/hooks:$HOME/.codex/hooks"
        # AI CLI — Claude Code only
        "$DOTFILES_ROOT/.ai/claude/settings.json:$HOME/.claude/settings.json"
        "$DOTFILES_ROOT/.ai/claude/config:$HOME/.claude/config"
        # AI CLI — Codex CLI only
        "$DOTFILES_ROOT/.ai/codex/config.toml:$HOME/.codex/config.toml"
        "$DOTFILES_ROOT/.ai/codex/hooks.json:$HOME/.codex/hooks.json"
    )

    # Platform-specific symlinks
    if $IS_MACOS; then
        symlink_pairs+=(
            "$DOTFILES_ROOT/.vscodium/settings.json:$HOME/Library/Application Support/VSCodium/User/settings.json"
        )
    elif $IS_LINUX; then
        symlink_pairs+=(
            "$DOTFILES_ROOT/.vscodium/settings.json:$HOME/.config/VSCodium/User/settings.json"
        )
    fi

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

    # Remove stale symlinks from previous layouts
    # (sources moved: dotfiles/.claude/ → dotfiles/.ai/ → dotfiles/.ai/common/)
    for old_link in "$HOME/.claude/CLAUDE.md" "$HOME/.claude/commands" "$HOME/.claude/skills" \
                    "$HOME/.claude/hooks" "$HOME/.claude/settings.json" "$HOME/.claude/config" \
                    "$HOME/.claude/statusline-command.sh" \
                    "$HOME/.codex/instructions.md" "$HOME/.codex/prompts" "$HOME/.codex/skills" \
                    "$HOME/.codex/hooks" "$HOME/.codex/hooks.json" "$HOME/.codex/config.toml"; do
        if [[ -L "$old_link" ]]; then
            local target
            target="$(readlink "$old_link")"
            if [[ "$target" == *"/dotfiles/.claude/"* || "$target" == *"/dotfiles/.ai/instructions"* \
               || "$target" == *"/dotfiles/.ai/commands"* || "$target" == *"/dotfiles/.ai/skills"* \
               || "$target" == *"/dotfiles/.ai/hooks"* || ! -e "$old_link" ]]; then
                rm "$old_link"
                log "Removed stale symlink (old layout): $old_link"
            fi
        elif [[ -d "$old_link" && ! -L "$old_link" ]]; then
            rm -rf "$old_link"
            log "Removed old directory (now a directory symlink): $old_link"
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
        elif [[ -e "$target" && "$target" == *"/.ssh/"* ]]; then
            warning "Refusing to overwrite non-symlink SSH file: $target"
            continue
        fi

        # Create symlink
        ln -sf "$source" "$target"
        log "Created symlink: $target -> $source"
    done


    # Warn if authorized_keys is missing (SSH login will fail)
    if [[ ! -f "$HOME/.ssh/authorized_keys" ]]; then
        warning "~/.ssh/authorized_keys does not exist — SSH key login will not work!"
        warning "Add your public key: cat your_key.pub >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
    fi

    success "Symbolic links created"
}

# Install Homebrew packages
install_packages() {
    log "Installing Homebrew packages..."

    if [[ -f "$DOTFILES_ROOT/.brewfile" ]]; then
        if $IS_LINUX; then
            # Filter out cask entries (macOS-only) for Linux
            grep -v '^cask[[:space:]]' "$DOTFILES_ROOT/.brewfile" | brew bundle --file=- || warning "Some Homebrew packages failed to install"
        else
            brew bundle --file="$DOTFILES_ROOT/.brewfile" || warning "Some Homebrew packages failed to install"
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

# Install custom MOTD scripts (Linux only, requires sudo)
install_motd() {
    if ! $IS_LINUX; then
        return
    fi

    local motd_dir="$DOTFILES_ROOT/.motd"
    if [[ ! -d "$motd_dir" ]]; then
        warning "MOTD directory not found: $motd_dir"
        return
    fi

    echo
    log "Custom MOTD scripts found in dotfiles."
    log "This will copy them to /etc/update-motd.d/ (requires sudo)."
    printf "${BLUE}[INFO]${NC} Install custom MOTD scripts? [y/N] "
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        log "Skipping MOTD installation"
        return
    fi

    # Disable default Ubuntu MOTD scripts that conflict with custom ones
    local disable_scripts=("00-header" "10-help-text" "50-landscape-sysinfo" "50-motd-news")
    for script in "${disable_scripts[@]}"; do
        if [[ -x "/etc/update-motd.d/$script" ]]; then
            sudo chmod -x "/etc/update-motd.d/$script"
            log "Disabled default MOTD script: $script"
        fi
    done

    # Copy custom MOTD scripts
    for script in "$motd_dir"/*; do
        local name="$(basename "$script")"
        sudo cp "$script" "/etc/update-motd.d/$name"
        sudo chmod 750 "/etc/update-motd.d/$name"
        sudo chown root:root "/etc/update-motd.d/$name"
        log "Installed MOTD script: $name"
    done

    success "Custom MOTD scripts installed"
}

# Install VSCodium extensions from extensions.txt
install_vscodium_extensions() {
    local extensions_file="$DOTFILES_ROOT/.vscodium/extensions.txt"

    if [[ ! -f "$extensions_file" ]]; then
        warning "VSCodium extensions file not found: $extensions_file"
        return
    fi

    if ! command -v codium &> /dev/null; then
        warning "VSCodium not installed — skipping extension installation"
        return
    fi

    log "Installing VSCodium extensions..."

    local installed=0
    local failed=0
    while IFS= read -r ext || [[ -n "$ext" ]]; do
        # Skip empty lines and comments
        [[ -z "$ext" || "$ext" == \#* ]] && continue
        # Trim leading/trailing whitespace
        ext="${ext#"${ext%%[![:space:]]*}"}"
        ext="${ext%"${ext##*[![:space:]]}"}"
        [[ -z "$ext" ]] && continue

        if codium --install-extension "$ext" --force; then
            installed=$((installed + 1))
        else
            warning "Failed to install extension: $ext"
            failed=$((failed + 1))
        fi
    done < "$extensions_file"

    if [[ $failed -eq 0 ]]; then
        success "All $installed VSCodium extensions installed"
    else
        warning "$installed extensions installed, $failed failed"
    fi
}

# Sync currently installed VSCodium extensions back to extensions.txt
sync_vscodium_extensions() {
    local extensions_file="$DOTFILES_ROOT/.vscodium/extensions.txt"

    if ! command -v codium &> /dev/null; then
        warning "VSCodium not installed — skipping extension sync"
        return
    fi

    log "Syncing VSCodium extensions to extensions.txt..."

    codium --list-extensions | sort > "$extensions_file"

    success "VSCodium extensions synced ($(wc -l < "$extensions_file" | tr -d ' ') extensions)"
}

# Apply custom macOS application icons (must run after brew installs/upgrades)
apply_custom_icons() {
    if ! $IS_MACOS; then
        return
    fi

    if ! command -v fileicon &> /dev/null; then
        warning "fileicon not installed — skipping custom icon application"
        warning "Install with: brew install fileicon"
        return
    fi

    # Map: app path -> icon file in dotfiles
    local icon_pairs=(
        "/Applications/VSCodium.app:$DOTFILES_ROOT/.vscodium/icon.icns"
        # Add more apps here as needed
    )

    for pair in "${icon_pairs[@]}"; do
        local app="${pair%:*}"
        local icon="${pair#*:}"

        if [[ -d "$app" && -f "$icon" ]]; then
            if fileicon set "$app" "$icon" 2>/dev/null; then
                log "Applied custom icon to $(basename "$app")"
            else
                warning "Failed to apply custom icon to $(basename "$app")"
            fi
        fi
    done
}

# Install Claude Code plugins listed in settings.json
install_claude_plugins() {
    if ! command -v claude &> /dev/null; then
        warning "Claude Code not found — skipping plugin installation"
        return
    fi

    if ! command -v jq &> /dev/null; then
        warning "jq not found — skipping Claude Code plugin installation"
        return
    fi

    log "Installing Claude Code plugins..."

    local settings_file="$DOTFILES_ROOT/.ai/claude/settings.json"
    local plugins=()

    mapfile -t plugins < <(jq -r '
        .enabledPlugins // {}
        | to_entries[]
        | select(.value == true)
        | .key
    ' "$settings_file")

    if [[ ${#plugins[@]} -eq 0 ]]; then
        log "No enabled Claude Code plugins found in settings.json"
        return
    fi

    for plugin in "${plugins[@]}"; do
        log "Installing plugin: $plugin"
        claude plugin install "$plugin" || warning "Failed to install plugin: $plugin"
    done

    success "Claude Code plugins installed"
}
