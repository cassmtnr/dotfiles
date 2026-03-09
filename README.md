# Dotfiles v2.3.0

> **Modern, secure, and performance-optimized development environment for macOS and Linux**

## What are Dotfiles?

Dotfiles are configuration files that customize your development environment and command line tools. They're called "dotfiles" because they typically start with a dot (.) and are hidden by default in Unix-like systems. These files control everything from your shell prompt to your text editor settings, making your development environment consistent and personalized across different machines.

## What This Repository Does

This dotfiles repository will transform your macOS or Linux system into a comprehensive, secure, and performant development environment. It provides:

- 🚀 **Performance Optimized**: Optimized shell startup with immediate Node.js/npm availability
- 🔒 **Security First**: Secure SSH configuration templates and key management
- 🤖 **Claude Code Safety Hooks**: PreToolUse hooks that block dangerous commands before execution
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
vim ~/dotfiles/.ssh/config
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
├── .claude/
│   ├── CLAUDE.md              # Global Claude Code safety rules & instructions
│   ├── settings.json          # Settings (hooks, permissions, statusline)
│   ├── config/
│   │   └── statusline-command.sh  # Custom statusline (project, branch, context %)
│   └── hooks/
│       └── block-dangerous-commands.js  # PreToolUse safety hook
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
- **`.claude/`** - Claude Code configuration with safety hooks (symlinked to `~/.claude/`)
- **`.lazydocker/`** - LazyDocker terminal UI for Docker management
- **`.motd/`** - Message of the Day scripts for Linux/VPS servers
- **`.alfred/`** - Alfred workflows and preferences (macOS only, symlinked via Alfred's sync feature)

### Claude Code Safety Hooks

The `.claude/hooks/` directory contains PreToolUse hooks that run before Claude Code executes tool calls:

- **`block-dangerous-commands.js`** - Blocks dangerous Bash commands at three safety levels:
  - **Critical**: filesystem destruction (`rm -rf ~/`), disk operations (`dd`, `mkfs`), fork bombs, git history rewriting
  - **High**: all git write operations, elevated privileges (`sudo`), secrets exposure, publishing/deployment commands, database operations, network/infrastructure changes
  - **Strict**: cautionary patterns like `git checkout .`, `docker prune`

  Safety level is set to `high` by default. Patterns are enforced via regex matching and blocked commands are logged to `~/.claude/hooks-logs/`.

- **Custom statusline** (`.claude/config/statusline-command.sh`) displays project name, git branch, session ID, context window %, and model name.

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
