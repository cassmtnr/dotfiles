# Dotfiles v2.2.0

> **Modern, secure, and performance-optimized development environment for macOS and Linux**

## What are Dotfiles?

Dotfiles are configuration files that customize your development environment and command line tools. They're called "dotfiles" because they typically start with a dot (.) and are hidden by default in Unix-like systems. These files control everything from your shell prompt to your text editor settings, making your development environment consistent and personalized across different machines.

## What This Repository Does

This dotfiles repository will transform your macOS or Linux system into a comprehensive, secure, and performant development environment. It provides:

- 🚀 **Performance Optimized**: Optimized shell startup with immediate Node.js/npm availability
- 🔒 **Security First**: Secure SSH configuration templates and key management
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

## Available Aliases & Functions

This configuration includes a comprehensive set of productivity-enhancing aliases and functions.

**Key productivity features:**

- **25+ aliases** for navigation, git, and system utilities ([`.aliases`](.aliases))
- **Utility functions** including `mkd`, `killport`, `extract` ([`.functions`](.functions))
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
├── .brewfile                  # Package definitions (45+ packages)
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
│   └── config                # Ghostty terminal configuration (Nord theme)
├── .ssh/
│   └── config                # SSH configuration template
├── .claude/
│   ├── CLAUDE.md             # Global Claude Code instructions
│   ├── settings.json         # Claude Code settings
│   ├── statusline-command.sh # Custom statusline (Bash)
│   └── commands/
│       └── ralph-prompt.md   # /ralph-prompt slash command
└── .alfred/
    └── Alfred.alfredpreferences/ # Alfred workflows and settings
```

### Core Components

- **`install.sh`** - Comprehensive installation with error handling and progress feedback
- **`.zshrc`** - Modular shell configuration with performance optimizations
- **`.functions`** - Utility functions (`mkd`, `killport`, `extract`)
- **`.brewfile`** - Curated collection of 40+ development tools
- **`.ghostty/config`** - Ghostty terminal with Nord theme, custom keybindings, and shell integration
- **`.ssh/config`** - Security-focused SSH template with organized key management
- **`.claude/`** - Claude Code configuration (symlinked to `~/.claude/`)

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
