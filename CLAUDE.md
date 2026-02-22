# Claude Code Configuration for Dotfiles

Cross-platform dotfiles (macOS & Linux) — development environment configuration. See `README.md` for full project documentation, structure, and setup instructions.

## Cross-Platform Rule

This project supports **both macOS and Linux**. When making any changes:

- All shell scripts, aliases, and functions must work on both platforms
- Use OS detection (`$OSTYPE`, `$IS_MACOS`, `$IS_LINUX`) to gate platform-specific code
- Homebrew paths differ: `/opt/homebrew` (macOS ARM), `/usr/local` (macOS Intel), `/home/linuxbrew/.linuxbrew` (Linux) — always check all three
- Casks are macOS-only — never assume cask availability on Linux
- Commands like `defaults`, `osascript`, `open`, `pbcopy`, `pbpaste` are macOS-only — wrap in OS checks or provide Linux alternatives
- Test changes mentally against both platforms before committing

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
- **`.defaults`** - macOS system preferences
- **`.bun`** - Bun JavaScript runtime configuration
- **`.ghostty/config`** - Ghostty terminal configuration
- **`.ssh/config`** - SSH configuration template
- **`.claude/`** - Claude Code global config (symlinked to `~/.claude/`)

## Before Committing

1. Run syntax checks on all shell files
2. Verify no secrets are committed (SSH keys, `.env`, credentials)
3. Check shell startup time: `time zsh -lic exit`
