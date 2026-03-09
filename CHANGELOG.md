# Changelog

All notable changes to this dotfiles project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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