# Claude Code Configuration for Dotfiles

## Project Summary

🏠 **MacOS Dotfiles** - A comprehensive, modern, and performance-optimized development environment configuration system for MacOS.

### Key Features

- 🚀 **Performance Optimized**: Optimized shell startup with immediate Node.js/npm availability
- 🔒 **Security First**: SSH key organization, agent management, no hardcoded secrets
- 📦 **Modular Architecture**: Well-organized, maintainable configuration with 374+ lines of code
- 🛠️ **Modern Toolchain**: Starship prompt, Oh My Zsh, 30+ Homebrew packages
- 🔄 **Automated Setup**: Robust installation script with comprehensive error handling
- 🤖 **Claude Flow Integration**: Advanced session management and AI workflow automation
- 🍎 **MacOS Native**: Optimized specifically for MacOS development environments

### What's Included

- **Shell Configuration**: Zsh with Oh My Zsh, modular configs, Starship prompt, custom functions
- **Package Management**: 30+ essential packages via Homebrew (core utils, dev tools, apps)
- **Applications**: 1Password, Alfred, VSCode, Chrome, Ghostty terminal, Docker Desktop
- **Security Framework**: SSH templates, key organization, secure agent management
- **Alfred Workflows**: Mac App Store search, productivity automation
- **Claude Flow System**: Session `session-1757710180784-9lvy5ayjp`, hive-mind integration
- **Performance Monitoring**: Real-time system metrics tracking

## Project Context

This is a production-ready dotfiles ecosystem that transforms a fresh MacOS installation into a fully configured development environment. The system has evolved from basic configuration management to an intelligent development workflow with Claude Flow integration for enhanced session management, AI-assisted development, and automated workflow optimization.

The project represents a modern approach to dotfiles management with enterprise-level security practices, performance optimization, and intelligent automation.

## Commands to Run After Changes

### Lint/Type Check Commands

```bash
# Validate shell configuration
zsh -n .zshrc                   # Syntax check primary Zsh config
shellcheck .functions .aliases .ssh-agent  # Shell script linting (if available)

# Validate specific components
zsh -n .functions               # Check custom functions
zsh -n .aliases                 # Check aliases
zsh -n .ssh-agent               # Check SSH agent setup
```

### Test Commands

```bash
# Test complete installation
./install.sh

# Test shell functions
zsh -c "source .functions && mkd test_dir"      # Test directory creation
zsh -c "source .functions && weather London"    # Test weather function
zsh -c "source .aliases && ll"                  # Test aliases

# Test Claude Flow integration
flow resume dotfiles            # Resume dotfiles session
flow wizard                     # Test hive-mind wizard
flow init test-project          # Initialize new project

# Test SSH configuration
ssh -T git@github.com          # Test GitHub SSH (after setup)
ssh-add -l                     # List loaded SSH keys

# Performance testing
time zsh -lic exit             # Measure shell startup time
```

### Build Commands

```bash
# Package validation
brew bundle check --file=.brewfile  # Check Homebrew packages
brew bundle install --file=.brewfile # Install missing packages

# System validation
brew doctor                     # Check Homebrew health
git config --list              # Verify git configuration
```

## Development Workflow

### Essential Files

- **`install.sh`** - Main installation script (8,327+ bytes, comprehensive setup)
- **`.zshrc`** - Primary shell configuration with modular loading
- **`.functions`** - Custom shell functions including Claude Flow helper (`flow()` at lines 53-107)
- **`.aliases`** - Shell aliases and shortcuts
- **`.ssh-agent`** - SSH agent management and key loading
- **`.completion`** - Zsh completion configurations
- **`.brewfile`** - Package definitions for 30+ essential tools (in root)
- **`.defaults`** - MacOS system preferences configuration (in root)
- **`.node`** - Node.js environment setup script (in root)
- **`.bun`** - Bun JavaScript runtime configuration (modular config)
- **`.ghostty/config`** - Ghostty terminal configuration (Nord theme, keybindings)
- **`.ssh/config`** - SSH configuration template for secure key management
- **`.alfred/`** - Alfred workflows and preferences
- **`.claude-flow/`** - Claude Flow session data and metrics

### Claude Flow Integration

- **Session ID**: Dynamic (stored in `.claude-flow:session` when active)
- **Helper Function**: `flow()` in `.functions:53-107`
- **Metrics Directory**: `.claude-flow/metrics/`
  - `system-metrics.json` - Real-time system performance (memory, CPU, uptime)
  - `performance.json` - Task execution metrics
  - `task-metrics.json` - Swarm task tracking
  - `agent-metrics.json` - Agent performance data

### Key Commands

```bash
# Claude Flow Session Management
flow resume                     # Resume previous session with summary
flow resume dotfiles           # Resume specific dotfiles session
flow init <project>            # Initialize new project
flow wizard                    # Run hive-mind wizard

# Dotfiles Management
./install.sh                   # Install/update complete dotfiles system
git status                     # Check configuration changes
```

### Project Structure

```
dotfiles/
├── install.sh                 # Main installation script
├── .brewfile                  # Homebrew packages definition
├── .defaults                  # MacOS system preferences
├── .node                      # Node.js environment setup
├── .zshrc                     # Main shell configuration
├── .zshenv                    # Environment variables
├── .functions                 # Custom functions + Claude Flow
├── .aliases                   # Shell aliases and shortcuts
├── .ssh-agent                 # SSH agent management
├── .completion                # Shell completions
├── .ssh/
│   └── config                # SSH configuration template
├── .alfred/
│   └── Alfred.alfredpreferences/ # Alfred workflows
├── .ghostty/
│   └── config                # Ghostty terminal configuration
├── .starship                  # Starship prompt configuration
└── .claude-flow/
    └── metrics/              # Claude Flow session data
```

### Before Committing

1. **Validation Checks**:
   - Run syntax checks on all shell files
   - Verify no secrets are committed to repository

2. **Performance Verification**:
   - Check shell startup time: `time zsh -lic exit`
   - Monitor system metrics in `.claude-flow/metrics/`
   - Verify Node.js tools are immediately available

3. **Security Audit**:
   - Ensure SSH keys are not committed
   - Verify SSH agent configuration is secure
   - Check that personal information is in ignored files

### SSH Setup Requirements

1. **Organize SSH Keys**:
   ```bash
   # Create organized directory structure
   mkdir -p ~/.ssh/{github,gitlab,work}

   # Generate keys for different services
   ssh-keygen -t ed25519 -C "your_email@example.com" -f ~/.ssh/github/id_ed25519
   ssh-keygen -t ed25519 -C "work_email@company.com" -f ~/.ssh/work/id_ed25519
   ```

2. **Update Configuration**:
   - Update `.ssh/config` with actual key paths
   - Modify `.ssh-agent` with real key locations (lines 32-34)
   - Add public keys to respective services (GitHub, GitLab, etc.)

3. **Test SSH Setup**:
   ```bash
   ssh -T git@github.com       # Test GitHub
   ssh-add -l                  # List loaded keys
   ```

### Bun Setup Requirements

**Note:** Bun is not available via Homebrew and must be installed manually.

1. **Install Bun**:
   ```bash
   # Official installation method
   curl -fsSL https://bun.sh/install | bash
   ```

2. **Configuration**:
   - Bun config file: `.bun` (automatically loaded via `.zshrc`)
   - Installation path: `~/.bun/`
   - Completions: Auto-loaded from `~/.bun/_bun`

3. **Verify Installation**:
   ```bash
   bun --version              # Check installed version
   which bun                  # Verify PATH setup
   ```

4. **Usage**:
   - Package manager: `bun install`, `bun add <package>`
   - Run scripts: `bun run <script>`
   - Execute files: `bun <file.ts>` or `bun <file.js>`
   - Test runner: `bun test`

### Performance Notes

- **NVM Auto-Loading**: Node.js environment loads automatically for immediate availability
- **Modular Configuration**: Functions organized for easy maintenance and debugging
- **Starship Integration**: Git-aware prompt with optimized performance
- **Memory Management**: System actively monitored (currently 98.6% usage)

## Recent Implementation Summary

### ✅ What's Implemented

- **Complete Infrastructure** with modular shell configuration
- **Claude Flow Integration** with hive-mind support and session management
- **Alfred Workflows** with Mac App Store search and productivity automation
- **Modular Shell System** with utility functions and performance optimizations
- **Security Framework** with SSH templates and organized key management
- **Automated Installation** with comprehensive error handling

### 🎯 Post-Installation Steps

1. **SSH Configuration**:
   - Generate and organize SSH keys in structured directories (`~/.ssh/github/`, etc.)
   - Update `.ssh/config` with actual key paths
   - Test with `ssh -T git@github.com`

2. **Git Configuration**:
   - Set your identity with `git config --global user.name/user.email`

3. **Local Customization**:
   - Create `~/.zshrc.local` for machine-specific settings

## Troubleshooting

### Common Issues

- **Shell Startup Performance**: `time zsh -lic exit` (should be <1 second)
- **SSH Key Issues**: `ssh-add -l` to verify loaded keys
- **Homebrew Problems**: `brew doctor` for health check
- **Node.js Timeout**: Check Starship `command_timeout` setting
- **Memory Issues**: Monitor with `.claude-flow/metrics/system-metrics.json`

### Claude Flow Commands

- **Start Session**: `flow start` or `flow start 'objective'`
- **Session Recovery**: `flow resume` or `flow resume <session-id>`
- **New Projects**: `flow init project-name`
- **Interactive Setup**: `flow wizard`
- **Check Status**: `flow status`
- **Session Debugging**: Check `.claude-flow/metrics/` for performance data

### Performance Monitoring

System metrics are automatically tracked in `.claude-flow/metrics/system-metrics.json`:
- Memory usage and efficiency
- CPU load and core utilization
- System uptime and stability
- Performance trends over time

## System Requirements

- **MacOS**: 10.15+ (optimized for macOS Sonoma/Ventura)
- **Memory**: 8GB minimum, 16GB+ recommended
- **Storage**: 5GB free space for packages and applications
- **Network**: Internet connection for package downloads
- **Permissions**: Administrative access for system configuration

## Security Features

- **SSH Key Organization**: Structured key management in `~/.ssh/`
- **Agent Management**: Secure SSH agent configuration
- **No Hardcoded Secrets**: All sensitive data externalized
- **Permission Controls**: Proper file permissions for security
- **Template System**: SSH config templates prevent accidental exposure

This dotfiles system represents a comprehensive, production-ready development environment with enterprise security practices, performance optimization, and intelligent automation through Claude Flow integration.