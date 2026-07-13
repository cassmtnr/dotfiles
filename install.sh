#!/usr/bin/env bash

# ============================================
# Dotfiles Installation Script
# ============================================

set -euo pipefail  # Exit on error, undefined variable, or pipe failure

# Load shared utilities (OS detection, logging, symlinks, packages, defaults)
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.utils.sh"

# RUN_SUDO: whether steps that need administrative privileges run at all.
# Default by platform: Linux (servers, we have root) uses sudo; macOS and
# anything else (laptops, often managed without admin rights) does not.
# Override with --sudo / --no-sudo. Auto-disabled if the sudo prompt fails.
if $IS_LINUX; then
    RUN_SUDO=true
else
    RUN_SUDO=false
fi

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

Options:
  --sudo       Use administrative privileges (default on Linux)
  --no-sudo    Skip all steps that need administrative privileges
               (Homebrew bootstrap, system defaults, /etc changes;
               default on macOS)

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
            --sudo)
                RUN_SUDO=true
                ;;
            --no-sudo)
                RUN_SUDO=false
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

# Show welcome message (after arg parsing so --help doesn't trigger sudo)
show_welcome() {
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
    if ! $RUN_SUDO; then
        log "Running in no-sudo mode — admin-only steps will be skipped"
        log "(use --sudo for a fresh machine that needs Homebrew or system defaults)"
        return
    fi

    echo "Administrative privileges are required for system configuration."
    echo "Please enter your password to continue:"
    if ! sudo -v; then
        warning "Could not obtain administrative privileges — continuing in no-sudo mode"
        RUN_SUDO=false
    fi
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

    if ! $RUN_SUDO; then
        warning "Missing system dependencies (${missing[*]}) — cannot install without admin rights"
        return
    fi

    log "Installing: ${missing[*]}"
    if $IS_MACOS; then
        xcode-select --install || warning "xcode-select install failed (may already be installed)"
    elif $IS_LINUX; then
        sudo apt-get update
        sudo apt-get install -y "${missing[@]}"
    fi

    success "System dependencies installed"
}

# Install Homebrew
install_homebrew() {
    if ensure_brew_path; then
        log "Homebrew already installed"
        return
    fi

    if ! $RUN_SUDO; then
        warning "Homebrew not installed and requires admin rights to bootstrap — skipping"
        warning "Ask IT to install Homebrew, or install packages manually"
        return
    fi

    log "Installing Homebrew..."

    # Download first: `bash -c "$(curl ...)"` with a failed curl runs an
    # empty script and reports false success
    local installer
    if ! installer="$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        warning "Could not download the Homebrew installer — skipping"
        return
    fi

    # Homebrew installation script handles its own sudo requests
    if ! NONINTERACTIVE=1 /bin/bash -c "$installer"; then
        warning "Homebrew installation failed — continuing without it"
        return
    fi

    # Add Homebrew to PATH
    ensure_brew_path || warning "Homebrew installed but brew binary not found"

    success "Homebrew installed"
}

# Install Oh My Zsh
install_oh_my_zsh() {
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log "Oh My Zsh already installed"
        return
    fi

    log "Installing Oh My Zsh..."

    # Download first: `sh -c "$(curl ...)"` with a failed curl runs an
    # empty script and reports false success
    local installer
    if ! installer="$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; then
        warning "Could not download the Oh My Zsh installer — skipping"
        return
    fi

    # KEEP_ZSHRC prevents Oh My Zsh from replacing .zshrc
    if ! KEEP_ZSHRC=yes sh -c "$installer" "" --unattended; then
        warning "Oh My Zsh installation failed — continuing without it"
        return
    fi

    success "Oh My Zsh installed"
}

# Setup Node.js environment
setup_nodejs() {
    log "Setting up Node.js environment..."
    source_nvm

    if ! command -v nvm &> /dev/null; then
        # plain return: `return 1` would abort the whole script under set -e
        warning "NVM not found — skipping Node.js setup"
        warning "Install NVM first with: brew install nvm"
        return
    fi

    # Install and activate Node.js
    log "Installing Node.js v22.19.0..."
    nvm install 22.19.0 || { warning "Failed to install Node.js v22.19.0"; return; }
    nvm use 22.19.0
    nvm alias default 22.19.0

    log "Node.js version: $(node --version)"
    log "NPM version: $(npm --version)"
    success "Node.js setup complete"
}


# Setup Bun runtime
setup_bun() {
    log "Setting up Bun JavaScript runtime..."

    # Check if Bun is already installed (packages below still sync)
    if command -v bun &> /dev/null; then
        log "Bun is already installed ($(bun --version))"
    else
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
                return
            fi
        else
            # plain return: `return 1` would abort the whole script under set -e
            warning "Bun installation failed - you can install manually later with: curl -fsSL https://bun.sh/install | bash"
            return
        fi
    fi

    # Install global packages
    local packages=(
        yarn
        typescript
        eslint
        nodemon
    )

    log "Installing global packages via bun..."
    if bun install -g "${packages[@]}"; then
        success "Global packages installed"
    else
        warning "Some packages failed to install"
        warning "You can retry manually with: bun install -g ${packages[*]}"
    fi
}

# Install AI CLI tools (Linux only — macOS handled via .brewfile)
install_ai_tools() {
    if ! $IS_LINUX; then
        return
    fi

    log "Installing AI CLI tools via npm (Linux)..."

    # Ensure NVM and npm are available in current session
    source_nvm

    # source_nvm no longer auto-activates a node (--no-use); if setup_nodejs
    # couldn't install the pinned version, fall back to the default alias
    command -v npm &> /dev/null || nvm use --silent default &> /dev/null || true

    if ! command -v npm &> /dev/null; then
        # plain return: `return 1` would abort the whole script under set -e
        warning "npm not found — skipping AI CLI tools installation"
        warning "Install Node.js first, then run: npm install -g @anthropic-ai/claude-code @google/gemini-cli"
        return
    fi

    npm install -g @anthropic-ai/claude-code @google/gemini-cli || {
        warning "Some AI CLI tools failed to install via npm"
        warning "You can retry manually with: npm install -g @anthropic-ai/claude-code @google/gemini-cli"
    }

    success "AI CLI tools installed"
}

# Install Agent Reach (internet channel router for AI CLIs)
install_agent_reach() {
    if ! command -v pipx &> /dev/null; then
        warning "pipx not found — skipping Agent Reach installation"
        return
    fi

    if ! command -v agent-reach &> /dev/null; then
        log "Installing Agent Reach..."
        pipx install https://github.com/Panniantong/agent-reach/archive/main.zip || {
            # plain return: `return 1` would abort the whole script under set -e
            warning "Agent Reach installation failed"
            return
        }
    fi

    # backs `agent-reach configure --from-browser` (cookie import for Twitter login)
    pipx inject agent-reach browser-cookie3 || warning "browser-cookie3 injection failed"

    # Channels: core public set + bilibili/twitter (no browser needed;
    # Twitter login is manual per machine — see README)
    agent-reach install --env=auto --channels=bilibili,twitter || \
        warning "Some Agent Reach channels failed — run 'agent-reach doctor' to diagnose"

    # Reddit backend installed directly: the agent-reach reddit channel would pull
    # in OpenCLI (browser bridge) on desktop — we use cookie-based rdt-cli instead.
    # Pinned commit is the version agent-reach's own docs pin. Login: `rdt login`.
    if ! command -v rdt &> /dev/null; then
        pipx install 'git+https://github.com/public-clis/rdt-cli.git@5e4fb3720d5c174e976cd425ccc3b879d52cac66' || \
            warning "rdt-cli (Reddit) installation failed"
    fi

    # agent-reach regenerates its skill with upstream content (Chinese docs,
    # all 15 platforms incl. uninstalled ones) — restore our trimmed English
    # version from git. No-op when the files already match.
    if ! git -C "$DOTFILES_ROOT" diff --quiet -- .ai/common/skills/agent-reach/ 2>/dev/null; then
        if git -C "$DOTFILES_ROOT" checkout -- .ai/common/skills/agent-reach/; then
            log "Restored trimmed agent-reach skill (installer had overwritten it)"
        else
            warning "Could not restore trimmed agent-reach skill from git"
        fi
    fi

    success "Agent Reach installed"
}

# Post-installation message
post_install() {
    echo
    success "Installation complete!"
    echo
    log "Final setup - reloading shell configuration..."

    # Best-effort: source zshrc from bash — zsh-specific syntax will produce
    # harmless errors, but PATH/env vars are still picked up.
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
    echo "  ✓ VSCodium editor with extensions and custom icon"
    echo "  ✓ AI CLI configuration (Claude Code + Codex CLI — instructions, commands, hooks)"
    echo "  ✓ Agent Reach internet channels (web, YouTube, GitHub, RSS, Twitter, Reddit…)"
    echo "  ✓ Symbolic links for all configurations"
    echo ""
    echo
    echo "Optional next steps:"
    echo "  • Configure your SSH keys in ~/.ssh/"
    echo "  • Customize ~/.zshrc.local for machine-specific settings"
    echo
    echo "For more information, see: $DOTFILES_ROOT/README.md"

    # Switch to zsh if not already running it
    if [[ "$SHELL" != *"zsh"* ]] && command -v zsh &> /dev/null; then
        log "Switching to zsh..."
        exec zsh -l
    fi
}

# Main installation flow
main() {
    parse_args "$@"
    show_welcome

    # Run installation steps
    check_prerequisites || exit 1
    install_deps
    install_homebrew
    install_oh_my_zsh
    create_symlinks
    install_packages
    hash -r  # Refresh PATH so newly installed binaries (codium, fileicon) are found
    apply_custom_icons
    setup_bun
    setup_nodejs
    sync_vscodium_extensions
    configure_macos
    install_motd
    install_ai_tools
    install_claude_plugins
    install_agent_reach
    set_default_shell
    post_install
}

# Set zsh as default shell
set_default_shell() {
    # Any zsh counts — on macOS $SHELL is typically /bin/zsh while brew's
    # zsh isn't in /etc/shells, so chsh to it fails without admin rights
    if [[ "$SHELL" == *zsh ]]; then
        log "Zsh is already the default shell"
        return
    fi

    local zsh_path
    zsh_path="$(which zsh || true)"
    if [[ -z "$zsh_path" ]]; then
        warning "zsh not installed — cannot set it as default shell"
        return
    fi

    # On Linux, ensure zsh is listed in /etc/shells (required by chsh)
    if $IS_LINUX && ! grep -qx "$zsh_path" /etc/shells 2>/dev/null; then
        if ! $RUN_SUDO; then
            warning "Cannot add $zsh_path to /etc/shells without admin rights — skipping shell change"
            return
        fi
        log "Adding $zsh_path to /etc/shells..."
        echo "$zsh_path" | sudo tee -a /etc/shells > /dev/null
    fi

    log "Setting zsh as default shell..."
    if chsh -s "$zsh_path"; then
        success "Default shell changed to zsh (takes effect on next login)"
    else
        warning "Failed to change default shell. Run manually: chsh -s $zsh_path"
    fi
}

# Run main function
main "$@"
