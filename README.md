# Dotfiles

## What are Dotfiles?

Dotfiles are configuration files that customize your development environment and command line tools. They're called "dotfiles" because they typically start with a dot (.) and are hidden by default in Unix-like systems. These files control everything from your shell prompt to your text editor settings, making your development environment consistent and personalized across different machines.

## What This Repository Does

This dotfiles repository will transform your macOS system into a comprehensive, secure, and performant development environment. It provides:

🚀 **Performance Optimized**: Lazy loading for NVM and other tools, resulting in fast shell startup
🔒 **Security First**: Secure SSH configuration templates and key management
📦 **Complete Package Management**: 90+ essential development tools and applications
🛠️ **Modern Toolchain**: Starship prompt, Oh My Zsh, and contemporary CLI utilities
🔄 **Automated Setup**: One-command installation with comprehensive error handling
🍎 **macOS Optimized**: System defaults and configurations designed specifically for macOS

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

- **40+ aliases** for navigation, git, and system utilities ([`zsh/aliases.zsh`](zsh/aliases.zsh))
- **Utility functions** including `mkd`, `killport`, `extract` ([`zsh/functions.zsh`](zsh/functions.zsh))
- **Claude Flow integration** with `flow create`, `flow resume`, `flow wizard` commands
- **Performance optimized** lazy loading for Node.js tools

## Required Customizations

After installation, you'll need to configure these components for your specific environment:

### 1. SSH Configuration

The SSH config is automatically symlinked to `~/.ssh/config`. Customize it with your actual settings:

```bash
vim ~/dotfiles/.ssh/config
```

Update with your actual SSH key paths and host configurations. Generate keys in organized folders (e.g., `~/.ssh/github/`, `~/.ssh/work/`).

### 2. Update Key Configurations

- **SSH Agent**: Edit `zsh/ssh-agent.zsh` with your actual key paths
- **Git**: Set your identity with `git config --global user.name/user.email`
- **Local Settings**: Create `~/.zshrc.local` for machine-specific configurations

## Project Structure

```
dotfiles/
├── install.sh                 # Main installation script (8,327+ bytes)
├── .brewfile              # Package definitions (90+ packages)
├── .zshrc                     # Main shell configuration
├── .functions                 # Custom functions + Claude Flow helper
├── .aliases                   # Shell aliases (40+ shortcuts)
├── .ssh-agent                 # SSH agent management
├── .completion                # Shell completions
├── .ssh/
│   └── config                # SSH configuration template
├── .alfred/
│   └── Alfred.alfredpreferences/ # Alfred workflows and settings
├── macos/
│   └── .defaults             # macOS system preferences
├── .node                  # Node.js environment setup
├── config/                   # Additional configuration files
└── .claude-flow/
    └── metrics/              # Claude Flow session data and metrics
```

### Core Components

- **`install.sh`** - Comprehensive installation with error handling and progress feedback
- **`.zshrc`** - Modular shell configuration with performance optimizations
- **`.functions`** - 40+ utility functions including Claude Flow integration (`flow()` command)
- **`.brewfile`** - Curated collection of 90+ essential development tools
- **`.ssh/config`** - Security-focused SSH template with organized key management
- **`.claude-flow/`** - AI workflow integration with session management and metrics

## Additional Customization

- **Aliases**: Edit `zsh/aliases.zsh` for custom shortcuts
- **Functions**: Add utilities to `zsh/functions.zsh`
- **Packages**: Modify `.brewfile` and run `brew bundle`
- **Prompt**: Customize `config/starship.toml` for terminal appearance

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

- macOS version
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
