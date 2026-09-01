#!/usr/bin/env bash

# ============================================
# Step 4 — AI tools (Claude Code + Codex CLI)
# Sourced by install.sh; run as the final, opt-in step. Nothing here runs
# unless you pick it from the menu, so a plain/non-interactive install stays
# AI-free. All user-level (no sudo):
#   - symlinks AI config into ~/.claude, ~/.codex and ~/.agents (AGENTS.md
#     rules, skills, safety hooks, settings)
#   - installs Claude Code (+ Gemini on Linux)
#   - optionally sets up Agent Reach and Claude Code plugins
# ============================================

# Read by post_install (install.sh) to print finish-later instructions when
# plugins were skipped for lack of a logged-in CLI
# shellcheck disable=SC2034
CLAUDE_PLUGINS_PENDING=false

# Symlink one source into place, replacing an existing symlink but never a
# real file/dir (which would mean the app wrote its own config there)
link() {
    local src="$1" dst="$2"
    if [[ ! -e "$src" ]]; then
        warning "Source not found: $src"
        return
    fi
    mkdir -p "$(dirname "$dst")"
    if [[ -L "$dst" ]]; then
        rm "$dst"
    elif [[ -e "$dst" ]]; then
        warning "Target exists and is not a symlink, skipping: $dst"
        return
    fi
    ln -sf "$src" "$dst"
    log "Linked: $dst -> $src"
}

# The AI configuration is a separate private repo cloned in place at .ai/,
# which .gitignore keeps out of this one. Every link below points into it, so
# without it there is nothing for this step to do.
AI_CONFIG_REPO="git@github.com:cassmtnr/ai-config.git"

ensure_ai_repo() {
    [[ -d "$DOTFILES_ROOT/.ai/.git" ]] && return 0

    # A machine that pulled this split while sitting at the pre-split commit
    # keeps everything .gitignore excluded (vendored skills, codex/config.toml,
    # a work-machine symlink), so .ai/ can exist and be non-empty with no repo
    # inside. `git clone` refuses that target, and its failure message below
    # would blame SSH access instead of the real problem.
    if [[ -d "$DOTFILES_ROOT/.ai" && -n "$(ls -A "$DOTFILES_ROOT/.ai" 2> /dev/null)" ]]; then
        warning ".ai/ exists but isn't a git repo — move it aside (mv .ai .ai.bak) and re-run"
        return 1
    fi

    log "AI configuration lives in a separate private repo."
    ui_confirm "Clone $AI_CONFIG_REPO into .ai now?" y || return 1

    git clone "$AI_CONFIG_REPO" "$DOTFILES_ROOT/.ai" || {
        warning "Clone failed — check your GitHub SSH access to cassmtnr/ai-config"
        return 1
    }
    success "AI config repo cloned"
}

# Symlink AI config into ~/.claude and ~/.codex
ai_symlinks() {
    log "Linking AI configuration..."
    mkdir -p "$HOME/.claude" "$HOME/.codex" "$HOME/.codex/rules" "$HOME/.mcporter"

    # Remove orphaned symlinks from older layouts — paths that no longer have a
    # link below, so the loop wouldn't otherwise touch them. Only symlinks into
    # this repo are removed (never real files/dirs — link() warns on those).
    # instructions.md: Codex reads only $CODEX_HOME/AGENTS.md now.
    # .codex/skills: replaced by ~/.agents/skills — keeping both would list
    # every skill twice (Codex dedupes skill roots by path, not target).
    local orphan
    for orphan in "$HOME/.claude/commands" "$HOME/.claude/statusline-command.sh" \
                  "$HOME/.codex/prompts" "$HOME/.codex/config.toml" \
                  "$HOME/.codex/instructions.md" "$HOME/.codex/skills"; do
        if [[ -L "$orphan" && "$(readlink "$orphan")" == *"/dotfiles/"* ]]; then
            rm "$orphan"
            log "Removed orphaned symlink (old layout): $orphan"
        fi
    done

    # Shared content (Claude Code + Codex) — only assets both CLIs support.
    # AGENTS.md is the canonical shared core; Claude Code reads it through the
    # @import in claude/CLAUDE.md, Codex reads ~/.codex/AGENTS.md directly.
    # ~/.agents/skills is the agentskills.io standard location Codex scans;
    # Claude Code only reads ~/.claude/skills.
    link "$DOTFILES_ROOT/.ai/common/AGENTS.md"       "$HOME/.codex/AGENTS.md"
    link "$DOTFILES_ROOT/.ai/common/skills"          "$HOME/.claude/skills"
    link "$DOTFILES_ROOT/.ai/common/skills"          "$HOME/.agents/skills"
    link "$DOTFILES_ROOT/.ai/common/hooks"           "$HOME/.claude/hooks"
    link "$DOTFILES_ROOT/.ai/common/hooks"           "$HOME/.codex/hooks"
    link "$DOTFILES_ROOT/.ai/common/scripts"         "$HOME/.claude/scripts"

    # Claude Code only. ~/.claude/AGENTS.md exists so the wrapper's @import
    # can use a repo-location-independent path (mirrors ~/.codex/AGENTS.md).
    link "$DOTFILES_ROOT/.ai/common/AGENTS.md"       "$HOME/.claude/AGENTS.md"
    link "$DOTFILES_ROOT/.ai/claude/CLAUDE.md"       "$HOME/.claude/CLAUDE.md"
    link "$DOTFILES_ROOT/.ai/claude/rules"           "$HOME/.claude/rules"
    link "$DOTFILES_ROOT/.ai/claude/settings.json"   "$HOME/.claude/settings.json"
    link "$DOTFILES_ROOT/.ai/claude/config"          "$HOME/.claude/config"

    # Codex CLI only. config.toml is COPIED, not symlinked: Codex writes hook
    # trust ([hooks.state]) and TUI allow-list amendments into the user config
    # at runtime, and write-through-symlink behavior is untested — a copy keeps
    # machine-local state out of the repo. Copy only when absent; push repo
    # changes by deleting the local file and re-running this step.
    # rules/: only the curated file is linked — Codex auto-appends its own
    # allow-list decisions to ~/.codex/rules/default.rules, which stays local.
    link "$DOTFILES_ROOT/.ai/codex/hooks.json"           "$HOME/.codex/hooks.json"
    link "$DOTFILES_ROOT/.ai/codex/rules/git-safety.rules" "$HOME/.codex/rules/git-safety.rules"
    if [[ ! -e "$HOME/.codex/config.toml" ]]; then
        cp "$DOTFILES_ROOT/.ai/codex/config.toml" "$HOME/.codex/config.toml"
        log "Copied: $HOME/.codex/config.toml (machine-local; holds Codex-written state)"
    elif ! cmp -s "$DOTFILES_ROOT/.ai/codex/config.toml" "$HOME/.codex/config.toml"; then
        # Expected on Codex machines once [hooks.state] lands — but it also
        # means repo-side config changes are NOT applied; merge them manually.
        warning "Kept existing ~/.codex/config.toml (differs from repo) — diff and merge repo changes by hand"
    fi

    # mcporter — global config so Exa search (agent-reach) works from any dir
    link "$DOTFILES_ROOT/config/mcporter.json"       "$HOME/.mcporter/mcporter.json"

    # Hooks (block-dangerous-commands.js, plugin hooks) run under /bin/sh,
    # which never loads nvm — they only see node if it's on the PATH Claude
    # Code inherited from its launching shell. ~/.local/bin is on that PATH
    # (.zshenv), so link a shim there that resolves nvm's current default at
    # call time (a versioned symlink would dangle after node upgrades).
    # No-op without nvm: brew/system node installs are already on PATH.
    if [[ -s "${NVM_DIR:-$HOME/.nvm}/nvm.sh" ]]; then
        link "$DOTFILES_ROOT/.ai/common/scripts/node-default.sh" "$HOME/.local/bin/node"
    fi

    success "AI configuration linked"
}

# Install Claude Code (+ Gemini on Linux). macOS uses the Homebrew cask;
# Linux uses npm under NVM.
install_ai_clis() {
    if $IS_MACOS; then
        if ! ensure_brew_path; then
            ui_skip "Homebrew not found — needed to install Claude Code"
            return 0
        fi
        # One-time migration: the old claude-code cask ships the same binary
        # as claude-code@latest and conflicts on install until removed
        if [[ -d "${HOMEBREW_PREFIX:-}/Caskroom/claude-code" ]]; then
            log "Migrating cask: claude-code → claude-code@latest"
            brew uninstall --cask claude-code || warning "Could not uninstall old claude-code cask"
        fi
        log "Installing Claude Code..."
        brew install --cask claude-code@latest || return 1
    elif $IS_LINUX; then
        source_nvm
        # source_nvm uses --no-use; fall back to the default alias for npm
        command -v npm &> /dev/null || nvm use --silent default &> /dev/null || true
        if ! command -v npm &> /dev/null; then
            ui_skip "npm not found — run ./install.sh first, then re-run this"
            return 0
        fi
        log "Installing Claude Code + Gemini via npm..."
        npm install -g @anthropic-ai/claude-code @google/gemini-cli || return 1
    fi
    hash -r
    success "AI CLIs installed"
}

# Install Agent Reach (internet channel router for AI CLIs) — user-level
setup_agent_reach() {
    if ! command -v pipx &> /dev/null; then
        ui_skip "pipx not found — brew install pipx"
        return 0
    fi

    # pipx installs to ~/.local/bin, which isn't on PATH yet during a
    # first-ever install (the .zshrc that adds it isn't in effect)
    export PATH="$HOME/.local/bin:$PATH"

    if ! command -v agent-reach &> /dev/null; then
        log "Installing Agent Reach..."
        pipx install https://github.com/Panniantong/agent-reach/archive/main.zip || {
            error "Agent Reach installation failed"
            return 1
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
    if ! git -C "$DOTFILES_ROOT/.ai" diff --quiet -- common/skills/agent-reach/ 2>/dev/null; then
        if git -C "$DOTFILES_ROOT/.ai" checkout -- common/skills/agent-reach/; then
            log "Restored trimmed agent-reach skill (installer had overwritten it)"
        else
            warning "Could not restore trimmed agent-reach skill from git"
        fi
    fi

    success "Agent Reach installed"
}

# Claude Code login state. Preferred probe: `claude auth status` — grep, not
# jq: the CLI appends terminal-escape bytes after the JSON that break jq.
# Fallbacks: API key in the environment; oauthAccount in ~/.claude.json
# (CLI versions predating `claude auth`).
claude_authenticated() {
    [[ -n "${ANTHROPIC_API_KEY:-}" ]] && return 0
    if claude auth status 2> /dev/null | grep -q '"loggedIn":[[:space:]]*true'; then
        return 0
    fi
    [[ -f "$HOME/.claude.json" ]] && jq -e '.oauthAccount' "$HOME/.claude.json" &> /dev/null
}

# Ensure the Claude CLI is logged in, offering the browser login inline —
# install.sh owns the TTY, so `claude auth login` can run right here.
# Nonzero = still unauthenticated; the caller skips and post_install prints
# how to finish (via CLAUDE_PLUGINS_PENDING).
ensure_claude_auth() {
    claude_authenticated && return 0

    [[ -t 0 ]] || return 1

    log "Claude Code plugins need a logged-in Claude CLI."
    ui_confirm "Log in now? Opens Claude's browser login from this terminal." y || return 1

    claude auth login || warning "Login did not complete"
    claude_authenticated
}

# Install Claude Code plugins listed in settings.json — user-level
setup_claude_plugins() {
    if ! command -v claude &> /dev/null; then
        ui_skip "Claude Code not found"
        return 0
    fi

    if ! command -v jq &> /dev/null; then
        ui_skip "jq not found — needed to read the plugin list"
        return 0
    fi

    log "Installing Claude Code plugins..."

    local settings_file="$DOTFILES_ROOT/.ai/claude/settings.json"
    local plugins=()

    # while-read instead of mapfile: macOS ships bash 3.2
    while IFS= read -r plugin; do
        [[ -n "$plugin" ]] && plugins+=("$plugin")
    done < <(jq -r '
        .enabledPlugins // {}
        | to_entries[]
        | select(.value == true)
        | .key
    ' "$settings_file")

    if [[ ${#plugins[@]} -eq 0 ]]; then
        log "No enabled Claude Code plugins found in settings.json"
        return
    fi

    # Plugins already on this machine are left alone. Reinstalling gains
    # nothing and fails hard for reasons the installer can't fix: a marketplace
    # mid-refresh reports "not found", and upstream sometimes ships a manifest
    # this CLI rejects. Moving versions is `claude plugin update`, deliberately.
    local installed=""
    local state="$HOME/.claude/plugins/installed_plugins.json"
    [[ -f "$state" ]] && installed="$(jq -r '.plugins // {} | keys[]' "$state" 2>/dev/null)"

    local failed=0 added=0 present=0
    for plugin in "${plugins[@]}"; do
        if printf '%s\n' "$installed" | grep -qxF "$plugin"; then
            present=$((present + 1))
            continue
        fi
        log "Installing plugin: $plugin"
        if claude plugin install "$plugin"; then
            added=$((added + 1))
        else
            warning "Failed to install plugin: $plugin"
            failed=1
        fi
    done
    [[ $failed -eq 0 ]] || return 1

    if [[ $added -eq 0 ]]; then
        ui_skip "$present already installed"
        return 0
    fi
    success "Claude Code plugins installed ($added added, $present already present)"
}

# Step driver — pick which AI tools to set up. Nothing is pre-selected and a
# non-terminal run selects nothing, so a plain install stays AI-free.
install_ai_tools() {
    local selected=() line
    while IFS= read -r line; do selected+=("$line"); done < <(ui_choose_many \
        "Pick AI tools to set up (space toggles, enter confirms):" \
        "claude-code:Claude Code — Anthropic's AI coding CLI, plus shared config for it and Codex" \
        "agent-reach:Agent Reach — lets the AI read Twitter/Reddit/YouTube/web links" \
        "claude-plugins:Claude Code plugins — extras listed in settings.json (needs a logged-in CLI)")

    if [[ ${#selected[@]} -eq 0 ]]; then
        ui_skip "No AI tools selected (re-run ./install.sh to add them)"
        return 0
    fi

    # Installing the CLIs needs nothing from .ai/, so a repo that won't clone
    # costs only the parts that read it. Losing the CLI to an unrelated SSH
    # problem is what made the all-or-nothing version wrong.
    local have_ai_repo=true
    if ensure_ai_repo; then
        run_step "AI config symlinks (~/.claude, ~/.codex)" ai_symlinks
    else
        have_ai_repo=false
        ui_skip "AI config repo not available (see README: cassmtnr/ai-config)"
    fi

    local tool
    for tool in "${selected[@]}"; do
        case "$tool" in
            claude-code)    run_step "Claude Code CLI"        install_ai_clis ;;
            agent-reach)
                # agent-reach writes its skill into ~/.claude/skills, which is
                # a symlink into .ai/ — without it the install lands in a real
                # directory the repo never sees
                if ! $have_ai_repo; then
                    ui_skip "Agent Reach — needs the AI config repo"
                else
                    run_step "Agent Reach channels" setup_agent_reach
                fi ;;
            claude-plugins)
                # The login prompt can't run under run_step's output capture —
                # authenticate first, then run the capturable part as a step.
                # Guard on the CLI existing: without it the login prompt offers
                # a command that isn't there, and so does the advice on failure.
                if ! $have_ai_repo; then
                    ui_skip "Claude Code plugins — needs the AI config repo (settings.json lists them)"
                elif ! command -v claude &> /dev/null; then
                    ui_skip "Claude Code plugins — Claude Code not installed (select claude-code too)"
                elif ensure_claude_auth; then
                    run_step "Claude Code plugins" setup_claude_plugins
                else
                    CLAUDE_PLUGINS_PENDING=true
                    ui_skip "Claude Code plugins — not logged in (claude auth login && ./install.sh)"
                fi ;;
        esac
    done

    # Validate the symlinked skills (frontmatter, dead links, missing commands).
    # Advisory, so deliberately not a run_step: lint exits 1 for optional tools
    # it can't find, which is not an install failure and not worth retrying.
    if $have_ai_repo; then
        "$DOTFILES_ROOT/.ai/common/scripts/skill-lint.sh" || \
            ui_skip "Skill lint found issues (see above)"
    fi
    return 0
}
