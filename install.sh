#!/usr/bin/env bash

# ============================================
# Dotfiles setup — four steps
#   1. Install software        (shell, dev toolchain, apps from .brewfile)
#   2. Apply personal config   (symlinks, defaults — always user-level)
#   3. Optional extras         (sudo/admin needs are labeled explicitly)
#   4. AI tools                (Claude Code / Codex / agent-reach — opt-in)
#
# Steps 3 and 4 are checkbox menus with nothing pre-selected, and are skipped
# without a terminal — so a plain/non-interactive install sets up NO extras
# and NO AI.
#
# Every choice is an interactive menu; the only flag is --verbose (full
# command output instead of one status line per step).
# ============================================

set -euo pipefail  # Exit on error, undefined variable, or pipe failure

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"
source "$DOTFILES_ROOT/lib/ui.sh"
source "$DOTFILES_ROOT/lib/install.sh"
source "$DOTFILES_ROOT/lib/configure.sh"
source "$DOTFILES_ROOT/lib/extras.sh"
source "$DOTFILES_ROOT/lib/ai.sh"

# RUN_SUDO: whether steps that need administrative privileges run at all.
# Default by platform: Linux (servers, we have root) uses sudo; macOS and
# anything else (laptops, often managed without admin rights) does not.
# Confirmed interactively; auto-disabled if the sudo prompt fails.
if $IS_LINUX; then
    RUN_SUDO=true
else
    RUN_SUDO=false
fi

show_help() {
    cat << EOF
Usage: $(basename "$0")

Set up this machine in four steps:
  1. Install software (shell, dev toolchain, apps) from .brewfile.
     GUI apps are Homebrew casks — installed on macOS, skipped on Linux.
  2. Apply personal configuration (symlinks, user-level defaults)
  3. Optional extras picked from a checkbox menu — anything that needs
     sudo/admin says so in its label and only runs if you select it
  4. AI tools picked from a checkbox menu — Claude Code, Codex config,
     agent-reach, plugins. Nothing is pre-selected.

Steps 3 and 4 are skipped without a terminal, so a plain or non-interactive
install (piped over SSH, CI) sets up no extras and no AI, and only asks for
sudo where the platform default allows it (Linux yes, macOS no).

Options:
  -v, --verbose   Show full command output instead of one line per step

All choices are interactive menus — nothing to memorize. Idempotent — re-run
anytime.
EOF
}

parse_args() {
    # Loop, not a single case: with more than one flag advertised, `case "$1"`
    # silently ignored everything after the first argument.
    # VERBOSE is consumed by lib/ui.sh (run_step)
    # shellcheck disable=SC2034
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -v|--verbose) VERBOSE=true ;;
            -h|--help) show_help; exit 0 ;;
            *) error "Unknown option: $1"; show_help; exit 1 ;;
        esac
        shift
    done
}

# Confirm whether privileged steps may run (platform default), then prime
# sudo; degrade to user-level mode if the prompt fails
confirm_sudo() {
    local def="n"
    $RUN_SUDO && def="y"
    if ui_confirm "Allow steps that need admin rights (Homebrew bootstrap, system packages)?" "$def"; then
        RUN_SUDO=true
    else
        RUN_SUDO=false
    fi
    if ! $RUN_SUDO; then
        log "Running user-level — steps that need admin rights will be skipped"
        return
    fi
    if ! sudo -v; then
        warning "Could not obtain administrative privileges — continuing user-level"
        RUN_SUDO=false
    fi
}

check_prerequisites() {
    log "Checking prerequisites..."

    if ! $IS_MACOS && ! $IS_LINUX; then
        error "This script supports MacOS and Linux only."
        exit 1
    fi

    local required_commands=("git" "curl")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            error "$cmd is required but not installed"
            return 1
        fi
    done

    success "Prerequisites check passed"
}

# $1: the run's exit status — a nonzero run must not exec into zsh, because
# exec replaces the process and throws that status away
post_install() {
    local status="${1:-0}"
    echo
    if [[ "$status" -eq 0 ]]; then
        success "Setup complete!"
    else
        warning "Setup finished with failures — see the summary above."
    fi
    echo
    echo "Optional next steps:"
    echo "  • Configure your SSH keys in ~/.ssh/"
    echo "  • Customize ~/.zshrc.local for machine-specific settings"
    echo "  • Re-run ./install.sh anytime to add extras or AI tools"
    echo
    echo "For more information, see: $DOTFILES_ROOT/README.md"

    if ${CLAUDE_PLUGINS_PENDING:-false}; then
        echo
        warning "Claude Code plugins were skipped (CLI not logged in)."
        echo "  Finish with: claude auth login && ./install.sh"
    fi

    # Switch to zsh if not already running it (interactive, clean runs only)
    if [[ "$status" -eq 0 && -t 0 && "$SHELL" != *"zsh"* ]] && command -v zsh &> /dev/null; then
        log "Switching to zsh..."
        exec zsh -l
    fi
}

main() {
    parse_args "$@"

    ui_header "Dotfiles setup — $(os_label)"
    if $IS_LINUX; then
        log "GUI apps (VSCodium, Ghostty, Chrome, …) are macOS-only — skipped here"
    fi

    confirm_sudo
    check_prerequisites || exit 1

    ui_header "Step 1/4 — install software"
    run_step "System dependencies (zsh, git, curl, build tools)" install_deps
    run_step "Homebrew (package manager)"                        install_homebrew
    run_step "Oh My Zsh (shell framework)"                       install_oh_my_zsh
    # Outside run_step: once the step starts its output is captured behind a
    # spinner, and a heads-up printed there would scroll past unseen.
    # No sudo priming needed — install_packages passes --no-upgrade, so Step 1
    # only ever installs, and new casks go to ~/Applications
    # (HOMEBREW_CASK_OPTS, set in ensure_brew_path).
    warn_about_source_builds
    run_step "Apps and CLI tools from .brewfile"                 install_packages
    run_step "Node.js via NVM"                                   setup_nodejs

    ui_header "Step 2/4 — personal configuration"
    run_step "Symlink dotfiles into \$HOME"        create_symlinks
    run_step "VSCodium extension sync"             sync_vscodium_extensions
    run_step "macOS defaults (user-level)"         apply_macos_defaults false
    run_step "Zsh as default shell"                set_default_shell

    ui_header "Step 3/4 — optional extras"
    install_extras

    ui_header "Step 4/4 — AI tools"
    install_ai_tools

    # Failed steps must fail the run (CI, scripts) — but after post_install
    local status=0
    ui_summary || status=1
    post_install "$status"
    return $status
}

main "$@"
