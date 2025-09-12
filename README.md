# 🏠 Dotfiles

Modern, secure, and performant dotfiles configuration for macOS developers.

## ✨ Features

- 🚀 **Performance Optimized**: Lazy loading for NVM and other tools
- 🔒 **Security First**: Secure SSH configuration and key management
- 📦 **Modular Design**: Well-organized, maintainable configuration files
- 🛠️ **Modern Tools**: Integration with Starship, FZF, and modern CLI tools
- 🔄 **Automated Setup**: Robust installation with backup and error handling
- 📱 **Cross-platform**: Works on macOS with partial Linux support

## 🚀 Quick Start

```bash
# Clone and install
git clone https://github.com/cassmtnr/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

## 📋 What's Included

### Shell Configuration
- **Zsh** with Oh My Zsh
- **Modular configuration** (aliases, functions, completions)
- **Starship prompt** for beautiful, informative shell prompt
- **Lazy loading** for improved startup performance

### Development Tools
- **Modern CLI tools**: `bat`, `eza`, `ripgrep`, `fd`, `fzf`
- **Version managers**: NVM (lazy-loaded), GVM
- **Package managers**: Homebrew, npm, yarn, pnpm
- **Container tools**: Docker, kubectl, k9s

### Security
- **SSH config template** with secure defaults
- **SSH agent management** with keychain support
- **No hardcoded secrets** in configuration files

### Productivity
- **Smart aliases** for common tasks
- **Useful functions** for development workflow
- **Git configuration** with better diff tools
- **Editor integration** with consistent styling

## 📖 Documentation

- **[Setup Guide](docs/SETUP.md)** - Detailed installation instructions
- **[Customization](docs/CUSTOMIZATION.md)** - How to customize for your needs
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Common issues and solutions

## 🔧 Simple Installation

```bash
# One command installs everything
./install.sh
```

The script automatically:
- Creates a backup of existing configuration
- Installs all packages and tools
- Sets up symbolic links
- Configures macOS defaults
- Provides detailed output during installation

## 🎨 Customization

After installation, you can customize your setup:

1. **Machine-specific settings**: Create `~/.zshrc.local` for local customizations
2. **SSH configuration**: Edit `~/dotfiles/ssh/config` to customize SSH settings for your hosts
3. **Git configuration**: Update your name and email in the global git config

## 📦 What Gets Installed

### Core System
- **Homebrew** with essential packages and modern CLI tools
- **Oh My Zsh** with minimal plugins for performance
- **Starship prompt** for a beautiful, fast terminal experience

### Development Tools
- **Version managers**: Node.js (NVM), Go (GVM), Python
- **Package managers**: yarn, pnpm, poetry
- **Container tools**: Docker, kubectl, k9s, helm
- **Database tools**: PostgreSQL, Redis, SQLite, DBeaver

### Modern CLI Tools
- **Better replacements**: `bat` (cat), `eza` (ls), `ripgrep` (grep), `fd` (find), `fzf` (fuzzy finder)
- **Productivity tools**: `zoxide` (smart cd), `tldr` (simplified man), `htop`, `ncdu`
- **Development utilities**: `jq`, `yq`, `diff-so-fancy`, `git-delta`

### Applications & Productivity
- **Editors**: Visual Studio Code
- **Terminal**: Kitty (with custom config)
- **Productivity**: Alfred (with custom workflows), 1Password
- **Media**: Spotify, VLC, The Unarchiver
- **Browser**: Google Chrome

### Security & SSH
- **SSH configuration** with secure defaults and connection multiplexing  
- **SSH agent management** with automatic key loading
- **GPG setup** for code signing

### macOS System Optimizations
- **Performance tweaks**: Fast key repeat, reduced animations
- **Productivity settings**: Screenshot location, Finder enhancements
- **Developer-friendly defaults**: Show hidden files, better file handling

## 🛠️ Additional Features

### Alfred Workflows
- **Speed Test**: Quick internet speed testing
- **DeepL Translation**: Fast translation workflows
- Custom productivity automations

### Configuration Management
- **EditorConfig**: Consistent coding standards across editors
- **Kitty Terminal**: Custom terminal configuration with themes
- **GitHub CLI**: Pre-configured for seamless Git workflow

### Backup & Recovery
- **Automatic backup**: Creates timestamped backups before installation
- **Uninstall script**: Clean removal with option to restore from backup
- **Version control**: All configurations tracked in Git
- **Cross-platform**: Works reliably across different systems and SSH versions

## 📁 Project Structure

```
dotfiles/
├── install.sh              # Main installation script
├── uninstall.sh            # Clean removal script
├── zsh/                    # Modular Zsh configuration
│   ├── .zshrc.new         # Main shell config
│   ├── .zshenv            # Environment variables
│   ├── aliases.zsh        # Command aliases
│   ├── functions.zsh      # Custom functions
│   ├── completion.zsh     # Shell completions
│   └── ssh-agent.zsh      # SSH key management
├── config/                # Application configs
│   └── starship.toml      # Prompt configuration
├── ssh/                   # SSH configuration
│   └── config             # Secure SSH configuration
├── homebrew/              # Package management
│   ├── Brewfile          # Modern package list
│   ├── apps.sh           # Legacy app list
│   └── install.sh        # Homebrew installer
├── macos/                 # System configuration
│   └── defaults.sh       # macOS system tweaks
├── alfred/                # Alfred workflows
├── .config/               # App-specific configs
│   ├── kitty/            # Terminal configuration
│   └── gh/               # GitHub CLI config
└── docs/                  # Documentation
    └── SETUP.md          # Detailed setup guide
```

## 🔄 Updates

To update your dotfiles:

```bash
cd ~/dotfiles
git pull origin main
./install.sh
```

## 📄 LICENSE

[![CC0](http://mirrors.creativecommons.org/presskit/buttons/88x31/svg/cc-zero.svg)](http://creativecommons.org/publicdomain/zero/1.0/)

## Inspired by their dotfiles

[@mathiasbynens](https://github.com/mathiasbynens/dotfiles)
[@rodionovd](https://github.com/rodionovd/dotfiles)
[@holman](https://github.com/holman/dotfiles)
