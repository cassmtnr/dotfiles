#!/usr/bin/env bash

# ============================================
# Dotfiles Update Script
# ============================================
# Lightweight alternative to install.sh for day-to-day updates.
# Default: symlinks + VSCodium extension sync. Flags for more.
# AI tooling is separate — it's step 4 of ./install.sh (opt-in).

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"
source "$DOTFILES_ROOT/lib/ui.sh"
source "$DOTFILES_ROOT/lib/install.sh"
source "$DOTFILES_ROOT/lib/configure.sh"
source "$DOTFILES_ROOT/lib/ai.sh"

# Flags
UPDATE_PACKAGES=false
UPDATE_DEFAULTS=false

show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Update dotfiles symlinks and optionally refresh packages or macOS defaults.

Options:
  -p, --packages    Also update Homebrew packages from .brewfile
  -d, --defaults    Also re-apply user-level macOS defaults (macOS only)
  -a, --all         Run all update operations (symlinks + packages + defaults)
  -v, --verbose     Show full command output instead of one line per step
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
            -v|--verbose)
                # shellcheck disable=SC2034
                VERBOSE=true
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

    ui_header "Dotfiles update — $(os_label)"

    # Fresh shells may not have brew's bin dir on PATH, hiding brew-installed
    # binaries the steps below check for (codium)
    ensure_brew_path || true

    # Always update symlinks and sync extensions (bidirectional)
    run_step "Symlink dotfiles into \$HOME"  create_symlinks
    run_step "AI config repo (.ai)"          update_ai_repo
    run_step "VSCodium extension sync"       sync_vscodium_extensions

    # Conditionally update Homebrew packages (casks skipped on Linux)
    if $UPDATE_PACKAGES; then run_step "Homebrew packages" install_packages; fi

    # Conditionally apply user-level macOS defaults (system-level ones are
    # an install.sh extra: macos-admin)
    if $UPDATE_DEFAULTS; then run_step "macOS defaults (user-level)" apply_macos_defaults false; fi

    # Last command on purpose: failed steps fail the run
    ui_summary
}

main "$@"
