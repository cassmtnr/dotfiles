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
        echo "icons:Custom app icons — nicer VSCodium icon in the Dock (admin on managed Macs)"
        echo "macos-admin:System-wide macOS tweaks — settings that need admin/sudo"
    fi
    if $IS_LINUX; then
        echo "motd:Server welcome screen — custom message on SSH login (sudo)"
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

# Which extras need admin rights, so install_extras can authenticate before
# the step starts. Keep in sync with the "(sudo)"/"admin" menu labels above.
extra_needs_sudo() {
    case "$1" in
        macos-admin|motd) return 0 ;;
        *)                return 1 ;;
    esac
}

# Prime sudo for one extra. The startup prompt in confirm_sudo can have expired
# by the time extras run — Step 1 alone takes minutes on a fresh machine — so
# re-prime rather than assume the timestamp is still warm.
ensure_extra_sudo() {
    ${RUN_SUDO:-false} || return 1
    sudo -n true 2> /dev/null && return 0
    log "$1 needs admin rights."
    sudo -v
}

# Step driver. Authentication happens HERE, never inside an extra: run_step
# sends the step's output to a file and paints a spinner over the terminal, so
# a password prompt underneath it is invisible and reads as a hang.
install_extras() {
    local extras=() line available=()
    while IFS= read -r line; do available+=("$line"); done < <(extras_available)
    if [[ ${#available[@]} -eq 0 ]]; then
        ui_skip "No extras available on this platform"
        return 0
    fi

    while IFS= read -r line; do extras+=("$line"); done \
        < <(ui_choose_many "Pick extras to set up (space toggles, enter confirms):" "${available[@]}")

    if [[ ${#extras[@]} -eq 0 ]]; then
        ui_skip "No extras selected (re-run ./install.sh anytime to add them)"
        return 0
    fi

    local name
    for name in "${extras[@]}"; do
        if extra_needs_sudo "$name" && ! ensure_extra_sudo "Extra: $name"; then
            ui_skip "Extra: $name (needs admin rights)"
            continue
        fi
        run_step "Extra: $name" run_extra "$name"
    done
}

# Apply custom macOS application icons — needs write access to the app
# bundles in /Applications (admin on managed Macs). The brew() wrapper in
# .functions re-applies icons after upgrades once this has run.
extra_icons() {
    if ! $IS_MACOS; then
        return
    fi

    if ! command -v fileicon &> /dev/null; then
        ui_skip "fileicon not installed — brew install fileicon"
        return 0
    fi

    # Map: app path -> icon file in dotfiles
    local icon_pairs=(
        "/Applications/VSCodium.app:$DOTFILES_ROOT/.vscodium/icon.icns"
    )

    # Flag rather than an early return: one unwritable bundle on a managed Mac
    # must not cost every app after it in the list
    local failed=0
    for pair in "${icon_pairs[@]}"; do
        local app="${pair%:*}"
        local icon="${pair#*:}"

        if [[ -d "$app" && -f "$icon" ]]; then
            if fileicon set "$app" "$icon"; then
                log "Applied custom icon to $(basename "$app")"
            else
                error "Failed to apply custom icon to $(basename "$app") — this usually needs admin rights"
                failed=1
            fi
        fi
    done
    return $failed
}

# System-level macOS defaults — NEEDS ADMIN (sudo defaults write)
extra_macos_admin() {
    if ! $IS_MACOS; then
        return
    fi

    apply_macos_defaults true
}

# Install custom MOTD scripts (Linux only) — NEEDS SUDO (/etc/update-motd.d)
extra_motd() {
    if ! $IS_LINUX; then
        return
    fi

    local motd_dir="$DOTFILES_ROOT/.motd"
    if [[ ! -d "$motd_dir" ]]; then
        ui_skip "MOTD directory not found: $motd_dir"
        return 0
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
        sudo cp "$script" "/etc/update-motd.d/$name" || return 1
        sudo chmod 750 "/etc/update-motd.d/$name" || return 1
        sudo chown root:root "/etc/update-motd.d/$name" || return 1
        log "Installed MOTD script: $name"
    done

    success "Custom MOTD scripts installed"
}
