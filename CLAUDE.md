# Claude Code Configuration for Dotfiles

## Project Summary

🏠 **Dotfiles** - Modern, secure, and performant dotfiles configuration for MacOS.

### Key Features

- 🚀 **Performance Optimized**: Lazy loading for NVM and other tools
- 🔒 **Security First**: Secure SSH configuration and key management
- 📦 **Modular Design**: Well-organized, maintainable configuration files
- 🛠️ **Modern Tools**: Starship prompt for beautiful terminal experience
- 🔄 **Automated Setup**: Robust installation with backup and error handling
- 🍎 **MacOS Optimized**: Designed specifically for MacOS systems

### What's Included

- **Shell Configuration**: Zsh with Oh My Zsh, modular configs, Starship prompt
- **90+ Packages**: Core utilities, programming languages, development tools
- **Applications**: 1Password, Alfred, VSCode, Chrome, Kitty terminal, etc.
- **Security**: SSH templates, agent management, no hardcoded secrets
- **Alfred Workflows**: Mac App Store search, productivity enhancements
- **Claude Flow Integration**: Session management and development workflow

## Project Context

This is a comprehensive dotfiles system that transforms a fresh MacOS installation into a fully configured development environment. The project has undergone significant evolution with recent Claude Flow integration for enhanced session management and workflow automation.

## Commands to Run After Changes

### Lint/Type Check Commands

```bash
# No specific linting - this is a shell/config project
# But run these to validate:
./install.sh --dry-run  # Test installation without making changes
zsh -n zsh/.zshrc       # Syntax check Zsh config
shellcheck zsh/*.zsh    # Shell script linting (if shellcheck installed)
```

### Test Commands

```bash
# Test installation process
./install.sh

# Test shell functions
zsh -c "source zsh/functions.zsh && mkd test_dir"  # Test mkd function
zsh -c "source zsh/aliases.zsh && ll"             # Test aliases

# Test SSH configuration
ssh -T git@github.com  # Test GitHub SSH (after setup)
```

### Build Commands

```bash
# No build step required - these are configuration files
# But validate package installations:
brew bundle check --file=homebrew/Brewfile  # Check Homebrew packages
```

## Development Workflow

### Essential Files

- `install.sh` - Main installation script
- `zsh/.zshrc` - Primary shell configuration
- `zsh/functions.zsh` - Custom shell functions (includes Claude Flow helper)
- `homebrew/Brewfile` - Package definitions
- `ssh/config` - SSH configuration template

### Claude Flow Integration

- Session ID: `session-1757710180784-9lvy5ayjp`
- Helper function: `flow()` in `zsh/functions.zsh:83-107`
- Metrics tracking in `.claude-flow/metrics/`

### Key Commands

```bash
# Resume Claude Flow sessions
flow resume              # General resume with summary
flow resume dotfiles     # Resume specific dotfiles session
flow init <project>      # Initialize new project
flow wizard             # Run hive-mind wizard

# Dotfiles management
./install.sh           # Install/update dotfiles
git status             # Check configuration changes
```

### Before Committing

1. Run syntax checks on shell files
2. Test installation on clean environment if possible
3. Ensure no secrets are committed
4. Update README.md if adding new features

### SSH Setup Requirements

1. Generate SSH keys in organized folders:
   ```bash
   mkdir -p ~/.ssh/github
   ssh-keygen -t ed25519 -C "your_email@example.com" -f ~/.ssh/github/id_ed25519
   ```
2. Update `ssh/config` with real key paths (e.g., `~/.ssh/github/id_ed25519`)
3. Update `zsh/ssh-agent.zsh` with actual key paths (line 32-34)
4. Add keys to GitHub/GitLab

### Performance Notes

- NVM uses lazy loading for faster shell startup
- Functions are modular for easy maintenance
- Starship prompt configured for git integration

## Recent Implementation Summary

### ✅ What Was Completed

- **Complete dotfiles restructure** (1,600+ lines of new configuration)
- **Claude Flow integration** with session management (`session-1757710180784-9lvy5ayjp`)
- **Alfred workflow enhancement** (Mac App Store search with JavaScript)
- **Modular shell configuration** with 40+ utility functions
- **Performance optimizations** with lazy loading
- **Security enhancements** with SSH templates and agent management

### 🚧 Current Status

- **Staged changes**: Alfred workflow, Node.js installer updates ready for commit
- **Active monitoring**: System metrics tracking (memory ~90%, 12-core CPU)
- **Session context**: Integrated with Claude Flow for continued development

### 🎯 Next Steps Required

1. **Commit current changes** with proper commit message
2. **SSH configuration** - Keys organized in folders (e.g., ~/.ssh/github/)
3. **Git configuration** - set global user details
4. **Machine-specific settings** - create ~/.zshrc.local
5. **Testing & validation** - run installation tests

## Troubleshooting

- Check shell startup time: `time zsh -lic exit`
- SSH issues: `ssh-add -l` to check loaded keys
- Homebrew issues: `brew doctor`
- Claude Flow session: Use `flow resume` or `flow resume dotfiles`
