# Dotfiles

- macOS and Linux development environment
- One-command setup, safe to re-run
- Version-controlled and portable across machines

## Installation

```bash
git clone https://github.com/cassmtnr/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Review .brewfile, .aliases, .functions, and .defaults before running
# to customize packages and preferences for your setup.
./install.sh
```

Idempotent — safe to run multiple times.

### Updating

```bash
./update.sh              # Refresh symlinks only
./update.sh -p           # Also update Homebrew packages
./update.sh -d           # Also re-apply macOS defaults
./update.sh -a           # All of the above
```

## Project Structure

```
dotfiles/
├── install.sh                 # Full installation
├── update.sh                  # Lightweight update (symlinks + optional packages/defaults)
├── .utils.sh                  # Shared utilities (OS detection, logging, symlinks, packages)
├── .brewfile                  # Homebrew packages (45+)
├── .editorconfig              # Cross-editor coding standards
├── .zshrc                     # Shell configuration
├── .zshenv                    # Environment variables
├── .functions                 # Utility functions (mkd, killport, extract, weather)
├── .aliases                   # Shell aliases (25+)
├── .ssh-agent                 # SSH agent management
├── .completion                # Shell completions
├── .starship                  # Starship prompt configuration
├── .defaults                  # macOS system preferences
├── .bun                       # Bun JavaScript runtime config
├── .ghostty/                  # Ghostty terminal (Nord theme, custom keybindings)
├── .ssh/config                # SSH configuration template
├── .ai/                       # AI CLI configuration
│   ├── common/                # Shared by Claude Code & Codex CLI
│   │   ├── instructions.md    # Global AI instructions
│   │   ├── commands/          # Slash commands
│   │   ├── skills/            # AI CLI skills
│   │   ├── hooks/             # PreToolUse safety hooks (fail-closed)
│   │   └── scripts/           # Helper scripts (vps-run.sh)
│   ├── claude/                # Claude Code only
│   │   ├── settings.json      # Settings (plugins, permissions, statusline)
│   │   └── config/            # Custom statusline script
│   └── codex/                 # Codex CLI only
│       ├── config.toml        # Model and approval policy
│       └── hooks.json         # Hook configuration
├── .vscodium/                 # VSCodium settings, extensions, custom icon
├── .lazydocker/               # LazyDocker terminal UI configuration
├── .motd/                     # Message of the Day scripts (Linux/VPS)
└── .alfred/                   # Alfred workflows and preferences (macOS only)
```

## Post-Install Configuration

1. **SSH**: Edit `~/dotfiles/.ssh/config` with your key paths and hosts
2. **SSH Agent**: Edit `.ssh-agent` with your key paths
3. **Git**: `git config --global user.name/user.email`
4. **Local overrides**: Create `~/.zshrc.local` for machine-specific settings

## AI CLI Configuration

Shared configuration for [Claude Code](https://claude.com/claude-code) and [Codex CLI](https://github.com/openai/codex), symlinked to `~/.claude/` and `~/.codex/`.

- `.ai/common/` contains only assets that are intended to work for both CLIs
- `.ai/claude/` contains Claude-only settings
- `.ai/codex/` contains Codex-only settings
- `~/.codex/instructions.md` is loaded by Codex via `model_instructions_file` in `.ai/codex/config.toml`
- Codex hooks are enabled explicitly in `.ai/codex/config.toml` because `hooks.json` is ignored unless the `codex_hooks` feature is on
- Codex TUI status line and terminal title are versioned in `.ai/codex/config.toml` via the built-in `[tui]` settings; keeping the full `status_line` list there makes it persist across new Codex sessions
- Codex project trust is intentionally not hardcoded in the repo because `projects.<path>.trust_level` is machine-specific

**Safety hooks** — `block-dangerous-commands.js` blocks dangerous Bash commands via PreToolUse hooks at three levels (fails closed on malformed input):

- **Critical**: filesystem destruction, disk operations, fork bombs, git history rewriting
- **High** (default): git write ops, elevated privileges, secrets exposure, publishing/deployment, database ops
- **Strict**: cautionary patterns (`git checkout .`, `docker prune`)

**Plugins** (Claude Code only) — installed from enabled entries in `.ai/claude/settings.json` (currently `superpowers`, `code-simplifier`, `frontend-design`, `sentry`, `swift-lsp`, `pyright-lsp`).

## VSCodium

[VSCodium](https://vscodium.com/) (open-source VS Code without Microsoft telemetry). Settings, extensions, and a custom icon are managed in `.vscodium/`:

- `install.sh` / `update.sh` handle symlinks, extensions, and icon automatically
- `brew()` wrapper in `.functions` re-applies the icon after upgrades
- `alias code="codium"` for transparent compatibility

## Security

- Never commit actual SSH keys — only configuration templates
- Use `.zshrc.local` for private/sensitive configurations
- SSH keys should have `600` permissions
- `.gitignore` protects sensitive files

## Troubleshooting

- **Slow startup**: `time zsh -lic exit` and uncomment `zmodload zsh/zprof` / `zprof` in `.zshrc`
- **SSH issues**: `ssh -T git@github.com` or `ssh -vT` for debug
- **Homebrew**: `brew doctor` and `brew update`
- **macOS defaults**: `.defaults` is audited for macOS 26+ / Apple Silicon — dead settings are removed periodically

## License

CC0 1.0 Universal

[![CC0](http://mirrors.creativecommons.org/presskit/buttons/88x31/svg/cc-zero.svg)](http://creativecommons.org/publicdomain/zero/1.0/)

## Inspired By

- [@mathiasbynens](https://github.com/mathiasbynens/dotfiles)
- [@rodionovd](https://github.com/rodionovd/dotfiles)
- [@holman](https://github.com/holman/dotfiles)
