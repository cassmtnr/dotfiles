#!/usr/bin/env bash

# ============================================
# Dotfiles Uninstallation Script
# ============================================

set -euo pipefail

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

# Find latest backup
find_latest_backup() {
    local backup_pattern="$HOME/.dotfiles.backup.*"
    local latest_backup=$(ls -dt $backup_pattern 2>/dev/null | head -1)
    echo "$latest_backup"
}

# Remove symlinks
remove_symlinks() {
    log "Removing symbolic links..."
    
    local symlinks=(
        "$HOME/.zshrc"
        "$HOME/.zshenv"
        "$HOME/.config/starship.toml"
    )
    
    for link in "${symlinks[@]}"; do
        if [[ -L "$link" ]]; then
            rm "$link"
            log "Removed symlink: $link"
        fi
    done
    
    success "Symbolic links removed"
}

# Restore from backup
restore_backup() {
    local backup_dir="$1"
    
    if [[ ! -d "$backup_dir" ]]; then
        warning "Backup directory not found: $backup_dir"
        return 1
    fi
    
    log "Restoring from backup: $backup_dir"
    
    # Restore files
    cp -R "$backup_dir"/. "$HOME/" 2>/dev/null || true
    
    success "Files restored from backup"
}

# Main uninstallation
main() {
    echo "======================================"
    echo "    Dotfiles Uninstallation Script    "
    echo "======================================"
    echo
    
    # Check for backup
    local latest_backup=$(find_latest_backup)
    
    if [[ -n "$latest_backup" ]]; then
        echo "Found backup: $latest_backup"
        read -p "Do you want to restore from this backup? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            remove_symlinks
            restore_backup "$latest_backup"
        else
            remove_symlinks
            warning "Skipped backup restoration"
        fi
    else
        warning "No backup found"
        read -p "Continue with uninstallation anyway? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            remove_symlinks
        else
            log "Uninstallation cancelled"
            exit 0
        fi
    fi
    
    echo
    success "Uninstallation complete!"
    echo
    echo "You may want to:"
    echo "  1. Remove the dotfiles directory: rm -rf $DOTFILES_ROOT"
    echo "  2. Restart your terminal"
    echo "  3. Clean up any remaining backup directories"
}

# Run main function
main "$@"