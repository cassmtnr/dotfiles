# 🎨 Customization Guide

This repository contains generic dotfiles that need to be customized for your personal use.

## 📋 Required Customizations

### 1. SSH Configuration

The SSH config is automatically symlinked to `~/.ssh/config`. Edit it directly:

```bash
vim ~/dotfiles/ssh/config
```

Update the configuration with:
- SSH key paths (replace generic paths with your actual key locations)
- Host configurations for your Git providers
- Any specific connection settings

### 2. Git Configuration

Update git configuration with your details:

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### 3. SSH Agent Configuration

Edit `zsh/ssh-agent.zsh` and update the `ssh_keys` array with your actual SSH key paths:

```bash
local ssh_keys=(
    "$HOME/.ssh/your_github_key"
    "$HOME/.ssh/your_work_key"
    "$HOME/.ssh/id_ed25519"
    # Add your specific key paths here
)
```

### 4. Machine-Specific Settings

Create a local configuration file for machine-specific settings:

```bash
touch ~/.zshrc.local
```

Add any local customizations like:
- Environment variables
- Local aliases
- Machine-specific paths
- Private configurations

### 5. Package Customization

Review and customize the package lists:
- `homebrew/Brewfile` - Modern packages via Homebrew Bundle
- `homebrew/apps.sh` - Legacy application list

Add or remove packages based on your needs.

## 🔒 Security Notes

- Never commit actual SSH keys or sensitive data
- Use `.zshrc.local` for private configurations
- The `.gitignore` is configured to exclude sensitive files
- SSH key paths in templates are examples - replace with your actual paths

## 🏠 Personal Information

This repository has been cleaned of personal information, but you may still need to:
- Update any remaining hardcoded paths
- Customize Alfred workflows for your preferences
- Adjust macOS defaults in `macos/defaults.sh`

## 💡 Pro Tips

1. Fork this repository to your own GitHub account
2. Clone your fork and make personal customizations
3. Keep your fork private if it contains sensitive information
4. Regularly sync with the upstream repository for updates