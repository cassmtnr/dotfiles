#!/usr/bin/env bash

# ============================================
# Step 1 — install software (shell, dev toolchain, apps)
# Packages come from .brewfile (casks skipped on Linux). No AI tooling —
# that is step 4 (lib/ai.sh). Callers set RUN_SUDO before start_installation.
# ============================================

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

# Install Homebrew. Two paths:
#   - With admin: the official installer → /opt/homebrew (macOS) or
#     /home/linuxbrew/.linuxbrew (Linux). Uses precompiled "bottles" (fast).
#   - Without admin: untar into ~/.homebrew — fully user-level, no sudo, but
#     that prefix has no bottles, so packages build from source (slower).
# Either way brew itself runs user-level afterward.
install_homebrew() {
    if ensure_brew_path; then
        log "Homebrew already installed"
        return
    fi

    if $RUN_SUDO; then
        log "Installing Homebrew (official installer)..."
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
    else
        log "Installing Homebrew into ~/.homebrew (user-level, no admin)..."
        warning "This prefix has no precompiled bottles — packages build from source (slower)"
        mkdir -p "$HOME/.homebrew" || { warning "Could not create ~/.homebrew — skipping"; return; }
        # Untar the brew repo straight into the prefix (official "untar anywhere"
        # method). Pipefail makes a failed curl abort the tar, not silently empty it.
        if ! curl -fsSL https://github.com/Homebrew/brew/tarball/master \
             | tar xz --strip-components 1 -C "$HOME/.homebrew"; then
            warning "Homebrew untar install failed — continuing without it"
            return
        fi
    fi

    # Add Homebrew to PATH (probes all three prefixes)
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

    # KEEP_ZSHRC prevents Oh My Zsh from replacing .zshrc; ZSH pinned so an
    # inherited $ZSH from the calling shell can't redirect the installer away
    # from the directory the check above looked at
    if ! KEEP_ZSHRC=yes ZSH="$HOME/.oh-my-zsh" sh -c "$installer" "" --unattended; then
        warning "Oh My Zsh installation failed — continuing without it"
        return
    fi

    success "Oh My Zsh installed"
}

# Install brew packages from .brewfile
install_packages() {
    if ! ensure_brew_path; then
        warning "Homebrew not installed — skipping package installation"
        return
    fi

    local file="$DOTFILES_ROOT/.brewfile"
    if [[ ! -f "$file" ]]; then
        warning "Brewfile not found: $file"
        return
    fi

    log "Installing packages..."
    if $IS_LINUX; then
        # Filter out cask entries (macOS-only GUI apps) for Linux
        grep -v '^cask[[:space:]]' "$file" | brew bundle --file=- \
            || warning "Some packages failed to install"
    else
        brew bundle --file="$file" || warning "Some packages failed to install"
    fi

    hash -r  # Refresh PATH so newly installed binaries are found
    success "Packages installed"
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

    # Install and activate Node.js. Guard each nvm call: an unguarded failure
    # would abort the whole install (set -e) before configuration runs.
    log "Installing Node.js v22.19.0..."
    nvm install 22.19.0 || { warning "Failed to install Node.js v22.19.0"; return; }
    nvm use 22.19.0 || { warning "Failed to activate Node.js v22.19.0"; return; }
    nvm alias default 22.19.0 || warning "Could not set default Node.js alias"

    log "Node.js version: $(node --version)"
    log "NPM version: $(npm --version)"
    success "Node.js setup complete"
}

# Step driver — install software (no AI; that is step 4, install_ai_tools)
start_installation() {
    log "── Step 1/4: install software ──"
    install_deps
    install_homebrew
    install_oh_my_zsh
    install_packages
    setup_nodejs
    return 0
}
