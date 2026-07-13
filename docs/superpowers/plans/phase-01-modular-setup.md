# Phase 01 — Modular three-step setup

Status: designed 2026-07-13 while Cassiano was away (pre-authorized: "brainstorm,
then execute"). Approval deferred to the walkthrough on his return.

> **Partially superseded 2026-07-13 (same day, post-walkthrough).** Two of this
> phase's decisions were reversed at Cassiano's request:
> - **Tiers removed.** `packages/{basic,standard,full}.brewfile` and the tier
>   menu collapsed into a single `.brewfile`. The only OS axis left is
>   CLI-vs-GUI, handled by the Linux cask filter. `install.sh` no longer asks
>   for a tier; `~/.config/dotfiles-tier` is gone.
> - **AI split out of the regular install.** All AI setup (Claude/Codex config
>   symlinks, CLI installs, agent-reach, plugins) moved to a standalone
>   `lib/ai.sh`. `./install.sh` installs zero AI tooling. The `agent-reach` and
>   `claude-plugins` extras and `update.sh -P` were removed.
>
> Sections below describing tiers, `packages/`, and AI-in-install are historical.
> See CHANGELOG "Dry core + separated AI setup" for the current shape.
>
> Migration note: `lib/ai.sh` cleans orphaned AI symlinks from old layouts but
> never `rm -rf`s a real directory (it warns instead). A machine upgraded from a
> very old per-file layout where `~/.claude/skills` etc. exist as real dirs may
> need a one-time manual `mv ~/.claude/skills ~/.claude/skills.bak` before the
> link takes.

## Problem

`install.sh` runs everything in a fixed order; `.utils.sh` (513 lines) mixes
symlinks, packages, macOS defaults, VSCodium sync, and extras. Packages live in
one flat `.brewfile`. There is no way to install "just the basics" on a VPS, no
separation between installing software and applying personal config, and
sudo-needing steps are scattered. Result: every change risks the whole script,
and machines drift (tars is many commits behind with local edits).

## Goals

1. Three explicit steps: **1 install software** (tiered), **2 configure**
   (personal settings), **3 extras** (optional perks).
2. Checkbox/tier selection when run interactively; safe defaults when there
   is no terminal (VPS over SSH, CI). No flags to memorize.
3. Everything user-level by default. Anything needing sudo/admin is explicitly
   labeled and opt-in.
4. Adding new software or config touches one or two obvious lines.
5. Human-readable plain bash (macOS ships bash 3.2). No new dependencies.

## Decisions

**One repo, not three.** Splitting install/config/perks into separate repos
adds clone-and-sync coordination for a solo user and breaks "one command on a
new machine". The step split inside one repo gives the same separation.

**No dotfiles manager.** chezmoi/dotbot/stow/yadm each add a dependency, a
naming convention, or sudo (research: chezmoi comparison table, Homebrew docs).
A 30-line symlink loop over an explicit list is fully readable and bash-3.2
safe. Revisit chezmoi only if real per-machine templating pain appears.

**Homebrew stays the package layer.** Both current machines already have it.
Bootstrap needs admin on macOS and sudo on Linux (verified: Homebrew
`install.sh` aborts — "Insufficient permissions to install Homebrew";
docs.brew.sh/Homebrew-on-Linux: "The installation script installs Homebrew to
/home/linuxbrew/.linuxbrew using sudo"). On a no-sudo machine without brew, the
installer warns clearly and skips instead of pretending.

**Pure-bash menus.** Tier = numbered single choice; extras = numbered toggle
(checkbox) list. Both gated on `[ -t 0 ]`; without a terminal the script
uses safe defaults (basic tier, no extras).
Pattern verified on macOS /bin/bash 3.2.57.

## Layout

```
dotfiles/
├── install.sh              # Entry point: steps 1→2→3
├── update.sh               # Day-to-day refresh (same flags as before)
├── lib/
│   ├── common.sh           # OS detection, logging, brew path, menu helpers
│   ├── install.sh          # Software: brew tiers, Oh My Zsh, node, bun
│   ├── configure.sh        # Symlinks, SSH perms, VSCodium, user defaults, shell
│   └── extras.sh           # Perks: agent-reach, plugins, icons, MOTD, admin defaults
├── packages/
│   ├── basic.brewfile      # Shell + core CLI (VPS-friendly)
│   ├── standard.brewfile   # + dev toolchain, fonts, desktop apps (macOS casks)
│   └── full.brewfile       # + AI CLI cask, media apps
├── .defaults               # macOS defaults (unchanged; RUN_SUDO gates admin lines)
└── (config dirs unchanged: .ghostty/, .vscodium/, .ai/, .ssh/, …)
```

`.utils.sh` and `.brewfile` are deleted; their content moves into `lib/` and
`packages/`. All references updated (README, .zshenv comment, .zshrc comment,
TODO.md).

## Tiers (cumulative: standard includes basic; full includes standard)

| Tier | Contents |
|---|---|
| **basic** | git, curl/wget, coreutils/findutils/gnu-sed/grep, jq, yq, zsh + plugins, starship, Oh My Zsh |
| **standard** | + nvm/Node 22, bun + globals, python/pipx/poetry, pnpm, gnupg/openssh/openssl, lazydocker; macOS: fonts, ghostty, vscodium, 1password, chrome, fileicon |
| **full** | + claude-code cask (macOS) / claude+gemini via npm (Linux), spotify, vlc |

VPS default: basic. macOS interactive default: standard.

## Steps

**Step 1 — install** (`lib/install.sh`): prerequisites check, Homebrew
bootstrap (only if missing; needs admin — labeled), Oh My Zsh, brew bundle per
selected tier (casks filtered out on Linux), Node via nvm + Bun (standard+),
AI CLIs via npm on Linux (full).

**Step 2 — configure** (`lib/configure.sh`): symlinks from one explicit
`source:target` list (everything is linked regardless of tier — configs for
absent software are inert), SSH permissions, VSCodium settings + extension
sync (skipped when codium absent), user-level macOS defaults (`.defaults` with
RUN_SUDO=false), zsh as default shell (warns if /etc/shells needs sudo).

**Step 3 — extras** (`lib/extras.sh`): each item independent, each
labeled where privileges are needed:

| Extra | Privileges |
|---|---|
| Agent Reach + channels (pipx) | user-level |
| Claude Code plugins | user-level, needs logged-in CLI |
| Custom app icons (fileicon) | admin on managed Macs (writes /Applications bundles) |
| System-level macOS defaults | admin (sudo defaults write) |
| Custom MOTD (Linux) | sudo (/etc/update-motd.d) |

Interactive: toggle menu, nothing pre-selected. Non-interactive: none
(re-run interactively to add extras).

## Interface

Revised during the walkthrough (owner's call): no flags — "the user always
have to be guessing what exists". Every choice is a menu.

```
./install.sh                # TTY: tier menu → admin y/N question → extras
                            # checkboxes. No TTY (SSH pipe, CI): safe
                            # defaults — basic tier, no extras, platform
                            # sudo default with auto-degrade.
./update.sh [-p|-d|-P|-a]   # unchanged; -p uses the tier recorded
                            # in ~/.config/dotfiles-tier (default basic)
```

Interactive remote setup: `ssh -t host` then run it. Re-running is the way
to change tier or add extras (idempotent).

## Error handling

Same philosophy as today: `set -euo pipefail` at entry points; every optional
step degrades to a warning rather than aborting; download-then-execute for
remote installers. Idempotent — safe to re-run any step.

## Verification

- `bash -n` + shellcheck on every script.
- Local: `./install.sh --help`, menu behavior (incl. EOF), step 2 dry behavior.
- tars (via vps-run): copy of the working tree, non-TTY run (safe defaults)
  under an isolated `$HOME` — user-level, idempotent.
- New minimal CI workflow (`.github/workflows/ci.yml`): shellcheck + plain
  `./install.sh` (non-TTY → safe defaults) twice on ubuntu-latest and
  macos-latest — catches "new machine" breakage before it bites.

## Non-goals

- No new repos, no dotfiles manager, no curl-to-~/.local/bin binary layer
  (brew exists on both machines; revisit only if a no-sudo machine without
  brew becomes real).
- No changes to shell config content (.zshrc, .aliases, .functions) beyond
  comment references.
- TODO.md nits stay deferred (they change behavior the user may prefer as-is).

---

# Implementation plan

Executed inline in-session 2026-07-13 (user away; no git steps — user handles
all commits). Each task ends with a verification command.

**Global constraints:** bash 3.2 compatible (no mapfile, no associative
arrays, no `${var^^}`), `set -euo pipefail` only at entry points, optional
steps degrade to `warning` never abort, every script passes `bash -n` and
shellcheck, user-level by default.

### Task 1: `lib/common.sh` — shared foundation

Create `lib/common.sh` holding, moved verbatim from `.utils.sh:7-45,196-221`:
OS detection (`IS_MACOS`/`IS_LINUX`), colors, `log/success/warning/error`,
`DOTFILES_ROOT` (note: now resolves from `lib/`, so use `dirname` twice),
`source_nvm`, `ensure_brew_path`. New code — menu helpers:

```bash
# Single-choice menu. Args: prompt, then options ("value:label" pairs).
# Echoes the chosen value. Caller must ensure a TTY.
choose_one() {
    local prompt="$1"; shift
    local options=("$@") i choice
    echo "$prompt" >&2
    for i in "${!options[@]}"; do
        printf '  %d) %s\n' $((i + 1)) "${options[$i]#*:}" >&2
    done
    while true; do
        printf 'Choice [1-%d]: ' "${#options[@]}" >&2
        read -r choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#options[@]} )); then
            echo "${options[$((choice - 1))]%%:*}"
            return
        fi
    done
}

# Checkbox menu. Args: prompt, then options ("value:label" pairs).
# Toggle by number, Enter to confirm. Echoes chosen values, one per line.
choose_many() {
    local prompt="$1"; shift
    local options=("$@") selected=() i num
    for i in "${!options[@]}"; do selected[$i]=""; done
    while true; do
        echo >&2; echo "$prompt (toggle by number, Enter to confirm)" >&2
        for i in "${!options[@]}"; do
            printf '  [%s] %d) %s\n' "${selected[$i]:- }" $((i + 1)) "${options[$i]#*:}" >&2
        done
        printf 'Toggle: ' >&2
        read -r num
        [[ -z "$num" ]] && break
        if [[ "$num" =~ ^[0-9]+$ ]] && (( num >= 1 && num <= ${#options[@]} )); then
            i=$((num - 1))
            [[ -n "${selected[$i]}" ]] && selected[$i]="" || selected[$i]="x"
        fi
    done
    for i in "${!options[@]}"; do
        [[ -n "${selected[$i]}" ]] && echo "${options[$i]%%:*}"
    done
    return 0
}
```

Verify: `bash -n lib/common.sh && shellcheck lib/common.sh`; menu logic via
a scripted stdin run (`printf '2\n' | bash -c '…choose_one…'`).

### Task 2: `packages/` tier brewfiles

Split `.brewfile` into three cumulative increments (delete `.brewfile`):

- `packages/basic.brewfile`: coreutils, findutils, gnu-sed, grep, wget, curl,
  jq, yq, git, zsh, zsh-completions, zsh-autosuggestions,
  zsh-syntax-highlighting, starship
- `packages/standard.brewfile`: nvm, python@3.13, poetry, pipx, pnpm,
  lazydocker, gnupg, openssh, openssl, fileicon; casks: all six fonts,
  1password, ghostty, google-chrome, vscodium (+ the commented dbeaver line)
- `packages/full.brewfile`: cask claude-code@latest, spotify, vlc

Keep section comments. Verify: `cat packages/*.brewfile | grep -c '^brew\|^cask'`
equals the count in the old `.brewfile`.

### Task 3: `lib/install.sh` — software

Functions, all taking the tier via `TIER` global: `step1_install` (driver),
moved from install.sh mostly verbatim: `install_deps`, `install_homebrew`,
`install_oh_my_zsh`, `setup_nodejs`, `setup_bun` (standard+),
`install_ai_clis` (Linux, full only; was `install_ai_tools`). Rewritten
`install_packages`:

```bash
# Install brew packages for the selected tier (cumulative: full ⊃ standard ⊃ basic)
install_packages() {
    if ! ensure_brew_path; then
        warning "Homebrew not installed — skipping package installation"
        return
    fi
    local tiers=("basic")
    [[ "$TIER" == "standard" || "$TIER" == "full" ]] && tiers+=("standard")
    [[ "$TIER" == "full" ]] && tiers+=("full")
    local tier file
    for tier in "${tiers[@]}"; do
        file="$DOTFILES_ROOT/packages/$tier.brewfile"
        log "Installing packages: $tier tier..."
        if $IS_LINUX; then
            grep -v '^cask[[:space:]]' "$file" | brew bundle --file=- \
                || warning "Some $tier packages failed to install"
        else
            brew bundle --file="$file" || warning "Some $tier packages failed"
        fi
    done
    hash -r
    success "Packages installed"
}
```

Driver:

```bash
step1_install() {
    log "── Step 1/3: install software (tier: $TIER) ──"
    install_deps
    install_homebrew
    install_oh_my_zsh
    install_packages
    if [[ "$TIER" != "basic" ]]; then
        setup_nodejs
        setup_bun
    fi
    [[ "$TIER" == "full" ]] && install_ai_clis
    return 0
}
```

Keep the claude-code cask migration check inside `install_packages` (macOS
only, before the loop). Verify: `bash -n`, shellcheck.

### Task 4: `lib/configure.sh` — personal configuration

`step2_configure` driver + moved verbatim from `.utils.sh`:
`create_symlinks`, `sync_vscodium_extensions`; `configure_macos` renamed
`apply_macos_defaults` and always called with `RUN_SUDO=false` here (silent
no-op on Linux instead of warning); `set_default_shell` moved from install.sh.

```bash
step2_configure() {
    log "── Step 2/3: apply personal configuration ──"
    create_symlinks
    sync_vscodium_extensions
    if $IS_MACOS; then
        apply_macos_defaults false
    fi
    set_default_shell
    return 0
}
```

`apply_macos_defaults` takes the sudo choice as `$1` instead of reading
RUN_SUDO ambient state:

```bash
# Apply macOS defaults from .defaults. $1: "true" to include admin-only lines.
apply_macos_defaults() {
    local with_sudo="${1:-false}"
    [[ -f "$DOTFILES_ROOT/.defaults" ]] || { warning ".defaults not found"; return; }
    RUN_SUDO="$with_sudo" bash "$DOTFILES_ROOT/.defaults" \
        || warning "Some macOS defaults failed to apply"
}
```

Verify: `bash -n`, shellcheck.

### Task 5: `lib/extras.sh` — optional perks

Registry + dispatcher; each extra is `extra_<name>` moved from existing code:
`extra_agent_reach` (was `install_agent_reach`), `extra_claude_plugins` (was
`install_claude_plugins` + `claude_authenticated`), `extra_icons` (was
`apply_custom_icons`, minus the silent always-run), `extra_macos_admin`
(calls `apply_macos_defaults true`, requires sudo), `extra_motd` (was
`install_motd`, minus the inline y/N prompt — selection now happens in the
menu).

```bash
# Extras registry: name:description. Platform-gated entries are appended in
# extras_available. Labels state privilege needs explicitly.
extras_available() {
    echo "agent-reach:Agent Reach internet channels for AI CLIs (user-level)"
    echo "claude-plugins:Claude Code plugins (user-level, needs logged-in CLI)"
    if $IS_MACOS; then
        echo "icons:Custom app icons (needs write access to /Applications — admin on managed Macs)"
        echo "macos-admin:System-level macOS defaults (NEEDS ADMIN/SUDO)"
    fi
    if $IS_LINUX; then
        echo "motd:Custom MOTD scripts in /etc/update-motd.d (NEEDS SUDO)"
    fi
}

run_extra() {
    case "$1" in
        agent-reach)    extra_agent_reach ;;
        claude-plugins) extra_claude_plugins ;;
        icons)          extra_icons ;;
        macos-admin)    extra_macos_admin ;;
        motd)           extra_motd ;;
        *)              warning "Unknown extra: $1" ;;
    esac
}

step3_extras() {
    log "── Step 3/3: extras ──"
    local name
    for name in "$@"; do
        run_extra "$name"
    done
}
```

Sudo-needing extras check upfront and warn-skip when unavailable:
`extra_motd` and `extra_macos_admin` start with
`sudo -v || { warning "…needs sudo — skipped"; return; }`.
Verify: `bash -n`, shellcheck.

### Task 6: new `install.sh` — orchestrator

> Amended post-review at the owner's request: all selection flags
> (`--tier`, `--extras`, `--yes`, `--sudo`, `--no-sudo`) were removed again —
> menus + one admin y/N question on a TTY, safe defaults otherwise. The task
> below is kept as originally executed.

Full rewrite. Keeps `--sudo/--no-sudo`; adds `--tier`, `--extras`, `--yes`,
`--help`. Interactive when stdin is a TTY and `--yes` absent; otherwise
defaults (Linux→basic, macOS→standard, extras none).

```bash
#!/usr/bin/env bash
# Dotfiles setup — three steps:
#   1. install software (tier: basic | standard | full)
#   2. apply personal configuration (symlinks, defaults)
#   3. optional extras (some need sudo/admin — labeled in the menu)
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"
source "$DOTFILES_ROOT/lib/install.sh"
source "$DOTFILES_ROOT/lib/configure.sh"
source "$DOTFILES_ROOT/lib/extras.sh"

TIER=""
EXTRAS=""
ASSUME_YES=false
if $IS_LINUX; then RUN_SUDO=true; else RUN_SUDO=false; fi
```

(arg parsing per the Interface section of the design; `--extras` takes a
comma list validated against `extras_available`, or `none`.)

```bash
main() {
    parse_args "$@"
    if [[ ! -t 0 ]]; then ASSUME_YES=true; fi

    if [[ -z "$TIER" ]]; then
        if $ASSUME_YES; then
            if $IS_LINUX; then TIER=basic; else TIER=standard; fi
        else
            TIER="$(choose_one "Step 1/3 — choose an install tier:" \
                "basic:Basic — shell + core CLI tools (VPS-friendly)" \
                "standard:Standard — basic + dev toolchain + desktop apps" \
                "full:Full — standard + AI CLIs + media apps")"
        fi
    fi

    confirm_sudo          # sudo -v when RUN_SUDO, degrade to no-sudo on failure
    check_prerequisites   # git + curl present, supported OS
    step1_install
    step2_configure

    local extras=()
    if [[ -n "$EXTRAS" && "$EXTRAS" != "none" ]]; then
        IFS=',' read -r -a extras <<< "$EXTRAS"
    elif ! $ASSUME_YES; then
        # Read the platform's extras into an array, offer the checkbox menu
        local available=() line
        while IFS= read -r line; do available+=("$line"); done < <(extras_available)
        while IFS= read -r line; do extras+=("$line"); done \
            < <(choose_many "Step 3/3 — select extras:" "${available[@]}")
    fi
    if [[ ${#extras[@]} -gt 0 ]]; then
        step3_extras "${extras[@]}"
    else
        log "No extras selected — run ./install.sh --extras <name,…> anytime"
    fi
    post_install
}
main "$@"
```

`post_install` trimmed to: success banner, note about `~/.zshrc.local`,
`exec zsh -l` switch (kept, TTY-gated). Verify: `bash -n install.sh`,
shellcheck, `./install.sh --help`, `./install.sh --tier bogus` errors.

### Task 7: `update.sh` re-pointed

Change the `source .utils.sh` line to source `lib/common.sh` +
`lib/install.sh` + `lib/configure.sh` (for `install_packages`
with `TIER=full` on `-p`, `create_symlinks`, `sync_vscodium_extensions`,
`apply_macos_defaults false` on `-d`) and `lib/extras.sh` (for
`extra_claude_plugins` on `-P`). Drop `apply_custom_icons` from the default
path (icons are an extra now; the `brew()` wrapper in `.functions` still
re-applies after upgrades). `-d` applies user-level defaults only. Verify:
`bash -n update.sh && ./update.sh` full run locally (idempotent).

### Task 8: delete `.utils.sh` + update references

`rm .utils.sh`. Grep repo for `utils.sh` and fix: `.zshenv:26` comment →
`lib/common.sh`; `.zshrc:118` comment → `packages/standard.brewfile`;
TODO.md `.utils.sh` item → `lib/configure.sh`; README structure block
(rewritten fully in Task 10). Verify: `grep -rn 'utils\.sh' --exclude-dir=.git .`
returns only CHANGELOG/log.md history mentions.

### Task 9: CI smoke test

Create `.github/workflows/ci.yml`: shellcheck all `*.sh` + `lib/*` +
`.defaults`, then `./install.sh --tier basic --yes --no-sudo` on
ubuntu-latest and macos-latest (runners have brew preinstalled; no-sudo
exercises the managed-machine path). Verify: `bash -n` equivalents locally;
YAML lint via `yq`.

### Task 10: docs

README: new Installation/Updating sections (tier table, extras table with
privilege labels, non-interactive examples incl. tars), updated structure
tree. CHANGELOG entry under a new "Modular three-step setup" heading. log.md:
`decision` + `analysis` entries. Verify: skill-lint/readthrough.

### Task 11: verification sweep

1. `shellcheck install.sh update.sh lib/*.sh` — zero findings (or documented
   directives).
2. Local real run: `./update.sh` and `./install.sh --tier full --yes
   --extras none` (everything already installed → fast idempotent pass).
3. tars via vps-run: fetch rework branch into `~/dotfiles-rework` (separate
   clone — the existing `~/dotfiles` has local drift the user must resolve),
   run `./install.sh --tier basic --yes --no-sudo`, then a second run to
   prove idempotence, then `zsh -lic exit` sanity.
4. Code-review agent pass; fix all findings; re-run 1-3 as needed.
