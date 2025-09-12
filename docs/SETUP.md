# Dotfiles Setup Guide

## Prerequisites

Before installing these dotfiles, ensure you have:

- macOS 10.15 or later (some features may work on Linux)
- Command Line Tools for Xcode: `xcode-select --install`
- Git installed and configured
- Administrative access to your machine

## Installation

### Quick Install

```bash
git clone https://github.com/cassmtnr/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

### Simple Installation

```bash
# One command does everything
./install.sh
```

The installation script will automatically:
- Create a timestamped backup of your existing configuration
- Install Homebrew and all packages from the Brewfile
- Install Oh My Zsh
- Create symbolic links for all configuration files
- Configure macOS system defaults
- Provide detailed output showing each step

## Manual Setup

If you prefer manual installation:

### 1. Clone the Repository

```bash
git clone https://github.com/cassmtnr/dotfiles.git ~/dotfiles
```

### 2. Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 3. Install Oh My Zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### 4. Create Symbolic Links

```bash
# Zsh configuration
ln -sf ~/dotfiles/zsh/.zshrc.new ~/.zshrc
ln -sf ~/dotfiles/zsh/.zshenv ~/.zshenv

# Starship prompt
mkdir -p ~/.config
ln -sf ~/dotfiles/config/starship.toml ~/.config/starship.toml

# Git configuration (optional)
ln -sf ~/dotfiles/git/.gitconfig ~/.gitconfig
```

### 5. Install Packages

```bash
brew bundle --file=~/dotfiles/homebrew/Brewfile
```

## Post-Installation

### 1. SSH Configuration

The SSH config is automatically symlinked during installation. Customize it for your needs:

```bash
# Edit the SSH configuration
vim ~/dotfiles/ssh/config
# Changes are automatically reflected in ~/.ssh/config via symlink
```

Generate SSH keys if needed:

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

### 2. Local Customization

Create a local configuration file for machine-specific settings:

```bash
touch ~/.zshrc.local
```

Add any local environment variables, aliases, or functions to this file.

### 3. Node.js Setup

The configuration uses lazy loading for NVM. To use Node.js:

```bash
# First use will load NVM
node --version

# Install a specific version
nvm install 20
nvm use 20
```

### 4. Additional Tools

Install global npm packages:

```bash
npm install -g typescript prettier eslint
```

Install Python tools:

```bash
pipx install black
pipx install pylint
pipx install poetry
```

## Customization

### Adding Aliases

Edit `~/dotfiles/zsh/aliases.zsh` to add custom aliases.

### Adding Functions

Edit `~/dotfiles/zsh/functions.zsh` to add custom functions.

### Changing the Theme

1. For Oh My Zsh themes, edit the `ZSH_THEME` variable in `.zshrc`
2. For Starship, edit `~/dotfiles/config/starship.toml`

### Adding Homebrew Packages

Edit `~/dotfiles/homebrew/Brewfile` and run:

```bash
brew bundle --file=~/dotfiles/homebrew/Brewfile
```

## Troubleshooting

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

## Uninstallation

To remove the dotfiles:

```bash
# Restore from backup (if created during installation)
cp -R ~/.dotfiles.backup.*/* ~/

# Or manually remove symlinks
rm ~/.zshrc ~/.zshenv
rm ~/.config/starship.toml

# Remove the dotfiles directory
rm -rf ~/dotfiles
```

## Updates

To update the dotfiles:

```bash
cd ~/dotfiles
git pull origin main
./install.sh
```

## Contributing

Feel free to fork and customize these dotfiles for your own use!

## License

These dotfiles are released under the CC0 1.0 Universal license.