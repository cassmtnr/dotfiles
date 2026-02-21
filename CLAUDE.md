# Claude Code Configuration for Dotfiles

Cross-platform dotfiles (macOS & Linux) — development environment configuration. See `README.md` for full project documentation, structure, and setup instructions.

## Commands to Run After Changes

### Lint/Type Check

```bash
zsh -n .zshrc                   # Syntax check primary Zsh config
zsh -n .functions               # Check custom functions
zsh -n .aliases                 # Check aliases
zsh -n .ssh-agent               # Check SSH agent setup
shellcheck .functions .aliases .ssh-agent  # Shell script linting (if available)
```

### Test

```bash
./install.sh                   # Test complete installation
time zsh -lic exit             # Measure shell startup time (should be <1 second)
brew bundle check --file=.brewfile  # Check Homebrew packages
```

## Essential Files

- **`install.sh`** - Main installation script
- **`.zshrc`** - Primary shell configuration with modular loading
- **`.functions`** - Custom shell functions (`mkd`, `killport`, `extract`)
- **`.aliases`** - Shell aliases and shortcuts
- **`.ssh-agent`** - SSH agent management and key loading
- **`.completion`** - Zsh completion configurations
- **`.brewfile`** - Homebrew package definitions
- **`.defaults`** - MacOS system preferences
- **`.node`** - Node.js environment setup
- **`.bun`** - Bun JavaScript runtime configuration
- **`.ghostty/config`** - Ghostty terminal configuration
- **`.ssh/config`** - SSH configuration template
- **`.claude/`** - Claude Code global config (symlinked to `~/.claude/`)

## Before Committing

1. Run syntax checks on all shell files
2. Verify no secrets are committed (SSH keys, `.env`, credentials)
3. Check shell startup time: `time zsh -lic exit`
