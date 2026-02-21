#!/usr/bin/env bash

# ============================================
# Dotfiles Installation Script
# ============================================

set -euo pipefail  # Exit on error, undefined variable, or pipe failure

# OS detection
IS_MACOS=false
IS_LINUX=false
if [[ "$OSTYPE" == "darwin"* ]]; then
    IS_MACOS=true
elif [[ "$OSTYPE" == "linux"* ]]; then
    IS_LINUX=true
fi

# Show welcome message first
echo "======================================"
echo "     Dotfiles Installation Script     "
echo "======================================"
echo
echo "This script will install and configure:"
echo "  • Homebrew package manager"
echo "  • Oh My Zsh shell framework"
echo "  • Starship prompt"
echo "  • Node.js environment via NVM"
echo "  • Bun JavaScript runtime"
echo "  • Essential development tools"
if $IS_MACOS; then
    echo "  • MacOS system optimizations"
fi
echo "  • Configuration file symlinks"
echo
echo "Administrative privileges are required for system configuration."
echo "Please enter your password to continue:"
sudo -v


# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Logging functions
log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

# Help function
show_help() {
    cat << EOF
Usage: $(basename "$0")

Install dotfiles and configure system with full setup including applications.

This script will:
- Install Homebrew and packages
- Install Oh My Zsh
- Create symbolic links for dotfiles
- Configure MacOS defaults (macOS only)

Run without any arguments to start the installation.

For help: $(basename "$0") --help
EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
        shift
    done
}

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."

    # Check OS
    if ! $IS_MACOS && ! $IS_LINUX; then
        error "This script supports MacOS and Linux only."
        exit 1
    fi

    # Check for required commands
    local required_commands=("git" "curl")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            error "$cmd is required but not installed"
            return 1
        fi
    done

    success "Prerequisites check passed"
}


# Install system dependencies
install_deps() {
    log "Checking system dependencies..."

    local missing=()
    for cmd in zsh git curl; do
        if ! command -v "$cmd" &> /dev/null; then
            missing+=("$cmd")
        fi
    done

    if $IS_LINUX; then
        if ! dpkg -s build-essential &> /dev/null; then
            missing+=("build-essential")
        fi
    fi

    if [[ ${#missing[@]} -eq 0 ]]; then
        log "All system dependencies already installed"
        return
    fi

    log "Installing: ${missing[*]}"
    if $IS_MACOS; then
        xcode-select --install 2>/dev/null || true
    elif $IS_LINUX; then
        sudo apt-get update
        sudo apt-get install -y "${missing[@]}"
    fi

    success "System dependencies installed"
}

# Install Homebrew
install_homebrew() {
    if command -v brew &> /dev/null; then
        log "Homebrew already installed"
        return
    fi

    log "Installing Homebrew..."

    # Homebrew installation script handles its own sudo requests
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    elif [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi

    success "Homebrew installed"
}

# Install Oh My Zsh
install_oh_my_zsh() {
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log "Oh My Zsh already installed"
        return
    fi

    log "Installing Oh My Zsh..."

    # Prevent Oh My Zsh from replacing .zshrc
    export KEEP_ZSHRC=yes
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    unset KEEP_ZSHRC

    success "Oh My Zsh installed"
}

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
        "$DOTFILES_ROOT/.claude/statusline-command.ts:$HOME/.claude/statusline-command.ts"
        "$DOTFILES_ROOT/.claude/commands:$HOME/.claude/commands"
    )

    # Create conditional symlinks for private configs (only if they exist)
    local private_configs=(
        "$DOTFILES_ROOT/.zshrc.local:$HOME/.zshrc.local"
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
            grep -v '^cask ' "$DOTFILES_ROOT/.brewfile" | brew bundle --file=-
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
        log "Skipping MacOS configuration (not on MacOS)"
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

# Setup Node.js environment
setup_nodejs() {
    log "Setting up Node.js environment..."

    if [[ -f "$DOTFILES_ROOT/.node" ]]; then
        log "Running Node.js setup script..."
        # Execute the Node.js script and automatically handle the shell restart requirement
        if bash "$DOTFILES_ROOT/.node"; then
            success "Node.js setup complete"
        else
            log "NVM requires shell environment reload - executing source command..."
            # Reload the shell environment to make NVM available
            if [[ -f "$HOME/.zshrc" ]]; then
                source "$HOME/.zshrc" 2>/dev/null || true
            fi
            # Try the Node.js setup again after reloading
            bash "$DOTFILES_ROOT/.node" || warning "Node.js setup may require manual shell restart"
        fi
    else
        log "Node.js setup script not found, skipping..."
    fi
}


# Setup Bun runtime
setup_bun() {
    log "Setting up Bun JavaScript runtime..."

    # Check if Bun is already installed
    if command -v bun &> /dev/null; then
        log "Bun is already installed ($(bun --version))"
        return 0
    fi

    log "Installing Bun..."

    # Install Bun using official installer
    if curl -fsSL https://bun.sh/install | bash; then
        # Add Bun to PATH for current session
        export BUN_INSTALL="$HOME/.bun"
        export PATH="$BUN_INSTALL/bin:$PATH"

        # Verify installation
        if command -v bun &> /dev/null; then
            success "Bun installed successfully ($(bun --version))"
        else
            warning "Bun installed but not found in PATH - restart your shell"
        fi
    else
        warning "Bun installation failed - you can install manually later with: curl -fsSL https://bun.sh/install | bash"
        return 1
    fi

    # Install global packages
    local packages=(
        yarn
        typescript
        eslint
        nodemon
        @anthropic-ai/claude-code
        @google/gemini-cli
    )

    log "Installing global packages via bun..."
    if bun install -g "${packages[@]}"; then
        success "Global packages installed"
    else
        warning "Some packages failed to install"
        warning "You can retry manually with: bun install -g ${packages[*]}"
    fi
}

# Post-installation message
post_install() {
    echo
    success "Installation complete!"
    echo
    log "Final setup - reloading shell configuration..."

    # Automatically source the new shell configuration
    if [[ -f "$HOME/.zshrc" ]]; then
        source "$HOME/.zshrc" 2>/dev/null || true
        success "Shell configuration reloaded"
    fi

    echo
    echo "Your system is now configured! Here's what was installed:"
    echo "  ✓ Homebrew and essential packages"
    echo "  ✓ Oh My Zsh with custom configuration"
    echo "  ✓ Starship prompt for enhanced terminal"
    echo "  ✓ Node.js environment via NVM"
    echo "  ✓ Bun JavaScript runtime"
    if $IS_MACOS; then
        echo "  ✓ MacOS system optimizations"
    fi
    echo "  ✓ Claude Code configuration (CLAUDE.md, statusline, commands)"
    echo "  ✓ Symbolic links for all configurations"
    echo ""
    echo
    echo "Optional next steps:"
    echo "  • Configure your SSH keys in ~/.ssh/"
    echo "  • Customize ~/.zshrc.local for machine-specific settings"
    echo "  • Open a new terminal to see the full configuration"
    echo
    echo "For more information, see: $DOTFILES_ROOT/README.md"
}

# Main installation flow
main() {
    parse_args "$@"

    # Run installation steps
    check_prerequisites || exit 1
    install_deps
    install_homebrew
    install_oh_my_zsh
    create_symlinks
    install_packages
    setup_bun
    setup_nodejs
    configure_macos

    post_install
}

# Run main function
main "$@"