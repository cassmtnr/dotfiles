#!/usr/bin/env bash

# ============================================
# Dotfiles Update Script
# ============================================
# Lightweight alternative to install.sh for day-to-day updates.
# Default: recreate symlinks only. Use flags for more.

set -euo pipefail

# Load shared utilities (OS detection, logging, symlinks, packages, defaults)
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.utils.sh"

# Flags
UPDATE_PACKAGES=false
UPDATE_DEFAULTS=false

show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Update dotfiles symlinks and optionally refresh packages or macOS defaults.

Options:
  -p, --packages    Also update Homebrew packages from .brewfile
  -d, --defaults    Also re-apply macOS system defaults (macOS only)
  -a, --all         Run all update operations (symlinks + packages + defaults)
  -h, --help        Show this help message

Default behavior (no flags): recreate symlinks only.

Examples:
  $(basename "$0")              # Just update symlinks
  $(basename "$0") -p           # Symlinks + brew bundle
  $(basename "$0") --all        # Everything
EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--packages)
                UPDATE_PACKAGES=true
                ;;
            -d|--defaults)
                UPDATE_DEFAULTS=true
                ;;
            -a|--all)
                UPDATE_PACKAGES=true
                UPDATE_DEFAULTS=true
                ;;
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

main() {
    parse_args "$@"

    echo "======================================"
    echo "       Dotfiles Update Script         "
    echo "======================================"
    echo

    # Always update symlinks
    create_symlinks

    # Conditionally update packages
    if $UPDATE_PACKAGES; then
        install_packages
    fi

    # Conditionally apply macOS defaults
    if $UPDATE_DEFAULTS; then
        configure_macos
    fi

    echo
    success "Update complete!"
}

main "$@"
