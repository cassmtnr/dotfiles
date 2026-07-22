# Changelog

All notable changes to this dotfiles project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### TODO closeout — 2026-07-22

#### Removed

- **`extract()`** — unused; deleted from `.functions` rather than fixing its
  broken `.rar`/`.7z` branches (no tool for them was ever installed)

#### Fixed

- **`/usr/local/bin` preceded Homebrew in PATH** — on Apple Silicon a stale
  Intel binary there would shadow its ARM brew twin; brew's bin/sbin now come
  first in `.zshenv`
- **`cc` alias compiler shadow accepted** — interactive shells only, no C
  work happens here; TODO closed without changes

### Menu-driven modular setup — 2026-07-14

Reworked the installer into a modular, fully menu-driven, user-level-first
setup. (Superseded, in the same unreleased batch, an intermediate tiered
design and a standalone AI script — this entry reflects the final shape.)

#### Changed

- **`install.sh` runs four interactive steps, no flags** (only `--help`):
  1. install software, 2. apply personal configuration (symlinks, user-level
  defaults), 3. optional extras, 4. AI tools. Steps 3 and 4 are checkbox menus
  with nothing pre-selected and are skipped without a terminal, so a plain or
  non-interactive run (SSH pipe, CI) installs no extras and no AI. Menus are
  pure bash (macOS bash 3.2, zero dependencies).
- **`.utils.sh` split into `lib/`** — `common.sh` (OS detection, logging, brew
  PATH, menu helper), `install.sh`, `configure.sh`, `extras.sh`, `ai.sh`. Step
  drivers: `start_installation`, `start_configuration`, `install_extras`,
  `install_ai_tools`.
- **Single `.brewfile`** — casks (GUI apps) are automatically skipped on Linux,
  so a VPS gets CLI tools only. `install.sh` prints the detected OS at the start.
- **Sudo-needing perks are opt-in extras** (step 3) — custom app icons,
  system-level macOS defaults, Linux MOTD — each labels its privilege need and
  only runs if selected.
- **AI tooling is opt-in step 4** — a checkbox of `claude-code` (Claude Code +
  Codex config), `agent-reach`, and `claude-plugins`. Nothing is pre-selected.
- **Homebrew adapts to admin availability** — official installer with admin
  (bottles, fast); untar into `~/.homebrew` without admin (user-level, builds
  from source). `ensure_brew_path` and `.zshenv` detect all three prefixes.
- **`update.sh`** — no-arg refreshes symlinks + VSCodium extensions; `-p`
  refreshes packages from `.brewfile`; `-d` re-applies user-level macOS defaults.

#### Removed

- **Bun** — redundant with the Node + pnpm stack; nothing depended on it
  (`playwright-install` kept its npx fallback). Dropped `setup_bun`, `.bun`, and
  its four global installs (yarn, typescript, eslint, nodemon).

#### Added

- **Arrow-key checkbox menus** — the extras and AI-tools selectors use ↑/↓ (or
  j/k) to move, space to toggle, `a` for all, enter to confirm, q/Esc to cancel,
  replacing the numbered-toggle prompt. Pure bash 3.2, zero dependencies (no
  gum/fzf/whiptail); restores the terminal on Ctrl-C.
- **CI smoke test** (`.github/workflows/ci.yml`) — shellcheck + non-interactive
  install, twice for idempotence, on ubuntu-latest and macos-latest.
- **Design doc** — `docs/superpowers/plans/phase-01-modular-setup.md`.

### Install Failure Fixes — 2026-07-13

#### Fixed

- **`brew bundle` crashed when brew wasn't on PATH** (`.utils.sh:207: brew: command not found` on the work machine) — new `ensure_brew_path()` finds an installed brew that isn't on PATH yet (fresh shells), exports its shellenv (incl. `HOMEBREW_PREFIX`, which `source_nvm` needs), rejects broken binaries, and `install_packages` now skips with a warning when brew is truly absent. `update.sh` calls it up front so brew-installed binaries (codium, fileicon, claude, jq) are found in fresh shells too
- **`claude-code` cask conflicted with the installed `claude-code@latest`** — both ship `/opt/homebrew/bin/claude`; `.brewfile` now tracks `claude-code@latest` and `install_packages` migrates machines that still have the old cask (one-time `brew uninstall`)
- **A failing `defaults write` aborted the whole install** — `com.apple.helpviewer` is sandboxed on macOS 26+ and killed the run mid-way (skipping plugins, agent-reach, shell setup) because `.defaults` was sourced under `set -e`; the dead helpviewer tweak is removed, `.defaults` now runs as a subprocess with an ERR-trap failure counter, and `configure_macos` warns instead of dying when some defaults fail
- **`source_nvm` aborted the install on a fresh machine with a cwd `.nvmrc`** — nvm's auto-`use` returns nonzero for an uninstalled version (reproduced with a fake `$HOME`); now sourced with `--no-use` since the callers run `nvm install`/`nvm use` explicitly
- **`~/Screenshots` was never created** — `.defaults` pointed `com.apple.screencapture location` at it, but `screencapture` doesn't create missing folders, so screenshots on a fresh machine silently saved nowhere
- **`/usr/local` dropped from brew detection** (`ensure_brew_path` and `.zshenv` `HOMEBREW_PREFIX`) — only `/opt/homebrew` (macOS) and `/home/linuxbrew/.linuxbrew` (Linux) are probed
- **Remote installers guarded** (Homebrew, Oh My Zsh) — a failed download no longer executes an empty script and reports success, and a failed install warns and continues instead of aborting the run under `set -e`
- **`source nvm.sh` guarded and default-alias fallback added** — `install_ai_tools` and `update.sh -P` activate nvm's default node when the pinned version isn't active, restoring the npm/claude lookup that `--no-use` had removed on Linux failure paths
- **`.zshenv` PATH no longer front-loads `/bin` and `/sbin`** when `HOMEBREW_PREFIX` is unset (the unset var made `$HOMEBREW_PREFIX/bin` expand to `/bin`)
- **Cask migration check via Caskroom dir test** instead of `brew list --cask` — saves ~0.7s of Ruby startup on every `install.sh`/`update.sh -p` run
- **`.defaults` hardening** — failed `sudo -v` degrades to no-sudo instead of re-prompting mid-run; a failed `~/Screenshots` mkdir is recorded and no longer lets the screencapture location point at an unusable path; `capture-setting.sh` errors instead of appending after the failure summary when its insertion mark is missing

#### Changed

- **`authorized_keys` handling scoped to Linux** — the chmod-600 upkeep and missing-file warning matter on the tars VPS (key logins for user + CI; sshd StrictModes rejects lax perms) but fired as noise on every macOS run, where no inbound SSH exists

### Repo Overhaul — 2026-07-13

#### Fixed

- **`.ssh-agent` leaked one agent per shell** — `ssh-add -l` exit 1 (agent up, no keys) was treated like exit 2 (no agent), so every terminal spawned a fresh `ssh-agent` (36 were running); now only starts on exit 2
- **RSS skill instructions required `feedparser`, which isn't installed** — replaced with a dependency-free Python stdlib snippet (handles RSS and Atom), verified against a live feed
- **Stale `.ai/common/commands` symlink pairs removed** — the directory died in 2026-04 when its last command was deleted; every install/update printed two "Source file not found" warnings since
- **Four more `set -e` abort paths** — `source_nvm` on unset `HOMEBREW_PREFIX`, extension sync on an empty `extensions.txt` (plus a BRE bug letting blank lines through to `codium --install-extension ""`), the MOTD prompt in non-interactive sessions, and `set_default_shell` when zsh is absent — all now warn and continue
- **`setup_bun` never synced global packages on machines that already had bun** — early return skipped yarn/typescript/eslint/nodemon forever
- **`.gitignore` now covers `.ssh/config.work`** — the install flow symlinks it as a private config, but it wasn't ignored; creating it would have made a work SSH config committable to this public repo
- README corrections: removed references to the deleted `.ai/codex/config.toml`, fixed the plugin list (`ponytail`, not sentry/swift-lsp/pyright-lsp), brewfile count, structure tree, and documented the agent-reach skill auto-restore

#### Removed (clarification for earlier [Unreleased] entries)

- `.ai/codex/config.toml` (removed 2026-04-16) and `.ai/common/commands/` (last file deleted 2026-04-07) no longer exist — earlier entries below that reference them are historical

### No-Sudo Mode & Plugin Auth Gate — 2026-07-06 → 2026-07-13

#### Added

- **Platform-conditional sudo** — Linux defaults to sudo (servers with root), macOS defaults to no-sudo (managed work laptops just work); `--sudo`/`--no-sudo` override. No-sudo mode skips Homebrew bootstrap, apt-get, `/etc/shells`, system-level macOS defaults, and MOTD install, each with a warning, and auto-engages if the `sudo -v` prompt fails
- **Claude Code plugin auth gate** — `install_claude_plugins` now checks login state (`oauthAccount` in `~/.claude.json` or `ANTHROPIC_API_KEY`) and interactively waits for the user to authenticate in another terminal instead of failing every install on a fresh machine; skippable, with `./update.sh --plugins` (`-P`) as the deferred path

#### Added (macOS defaults)

- **`capture-setting.sh`** — one-step capture of any macOS setting into `.defaults`: run it, change the setting in System Settings, press Enter; it detects the changed preference keys, filters out churn (timestamps, counters, caches, app state), and appends ready-made `defaults write` lines to `.defaults` for review via `git diff`. Deliberate non-goal: importing a full `defaults read` dump (app state + machine identifiers, not preferences). Replaced an earlier defaults-diff.sh/defaults-sync.sh pair that required manual diff-reading

- **Finder view preferences captured into `.defaults`** — default icon view (`FXPreferredViewStyle icnv`), Recent Tags hidden, and the ⌘J "Use as Defaults" icon-view template (64px icons, grid 54, text 12, sort by name, item info + previews) via PlistBuddy since it's a nested dict. Per-folder view overrides live in `.DS_Store` files and cannot be captured

#### Fixed

- **Trackpad corner right-click never fully applied** — `.defaults` only wrote the Bluetooth-trackpad domain (built-in trackpads read `com.apple.AppleMultitouchTrackpad`), and two pre-existing values were wrong for corner mode (`TrackpadRightClick` and `enableSecondaryClick` must be false). Full six-key set captured live while flipping the setting in System Settings
- **`install_claude_plugins` never worked under macOS system bash** — `mapfile` is bash 4+; replaced with a `while read` loop (macOS ships bash 3.2)
- **agent-reach upgrades overwrite the trimmed skill** — newer versions regenerate the skill with upstream's Chinese 15-platform docs instead of preserving existing files; `install_agent_reach()` now restores the committed trimmed version from git after every channel install
- **`set_default_shell` tried to chsh from `/bin/zsh` to brew's zsh** — failed on macOS ("non-standard shell", not in `/etc/shells`); any zsh now counts as done
- **`.defaults` kill-apps loop aborted install.sh when an app wasn't running** — `killall` exits 1 on no match; now `|| true` (same `set -e` failure class as the `return 1` fixes)
- **`setup_nodejs`/`setup_bun`/`install_ai_tools` aborted the whole install on guarded failures** — `return 1` under `set -e` exits the script; a missing NVM or a failed Bun download now warns and continues like every other optional step
- **`killall Finder` no longer uses sudo** — restarting the user's own Finder never needed it

### Agent Reach Integration — 2026-07-06

#### Added

- **Agent Reach** internet channel router for AI CLIs — `install_agent_reach()` in `install.sh` (pipx install + core channels + bilibili/twitter + rdt-cli for Reddit). Active channels: web pages, Exa search, YouTube, GitHub, RSS, V2EX, Bilibili (bili-cli), Twitter (twitter-cli), Reddit (rdt-cli). Twitter/Reddit logins are cookie-based, manual per machine
- **`agent-reach` skill** (`.ai/common/skills/agent-reach/`) — platform routing rules and per-domain command references, auto-shared with Claude Code and Codex via the existing skills symlink. Trimmed to installed channels (upstream ships docs for 15 platforms incl. XiaoHongShu/Facebook/Instagram/LinkedIn — removed along with all OpenCLI references) and translated from Chinese to English; `career.md` is a stub because `agent-reach doctor` recreates deleted skill files
- **`config/mcporter.json`** symlinked to `~/.mcporter/mcporter.json` — makes Exa search work from any directory (was project-local to the dotfiles repo only)
- **`update.sh -p` now also runs `pipx upgrade-all`** — upgrades the channel CLIs alongside brew packages; agent-reach re-installs from its main.zip spec when upstream bumps its version; rdt-cli stays at its pinned commit
- **`skill-lint.sh`** (`.ai/common/scripts/`) — structural health check for AI CLI skills, runs on every `update.sh`: missing SKILL.md/frontmatter, dead relative links, commands referenced in code blocks that aren't installed. Idea extracted from [ctx](https://github.com/stevesolun/ctx)'s skill-health without adopting its recommendation layer

### AI/Editor Config Refresh — 2026-05-21

#### Added

- **`markdown-to-html` skill** (`.ai/common/skills/markdown-to-html/`) — turns markdown into a self-contained single-file HTML page. Fraunces serif headings, DM Sans body, IBM Plex Mono code, inline CSS, built-in dark-mode toggle that persists to `localStorage` and respects `prefers-color-scheme`. Replaces the older decorative `editorial-html-pages` skill with a calmer docs/blog aesthetic
- **`Working Style` section** in `.ai/common/instructions.md` — captures durable cross-session preferences: trust the user, junior-clear documentation, research discipline (verify before specs), spec conventions (one file per phase, no date prefixes), commit bundling, deploy approach (full automation, never silently downgrade)
- **`agentPushNotifEnabled: true`** in `.ai/claude/settings.json` — enables system notifications when background agents finish

#### Changed

- **`git.autofetch: false`** + **`git.autofetchPeriod: 0`** in `.vscodium/settings.json` — was causing background fetch churn; explicit period of 0 prevents re-enable if VSCodium changes its default
- **Trailing commas** added throughout `.vscodium/settings.json` to match Prettier JSONC output and avoid noisy diffs on future edits

### Code Quality Audit — 2026-04-24

Comprehensive codebase cleanup across 24 files (net -300 lines).

#### Security

- **Security hook fails closed**: `block-dangerous-commands.js` now returns a deny decision on malformed input instead of silently allowing — a critical fix for the PreToolUse safety hook
- **Removed global Gatekeeper disable** (`LSQuarantine`): Was disabling the "are you sure?" dialog for all downloaded apps. Use per-app `xattr -d com.apple.quarantine` instead
- **Removed DMG verification skip** (`skip-verify`): Was skipping integrity checks on disk images. Verification is instant on NVMe — no reason to skip

#### Removed — Dead macOS Defaults

Removed 18 `defaults write` commands from `.defaults` that are no-ops on modern macOS (26.x / Apple Silicon):

- `systemuiserver` menu bar extras (replaced by Control Center in Ventura)
- `hibernatemode 0` (harmful on Apple Silicon — battery drain loses session; default `3` is already optimized)
- `AppleFontSmoothing` subpixel rendering (removed in Mojave 2018)
- `DisplayResolutionEnabled` HiDPI (all modern Macs handle automatically)
- `QLEnableTextSelection` Quick Look text selection (removed in Yosemite 2014)
- `sms 0` Sudden Motion Sensor (HDD-only hardware removed in 2012)
- `BluetoothAudioAgent` bitpool quality (removed in Monterey 2021)
- `_FXShowPosixPathInTitle` (broken since Ventura — path bar serves same purpose)
- `NSWindowResizeTime` (no visible effect with modern animation frameworks)
- `WebKitDeveloperExtras` (Safari uses different developer tools mechanism)
- `Spotlight MenuItemHidden` (managed by Control Center now)
- `menuextra.clock DateFormat` (managed by Control Center now)
- Chrome `ExtensionInstallSources` (userscripts.org offline since 2014)
- Chrome trackpad backswipe (had comment/value mismatch)
- Spotlight indexing off/sleep/on cycle (no-op)
- "System Preferences" quit (renamed to "System Settings" in Ventura)
- "Address Book" in kill list (renamed to "Contacts" years ago)

#### Removed — Unused Code

- 3 dead Starship module configs (`cmd_duration`, `memory_usage`, `battery`) not referenced in the custom `format` string
- Windows-only VSCodium setting (`update.enableWindowsBackgroundUpdates`)
- Dead `configure_macos` inline fallback in `.utils.sh` (duplicated a subset of `.defaults`)

#### Changed — DRY Consolidation

- **Extracted `source_nvm()`** into `.utils.sh` — replaces duplicate 5-line NVM sourcing blocks in `install.sh`
- **Extracted `format_rate_limit()`** in `statusline-command.sh` — replaces two 16-line copy-pasted rate-limit display blocks
- **Fixed duplicate `apply_custom_icons` call** in `update.sh` — was running icons twice during `--packages`/`--all`
- **Fixed hardcoded linuxbrew path** in `install_ai_tools()` — now uses `$HOMEBREW_PREFIX` consistently

#### Changed — Shell Hardening

- Replaced 11 backtick command substitutions with `$()` in `.motd/20-sysinfo`
- Fixed unquoted command substitution in array assignments (`.motd/40-services`, `.motd/50-fail2ban`)
- Fixed `printf "$var"` format string injection in `.motd/40-services`, `.motd/50-fail2ban`, `.motd/60-docker`
- Added `mapfile -t` for safe array population in `.motd/50-fail2ban`
- Added `-r` flag to `read` commands to prevent backslash interpretation
- Added variable defaults (`${VAR:-0}`) to prevent arithmetic errors on empty values
- Split `local pid=$(...)` in `.functions` to avoid masking exit codes
- Added `${DOTFILES_ROOT:-default}` fallback in `brew()` wrapper
- Quoted `$VPS_APP_DIR` inside SSH command string in `vps-run.sh`

#### Changed — Error Visibility

- Removed `2>/dev/null` from `fileicon set` (`.utils.sh`, `.functions`) — failures now show the reason
- Removed `2>/dev/null` from `ssh-add -q` (`.ssh-agent`) — key loading errors now visible
- Removed `2>/dev/null || true` from `mdutil` in `.defaults` — Spotlight config failures now visible
- Changed `xcode-select --install 2>/dev/null || true` to show a warning on failure

#### Changed — Modernization

- Renamed `ChallengeResponseAuthentication` → `KbdInteractiveAuthentication` in `.ssh/config` (deprecated in OpenSSH 8.7)
- Added full JSDoc type annotations to `block-dangerous-commands.js`

#### Changed — Comment Cleanup

- Removed AI-generated boilerplate and box headers (`===`, `---` banners) across all files
- Removed comments restating the code; kept navigational section headers and "why" comments
- `.ghostty/config` reduced from 159 → 77 lines with concise inline comments preserved
- `.bun` reduced from 21 → 9 lines (removed 10-line boilerplate header)

---

### Fixed — Codex Status Line Persistence

- **Persisted Codex status line across sessions**: Replaced the short default `tui.status_line` list in `.ai/codex/config.toml` with the full confirmed item set so new Codex sessions keep the same footer layout
- **Removed machine-specific Codex trust entries from repo config**: Dropped hardcoded `projects.<path>.trust_level` blocks from `.ai/codex/config.toml` so trust stays local to each machine as documented
- **Updated AI CLI docs**: Clarified in `README.md` that Codex status-line persistence comes from the versioned `[tui]` config in `.ai/codex/config.toml`

### Changed — AI CLI Directory Refactor

- **Refactored `.claude/` → `.ai/`**: Restructured AI CLI configuration from Claude-specific `.claude/` to a generic `.ai/` layout supporting multiple AI CLI tools
  - Shared content (`instructions.md`, `commands/`, `skills/`, `hooks/`) lives at `.ai/` root
  - Claude-specific files (`settings.json`, `config/`) moved to `.ai/claude/`
  - New Codex CLI configuration (`config.toml`) at `.ai/codex/`
- **Restructured `.ai/` directory**: Three-way split — `common/` (shared instructions, commands, skills), `claude/` (settings, hooks, config), `codex/` (config.toml)
- **Updated symlink system**: `create_symlinks()` now creates symlinks for both `~/.claude/` and `~/.codex/`, sourced from the appropriate `.ai/` subdirectory
- **Renamed `CLAUDE.md` → `instructions.md`**: Global instructions file renamed to tool-agnostic name; symlinked as `~/.claude/CLAUDE.md` and `~/.codex/instructions.md`

### Added — Codex CLI Support

- **Codex CLI symlinks**: `~/.codex/instructions.md` → `.ai/common/instructions.md`, `~/.codex/prompts/` → `.ai/common/commands/`, `~/.codex/skills/` → `.ai/common/skills/`
- **`.ai/codex/config.toml`**: Codex CLI configuration (model, approval mode)

---

## [2.5.0] — VSCodium Migration

### Added

- **VSCodium editor configuration** (`.vscodium/`): Version-controlled settings, keybindings, extension list, and custom icon — cleaned from VS Code config with Copilot, Settings Sync, and work-specific entries removed
- **`install_vscodium_extensions()`** in `.utils.sh`: Reads `.vscodium/extensions.txt` and installs each extension via `codium` CLI, with `set -euo pipefail`-safe counters and whitespace trimming
- **`sync_vscodium_extensions()`** in `.utils.sh`: Syncs currently installed extensions back to `extensions.txt` on every `update.sh` run
- **`apply_custom_icons()`** in `.utils.sh`: Applies custom macOS app icons via `fileicon`, with safe error handling under `set -e`
- **`brew()` wrapper** in `.functions`: Automatically re-applies custom icons after `brew upgrade` or `brew reinstall`
- **VSCodium + fileicon** added to `.brewfile`
- **Platform-specific symlinks** in `.utils.sh`: Conditional macOS/Linux symlink pairs for VSCodium config directory
- **`alias code="codium"`** in `.aliases`: Conditional alias (only when codium is installed) so existing `dot`, `meow`, `zrc` aliases work transparently

### Changed

- **`.utils.sh` `create_symlinks()`**: Added `mkdir -p` for VSCodium config directory and conditional symlink pairs for settings/keybindings
- **`.utils.sh` `install_packages()`**: `brew bundle` failures no longer abort the entire install script
- **`install.sh` `main()`**: Added `hash -r`, `apply_custom_icons`, and `install_vscodium_extensions`; post-install message now lists VSCodium
- **`update.sh` `main()`**: Added `apply_custom_icons`, `sync_vscodium_extensions`, and conditional `install_vscodium_extensions` with `-p` flag
- **`.zshenv`**: `EDITOR` default changed from `vim` to `nano`; `VISUAL` conditionally set to `codium` (falls back to `code`)
- **`.brewfile`**: Fixed `claude-code` from `brew` to `cask`
- **README.md**: Added VSCodium section, updated project structure

### Removed

- **VS Code** removed from `.brewfile` — migration complete

---

## [2.4.0] - 2026-03-23

### 🧠 Claude Code Skills & Commands

- **Code Review Skill** (`code-review.md`): Critical code review that examines changed code across 8 dimensions — correctness/logic, security, concurrency/state, error handling/resilience, performance/resource leaks, API contracts, code quality, and test quality. Reports findings by severity (critical/high/medium/low), fixes all issues, then verifies with linter and tests.
- **Spec Writing Skill** (`spec-writing.md`): Implementation-ready spec templates following proven patterns — phase/epic headers, task templates for planned and completed work, quality checklists, decision tables, and anti-patterns to avoid.
- **CRAFT Command** (`craft.md`): Full implementation workflow — Code, Review, Audit, Fix, Test. Implements a spec task then refines through 3 rounds of expert code review with all findings fixed between rounds.

### 🔧 Shell Improvements

- **Cross-platform IP alias**: Replaced macOS-only `localip` with cross-platform `myip` (uses `ipconfig getifaddr` on macOS, `hostname -I` on Linux)
- **Grep alias cleanup**: Changed deprecated `egrep`/`fgrep` aliases to use `grep -E`/`grep -F`
- **`mkd()` fix**: Fixed to correctly `cd` into the last argument when multiple directories are created
- **Completion loading**: Moved `fpath` setup before Oh My Zsh for correct completion discovery
- **NVM sourcing**: Refactored to use `$HOMEBREW_PREFIX` variable for cross-platform compatibility

### 📁 Symlink System

- **Directory symlinks for `.claude/`**: Changed from individual file symlinks to directory symlinks for `commands/`, `skills/`, `config/`, `hooks/` — new files in these directories are automatically available without updating symlink pairs

### 🗑️ Removed

- **Notion integration**: Removed Notion-related configuration
- **Worktree settings**: Removed worktree hook settings from Claude Code config

### 📚 Documentation

- **Updated README.md**: Added skills and commands documentation, updated project structure tree, bumped to v2.4.0
- **Updated CHANGELOG.md**: Added v2.4.0 entry

---

## [2.3.0] - 2026-03-10

### 🤖 Claude Code Safety Hooks

- **PreToolUse Hook System**: Added `.claude/hooks/block-dangerous-commands.js` — a comprehensive safety hook that blocks dangerous Bash commands before execution
  - Three safety levels: `critical`, `high`, `strict` (defaults to `high`)
  - Blocks 80+ dangerous patterns across categories: git write ops, filesystem destruction, elevated privileges, publishing/deployment, database, network, credentials exposure
  - Logged to `~/.claude/hooks-logs/` for audit trail
- **Migrated CLAUDE.md safety rules**: Moved all command-specific safety rules from `.claude/CLAUDE.md` into the hook for programmatic enforcement, keeping only non-automatable rules in CLAUDE.md

### 📁 Claude Code Configuration Restructure

- **Reorganized `.claude/` directory**:
  - Moved `statusline-command.sh` → `.claude/config/statusline-command.sh`
  - Added `.claude/hooks/` directory for PreToolUse hooks
- **Updated symlinks**: Fixed `create_symlinks` in `.utils.sh` to match new `.claude/` layout
  - Added `~/.claude/config/` and `~/.claude/hooks/` directory creation
  - Added symlinks for `statusline-command.sh` and `block-dangerous-commands.js`
  - Added stale symlink cleanup for old `.claude/statusline-command.sh` path

### 📚 Documentation

- **Updated README.md**: Added Claude Code safety hooks section, `.editorconfig`, `.lazydocker/`, `.motd/`, GitHub Pages files to project structure
- **Updated CLAUDE.md** (project-level): Added hooks and config references to essential files
- **Updated CHANGELOG.md**: Added v2.3.0 entry

---

## [2.2.0] - 2024-12-03

### 👻 Terminal Migration: Kitty → Ghostty

- **Ghostty Terminal**: Migrated to Ghostty as primary terminal emulator
  - GPU-accelerated terminal with platform-native UI
  - Built-in Nord theme (no custom theme files needed)
  - Shell integration with auto-detection for Zsh
  - Custom keybindings matching previous Kitty setup

### 🎨 Ghostty Configuration
- **Font Settings**: Fira Code 14pt with font-thicken enabled
- **Key Bindings**:
  - Tab navigation: Cmd+1-9 for quick tab switching
  - Text navigation: Alt+Left/Right for word movement
  - Line navigation: Cmd+Left/Right for line start/end
  - Clear screen: Cmd+K
- **Window Settings**: 4px horizontal, 2px vertical padding with state persistence
- **Shell Integration**: Auto-detect with cursor, sudo, and title features

### 📁 File Changes
- **Added**: `.ghostty/config` - Complete Ghostty configuration
- **Updated**: `install.sh` - Added Ghostty symlink to `~/.config/ghostty`
- **Updated**: `.brewfile` - Added `ghostty` cask, kept `kitty` for transition
- **Updated**: `.aliases` - Changed `meow` alias to Ghostty, added `kittyconf` for Kitty

### 📚 Documentation
- **Added**: `docs/KITTY_TO_GHOSTTY_MIGRATION.md` - Comprehensive migration guide
- **Updated**: `README.md` - Added Ghostty to features and project structure
- **Updated**: `CLAUDE.md` - Updated terminal references throughout

### 🗑️ Removed
- **Kitty Terminal**: Fully removed after successful migration
  - Removed `.kitty/` directory (kitty.conf, nord.conf, tab_bar.py, search.py, scroll_mark.py)
  - Removed `kitty` from `.brewfile`
  - Removed Kitty symlink from `install.sh`
  - Custom Python kittens not portable to Ghostty (use built-in search Cmd+F)

---

## [2.1.0] - 2025-09-23

### 🚀 Node.js Environment Improvements
- **Immediate Node.js Availability**: Removed lazy loading for `node`, `npm`, `npx` commands
  - NVM now loads automatically on shell startup
  - Node.js tools are immediately available without first-time delays
  - Optimized configuration (removed Intel compatibility)
- **Simplified Configuration**: Streamlined NVM setup for single-platform consistency

### 🧹 Cleanup & Optimization
- **Deno Removal**: Removed all Deno references and installation components
  - No Deno packages in Homebrew bundle
  - Cleaned up shell configuration
- **Platform Optimization**: Configuration optimized for modern macOS
  - Removed legacy Intel-specific NVM paths
  - Streamlined Homebrew integration

### 📊 System Performance
- **Memory Management**: Improved from critical 99.7% to stable 97% usage
- **Shell Optimization**: Maintained fast startup while ensuring Node.js availability

---

## [2.0.0] - 2025-09-22

### 🚀 Performance Improvements
- **Shell Startup Speed**: Optimized from 3.78s to 0.184s (95% improvement)
  - Added completion caching with daily refresh
  - Implemented lazy loading for NVM/Node.js tools
  - Optimized compinit execution with `-C` flag
- **Memory Usage Analysis**: Identified and documented memory consumers
  - Microsoft Teams: 1.5GB (primary consumer)
  - VS Code TypeScript servers: ~900MB each
  - Total system memory: 35GB/38GB (normal for development workload)

### 🔧 Bug Fixes
- **Node.js Package Managers**: Fixed "env: node: No such file or directory" error
  - Added lazy loading for `yarn` and `pnpm` commands
  - Ensures NVM loads before any Node.js package manager execution
- **Starship Prompt Timeouts**: Fixed Node.js command timeouts
  - Increased `command_timeout` from 500ms to 3000ms
  - Prevents timeout errors when using Node.js tools with lazy loading

### 🏗️ Architecture Changes
- **Modular Configuration**: Moved personal/work settings to `~/.zshrc.local`
  - Removed `flow()` function from shared dotfiles for privacy
  - Work-specific aliases and environment variables externalized
- **SSH Configuration**: Validated and organized key management
  - Personal GitHub key: `~/.ssh/personal/github`
  - Work GitLab key: `~/.ssh/work/gitlab`
  - SSH agent properly loads both keys on startup

### 🖥️ Terminal & Development Environment
- **Kitty Terminal Configuration**: Complete integration with advanced features
  - Nord color scheme with custom tab bar styling
  - Activity indicators and bell symbols for tab management
  - Smart keyboard mappings and search functionality
  - GPU acceleration and Wayland support enabled
- **EditorConfig Standards**: Cross-editor consistency implementation
  - Multi-language indentation rules (Python, JavaScript, YAML, etc.)
  - Line ending normalization and whitespace management
  - Makefile and shell script specific configurations

### 🚀 Productivity Enhancements
- **Alfred Workflow Ecosystem**: Enhanced productivity extensions
  - Internet Speedtest workflow with live result updates
  - Multiple workflow integrations and custom triggers
  - Parallel vs sequential execution options
- **Starship Prompt Enhancements**: Advanced monitoring capabilities
  - Battery status monitoring with charging/discharging indicators
  - Memory usage tracking with 75% threshold alerts
  - Command duration tracking for performance monitoring
  - Enhanced Git status indicators with emoji symbols

### 📦 Dependencies
- **Completion System**: Optimized Zsh completion loading
- **Homebrew Packages**: 78 essential packages maintained

### 🛡️ Security
- **SSH Key Organization**: Structured directory layout maintained
- **No Hardcoded Secrets**: All sensitive data in gitignored files
- **Permission Validation**: SSH keys have correct 600/644 permissions

### 📊 Metrics
- **Shell Startup Time**: 0.184s (target: <1s) ✅
- **Memory Usage**: 35GB/38GB (92% - normal for development) ✅
- **SSH Keys Loaded**: 2 keys (personal + work) ✅
- **Git Configuration**: Properly configured with user settings ✅

### 🧪 Testing
- **Syntax Validation**: All shell files pass `zsh -n` checks
- **Installation Test**: `./install.sh --dry-run` validates successfully
- **SSH Connectivity**: Keys loaded, though network connectivity varies by environment

### 📝 Documentation
- **CLAUDE.md**: Updated with current system state and metrics
- **Performance Profiling**: Added zprof integration for debugging
- **Todo List**: Completed all optimization tasks

### 🔄 Maintenance
- **Configuration Validation**: Pre-commit syntax checking

---

## [1.5.0] - 2025-09-14

### 🎨 Visual & Documentation Improvements
- **GitHub Pages**: Complete website with modern dark theme
- **Enhanced Documentation**: Comprehensive HTML documentation with responsive design
- **Alfred Workflows**: Added Emoji Mate and productivity workflows
- **UI Polish**: Improved styling and formatting across documentation

---

## [1.4.0] - 2025-09-13 to 2025-09-15

### 🔄 Configuration Refinements
- **SSH Flow**: Enhanced SSH key management and workflow
- **Documentation Updates**: Multiple documentation improvements
- **Code Organization**: Better file structure and organization

---

## [1.3.0] - 2025-09-18

### 🖥️ Terminal Environment
- **Kitty Terminal**: Complete migration from iTerm2 to Kitty
- **Configuration Management**: Moved Kitty config to dotfiles
- **Performance**: Optimized terminal performance and features

---

## [1.2.0] - 2024-2025 Evolution

### 🏗️ Modern Architecture Transition
- **Apple Silicon Support**: Full M1/M2/M3 Mac optimization
- **Homebrew Migration**: Complete package management overhaul
- **Node.js Ecosystem**: NVM integration and global package management
- **Python Environment**: PyEnv integration for version management

### 🛠️ Development Tools
- **Alfred Integration**: Comprehensive workflow ecosystem
- **Git Enhancements**: Advanced aliases and configuration
- **Docker Support**: Container development environment

### 📦 Package Management Evolution
- **90+ Homebrew Packages**: Curated development tools
- **Application Suite**: Complete development application stack
- **Font Management**: Developer font installation

---

## [1.1.0] - 2018-2020 Maturation

### 🎯 Focus & Refinement
- **macOS Big Sur**: Compatibility updates
- **Security Hardening**: Enhanced SSH and security practices
- **Cleanup**: Removed deprecated tools and configurations
- **Performance**: Shell optimization and startup improvements

### 🔧 Tool Evolution
- **Terminal Migration**: Hyper → iTerm2 → Kitty progression
- **Editor Support**: Multi-editor configuration support
- **Workflow Optimization**: Improved daily development workflows

---

## [1.0.0] - 2017-2018 Foundation

### 🏗️ Initial Architecture
- **Zsh Foundation**: Oh My Zsh integration and customization
- **Homebrew Setup**: Package management infrastructure
- **macOS Defaults**: System preference automation
- **SSH Configuration**: Basic key management

### 📦 Core Components
- **Shell Configuration**: Basic aliases and functions
- **Development Environment**: Initial tool installations
- **Git Integration**: Basic Git aliases and configuration
- **File Organization**: Dotfiles structure establishment

### 🚀 First Implementation
- **Installation Script**: Automated setup process
- **Modular Design**: Separated concerns and configurations
- **Cross-Machine**: Consistent environment across systems
- **Documentation**: Basic setup and usage guides

---

## [0.1.0] - 2017-12-27 Genesis

### 🌱 Project Birth
- **First Commit**: Initial dotfiles implementation
- **Basic Structure**: Core file organization
- **Shell Setup**: Initial Zsh configuration
- **Package Lists**: Early Homebrew package definitions

### 📝 Initial Goals
- **Automation**: Reduce manual configuration time
- **Consistency**: Standardize development environment
- **Portability**: Easy setup on new machines
- **Documentation**: Clear setup instructions

---

## Development Guidelines

### Performance Targets
- Shell startup time: <1 second
- Memory usage: Monitor via system tools
- SSH connectivity: All keys should load successfully

### Testing Checklist
```bash
# Syntax validation
zsh -n .zshrc .functions .aliases .ssh-agent .completion

# Performance testing
time zsh -lic exit

# SSH validation
ssh-add -l

# Installation testing
./install.sh --dry-run
```

### Contribution Guidelines
1. Always test changes with `zsh -n` before committing
2. Update this changelog for significant changes
3. Maintain performance targets
4. Keep sensitive data in `~/.zshrc.local` (gitignored)
5. Document any new dependencies or requirements
