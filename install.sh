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
# No flags to remember: every choice is an interactive menu.
# ============================================

set -euo pipefail  # Exit on error, undefined variable, or pipe failure

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"
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

All choices are interactive menus — nothing to memorize. Idempotent — re-run
anytime.
EOF
}

# Only --help exists; everything else errors — all choices are menus
parse_args() {
    case "${1:-}" in
        "") ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            error "Unknown option: $1 (this script has no flags — just run it)"
            show_help
            exit 1
            ;;
    esac
}

# Confirm whether privileged steps may run (platform default), then prime
# sudo; degrade to user-level mode if the prompt fails
confirm_sudo() {
    if [[ -t 0 ]]; then
        local hint answer
        if $RUN_SUDO; then hint="Y/n"; else hint="y/N"; fi
        # >&2: a stdout redirect (./install.sh > log) must not hide the question
        printf '%b' "${BLUE}[INFO]${NC} Allow steps that need admin rights (Homebrew bootstrap, system packages)? [$hint] " >&2
        read -r answer || answer=""
        case "$answer" in
            [Yy]*) RUN_SUDO=true ;;
            [Nn]*) RUN_SUDO=false ;;
        esac
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

post_install() {
    echo
    success "Setup complete!"
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

    # Switch to zsh if not already running it (interactive sessions only)
    if [[ -t 0 && "$SHELL" != *"zsh"* ]] && command -v zsh &> /dev/null; then
        log "Switching to zsh..."
        exec zsh -l
    fi
}

main() {
    parse_args "$@"

    echo "======================================"
    echo "        Dotfiles Setup Script         "
    echo "======================================"
    echo
    log "Detected: $(os_label)"
    if $IS_LINUX; then
        log "GUI apps (VSCodium, Ghostty, Chrome, …) are macOS-only — skipped here"
    fi
    echo

    confirm_sudo
    check_prerequisites || exit 1

    start_installation
    start_configuration

    # Step 3 choice — checkbox menu on a terminal, none without one
    local extras=()
    if [[ -t 0 ]]; then
        local available=() line
        while IFS= read -r line; do available+=("$line"); done < <(extras_available)
        while IFS= read -r line; do extras+=("$line"); done \
            < <(choose_many "Step 3/4 — select extras:" "${available[@]}")
    fi

    if [[ ${#extras[@]} -gt 0 ]]; then
        install_extras "${extras[@]}"
    else
        log "── Step 3/4: no extras selected (re-run ./install.sh to add them) ──"
    fi

    # Step 4 — AI tools (opt-in; nothing selected on a non-terminal run)
    install_ai_tools

    post_install
}

main "$@"
