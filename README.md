# 🏠 Dotfiles

Modern, secure, and performant dotfiles configuration for MacOS.

## ✨ Features

- 🚀 **Performance Optimized**: Lazy loading for NVM and other tools
- 🔒 **Security First**: Secure SSH configuration and key management
- 📦 **Modular Design**: Well-organized, maintainable configuration files
- 🛠️ **Modern Tools**: Starship prompt for beautiful terminal experience
- 🔄 **Automated Setup**: Robust installation with error handling
- 🔐 **Minimal Password Requests**: Streamlined authentication process
- 🍎 **MacOS Optimized**: Designed specifically for MacOS systems

## 🚀 Quick Start

```bash
# Clone and install
git clone https://github.com/cassmtnr/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

**✨ Streamlined Setup**: Administrative privileges are requested only when needed for system configuration.

## 📁 Project Structure

```
dotfiles/
├── homebrew/
│   ├── Brewfile      # All Homebrew packages and casks
│   └── install.sh    # Homebrew installer
├── config/
│   └── starship.toml # Starship prompt configuration
├── node/
│   └── install.sh    # Node.js setup with NPM packages
├── zsh/
│   ├── .zshrc        # Main Zsh configuration
│   ├── .zshenv       # Environment variables
│   ├── aliases.zsh   # Shell aliases
│   ├── functions.zsh # Shell functions
│   ├── completion.zsh # Shell completions
│   └── ssh-agent.zsh # SSH key management
├── macos/
│   └── defaults.sh   # MacOS system preferences
├── ssh/
│   └── config        # SSH configuration template
├── alfred/           # Alfred workflows
├── .config/          # Application configs
│   └── kitty/        # Terminal configuration
└── install.sh        # Main installation script
```

## 📋 What's Included

### Shell Configuration

- **Zsh** with Oh My Zsh
- **Modular configuration** (aliases, functions, completions)
- **Starship prompt** for beautiful, informative terminal
- **Lazy loading** for improved startup performance

### Security

- **SSH config template** with secure defaults
- **SSH agent management** with keychain support
- **No hardcoded secrets** in configuration files

## 📦 Complete Package List

The following packages and applications will be installed automatically:

### 🛠️ Core Utilities & CLI Tools

| Package     | Description                                  |
| ----------- | -------------------------------------------- |
| `coreutils` | GNU Core Utilities (better ls, cp, mv, etc.) |
| `findutils` | GNU findutils (better find, locate, xargs)   |
| `gnu-sed`   | GNU sed (stream editor)                      |
| `grep`      | GNU grep (text search)                       |
| `wget`      | Web file downloader                          |
| `curl`      | Command line tool for transferring data      |
| `htop`      | Interactive process viewer                   |
| `tldr`      | Simplified man pages with practical examples |
| `jq`        | JSON processor and query tool                |
| `yq`        | YAML processor and query tool                |
| `git`       | Version control system                       |
| `watch`     | Execute commands repeatedly                  |

### 🐚 Shell Enhancements

| Package                   | Description                             |
| ------------------------- | --------------------------------------- |
| `zsh`                     | Z Shell (modern shell)                  |
| `zsh-completions`         | Additional completions for Zsh          |
| `zsh-autosuggestions`     | Fish-like autosuggestions               |
| `zsh-syntax-highlighting` | Syntax highlighting in terminal         |
| `starship`                | Cross-shell prompt with Git integration |

### 💻 Programming Languages & Tools

| Package       | Description                                          |
| ------------- | ---------------------------------------------------- |
| `nvm`         | Node.js Version Manager                              |
| `python@3.13` | Python 3.13 programming language                     |
| `poetry`      | Python dependency management                         |
| `pipx`        | Install Python applications in isolated environments |
| `go`          | Go programming language                              |
| `rust`        | Rust programming language                            |
| `yarn`        | Alternative package manager for Node.js              |
| `pnpm`        | Fast, disk space efficient package manager           |

### 🐳 Container & Orchestration

| Package          | Description                         |
| ---------------- | ----------------------------------- |
| `docker`         | Container platform                  |
| `docker-compose` | Multi-container Docker applications |
| `kubectl`        | Kubernetes command-line tool        |
| `helm`           | Kubernetes package manager          |

### 🗄️ Database Tools

| Package         | Description                     |
| --------------- | ------------------------------- |
| `postgresql@16` | PostgreSQL database server v16  |
| `sqlite`        | Lightweight SQL database engine |

### 🔒 Security Tools

| Package   | Description                     |
| --------- | ------------------------------- |
| `gnupg`   | GNU Privacy Guard (encryption)  |
| `openssh` | Secure Shell (SSH) client       |
| `openssl` | Cryptographic library and tools |

### 🔤 Fonts

| Font                       | Description                                |
| -------------------------- | ------------------------------------------ |
| `font-fira-code`           | Monospaced font with programming ligatures |
| `font-jetbrains-mono`      | JetBrains monospaced font family           |
| `font-cascadia-code`       | Microsoft's monospaced font                |
| `font-hack-nerd-font`      | Hack font with icons and symbols           |
| `font-meslo-for-powerline` | Meslo font optimized for Powerline         |
| `font-meslo-lg`            | Meslo LG font family                       |

### 🚀 Applications

| Application          | Description                          |
| -------------------- | ------------------------------------ |
| `1password`          | Password manager and secure wallet   |
| `alfred`             | Productivity app for MacOS           |
| `google-chrome`      | Google Chrome web browser            |
| `kitty`              | Fast, feature-rich terminal emulator |
| `spotify`            | Music streaming service              |
| `the-unarchiver`     | Archive extraction utility           |
| `visual-studio-code` | Code editor by Microsoft             |
| `vlc`                | Multimedia player and framework      |
| `dbeaver-community`  | Universal database tool              |

### 📦 Node.js Global Packages

The following NPM packages are installed globally by default:

| Package      | Description                           | Status     |
| ------------ | ------------------------------------- | ---------- |
| `npm`        | Node Package Manager (auto-installed) | ✅ Enabled |
| `yarn`       | Fast, reliable package manager        | ✅ Enabled |
| `typescript` | TypeScript language compiler          | ✅ Enabled |
| `eslint`     | JavaScript linting utility            | ✅ Enabled |
| `nodemon`    | Development server with auto-restart  | ✅ Enabled |

### 🎛️ MacOS System Configurations

The installation also applies numerous MacOS system optimizations:

- **Finder**: Show hidden files, extensions, path bar
- **Dock**: Auto-hide, custom size, faster animations
- **Keyboard**: Faster key repeat, disable press-and-hold
- **Screenshots**: Save to ~/Screenshots folder in JPG format
- **Security**: Various privacy and security enhancements
- **Performance**: SSD optimizations, faster UI animations

## 📦 Installation

### Prerequisites

Before installing these dotfiles, ensure you have:

- MacOS 10.15 or later
- Command Line Tools for Xcode: `xcode-select --install`
- Git installed and configured
- Administrative access to your machine

### Automatic Installation

```bash
# One command does everything
./install.sh
```

The installation script will automatically:

- Install Homebrew and all packages from the Brewfile
- Install Oh My Zsh
- Create symbolic links for all configuration files
- Configure MacOS system defaults
- Provide detailed output showing each step

### Manual Installation

If you prefer manual installation:

#### 1. Clone the Repository

```bash
git clone https://github.com/cassmtnr/dotfiles.git ~/dotfiles
```

#### 2. Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### 3. Install Oh My Zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

#### 4. Create Symbolic Links

```bash
# Zsh configuration
ln -sf ~/dotfiles/zsh/.zshrc ~/.zshrc
ln -sf ~/dotfiles/zsh/.zshenv ~/.zshenv

# Starship prompt configuration
mkdir -p ~/.config
ln -sf ~/dotfiles/config/starship.toml ~/.config/starship.toml

# SSH configuration
ln -sf ~/dotfiles/ssh/config ~/.ssh/config

# Application configurations
ln -sf ~/dotfiles/.config/kitty ~/.config/kitty
ln -sf ~/dotfiles/.config/gh ~/.config/gh
```

#### 5. Install Packages

```bash
brew bundle --file=~/dotfiles/homebrew/Brewfile
```

## 🎨 Customization

### Required Customizations

#### 1. SSH Configuration

The SSH config is automatically symlinked to `~/.ssh/config`. Edit it directly:

```bash
vim ~/dotfiles/ssh/config
```

Update the configuration with:

- SSH key paths (replace generic paths with your actual key locations)
- Host configurations for your Git providers
- Any specific connection settings

Generate SSH keys if needed:

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

#### 2. Git Configuration

Update git configuration with your details:

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

#### 3. SSH Agent Configuration

Edit `zsh/ssh-agent.zsh` and update the `ssh_keys` array with your actual SSH key paths:

```bash
local ssh_keys=(
    "$HOME/.ssh/github/id_ed25519"  # GitHub key
    "$HOME/.ssh/work/gitlab"         # GitLab work key (if exists)
    "$HOME/.ssh/id_rsa"              # Legacy RSA key (if exists)
)
```

#### 4. Machine-Specific Settings

Create a local configuration file for machine-specific settings:

```bash
touch ~/.zshrc.local
```

Add any local customizations like:

- Environment variables
- Local aliases
- Machine-specific paths
- Private configurations

#### 5. Package Customization

Review and customize the package lists:

- `homebrew/Brewfile` - All Homebrew packages and applications
- `node/install.sh` - Node.js setup with essential development packages

### Additional Customizations

#### Adding Aliases

Edit `~/dotfiles/zsh/aliases.zsh` to add custom aliases.

#### Adding Functions

Edit `~/dotfiles/zsh/functions.zsh` to add custom functions.

#### Changing the Theme

1. For Oh My Zsh themes, edit the `ZSH_THEME` variable in `.zshrc`
2. For Starship customization, edit `~/dotfiles/config/starship.toml`

#### Adding Homebrew Packages

Edit `~/dotfiles/homebrew/Brewfile` and run:

```bash
brew bundle --file=~/dotfiles/homebrew/Brewfile
```

## 🔧 Post-Installation

### Node.js Setup

The configuration uses lazy loading for NVM. To use Node.js:

```bash
# First use will load NVM
node --version

# Install a specific version
nvm install 22
nvm use 22
```

Install global npm packages:

```bash
# Use the Node.js setup script
~/dotfiles/node/install.sh

# Or edit the npm_packages array in node/install.sh to add/remove packages
```

### Python Tools

Install Python tools:

```bash
pipx install black
pipx install pylint
pipx install poetry
```

## 🚑 Troubleshooting

### Slow Shell Startup

1. Check for duplicate completions:

   ```bash
   echo $fpath | tr ' ' '\n' | sort | uniq -d
   ```

2. Profile your shell startup:

   ```bash
   # Add to beginning of .zshrc
   zmodload zsh/zprof

   # Add to end of .zshrc
   zprof
   ```

### SSH Agent Issues

If SSH keys aren't loading:

```bash
# Check agent status
ssh-add -l

# Manually add keys
ssh-add ~/.ssh/id_ed25519
```

### Permission Issues

Fix permissions for SSH files:

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/config
chmod 600 ~/.ssh/id_*
chmod 644 ~/.ssh/*.pub
```

## 🔄 Updates

To update your dotfiles:

```bash
cd ~/dotfiles
git pull origin main
./install.sh
```

## 🔒 Security Notes

- Never commit actual SSH keys or sensitive data
- Use `.zshrc.local` for private configurations
- The `.gitignore` is configured to exclude sensitive files
- SSH key paths in templates are examples - replace with your actual paths

## 💡 Pro Tips

1. Fork this repository to your own GitHub account
2. Clone your fork and make personal customizations
3. Keep your fork private if it contains sensitive information
4. Regularly sync with the upstream repository for updates

## 🤝 Contributing

Feel free to fork and customize these dotfiles for your own use!

## 📄 License

These dotfiles are released under the CC0 1.0 Universal license.

[![CC0](http://mirrors.creativecommons.org/presskit/buttons/88x31/svg/cc-zero.svg)](http://creativecommons.org/publicdomain/zero/1.0/)

## Inspired by

[@mathiasbynens](https://github.com/mathiasbynens/dotfiles)
[@rodionovd](https://github.com/rodionovd/dotfiles)
[@diessica](https://github.com/diessica/dotfiles)
[@holman](https://github.com/holman/dotfiles)
