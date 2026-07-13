#!/usr/bin/env bash

# ============================================
# Step 3 — optional extras
# Secondary tools and perks, each independently selectable. Anything that
# needs sudo/admin says so in its menu label and checks before running.
# ============================================

# Extras registry: "name:description" lines, platform-gated.
# To add an extra: add a line here, a case in run_extra, and an extra_<name>
# function below.
extras_available() {
    if $IS_MACOS; then
        echo "icons:Custom app icons (writes to /Applications — needs admin on managed Macs)"
        echo "macos-admin:System-level macOS defaults (NEEDS ADMIN/SUDO)"
    fi
    if $IS_LINUX; then
        echo "motd:Custom MOTD scripts in /etc/update-motd.d (NEEDS SUDO)"
    fi
}

run_extra() {
    case "$1" in
        icons)          extra_icons ;;
        macos-admin)    extra_macos_admin ;;
        motd)           extra_motd ;;
        *)              warning "Unknown extra: $1 (available: $(extras_available | cut -d: -f1 | tr '\n' ' '))" ;;
    esac
}

# Apply custom macOS application icons — needs write access to the app
# bundles in /Applications (admin on managed Macs). The brew() wrapper in
# .functions re-applies icons after upgrades once this has run.
extra_icons() {
    if ! $IS_MACOS; then
        return
    fi

    if ! command -v fileicon &> /dev/null; then
        warning "fileicon not installed — skipping custom icon application"
        warning "Install with: brew install fileicon"
        return
    fi

    # Map: app path -> icon file in dotfiles
    local icon_pairs=(
        "/Applications/VSCodium.app:$DOTFILES_ROOT/.vscodium/icon.icns"
    )

    for pair in "${icon_pairs[@]}"; do
        local app="${pair%:*}"
        local icon="${pair#*:}"

        if [[ -d "$app" && -f "$icon" ]]; then
            if fileicon set "$app" "$icon"; then
                log "Applied custom icon to $(basename "$app")"
            else
                warning "Failed to apply custom icon to $(basename "$app") — this usually needs admin rights"
            fi
        fi
    done
}

# System-level macOS defaults — NEEDS ADMIN (sudo defaults write)
extra_macos_admin() {
    if ! $IS_MACOS; then
        return
    fi

    if ! sudo -v; then
        warning "System-level macOS defaults need admin rights — skipped"
        return
    fi

    apply_macos_defaults true
}

# Install custom MOTD scripts (Linux only) — NEEDS SUDO (/etc/update-motd.d)
extra_motd() {
    if ! $IS_LINUX; then
        return
    fi

    if ! sudo -v; then
        warning "MOTD scripts need sudo to install into /etc/update-motd.d — skipped"
        return
    fi

    local motd_dir="$DOTFILES_ROOT/.motd"
    if [[ ! -d "$motd_dir" ]]; then
        warning "MOTD directory not found: $motd_dir"
        return
    fi

    # Disable default Ubuntu MOTD scripts that conflict with custom ones
    local disable_scripts=("00-header" "10-help-text" "50-landscape-sysinfo" "50-motd-news")
    for script in "${disable_scripts[@]}"; do
        if [[ -x "/etc/update-motd.d/$script" ]]; then
            sudo chmod -x "/etc/update-motd.d/$script"
            log "Disabled default MOTD script: $script"
        fi
    done

    # Copy custom MOTD scripts
    for script in "$motd_dir"/*; do
        local name
        name="$(basename "$script")"
        sudo cp "$script" "/etc/update-motd.d/$name"
        sudo chmod 750 "/etc/update-motd.d/$name"
        sudo chown root:root "/etc/update-motd.d/$name"
        log "Installed MOTD script: $name"
    done

    success "Custom MOTD scripts installed"
}

# Step driver — run the selected extras (names as arguments)
install_extras() {
    log "── Step 3/4: extras ──"
    local name
    for name in "$@"; do
        run_extra "$name"
    done
    return 0
}
