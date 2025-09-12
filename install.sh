#!/usr/bin/env bash

# ============================================
# Dotfiles Installation Script
# ============================================

set -euo pipefail  # Exit on error, undefined variable, or pipe failure

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles.backup.$(date +%Y%m%d_%H%M%S)"

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
- Create a backup of your existing configuration
- Install Homebrew and packages
- Install Oh My Zsh
- Create symbolic links for dotfiles
- Configure macOS defaults

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
    if [[ "$OSTYPE" != "darwin"* ]]; then
        warning "This script is designed for macOS. Some features may not work correctly."
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

# Create backup of existing files
create_backup() {
    log "Creating backup in $BACKUP_DIR..."
    
    mkdir -p "$BACKUP_DIR"
    
    # Backup existing dotfiles
    local files_to_backup=(
        ".zshrc"
        ".zshenv"
        ".gitconfig"
        ".ssh/config"
    )
    
    for file in "${files_to_backup[@]}"; do
        if [[ -e "$HOME/$file" ]]; then
            local backup_path="$BACKUP_DIR/$file"
            mkdir -p "$(dirname "$backup_path")"
            cp -R "$HOME/$file" "$backup_path"
            log "Backed up: $file"
        fi
    done
    
    success "Backup created at: $BACKUP_DIR"
}

# Install Homebrew
install_homebrew() {
    if command -v brew &> /dev/null; then
        log "Homebrew already installed"
        return
    fi
    
    log "Installing Homebrew..."
    
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
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
    
    # Define symlinks as source:target pairs
    local symlink_pairs=(
        "$DOTFILES_ROOT/zsh/.zshrc.new:$HOME/.zshrc"
        "$DOTFILES_ROOT/zsh/.zshenv:$HOME/.zshenv"
        "$DOTFILES_ROOT/config/starship.toml:$HOME/.config/starship.toml"
    )
    
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
    
    if [[ -f "$DOTFILES_ROOT/homebrew/Brewfile" ]]; then
        brew bundle --file="$DOTFILES_ROOT/homebrew/Brewfile"
    else
        warning "Brewfile not found"
    fi
    
    success "Packages installed"
}

# Configure macOS defaults
configure_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log "Skipping macOS configuration (not on macOS)"
        return
    fi
    
    log "Configuring macOS defaults..."
    
    # Create Screenshots directory
    mkdir -p "$HOME/Screenshots"
    
    # Set screenshot location
    defaults write com.apple.screencapture location -string "$HOME/Screenshots"
    
    # Show hidden files in Finder
    defaults write com.apple.finder AppleShowAllFiles -bool true
    
    # Disable press-and-hold for keys in favor of key repeat
    defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
    
    # Set fast key repeat rate
    defaults write NSGlobalDomain KeyRepeat -int 2
    defaults write NSGlobalDomain InitialKeyRepeat -int 15
    
    # Restart affected apps
    killall Finder 2>/dev/null || true
    
    success "macOS configured"
}

# Post-installation message
post_install() {
    echo
    success "Installation complete!"
    echo
    echo "Next steps:"
    echo "  1. Restart your terminal or run: source ~/.zshrc"
    echo "  2. Configure your SSH keys in ~/.ssh/"
    echo "  3. Customize ~/.zshrc.local for machine-specific settings"
    echo
    if [[ -d "$BACKUP_DIR" ]]; then
        echo "Your old configuration was backed up to:"
        echo "  $BACKUP_DIR"
        echo
    fi
    echo "For more information, see: $DOTFILES_ROOT/README.md"
}

# Main installation flow
main() {
    echo "======================================"
    echo "     Dotfiles Installation Script     "
    echo "======================================"
    echo
    
    parse_args "$@"
    
    # Run installation steps
    check_prerequisites || exit 1
    create_backup
    install_homebrew
    install_oh_my_zsh
    create_symlinks
    install_packages
    configure_macos
    
    post_install
}

# Run main function
main "$@"