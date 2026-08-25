#!/usr/bin/env bash

# ============================================
# Step 1 — install software (shell, dev toolchain, apps)
# Packages come from .brewfile (casks skipped on Linux). No AI tooling —
# that is step 4 (lib/ai.sh). Callers set RUN_SUDO before these run.
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
        ui_skip "missing ${missing[*]} — needs admin rights"
        return 0
    fi

    log "Installing: ${missing[*]}"
    if $IS_MACOS; then
        # xcode-select exits 1 when the Command Line Tools are already present
        # or an install is already running, so a nonzero status here is not a
        # failure worth retrying. It also returns as soon as the GUI dialog
        # opens, which is why this cannot claim the tools are installed.
        if xcode-select --install 2> /dev/null; then
            ui_warn "Command Line Tools install started in a separate window — finish it, then re-run"
        else
            ui_skip "Command Line Tools already present or installing"
            return 0
        fi
    elif $IS_LINUX; then
        sudo apt-get update || return 1
        sudo apt-get install -y "${missing[@]}" || return 1
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
    # brew --version proves the install actually works — a half-extracted
    # ~/.homebrew can pass ensure_brew_path and turn a retry into a false ✓
    if ensure_brew_path && brew --version &> /dev/null; then
        ui_skip "Homebrew already installed"
        return 0
    fi

    if $RUN_SUDO; then
        log "Installing Homebrew (official installer)..."
        # Download first: `bash -c "$(curl ...)"` with a failed curl runs an
        # empty script and reports false success
        local installer
        if ! installer="$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
            error "Could not download the Homebrew installer"
            return 1
        fi
        # Homebrew installation script handles its own sudo requests
        if ! NONINTERACTIVE=1 /bin/bash -c "$installer"; then
            error "Homebrew installation failed"
            return 1
        fi
    else
        log "Installing Homebrew into ~/.homebrew (user-level, no admin)..."
        warning "This prefix has no precompiled bottles — packages build from source (slower)"
        mkdir -p "$HOME/.homebrew" || { error "Could not create ~/.homebrew"; return 1; }
        # Untar the brew repo straight into the prefix (official "untar anywhere"
        # method). Pipefail makes a failed curl abort the tar, not silently empty it.
        if ! curl -fsSL https://github.com/Homebrew/brew/tarball/master \
             | tar xz --strip-components 1 -C "$HOME/.homebrew"; then
            error "Homebrew untar install failed"
            return 1
        fi
    fi

    # Add Homebrew to PATH (probes all three prefixes)
    ensure_brew_path || warning "Homebrew installed but brew binary not found"

    success "Homebrew installed"
}

# Install Oh My Zsh
install_oh_my_zsh() {
    # Check the entry script, not just the directory — a partial clone left
    # by a failed install must fail loudly on retry, not skip as installed
    if [[ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]]; then
        ui_skip "Oh My Zsh already installed"
        return 0
    fi

    log "Installing Oh My Zsh..."

    # Download first: `sh -c "$(curl ...)"` with a failed curl runs an
    # empty script and reports false success
    local installer
    if ! installer="$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; then
        error "Could not download the Oh My Zsh installer"
        return 1
    fi

    # KEEP_ZSHRC prevents Oh My Zsh from replacing .zshrc; ZSH pinned so an
    # inherited $ZSH from the calling shell can't redirect the installer away
    # from the directory the check above looked at
    if ! KEEP_ZSHRC=yes ZSH="$HOME/.oh-my-zsh" sh -c "$installer" "" --unattended; then
        error "Oh My Zsh installation failed"
        return 1
    fi

    success "Oh My Zsh installed"
}

# Install brew packages from .brewfile
install_packages() {
    if ! ensure_brew_path; then
        ui_skip "Homebrew not installed — no packages to install"
        return 0
    fi

    local file="$DOTFILES_ROOT/.brewfile"
    if [[ ! -f "$file" ]]; then
        ui_skip "Brewfile not found: $file"
        return 0
    fi

    # brew bundle failure is retry-able: flaky downloads are the common case
    if $IS_LINUX; then
        # Filter out cask entries (macOS-only GUI apps) for Linux
        grep -v '^cask[[:space:]]' "$file" | brew bundle --file=- || return 1
    else
        brew bundle --file="$file" || return 1
    fi

    hash -r  # Refresh PATH so newly installed binaries are found
}

# Setup Node.js environment
setup_nodejs() {
    source_nvm

    if ! command -v nvm &> /dev/null; then
        ui_skip "NVM not found — install with: brew install nvm"
        return 0
    fi

    log "Installing Node.js v22.23.1..."
    nvm install 22.23.1 || { error "Failed to install Node.js v22.23.1"; return 1; }
    nvm use 22.23.1 || { error "Failed to activate Node.js v22.23.1"; return 1; }
    nvm alias default 22.23.1 || warning "Could not set default Node.js alias"

    log "Node.js version: $(node --version)"
    log "NPM version: $(npm --version)"
}
