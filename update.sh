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

Default behavior (no flags): recreate symlinks + sync VSCodium extensions (bidirectional).

Examples:
  $(basename "$0")              # Symlinks + sync extensions
  $(basename "$0") -p           # Also update brew packages
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

    # Always update symlinks and sync extensions (bidirectional)
    create_symlinks
    apply_custom_icons
    sync_vscodium_extensions

    # Conditionally update packages
    if $UPDATE_PACKAGES; then
        install_packages
        hash -r  # Refresh PATH so newly installed binaries are found
        apply_custom_icons
    fi

    # Conditionally apply macOS defaults
    if $UPDATE_DEFAULTS; then
        configure_macos
    fi

    echo
    success "Update complete!"
}

main "$@"
