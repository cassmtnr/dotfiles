#!/usr/bin/env bash

# ============================================
# Step 2 — apply personal configuration
# Symlinks, SSH permissions, VSCodium settings + extensions,
# user-level macOS defaults, default shell.
# All user-level; configs for software that isn't installed are inert.
# ============================================

# Create symbolic links
create_symlinks() {
    log "Creating symbolic links..."

    # Ensure target directories exist before symlinking
    mkdir -p "$HOME/.config"
    mkdir -p "$HOME/.config/1Password/ssh"
    mkdir -p "$HOME/.ssh"
    mkdir -p "$HOME/.ssh/sockets"

    # Ensure VSCodium config directory exists before symlinking
    if $IS_MACOS; then
        mkdir -p "$HOME/Library/Application Support/VSCodium/User"
    elif $IS_LINUX; then
        mkdir -p "$HOME/.config/VSCodium/User"
    fi

    # Define symlinks as source:target pairs.
    # To configure new software: add its config to the repo and one line here.
    local symlink_pairs=(
        "$DOTFILES_ROOT/.zshrc:$HOME/.zshrc"
        "$DOTFILES_ROOT/.zshenv:$HOME/.zshenv"
        "$DOTFILES_ROOT/.starship:$HOME/.config/starship.toml"
        "$DOTFILES_ROOT/.ssh/config:$HOME/.ssh/config"
        "$DOTFILES_ROOT/.1password/ssh/agent.toml:$HOME/.config/1Password/ssh/agent.toml"
        "$DOTFILES_ROOT/.ghostty:$HOME/.config/ghostty"
        "$DOTFILES_ROOT/.lazydocker:$HOME/.config/lazydocker"
        # AI CLI config (Claude Code, Codex) is intentionally NOT here —
        # run lib/ai.sh for that.
    )

    # Platform-specific symlinks
    if $IS_MACOS; then
        symlink_pairs+=(
            "$DOTFILES_ROOT/.vscodium/settings.json:$HOME/Library/Application Support/VSCodium/User/settings.json"
        )
    elif $IS_LINUX; then
        symlink_pairs+=(
            "$DOTFILES_ROOT/.vscodium/settings.json:$HOME/.config/VSCodium/User/settings.json"
        )
    fi

    # Private configs: only symlink if the file exists in the repo
    local private_configs=(
        "$DOTFILES_ROOT/.zshrc.local:$HOME/.zshrc.local"
        "$DOTFILES_ROOT/.ssh/config.local:$HOME/.ssh/config.local"
        "$DOTFILES_ROOT/.ssh/config.work:$HOME/.ssh/config.work"
    )

    # Process private configs
    for pair in "${private_configs[@]}"; do
        local source="${pair%:*}"
        local target="${pair#*:}"

        if [[ -f "$source" ]]; then
            log "Creating symlink for private config: $(basename "$source")"
            # Remove existing file/symlink
            [[ -e "$target" || -L "$target" ]] && rm -f "$target"
            # Create symlink
            ln -sf "$source" "$target"
        fi
    done

    # Old layout: ~/.config/ghostty was a real directory holding a config
    # symlink into the repo (now the whole dir is one symlink). Remove our
    # old links and the dir if that empties it; leftover user files keep the
    # dir and trigger the real-directory warning below instead.
    if [[ -d "$HOME/.config/ghostty" && ! -L "$HOME/.config/ghostty" ]]; then
        local old_ghostty
        for old_ghostty in "$HOME/.config/ghostty/config" "$HOME/.config/ghostty/.ghostty"; do
            if [[ -L "$old_ghostty" && "$(readlink "$old_ghostty")" == *"/dotfiles/.ghostty"* ]]; then
                rm "$old_ghostty"
                log "Removed old-layout ghostty symlink: $old_ghostty"
            fi
        done
        rmdir "$HOME/.config/ghostty" 2>/dev/null || true
    fi

    for pair in "${symlink_pairs[@]}"; do
        local source="${pair%:*}"
        local target="${pair#*:}"

        if [[ ! -e "$source" ]]; then
            warning "Source file not found: $source"
            continue
        fi

        # Create parent directory if needed
        local target_dir
        target_dir="$(dirname "$target")"
        if [[ ! -d "$target_dir" ]]; then
            mkdir -p "$target_dir"
        fi

        # Remove existing target if it's a symlink
        if [[ -L "$target" ]]; then
            rm "$target"
        elif [[ -e "$target" && "$target" == *"/.ssh/"* ]]; then
            warning "Refusing to overwrite non-symlink SSH file: $target"
            continue
        elif [[ -d "$target" ]]; then
            # ln -sf into an existing real directory would nest the link
            # inside it and "succeed" without ever linking the config —
            # app changes would then NOT land in the dotfiles repo
            warning "Target is a real directory: $target"
            warning "  Move it aside (mv \"$target\" \"$target.bak\") and re-run to link it"
            continue
        fi

        # Create symlink
        ln -sf "$source" "$target"
        log "Created symlink: $target -> $source"
    done


    # Fix SSH file permissions (SSH refuses files with group/world access)
    for ssh_file in "$DOTFILES_ROOT/.ssh/config" "$DOTFILES_ROOT/.ssh/config.local" "$DOTFILES_ROOT/.ssh/config.work"; do
        [[ -f "$ssh_file" ]] && chmod 600 "$ssh_file"
    done
    chmod 700 "$HOME/.ssh"

    # Servers accept key logins via authorized_keys: keep its permissions strict (sshd StrictModes rejects group/world access) and warn if it's missing — the next login would be locked out. Macs don't accept inbound SSH, so skip there.
    if $IS_LINUX; then
        if [[ -f "$HOME/.ssh/authorized_keys" ]]; then
            chmod 600 "$HOME/.ssh/authorized_keys"
        else
            warning "$HOME/.ssh/authorized_keys does not exist — SSH key login will not work!"
            warning "Add your public key: cat your_key.pub >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
        fi
    fi

    success "Symbolic links created"
}

# Bidirectional sync of VSCodium extensions:
#   1. Install extensions listed in extensions.txt but not yet installed
#   2. Add newly installed extensions to extensions.txt
#   3. Reinstall tracked extensions that are missing (extensions.txt is the
#      source of truth — a fresh machine must converge to it, which means an
#      extension uninstalled by hand comes back; delete its line here instead)
# After sync, extensions.txt matches the installed state exactly.
sync_vscodium_extensions() {
    local extensions_file="$DOTFILES_ROOT/.vscodium/extensions.txt"

    if ! command -v codium &> /dev/null; then
        warning "VSCodium not installed — skipping extension sync"
        return
    fi

    # Ensure the file exists
    [[ -f "$extensions_file" ]] || touch "$extensions_file"

    log "Syncing VSCodium extensions..."

    # Sorted lowercase lists for comparison via comm
    local tracked_sorted installed_sorted
    # grep -E (BRE treats the \| alternation's $ literally, letting blank
    # lines through); || true: grep exits 1 on an empty file, which would
    # abort the whole script under set -e
    tracked_sorted=$(grep -Ev '^[[:space:]]*$|^#' "$extensions_file" | tr '[:upper:]' '[:lower:]' | sort -u || true)
    installed_sorted=$(codium --list-extensions | tr '[:upper:]' '[:lower:]' | sort -u)

    # Extensions in file but not installed → need to install
    local to_install
    to_install=$(comm -23 <(echo "$tracked_sorted") <(echo "$installed_sorted"))

    # Extensions installed but not in file → will be added
    local to_add
    to_add=$(comm -13 <(echo "$tracked_sorted") <(echo "$installed_sorted"))

    # Install missing extensions
    local install_count=0
    local failed=0
    if [[ -n "$to_install" ]]; then
        while IFS= read -r ext; do
            if codium --install-extension "$ext" --force; then
                install_count=$((install_count + 1))
            else
                warning "Failed to install extension: $ext"
                failed=$((failed + 1))
            fi
        done <<< "$to_install"
    fi

    # Count additions and removals for reporting
    local added=0 removed=0
    [[ -n "$to_add" ]] && added=$(echo "$to_add" | wc -l | tr -d ' ')
    # Removals = extensions that failed to install (they were in the file but won't be in the final state)
    [[ $failed -gt 0 ]] && removed=$failed

    # Rewrite extensions.txt from actual installed state (canonical after sync)
    if [[ $added -gt 0 || $install_count -gt 0 || $failed -gt 0 ]]; then
        codium --list-extensions | sort > "$extensions_file"
    fi

    # Count extensions removed from file (were tracked, not installed, and failed to install)
    # Re-check: tracked extensions no longer in the final file
    local final_sorted
    final_sorted=$(grep -Ev '^[[:space:]]*$|^#' "$extensions_file" | tr '[:upper:]' '[:lower:]' | sort -u)
    local dropped
    dropped=$(comm -23 <(echo "$tracked_sorted") <(echo "$final_sorted"))
    [[ -n "$dropped" ]] && removed=$(echo "$dropped" | wc -l | tr -d ' ')

    # Report
    local msgs=()
    [[ $install_count -gt 0 ]] && msgs+=("$install_count installed")
    [[ $failed -gt 0 ]] && msgs+=("$failed failed")
    [[ $added -gt 0 ]] && msgs+=("$added added to extensions.txt")
    [[ $removed -gt 0 ]] && msgs+=("$removed removed from extensions.txt")
    if [[ ${#msgs[@]} -gt 0 ]]; then
        success "VSCodium extensions synced ($(IFS=', '; echo "${msgs[*]}"))"
    else
        success "VSCodium extensions up to date ($(wc -l < "$extensions_file" | tr -d ' ') extensions)"
    fi
}

# Apply macOS defaults from .defaults. $1: "true" to include admin-only lines
# (that path lives in step 3 extras — everything here runs user-level).
apply_macos_defaults() {
    local with_sudo="${1:-false}"

    if ! $IS_MACOS; then
        return
    fi

    log "Applying macOS defaults..."

    # Run as a subprocess, not sourced: under install.sh's set -e, one failing
    # `defaults write` (e.g. a domain macOS has sandboxed away) would abort the
    # whole install and skip the remaining defaults.
    if [[ ! -f "$DOTFILES_ROOT/.defaults" ]]; then
        warning ".defaults not found — skipping macOS defaults"
        return
    fi

    RUN_SUDO="$with_sudo" bash "$DOTFILES_ROOT/.defaults" || warning "Some macOS defaults failed to apply"
    success "macOS defaults applied"
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
        if ! ${RUN_SUDO:-false}; then
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

# Step driver — apply personal configuration (all user-level)
start_configuration() {
    log "── Step 2/4: apply personal configuration ──"
    create_symlinks
    sync_vscodium_extensions
    apply_macos_defaults false
    set_default_shell
    return 0
}
