# Changelog

All notable changes to this dotfiles project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
