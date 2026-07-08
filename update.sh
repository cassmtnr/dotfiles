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
UPDATE_PLUGINS=false

show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Update dotfiles symlinks and optionally refresh packages or macOS defaults.

Options:
  -p, --packages    Also update Homebrew packages from .brewfile and pipx tools
  -d, --defaults    Also re-apply macOS system defaults (macOS only)
  -P, --plugins     Also install Claude Code plugins (needs authenticated CLI)
  -a, --all         Run all update operations (symlinks + packages + defaults + plugins)
  -h, --help        Show this help message

Default behavior (no flags): recreate symlinks + sync VSCodium extensions (bidirectional) + skill lint.

Examples:
  $(basename "$0")              # Symlinks + sync extensions + skill lint
  $(basename "$0") -p           # Also update brew packages + pipx tools
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
            -P|--plugins)
                UPDATE_PLUGINS=true
                ;;
            -a|--all)
                UPDATE_PACKAGES=true
                UPDATE_DEFAULTS=true
                UPDATE_PLUGINS=true
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
    sync_vscodium_extensions

    # Lint skills for rot: missing frontmatter, dead links, uninstalled commands
    "$DOTFILES_ROOT/.ai/common/scripts/skill-lint.sh" || \
        warning "Skill lint found issues (see above)"

    # Conditionally update packages
    if $UPDATE_PACKAGES; then
        install_packages
        # pipx tools (agent-reach + channel CLIs; rdt-cli stays at its pinned commit)
        if command -v pipx &> /dev/null; then
            log "Updating pipx tools..."
            pipx upgrade-all || warning "Some pipx upgrades failed"
        fi
        hash -r  # Refresh PATH so newly installed binaries are found
    fi

    # Apply custom icons once (after packages, if updated, so new installs get icons)
    apply_custom_icons

    # Conditionally apply macOS defaults
    if $UPDATE_DEFAULTS; then
        configure_macos
    fi

    # Conditionally install Claude Code plugins (deferred from install.sh
    # when the CLI wasn't authenticated yet)
    if $UPDATE_PLUGINS; then
        install_claude_plugins
    fi

    echo
    success "Update complete!"
}

main "$@"
