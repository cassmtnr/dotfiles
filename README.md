# Dotfiles

- macOS and Linux development environment
- One-command setup, safe to re-run
- Version-controlled and portable across machines

## Installation

Setup runs in four steps, all driven by interactive menus (arrow keys to move,
space to toggle, enter to confirm) — there are no flags to remember:

1. **Install software** — shell, dev toolchain, and apps from `.brewfile`
2. **Apply personal configuration** — symlinks, user-level defaults (always runs)
3. **Extras** — optional perks in a checkbox menu; anything that needs
   sudo/admin says so in its label
4. **AI tools** — optional checkbox menu (`claude-code` — Claude Code + Codex
   config, `agent-reach`, `claude-plugins`); see [AI setup](#ai-setup)

```bash
git clone https://github.com/cassmtnr/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Review .brewfile, .aliases, .functions, and .defaults first.
./install.sh
```

Steps 3 and 4 have nothing pre-selected and are skipped without a terminal, so
a plain or non-interactive run (piped over SSH, CI) installs **no extras and no
AI**. Use `ssh -t host` to get the menus remotely.

Idempotent — re-run anytime to add extras or AI tools.

The script prints the detected OS at the start and tailors itself to it: GUI
apps are Homebrew casks and install on macOS only (skipped on Linux — a VPS
gets CLI tools only), and the extras menu shows only the perks relevant to the
platform.

| Extra | Privileges |
|---|---|
| `icons` (macOS) | writes to /Applications — admin on managed Macs |
| `macos-admin` (macOS) | **needs admin** — system-level `defaults write` |
| `motd` (Linux) | **needs sudo** — installs to /etc/update-motd.d |

**Everything is user-level by default.** The script asks one yes/no question
up front — "allow steps that need admin rights?" (`apt-get`, `/etc` changes,
the official Homebrew install) — defaulting to yes on Linux (servers, root
available) and no on macOS (managed work laptops just work).

**Homebrew adapts to that answer.** With admin it uses the official installer
(`/opt/homebrew` or `/home/linuxbrew/.linuxbrew`, precompiled "bottles", fast).
Without admin it untars Homebrew into **`~/.homebrew`** — no sudo needed — but
that prefix has no bottles, so packages **build from source** (slower, needs
Xcode Command Line Tools on macOS). Either way `brew` runs user-level after.
If Homebrew already exists, neither path runs.

Sudo-needing *extras* are different: they never run unless you select them
in the menu, and selecting one is the authorization — they prompt for sudo
themselves and skip with a warning if it's unavailable.

### Updating

```bash
./update.sh              # Refresh symlinks + VSCodium extension sync
./update.sh -p           # Also update Homebrew packages from .brewfile
./update.sh -d           # Also re-apply user-level macOS defaults
./update.sh -a           # All of the above
```

AI tooling updates via `./install.sh` step 4 (re-select and re-run; idempotent).

## Project Structure

```
dotfiles/
├── install.sh                 # Setup in four steps: install / configure / extras / ai-tools
├── update.sh                  # Lightweight update (symlinks + optional packages/defaults)
├── .brewfile                  # Homebrew packages (casks skipped on Linux)
├── lib/
│   ├── common.sh              # OS detection, logging, Homebrew PATH, menu helper
│   ├── install.sh             # Step 1: software installation
│   ├── configure.sh           # Step 2: symlinks, VSCodium, user-level defaults, shell
│   ├── extras.sh              # Step 3: optional perks (sudo/admin needs labeled)
│   └── ai.sh                  # Step 4: AI tools (Claude Code, Codex, agent-reach) — opt-in
├── .editorconfig              # Cross-editor coding standards
├── .zshrc                     # Shell configuration
├── .zshrc.local.example       # Template for machine-specific overrides
├── .zshenv                    # Environment variables
├── .functions                 # Utility functions (mkd, killport, extract, weather)
├── .aliases                   # Shell aliases (25+)
├── .ssh-agent                 # SSH agent management
├── .completion                # Shell completions
├── .starship                  # Starship prompt configuration
├── .defaults                  # macOS system preferences
├── capture-setting.sh         # Capture a changed macOS setting into .defaults
├── .ghostty/                  # Ghostty terminal (Nord theme, custom keybindings)
├── .ssh/config                # SSH configuration template
├── .ai/                       # AI CLI configuration (set up by install.sh step 4)
│   ├── common/                # Shared by Claude Code & Codex CLI
│   │   ├── instructions.md    # Global AI instructions
│   │   ├── skills/            # AI CLI skills
│   │   ├── hooks/             # PreToolUse safety hooks (fail-closed)
│   │   └── scripts/           # Helper scripts (vps-run.sh, skill-lint.sh)
│   ├── claude/                # Claude Code only
│   │   ├── settings.json      # Settings (plugins, permissions, statusline)
│   │   └── config/            # Custom statusline script
│   └── codex/                 # Codex CLI only
│       └── hooks.json         # Hook configuration
├── config/                    # mcporter config for AI search (→ ~/.mcporter, via step 4)
├── .1password/                # 1Password SSH agent config
├── .vscodium/                 # VSCodium settings, extensions, custom icon
├── .lazydocker/               # LazyDocker terminal UI configuration
├── .motd/                     # Message of the Day scripts (Linux/VPS)
├── index.html                 # GitHub Pages shell (renders this README)
├── .github/workflows/ci.yml   # CI: shellcheck + install on macOS/Ubuntu
├── docs/superpowers/plans/    # Design docs
├── CHANGELOG.md               # Notable changes
├── TODO.md                    # Deferred work
└── log.md                     # Append-only project log
```

### Capturing macOS settings

To make a System Settings change reproducible on future machines, capture it
into `.defaults`:

```bash
./capture-setting.sh      # 1. run it — it snapshots current preferences
                          # 2. change ONE setting in System Settings, wait ~2s
                          # 3. press Enter
```

The script detects which preference keys changed, filters out macOS churn
(timestamps, counters, caches), and appends ready-made `defaults write` lines
to `.defaults` — review with `git diff .defaults`, optionally move the lines
into a themed section, and commit. Keys the change *removed* are printed for
information but not appended (macOS often deletes a key to mean "back to
default"). If more than 12 keys changed, nothing is appended — that's
background noise; re-run and change only one thing. Captured settings apply
to new machines via `install.sh` (some need logout/login to take effect).

## Post-Install Configuration

1. **SSH**: Edit `~/dotfiles/.ssh/config` with your key paths and hosts
2. **SSH Agent**: Edit `.ssh-agent` with your key paths
3. **Git**: `git config --global user.name/user.email`
4. **Local overrides**: `cp .zshrc.local.example .zshrc.local` and edit for
   machine-specific settings (`.zshrc.local` is gitignored)
5. **AI tooling** (optional): pick it in step 4 of `./install.sh` — see [AI setup](#ai-setup)

## AI setup

AI tooling is **step 4 of `./install.sh`** — an opt-in checkbox menu, with
nothing pre-selected and skipped without a terminal, so a plain or
non-interactive install sets up none of it. Re-run `./install.sh` and select
what you want in the AI step:

- **`claude-code`** — links AI config into `~/.claude/` and `~/.codex/` and
  installs Claude Code (plus Gemini on Linux)
- **`agent-reach`** — internet channels (see below)
- **`claude-plugins`** — Claude Code plugins (needs a logged-in CLI)

It's all user-level (no sudo) and idempotent — re-run to update or add more.

Shared configuration for [Claude Code](https://claude.com/claude-code) and [Codex CLI](https://github.com/openai/codex):

- `.ai/common/` contains only assets that are intended to work for both CLIs
- `.ai/claude/` contains Claude-only settings
- `.ai/codex/` contains Codex-only settings (`hooks.json`; the former
  `config.toml` was removed — Codex hooks stay dormant until a machine-local
  config enables the `codex_hooks` feature)

**Agent Reach** — internet access channels for AI CLIs ([Panniantong/agent-reach](https://github.com/Panniantong/agent-reach)). Offered in `./install.sh` step 4 (select `agent-reach`) via pipx, activating: web pages (Jina Reader), Exa web search (via mcporter, config in `config/mcporter.json`), YouTube (yt-dlp), GitHub (gh), RSS, V2EX, Bilibili (bili-cli), Twitter (twitter-cli), Reddit (rdt-cli). The skill lives in `.ai/common/skills/agent-reach/` — trimmed to these channels; upgrades regenerate it with upstream's full 15-platform Chinese docs, so the AI step auto-restores the trimmed version from git afterwards. Manual per-machine steps (cookie logins, no browser needed at runtime): Twitter — log into x.com in Chrome, then `agent-reach configure --from-browser chrome`; Reddit — log into reddit.com in Chrome, then `rdt login`. Don't log out of those sites afterwards; that invalidates the tokens. Credentials live in `~/.agent-reach/` — never in this repo. Health check: `agent-reach doctor`.

**Safety hooks** — `block-dangerous-commands.js` blocks dangerous Bash commands via PreToolUse hooks at three levels (fails closed on malformed input):

- **Critical**: filesystem destruction, disk operations, fork bombs, git history rewriting
- **High** (default): git write ops, elevated privileges, secrets exposure, publishing/deployment, database ops
- **Strict**: cautionary patterns (`git checkout .`, `docker prune`)

**Plugins** (Claude Code only) — installed from enabled entries in `.ai/claude/settings.json` (currently `code-simplifier`, `frontend-design`, `superpowers` from the official marketplace, plus `ponytail` from its own marketplace). Needs an authenticated CLI — `./install.sh` step 4 offers a `claude-plugins` option; run it again after logging in.

## VSCodium

[VSCodium](https://vscodium.com/) (open-source VS Code without Microsoft telemetry). Settings, extensions, and a custom icon are managed in `.vscodium/`:

- `install.sh` / `update.sh` handle symlinks and extensions automatically
- Custom icon is an extra (re-run `./install.sh`, select `icons`) — writing
  to /Applications bundles needs admin rights on managed Macs
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
