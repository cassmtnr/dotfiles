# Phase 02 — Vendored-gum Installer UI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the installer's hand-rolled prompts and log-spam with a polished terminal UI backed by gum binaries vendored in the repo, plus a step runner that turns every failure into a retry/skip/abort choice and ends with a summary table.

**Architecture:** Two gum binaries (`bin/gum-darwin-arm64`, `bin/gum-linux-x86_64`) are committed to the repo, so the UI works from the very first prompt on a fresh machine, offline, with no bootstrap. All prompts and status output go through a new `lib/ui.sh` (gum when available → existing pure-bash menu → plain `read`/`printf`). A `run_step` wrapper gives every step one status line, failure recovery, and a final summary. `install.sh` stays the single entry point and becomes a thin orchestrator.

**Tech Stack:** bash 3.2, gum v0.17.0 (vendored, MIT), shellcheck for verification.

## Global Constraints

- **bash 3.2 floor** (macOS default): no `mapfile`, no associative arrays, no namerefs, no fractional `read -t`, no `${var,,}`.
- **User-level only, no sudo** except where the existing scripts already gate on `RUN_SUDO`.
- **The executor NEVER runs git write commands** (no `add`/`commit`/`checkout`/etc. — read-only git like `status`/`diff`/`log` is fine). Each task ends by proposing a commit message; the USER commits before the next task starts.
- **Idempotent**: re-running `./install.sh` on a configured machine is safe; an aborted run resumes cleanly on the next run.
- **Preserve** the symlink layout (`~/.claude`, `~/.codex`, `~/.mcporter`) and the "never overwrite a real file/dir" rule (`link()` in `lib/ai.sh`, symlink guards in `lib/configure.sh`).
- **Non-interactive runs** (no TTY: CI, `curl | bash`, SSH pipes) must keep today's behavior: steps 1–2 run with defaults, steps 3–4 select nothing, zero prompts.
- **Offline**: the installer must run fully offline as far as the UI is concerned (vendored gum, never downloaded at install time).
- Every changed file passes `shellcheck` and `bash -n`.
- Menu copy rule: every selectable option's label is plain English — *what it is + why you'd want it* — understandable by someone who doesn't know the tools.
- Repo root: `/Users/cassiano/dotfiles` (referred to as `$DOTFILES_ROOT` below).

---

### Task 1: Vendor the gum binaries

**Files:**
- Create: `bin/gum-darwin-arm64` (binary)
- Create: `bin/gum-linux-x86_64` (binary)
- Create: `bin/README.md`

**Interfaces:**
- Produces: executable `$DOTFILES_ROOT/bin/gum-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m)` — the exact path scheme `ui_init` (Task 2) resolves. Platform names are pinned: this Mac is `darwin-arm64`, the tars VPS is `linux-x86_64` (verified 2026-07-22).

- [ ] **Step 1: Download release assets and verify checksums**

Version is pinned to v0.17.0 (latest as of 2026-07-22; release ships `checksums.txt`).

```bash
mkdir -p "$DOTFILES_ROOT/bin" /tmp/gum-vendor && cd /tmp/gum-vendor
BASE=https://github.com/charmbracelet/gum/releases/download/v0.17.0
curl -fsSLO "$BASE/gum_0.17.0_Darwin_arm64.tar.gz"
curl -fsSLO "$BASE/gum_0.17.0_Linux_x86_64.tar.gz"
curl -fsSLO "$BASE/checksums.txt"
grep -E 'Darwin_arm64\.tar\.gz$|Linux_x86_64\.tar\.gz$' checksums.txt | shasum -a 256 -c -
```

Expected: two lines ending in `OK`. **If a checksum fails, STOP — do not commit the binary.**

- [ ] **Step 2: Extract and install into bin/**

```bash
cd /tmp/gum-vendor
mkdir -p darwin linux
tar xzf gum_0.17.0_Darwin_arm64.tar.gz -C darwin
tar xzf gum_0.17.0_Linux_x86_64.tar.gz -C linux
# goreleaser may nest the binary in a folder — locate it instead of assuming
install -m 755 "$(find darwin -name gum -type f)" "$DOTFILES_ROOT/bin/gum-darwin-arm64"
install -m 755 "$(find linux  -name gum -type f)" "$DOTFILES_ROOT/bin/gum-linux-x86_64"
```

- [ ] **Step 3: Verify the native binary runs and the repo will track them**

```bash
"$DOTFILES_ROOT/bin/gum-darwin-arm64" --version
# Expected: gum version v0.17.0 (or 0.17.0)
file "$DOTFILES_ROOT/bin/gum-linux-x86_64"
# Expected: ELF 64-bit ... x86-64 (can't execute on macOS — file type check only)
git -C "$DOTFILES_ROOT" check-ignore bin/gum-darwin-arm64 && echo "IGNORED — fix .gitignore" || echo "tracked OK"
# Expected: "tracked OK". If .gitignore excludes bin/, add negation lines: !bin/ and !bin/gum-*
```

- [ ] **Step 4: Survey gum flag syntax for the subcommands lib/ui.sh will use**

Run each and note exact flag names (Task 2's code assumes the ones listed; adjust Task 2 if they differ):

```bash
B="$DOTFILES_ROOT/bin/gum-darwin-arm64"
"$B" choose --help    # need: --no-limit, --header
"$B" confirm --help   # need: --default (behavior when set true/false)
"$B" spin --help      # need: --title, --spinner, --show-error (or --show-output)
"$B" style --help     # need: --bold, --foreground, --border, --padding
```

- [ ] **Step 5: Write bin/README.md**

```markdown
# bin/ — vendored binaries

## gum (v0.17.0, MIT — https://github.com/charmbracelet/gum)

Terminal UI for install.sh (menus, confirms, spinners) via lib/ui.sh.
Vendored so the UI works on a fresh machine with no install step and
offline. Only the two platforms we actually use are committed:

- `gum-darwin-arm64` — Apple Silicon Macs
- `gum-linux-x86_64` — tars VPS / Linux servers

## Updating gum

1. Pick the new version at https://github.com/charmbracelet/gum/releases
2. Download `gum_<ver>_Darwin_arm64.tar.gz`, `gum_<ver>_Linux_x86_64.tar.gz`,
   and `checksums.txt` from the release
3. Verify: `grep -E 'Darwin_arm64\.tar\.gz$|Linux_x86_64\.tar\.gz$' checksums.txt | shasum -a 256 -c -`
4. Extract; `install -m 755 <binary> bin/gum-<os>-<arch>` (same names as above)
5. Sanity check: `bin/gum-darwin-arm64 --version`, then commit

Each upgrade adds ~15 MB to git history (binaries don't diff) — update
when a release fixes something we hit, not on every release.
```

- [ ] **Step 6: Propose commit and pause for the user**

Propose: `feat: vendor gum v0.17.0 binaries for installer UI`
Wait for the user to commit before Task 2.

---

### Task 2: lib/ui.sh — the UI layer

**Files:**
- Create: `lib/ui.sh`
- Modify: `lib/common.sh` (move `choose_many` + `_choose_restore` out, lines 98–180)

**Interfaces:**
- Consumes: `$DOTFILES_ROOT`, `log()`, `warning()`, color vars from `lib/common.sh`; `bin/gum-<os>-<arch>` from Task 1.
- Produces (used by Tasks 3–8):
  - `ui_init` — resolve gum once; call before any other `ui_*`
  - `ui_header "text"` — styled section banner
  - `ui_ok|ui_skip|ui_fail "text"` — one-line step status (✓ / − / ✗)
  - `ui_confirm "question" [y|n]` → exit 0 yes / 1 no; 2nd arg = default (non-TTY takes the default)
  - `ui_choose "prompt" "value:label"...` → prints ONE chosen value
  - `ui_choose_many "prompt" "value:label"...` → prints selected values, one per line (empty on cancel/non-TTY)
  - `ui_spin "title" cmd args...` → runs cmd with spinner; plain passthrough when VERBOSE=true or no gum
  - `run_step "Label" fn [args...]` → captures output, one status line, retry/skip/abort loop on failure, records result
  - `ui_summary` → prints the end-of-run table; returns 1 if anything failed/aborted
  - Globals: `UI_GUM` (path or empty), `VERBOSE` (`true`/`false`, default `false`), parallel arrays `STEP_NAMES[@]` / `STEP_STATUS[@]` (`ok|skipped|failed|aborted`)

- [ ] **Step 1: Move `choose_many` and `_choose_restore` from lib/common.sh into lib/ui.sh unchanged**

Cut lines 98–180 of `lib/common.sh` (the `_choose_restore` and `choose_many` functions with their comments). They become the no-gum fallback inside `lib/ui.sh`. Update the header comment of `lib/common.sh` ("OS detection, logging, Homebrew PATH, NVM" — drop "menus").

- [ ] **Step 2: Write lib/ui.sh**

```bash
#!/usr/bin/env bash

# ============================================
# Terminal UI — every prompt and status line goes through here.
# Backend order: vendored gum (bin/gum-<os>-<arch>) → gum on PATH →
# pure-bash fallback (choose_many below / plain read). bash 3.2 only.
# Sourcing order: after lib/common.sh (needs DOTFILES_ROOT, log(), colors).
# ============================================

UI_GUM=""
VERBOSE="${VERBOSE:-false}"
STEP_NAMES=()
STEP_STATUS=()

# Resolve the gum binary once. Empty UI_GUM = pure-bash fallbacks.
ui_init() {
    local os arch candidate
    os="$(uname -s | tr '[:upper:]' '[:lower:]')"
    arch="$(uname -m)"
    candidate="$DOTFILES_ROOT/bin/gum-$os-$arch"
    if [[ -x "$candidate" ]] && "$candidate" --version &> /dev/null; then
        UI_GUM="$candidate"
    elif command -v gum &> /dev/null; then
        UI_GUM="$(command -v gum)"
    fi
}

ui_header() {
    if [[ -n "$UI_GUM" ]]; then
        "$UI_GUM" style --bold --foreground 212 --padding "0 1" "$1" >&2
    else
        printf '\n\033[1m%s\033[0m\n' "$1" >&2
    fi
}

# One-line step results. Drawn to stderr so command stdout stays clean.
ui_ok()   { printf '%b\n' "  ${GREEN}✓${NC} $1" >&2; }
ui_skip() { printf '%b\n' "  \033[2m− $1\033[0m" >&2; }
ui_fail() { printf '%b\n' "  ${RED}✗${NC} $1" >&2; }

# ui_confirm "Question?" [y|n] → 0 yes / 1 no. Default (2nd arg, default n)
# is what Enter picks — and what a non-TTY run gets without prompting.
ui_confirm() {
    local q="$1" def="${2:-n}" answer hint
    if [[ ! -t 0 ]]; then [[ "$def" == "y" ]]; return; fi
    if [[ -n "$UI_GUM" ]]; then
        if [[ "$def" == "y" ]]; then
            "$UI_GUM" confirm --default=yes "$q"
        else
            "$UI_GUM" confirm --default=no "$q"
        fi
        return
    fi
    if [[ "$def" == "y" ]]; then hint="Y/n"; else hint="y/N"; fi
    printf '%b' "${BLUE}[?]${NC} $q [$hint] " >&2
    read -r answer || answer=""
    case "$answer" in
        [Yy]*) return 0 ;;
        [Nn]*) return 1 ;;
        *)     [[ "$def" == "y" ]] ;;
    esac
}

# Map one selected gum label back to its value. Args: label, then pairs.
_ui_label_to_value() {
    local sel="$1" opt; shift
    for opt in "$@"; do
        if [[ "${opt#*:}" == "$sel" ]]; then printf '%s\n' "${opt%%:*}"; return; fi
    done
}

# ui_choose "prompt" "value:label"... → prints the ONE chosen value.
# Non-TTY: prints the first value (callers put the safe default first).
ui_choose() {
    local prompt="$1" opt sel; shift
    if [[ ! -t 0 ]]; then printf '%s\n' "${1%%:*}"; return; fi
    if [[ -n "$UI_GUM" ]]; then
        local labels=()
        for opt in "$@"; do labels+=("${opt#*:}"); done
        sel="$(printf '%s\n' "${labels[@]}" | "$UI_GUM" choose --header "$prompt")" || sel="${labels[0]}"
        _ui_label_to_value "$sel" "$@"
        return
    fi
    # Fallback: numbered plain prompt
    local i=1 answer
    printf '%s\n' "$prompt" >&2
    for opt in "$@"; do printf '  %d) %s\n' "$i" "${opt#*:}" >&2; i=$((i + 1)); done
    printf '%b' "${BLUE}[?]${NC} choice [1] " >&2
    read -r answer || answer=1
    case "$answer" in (*[!0-9]*|'') answer=1 ;; esac
    if [[ "$answer" -lt 1 || "$answer" -gt $# ]]; then answer=1; fi
    eval "opt=\${$answer}"   # bash 3.2: no ${!answer} for positional params
    printf '%s\n' "${opt%%:*}"
}

# ui_choose_many "prompt" "value:label"... → selected values, one per line.
# Empty output on cancel or non-TTY (same contract as choose_many).
ui_choose_many() {
    local prompt="$1" opt sel; shift
    [[ -t 0 ]] || return 0
    if [[ -z "$UI_GUM" ]]; then choose_many "$prompt" "$@"; return; fi
    local labels=()
    for opt in "$@"; do labels+=("${opt#*:}"); done
    "$UI_GUM" choose --no-limit --header "$prompt" "${labels[@]}" | \
        while IFS= read -r sel; do _ui_label_to_value "$sel" "$@"; done
    return 0
}

# ui_spin "title" cmd args... — spinner while cmd runs (quiet mode + gum +
# TTY only; otherwise plain passthrough so output/errors stay visible).
ui_spin() {
    local title="$1"; shift
    if [[ -n "$UI_GUM" && "$VERBOSE" != "true" && -t 0 ]]; then
        "$UI_GUM" spin --spinner dot --title "$title" --show-error -- "$@"
    else
        log "$title"
        "$@"
    fi
}

# run_step "Label" fn [args...] — run one installer step through the UI:
# output captured to a temp file (streamed when VERBOSE=true), ✓/−/✗ status
# line, and a retry / skip / abort menu on failure. Steps that only lack a
# prerequisite should ui_skip + return 0 themselves; a nonzero return means
# a real failure worth retrying.
run_step() {
    local label="$1" out rc action; shift
    out="$(mktemp)"
    while true; do
        rc=0
        if [[ "$VERBOSE" == "true" ]]; then
            "$@" 2>&1 | tee "$out" || rc=$?
        else
            "$@" > "$out" 2>&1 || rc=$?
        fi
        if [[ $rc -eq 0 ]]; then
            ui_ok "$label"
            STEP_NAMES+=("$label"); STEP_STATUS+=("ok")
            rm -f "$out"; return 0
        fi
        ui_fail "$label"
        [[ "$VERBOSE" == "true" ]] || tail -n 15 "$out" >&2
        if [[ ! -t 0 ]]; then
            STEP_NAMES+=("$label"); STEP_STATUS+=("failed")
            rm -f "$out"; return 0   # non-interactive: record and move on
        fi
        action="$(ui_choose "\"$label\" failed — what now?" \
            "retry:Try again (fix the problem in another terminal first if needed)" \
            "skip:Skip this step and continue" \
            "abort:Stop the installer")"
        case "$action" in
            retry) continue ;;
            abort)
                STEP_NAMES+=("$label"); STEP_STATUS+=("aborted")
                rm -f "$out"; ui_summary; exit 1 ;;
            *)
                STEP_NAMES+=("$label"); STEP_STATUS+=("skipped")
                rm -f "$out"; return 0 ;;
        esac
    done
}

# End-of-run summary table. Returns 1 if anything failed or aborted.
ui_summary() {
    local i bad=0
    [[ ${#STEP_NAMES[@]} -gt 0 ]] || return 0
    ui_header "Summary"
    for ((i = 0; i < ${#STEP_NAMES[@]}; i++)); do
        case "${STEP_STATUS[$i]}" in
            ok)      ui_ok   "${STEP_NAMES[$i]}" ;;
            skipped) ui_skip "${STEP_NAMES[$i]} (skipped)" ;;
            *)       ui_fail "${STEP_NAMES[$i]} (${STEP_STATUS[$i]})"; bad=1 ;;
        esac
    done
    return $bad
}

# ── pure-bash menu fallback (moved verbatim from lib/common.sh) ──
# [paste _choose_restore and choose_many here, unchanged, including their
#  original comments]
```

Adjust `--default=yes/no`, `--show-error`, `--header` etc. to whatever Task 1 Step 4 found — then re-verify.

- [ ] **Step 3: Static checks**

```bash
bash -n "$DOTFILES_ROOT/lib/ui.sh" && bash -n "$DOTFILES_ROOT/lib/common.sh"
shellcheck -s bash "$DOTFILES_ROOT/lib/ui.sh" "$DOTFILES_ROOT/lib/common.sh"
```

Expected: no output (clean). Fix every finding; `# shellcheck disable=` only with a comment saying why.

- [ ] **Step 4: Functional check of the non-interactive contract (no TTY = no prompts, defaults win)**

```bash
cd "$DOTFILES_ROOT"
bash -c 'source lib/common.sh; source lib/ui.sh; ui_init
  echo "gum: ${UI_GUM:-none}"
  ui_confirm "should be YES silently?" y && echo "confirm-default-y: yes"
  ui_confirm "should be NO silently?"  n || echo "confirm-default-n: no"
  ui_choose "pick" "first:Label A" "second:Label B"
  ui_choose_many "pick many" "a:One" "b:Two"; echo "choose_many printed nothing: $?"
  run_step "always ok"  true
  run_step "always bad" false
  ui_summary || echo "summary flagged the failure"' < /dev/null
```

Expected output (order matters): `gum: /Users/cassiano/dotfiles/bin/gum-darwin-arm64`, `confirm-default-y: yes`, `confirm-default-n: no`, `first`, `choose_many printed nothing: 0`, ✓/✗ status lines, a Summary block, `summary flagged the failure`. Nothing may hang waiting for input.

- [ ] **Step 5: Interactive smoke test (needs a real terminal — ask the user to run it if you have no TTY)**

```bash
bash -c 'source lib/common.sh; source lib/ui.sh; ui_init
  ui_choose_many "Pick some:" "a:Option A" "b:Option B" "c:Option C"
  run_step "deliberate failure — choose retry once, then skip" false'
```

Expected: gum checkbox menu renders; selected values print; the failure menu offers retry/skip/abort and behaves accordingly.

- [ ] **Step 6: Grep for stragglers**

```bash
grep -rn "choose_many\|_choose_restore" --include='*.sh' "$DOTFILES_ROOT" | grep -v 'lib/ui.sh'
```

Expected: only the call in `install.sh:160` (rewired in Task 3) and none in `lib/common.sh`.

- [ ] **Step 7: Propose commit and pause for the user**

Propose: `feat: add lib/ui.sh gum-backed UI layer`

---

### Task 3: install.sh — orchestrator rewrite

**Files:**
- Modify: `install.sh` (rewrite `main`, `confirm_sudo`, `show_help`, `parse_args`; keep `check_prerequisites`, `post_install`)

**Interfaces:**
- Consumes: everything `lib/ui.sh` produces; existing step functions (`install_deps`, `install_homebrew`, `install_oh_my_zsh`, `install_packages`, `setup_nodejs`, `create_symlinks`, `sync_vscodium_extensions`, `apply_macos_defaults`, `set_default_shell`, `extras_available`, `run_extra`, `install_ai_tools`).
- Produces: `--verbose` flag (sets `VERBOSE=true`); the four-step flow driven by `run_step`.

- [ ] **Step 1: Source ui.sh and init**

After line 19 (`source .../lib/common.sh`) add `source "$DOTFILES_ROOT/lib/ui.sh"`. In `main`, immediately after `parse_args "$@"`, call `ui_init`. Replace the `echo "======..."` banner block with `ui_header "Dotfiles setup — $(os_label)"` (keep the Linux GUI-apps note as a `log` line).

- [ ] **Step 2: Add --verbose to parse_args and show_help**

```bash
parse_args() {
    case "${1:-}" in
        "") ;;
        -v|--verbose) VERBOSE=true ;;
        -h|--help) show_help; exit 0 ;;
        *) error "Unknown option: $1"; show_help; exit 1 ;;
    esac
}
```

Add to `show_help`: `  -v, --verbose   Show full command output instead of one line per step`.

- [ ] **Step 3: Convert confirm_sudo to ui_confirm**

Replace the `printf`/`read` block (install.sh:76–85) with:

```bash
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
```

(Non-TTY takes the platform default via `ui_confirm`'s contract — same as today's behavior.)

- [ ] **Step 4: Rewrite main's step flow around run_step**

Replace `start_installation` / `start_configuration` calls and the step-3/4 blocks (install.sh:151–170) with:

```bash
    ui_header "Step 1/4 — install software"
    run_step "System dependencies (zsh, git, curl, build tools)" install_deps
    run_step "Homebrew (package manager)"                        install_homebrew
    run_step "Oh My Zsh (shell framework)"                       install_oh_my_zsh
    run_step "Apps and CLI tools from .brewfile"                 install_packages
    run_step "Node.js via NVM"                                   setup_nodejs

    ui_header "Step 2/4 — personal configuration"
    run_step "Symlink dotfiles into \$HOME"        create_symlinks
    run_step "VSCodium extension sync"             sync_vscodium_extensions
    run_step "macOS defaults (user-level)"         apply_macos_defaults false
    run_step "Zsh as default shell"                set_default_shell

    ui_header "Step 3/4 — optional extras"
    local extras=() line available=()
    while IFS= read -r line; do available+=("$line"); done < <(extras_available)
    if [[ ${#available[@]} -gt 0 ]]; then
        while IFS= read -r line; do extras+=("$line"); done \
            < <(ui_choose_many "Pick extras to set up (space toggles, enter confirms):" "${available[@]}")
    fi
    if [[ ${#extras[@]} -gt 0 ]]; then
        local name
        for name in "${extras[@]}"; do
            run_step "Extra: $name" run_extra "$name"
        done
    else
        ui_skip "No extras selected (re-run ./install.sh anytime to add them)"
    fi

    ui_header "Step 4/4 — AI tools"
    install_ai_tools

    ui_summary || true
    post_install
```

Delete the now-unused `start_installation` (lib/install.sh:171–179) and `start_configuration` (lib/configure.sh:284–291) drivers, and `install_extras` (lib/extras.sh:118–125). Grep first: `grep -rn "start_installation\|start_configuration\|install_extras" --include='*.sh' .` — `update.sh` does NOT use them (it calls `create_symlinks` etc. directly), but verify before deleting.

- [ ] **Step 5: Static + non-interactive verification**

```bash
bash -n install.sh && shellcheck -s bash install.sh
HOME="$(mktemp -d)" ./install.sh < /dev/null
```

Expected: runs end-to-end with no prompt and no hang; steps print one ✓/−/✗ line each; summary at the end. (In the fake HOME most steps will skip or fail fast — that's fine; what's being verified is flow, silence, and the summary.)

- [ ] **Step 6: Propose commit and pause for the user**

Propose: `refactor: drive install.sh through ui.sh step runner`

---

### Task 4: Step functions — real failures fail, prerequisite-skips stay quiet

The retry menu only works if functions return nonzero on *real* failures. Today most swallow errors with `warning ... return`. Convert per the rule: **network/tool failure → `return 1`; missing prerequisite or not-applicable → `ui_skip "reason"; return 0`.** Keep each function's internal logic otherwise untouched.

**Files:**
- Modify: `lib/install.sh`, `lib/configure.sh`, `lib/extras.sh`

**Interfaces:**
- Consumes: `ui_skip` from `lib/ui.sh`.
- Produces: step functions whose exit codes `run_step` can trust.

- [ ] **Step 1: lib/install.sh conversions**

| Function | Change |
|---|---|
| `install_deps` | `! $RUN_SUDO` branch (line 31–34): `warning` → `ui_skip "missing ${missing[*]} — needs admin rights"; return 0`. apt/xcode failures: append `|| return 1` instead of `|| warning ...`. |
| `install_homebrew` | Already-installed: `ui_skip "Homebrew already installed"; return 0`. The three `warning ... return` download/install failure paths (lines 65–67, 70–72, 79–83): → `error "<same text>"; return 1`. |
| `install_oh_my_zsh` | Already-installed → `ui_skip`; both failure paths → `return 1`. |
| `install_packages` | No brew / no .brewfile → `ui_skip`; `brew bundle` failure → `return 1` (retry-able: flaky downloads are the common case). |
| `setup_nodejs` | No NVM → `ui_skip "NVM not found — install with: brew install nvm"`; `nvm install/use` failures → `return 1`. |

- [ ] **Step 2: lib/configure.sh conversions**

| Function | Change |
|---|---|
| `create_symlinks` | Leave per-link warnings as-is (partial success is fine); function keeps returning 0. |
| `sync_vscodium_extensions` | No `codium` → `ui_skip "VSCodium not installed"`; keep the rest. |
| `apply_macos_defaults` | Not macOS / no `.defaults` → `ui_skip`; script failure → `return 1`. |
| `set_default_shell` | Already zsh / no zsh / no admin for /etc/shells → `ui_skip`; `chsh` failure → `return 1`. |

- [ ] **Step 3: lib/extras.sh conversions**

`extra_icons`: no `fileicon` → `ui_skip`; `fileicon set` failure → `return 1`. `extra_macos_admin` / `extra_motd`: `sudo -v` failure → `ui_skip "needs admin rights"`; command failures inside `extra_motd` → `return 1` (add `|| return 1` to the `sudo cp`/`chmod`/`chown` chain).

Also rewrite `extras_available` labels to the plain-English copy rule:

```bash
extras_available() {
    if $IS_MACOS; then
        echo "icons:Custom app icons — nicer VSCodium icon in the Dock (admin on managed Macs)"
        echo "macos-admin:System-wide macOS tweaks — settings that need admin/sudo"
    fi
    if $IS_LINUX; then
        echo "motd:Server welcome screen — custom message on SSH login (sudo)"
    fi
}
```

- [ ] **Step 4: Verify**

```bash
bash -n lib/install.sh lib/configure.sh lib/extras.sh
shellcheck -s bash lib/install.sh lib/configure.sh lib/extras.sh
HOME="$(mktemp -d)" ./install.sh < /dev/null   # still silent, still completes
grep -rn "warning \"" lib/install.sh | grep -v ui_skip   # eyeball what's left: only partial-success warnings should remain
```

- [ ] **Step 5: Propose commit and pause for the user**

Propose: `refactor: step functions signal failures for retry`

---

### Task 5: lib/ai.sh — same conversion + menu copy

**Files:**
- Modify: `lib/ai.sh`

**Interfaces:**
- Consumes: `ui_choose_many`, `ui_confirm`, `ui_skip`, `run_step` from `lib/ui.sh`.

- [ ] **Step 1: Convert install_ai_tools driver**

Replace the `choose_many` call (lib/ai.sh:228–232) with `ui_choose_many` and the plain-English copy:

```bash
        while IFS= read -r line; do selected+=("$line"); done < <(ui_choose_many \
            "Pick AI tools to set up (space toggles, enter confirms):" \
            "claude-code:Claude Code — Anthropic's AI coding CLI, plus shared config for it and Codex" \
            "agent-reach:Agent Reach — lets the AI read Twitter/Reddit/YouTube/web links" \
            "claude-plugins:Claude Code plugins — extras listed in settings.json (needs a logged-in CLI)")
```

Wrap the per-tool dispatch in `run_step`:

```bash
    run_step "AI config symlinks (~/.claude, ~/.codex)" ai_symlinks
    local tool
    for tool in "${selected[@]}"; do
        case "$tool" in
            claude-code)    run_step "Claude Code CLI"        install_ai_clis ;;
            agent-reach)    run_step "Agent Reach channels"   setup_agent_reach ;;
            claude-plugins) run_step "Claude Code plugins"    setup_claude_plugins ;;
        esac
    done
    run_step "Skill lint" "$DOTFILES_ROOT/.ai/common/scripts/skill-lint.sh"
```

- [ ] **Step 2: Failure conversions inside lib/ai.sh**

| Function | Change |
|---|---|
| `install_ai_clis` | No brew → `ui_skip`; cask/npm install failures → `return 1`. |
| `setup_agent_reach` | No pipx → `ui_skip "pipx not found — brew install pipx"`; pipx install failure → `return 1`; keep channel/inject soft-warnings (partial success). |
| `setup_claude_plugins` | No claude / no jq → `ui_skip`; per-plugin failure keeps `warning` but track: set a local `failed=1` and `return 1` at the end if any plugin failed. |

Auth is already handled (landed before this plan): `ensure_claude_auth` in `lib/ai.sh` offers the inline `claude auth login`, and `CLAUDE_PLUGINS_PENDING=true` makes `post_install` print finish-later instructions. Two adjustments here, because that prompt cannot run *inside* a `run_step` capture (it would be swallowed):

1. Move the `ensure_claude_auth` call out of `setup_claude_plugins` and into the driver:

```bash
            claude-plugins)
                if ensure_claude_auth; then
                    run_step "Claude Code plugins" setup_claude_plugins
                else
                    CLAUDE_PLUGINS_PENDING=true
                    ui_skip "Claude Code plugins — not logged in (claude auth login && ./install.sh)"
                fi ;;
```

2. Inside `ensure_claude_auth`, replace the `printf`/`read` question with `ui_confirm "Log in now? Opens Claude's browser login from this terminal." y` (keep the `[[ -t 0 ]] || return 1` guard and the `claude auth login` call as-is).

- [ ] **Step 3: Verify**

```bash
bash -n lib/ai.sh && shellcheck -s bash lib/ai.sh
HOME="$(mktemp -d)" ./install.sh < /dev/null    # step 4 must silently select nothing
```

- [ ] **Step 4: Propose commit and pause for the user**

Propose: `refactor: ai tools step uses ui.sh and clear menu copy`

---

### Task 6: update.sh + verbosity trim

**Files:**
- Modify: `update.sh`, `lib/configure.sh` (log-noise trim only)

- [ ] **Step 1: update.sh adopts the UI**

Source `lib/ui.sh` after `lib/common.sh` (update.sh:12); call `ui_init` at the top of `main`; replace the banner with `ui_header "Dotfiles update — $(os_label)"`; add `-v|--verbose) VERBOSE=true ;;` to `parse_args` and the help text; wrap the four operations:

```bash
    run_step "Symlink dotfiles into \$HOME"  create_symlinks
    run_step "VSCodium extension sync"       sync_vscodium_extensions
    if $UPDATE_PACKAGES; then run_step "Homebrew packages" install_packages; fi
    if $UPDATE_DEFAULTS; then run_step "macOS defaults (user-level)" apply_macos_defaults false; fi
    ui_summary || true
```

- [ ] **Step 2: Trim per-item log noise in quiet mode**

`create_symlinks` prints one `log` line per symlink (configure.sh:121) — under `run_step` capture this is invisible in quiet mode and shown with `--verbose`, which is exactly right. Only change: drop the standalone `log "Creating symbolic links..."` / `success "Symbolic links created"` bookends (redundant with the step line). Same for the `log/success` bookends in `sync_vscodium_extensions`, `apply_macos_defaults`, `install_packages`, `setup_nodejs` — the `run_step` label already says it. Keep warnings.

- [ ] **Step 3: Verify**

```bash
bash -n update.sh && shellcheck -s bash update.sh
./update.sh          # real HOME — safe: symlinks + extension sync are idempotent
./update.sh --verbose
```

Expected: quiet run shows ~2 status lines + summary; verbose shows full output. Symlinks unchanged after both (`ls -la ~/.zshrc` still points into the repo).

- [ ] **Step 4: Propose commit and pause for the user**

Propose: `refactor: update.sh uses ui.sh, quiet by default`

---

### Task 7: Docs

**Files:**
- Modify: `README.md` (install section), `CHANGELOG.md`, `log.md`, `docs/superpowers/plans/phase-02-gum-installer-ui.md` (tick checkboxes)

- [ ] **Step 1: README install section rewrite**

Rewrite for a newcomer: what `./install.sh` does (four steps, what each menu means), that menus are arrow-key driven, that failures offer retry/skip/abort, `--verbose`, that re-running is safe, and a short "vendored gum" note linking to `bin/README.md`. Delete any README text describing the old prompt behavior. Keep the section under ~60 lines.

- [ ] **Step 2: CHANGELOG + log.md**

CHANGELOG: one entry under a new version heading matching the file's existing format ("gum-based installer UI, vendored binaries, retry/skip/abort step runner, quiet output with --verbose"). `log.md`: append a `## [<date>] commit | ...` entry per the file's format after the user's final commit.

- [ ] **Step 3: Propose commit and pause for the user**

Propose: `docs: describe gum installer UI`

---

### Task 8: End-to-end verification

**Files:** none (verification only)

- [ ] **Step 1: Full lint sweep**

```bash
shellcheck -s bash install.sh update.sh lib/*.sh
bash -n install.sh update.sh lib/*.sh
```

Expected: clean.

- [ ] **Step 2: Fresh-machine simulation, non-interactive + idempotency**

```bash
FAKE="$(mktemp -d)"
HOME="$FAKE" ./install.sh < /dev/null      # run 1: converges
HOME="$FAKE" ./install.sh < /dev/null      # run 2: everything ok/skipped, fast
```

Expected: no hangs, no prompts, second run's summary shows no new failures.

- [ ] **Step 3: Offline UI check**

```bash
bash -c 'source lib/common.sh; source lib/ui.sh; ui_init; echo "${UI_GUM}"'
```

Expected: prints the `bin/gum-darwin-arm64` path (vendored, not a PATH gum) — proving the UI needs no network and no installed gum.

- [ ] **Step 4: Interactive acceptance on this Mac (USER runs this — agent can't drive a TTY)**

Ask the user to run `./install.sh` in a terminal and check: styled headers, gum checkbox menus with the new descriptions, spinner/status lines, deliberate failure recovery (e.g. toggle wifi off during brew bundle → retry menu), summary table.

- [ ] **Step 5: Linux run on tars**

```bash
.ai/common/scripts/vps-run.sh 'cd ~/dotfiles && git pull && ./install.sh < /dev/null && ./update.sh'
```

Expected: non-interactive path completes on Linux; `bin/gum-linux-x86_64` resolves (check with the Step-3 one-liner via vps-run). Requires the user to have pushed the branch first — coordinate.

- [ ] **Step 6: Code-review pass**

Run the review flow (dedicated reviewer agent / `/review`) over the full diff. Fix every finding, re-run Steps 1–2, and write anything genuinely deferred into `TODO.md` with context.

- [ ] **Step 7: Propose the final commit (if any fixes landed) and hand back**

Summarize: what changed, verification evidence, anything in `TODO.md`.

---

## Self-review notes

- Spec coverage: vendored gum (T1), ui wrapper + fallback chain (T2), orchestrator + previews/menu copy (T3–T5), retry/skip/abort + summary (T2/T4/T5), verbosity + --verbose (T3/T6), docs (T7), offline + idempotency + tars verification (T8). Codex removal is intentionally NOT in this phase.
- The `--verbose` flag contradicts install.sh's old "no flags" comment — T3 updates the header comment and help text.
- The inline Claude login (`ensure_claude_auth`, landed pre-plan) is the one prompt that can't live under `run_step` capture — T5 Step 2 moves its call site into the driver, before `run_step`.
- gum flag names (`--default`, `--show-error`, `--header`, `--no-limit`) are asserted from docs, not a live run — T1 Step 4 verifies them against the vendored binary before T2 hardcodes them.
