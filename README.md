# Dotfiles v2.4.0

> **Modern, secure, and performance-optimized development environment for macOS and Linux**

## What are Dotfiles?

Dotfiles are configuration files that customize your development environment and command line tools. They're called "dotfiles" because they typically start with a dot (.) and are hidden by default in Unix-like systems. These files control everything from your shell prompt to your text editor settings, making your development environment consistent and personalized across different machines.

## What This Repository Does

This dotfiles repository will transform your macOS or Linux system into a comprehensive, secure, and performant development environment. It provides:

- 🚀 **Performance Optimized**: Optimized shell startup with immediate Node.js/npm availability
- 🔒 **Security First**: Secure SSH configuration templates and key management
- 🤖 **AI CLI Safety Hooks**: PreToolUse hooks that block dangerous commands (shared by Claude Code & Codex CLI)
- 🧠 **AI CLI Skills & Commands**: Reusable skills (code review, spec writing) and workflow commands (CRAFT)
- 📦 **Complete Package Management**: 40+ essential development tools and applications
- 🛠️ **Modern Toolchain**: Starship prompt, Oh My Zsh, and contemporary CLI utilities
- 👻 **Ghostty Terminal**: GPU-accelerated terminal with Nord theme and custom keybindings
- 🔄 **Automated Setup**: One-command installation with comprehensive error handling
- 🐧 **Cross-Platform**: Supports both macOS and Linux with OS-specific adaptations
- 🍎 **macOS Optimized**: System defaults and configurations (macOS only)

## Installation

### Quick Start

```bash
# Clone the repository
git clone https://github.com/cassmtnr/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Run the installation
./install.sh
```

The installation script automatically sets up your complete development environment with error handling and progress feedback. It's idempotent, so you can run it multiple times safely.

### Updating After Changes

After editing dotfiles, use the lightweight update script instead of re-running the full installer:

```bash
./update.sh              # Just refresh symlinks (fast)
./update.sh -p           # Also update Homebrew packages
./update.sh -d           # Also re-apply macOS defaults
./update.sh -a           # All of the above
```

## Available Aliases & Functions

This configuration includes a comprehensive set of productivity-enhancing aliases and functions.

**Key productivity features:**

- **25+ aliases** for navigation, git, and system utilities ([`.aliases`](.aliases))
- **Utility functions** including `mkd`, `killport`, `extract`, `weather` ([`.functions`](.functions))
- **Performance optimized** with immediate Node.js tool availability

## Required Customizations

After installation, you'll need to configure these components for your specific environment:

### 1. SSH Configuration

The SSH config is automatically symlinked to `~/.ssh/config`. Customize it with your actual settings:

```bash
codium ~/dotfiles/.ssh/config   # or: code ~/dotfiles/.ssh/config
```

Update with your actual SSH key paths and host configurations. The 1Password SSH agent path is auto-configured for macOS. Generate keys in organized folders (e.g., `~/.ssh/github/`, `~/.ssh/work/`).

### 2. Update Key Configurations

- **SSH Agent**: Edit `.ssh-agent` with your actual key paths
- **Git**: Set your identity with `git config --global user.name/user.email`
- **Local Settings**: Create `~/.zshrc.local` for machine-specific configurations

## Project Structure

```
dotfiles/
├── install.sh                 # Main installation script
├── update.sh                  # Lightweight update (symlinks + optional packages/defaults)
├── .utils.sh                  # Shared utilities (OS detection, logging, symlinks, packages)
├── .brewfile                  # Package definitions (45+ packages)
├── .editorconfig              # Cross-editor coding style consistency
├── .zshrc                     # Main shell configuration
├── .zshenv                    # Environment variables
├── .functions                 # Custom functions (mkd, killport, extract)
├── .aliases                   # Shell aliases (25+ shortcuts)
├── .ssh-agent                 # SSH agent management
├── .completion                # Shell completions
├── .starship                  # Starship prompt configuration
├── .defaults                  # macOS system preferences
├── .bun                       # Bun JavaScript runtime config
├── .ghostty/
│   ├── config                 # Ghostty terminal configuration (Nord theme)
│   └── icon.icns              # Custom Ghostty application icon
├── .ssh/
│   └── config                 # SSH configuration template
├── .ai/                           # AI CLI config (shared by Claude Code & Codex CLI)
│   ├── instructions.md        # Shared global AI instructions (→ ~/.claude/CLAUDE.md)
│   ├── commands/
│   │   └── craft.md           # CRAFT workflow command (→ ~/.claude/commands/ & ~/.codex/prompts/)
│   ├── skills/
│   │   ├── code-review.md     # Critical code review & fix skill
│   │   └── spec-writing.md    # Implementation spec writing skill
│   ├── hooks/
│   │   └── block-dangerous-commands.js  # PreToolUse safety hook
│   ├── claude/                # Claude Code specific
│   │   ├── settings.json      # Settings (hooks, permissions, statusline, plugins)
│   │   └── config/
│   │       └── statusline-command.sh  # Custom statusline (project, branch, context %)
│   └── codex/                 # Codex CLI specific
│       ├── config.toml        # Codex CLI configuration
│       └── hooks.json         # Codex CLI hooks (references shared hook scripts)
├── .vscodium/
│   ├── settings.json          # Cleaned user settings (no Copilot/sync entries)
│   ├── extensions.txt         # Extension IDs for Open VSX (one per line)
│   └── icon.icns              # Custom macOS app icon (added manually)
├── .lazydocker/
│   └── config.yml             # LazyDocker terminal UI configuration
├── .motd/                     # Message of the Day scripts (Linux/VPS)
│   ├── 10-hostname-color      # Hostname display with figlet + lolcat
│   ├── 20-sysinfo             # System info (load, memory)
│   ├── 35-diskspace           # Disk space display
│   ├── 40-services            # System services status
│   ├── 50-fail2ban            # Fail2ban status
│   └── 60-docker              # Docker information
├── .alfred/
│   └── Alfred.alfredpreferences/  # Alfred workflows and settings (macOS only)
├── index.html                 # GitHub Pages landing page
└── .nojekyll                  # Disables Jekyll on GitHub Pages
```

### Core Components

- **`install.sh`** - Comprehensive installation with error handling and progress feedback
- **`update.sh`** - Lightweight update script (symlinks + optional packages/defaults)
- **`.utils.sh`** - Shared utilities sourced by both install.sh and update.sh
- **`.zshrc`** - Modular shell configuration with performance optimizations
- **`.functions`** - Utility functions (`mkd`, `killport`, `extract`, `weather`, `playwright-install`)
- **`.brewfile`** - Curated collection of 40+ development tools
- **`.editorconfig`** - Cross-editor coding standards (charset, indentation, line endings)
- **`.ghostty/config`** - Ghostty terminal with Nord theme, custom keybindings, and shell integration
- **`.ssh/config`** - Security-focused SSH template with organized key management
- **`.ai/`** - AI CLI configuration with safety hooks, skills, and commands (shared by Claude Code & Codex CLI, symlinked to `~/.claude/` & `~/.codex/`)
- **`.vscodium/`** - VSCodium editor configuration (settings, keybindings, extensions list, custom icon)
- **`.lazydocker/`** - LazyDocker terminal UI for Docker management
- **`.motd/`** - Message of the Day scripts for Linux/VPS servers
- **`.alfred/`** - Alfred workflows and preferences (macOS only, symlinked via Alfred's sync feature)

### AI CLI Safety Hooks

The `.ai/hooks/` directory contains PreToolUse hooks shared by Claude Code and Codex CLI:

- **`block-dangerous-commands.js`** - Blocks dangerous Bash commands at three safety levels:
  - **Critical**: filesystem destruction (`rm -rf ~/`), disk operations (`dd`, `mkfs`), fork bombs, git history rewriting
  - **High**: all git write operations, elevated privileges (`sudo`), secrets exposure, publishing/deployment commands, database operations, network/infrastructure changes
  - **Strict**: cautionary patterns like `git checkout .`, `docker prune`

  Safety level is set to `high` by default. Patterns are enforced via regex matching and blocked commands are logged to `~/.claude/hooks-logs/`.

- **Custom statusline** (`.ai/claude/config/statusline-command.sh`) displays project name, git branch, session ID, context window %, and model name.

### AI CLI Skills & Commands

The `.ai/skills/` and `.ai/commands/` directories provide reusable AI workflows (shared by Claude Code and Codex CLI):

- **Skills** (contextual capabilities automatically loaded when relevant):
  - **`code-review`** — Critical code review across 8 dimensions (correctness, security, concurrency, error handling, performance, API contracts, code quality, test quality). Reviews all changed code, reports findings by severity, fixes everything, and verifies with linter + tests.
  - **`spec-writing`** — Write implementation-ready specs following proven patterns: phase/epic headers, task templates, quality checklists, and anti-patterns to avoid.

- **Commands** (invoked explicitly via `/command-name`):
  - **`/craft`** — CRAFT workflow (Code, Review, Audit, Fix, Test): implements a task from the project spec, then refines it through 3 rounds of expert code review with fixes between rounds. Ships artisan-quality code.

## VSCodium

This repo uses [VSCodium](https://vscodium.com/) (the open-source VS Code build without Microsoft telemetry). Settings, keybindings, extensions, and a custom icon are version-controlled in `.vscodium/` and managed automatically:

- **`install.sh`** installs VSCodium via Brewfile, creates config symlinks, installs extensions, and applies the custom icon
- **`update.sh`** re-syncs symlinks, re-applies the icon, and syncs the extension list back to `extensions.txt`
- **`update.sh -p`** also runs package updates and installs any new extensions
- **`brew()` wrapper** in `.functions` automatically re-applies the custom icon after `brew upgrade` or `brew reinstall`
- **`alias code="codium"`** in `.aliases` lets existing aliases (`dot`, `meow`, `zrc`) work transparently

To customize the icon, save a `.icns` file to `~/dotfiles/.vscodium/icon.icns` — it will be applied automatically on the next `./update.sh` run.

## Additional Customization

- **Aliases**: Edit `.aliases` for custom shortcuts
- **Functions**: Add utilities to `.functions`
- **Packages**: Modify `.brewfile` and run `brew bundle`
- **Prompt**: Customize `.starship` for terminal appearance

## Security Notes

🔒 **Important Security Practices:**

- **Never commit actual SSH keys** - only configuration templates
- **Use `.zshrc.local`** for private/sensitive configurations
- **Keep secrets out of version control** - the `.gitignore` is configured to protect sensitive files
- **Template paths are examples** - replace with your actual key locations
- **Review permissions** - SSH keys should have `600` permissions (`chmod 600 ~/.ssh/*/id_*`)
- **Use strong passphrases** for SSH keys in sensitive environments

## Troubleshooting

- **Slow startup**: Profile with `time zsh -lic exit` and `zmodload zsh/zprof`
- **SSH issues**: Test with `ssh -T git@github.com` and debug with `ssh -vT`
- **Homebrew**: Check with `brew doctor` and update with `brew update`

## Reporting Issues

Found a bug or have a suggestion? Please report it on the [GitHub Issues page](https://github.com/cassmtnr/dotfiles/issues).

When reporting issues, please include:

- OS version (macOS / Linux distribution)
- Error messages (if any)
- Steps to reproduce
- Expected vs actual behavior

## License

These dotfiles are released under the CC0 1.0 Universal license.

[![CC0](http://mirrors.creativecommons.org/presskit/buttons/88x31/svg/cc-zero.svg)](http://creativecommons.org/publicdomain/zero/1.0/)

## Inspired By

- [@mathiasbynens](https://github.com/mathiasbynens/dotfiles)
- [@rodionovd](https://github.com/rodionovd/dotfiles)
- [@holman](https://github.com/holman/dotfiles)
