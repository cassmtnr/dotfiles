# Dotfiles

- macOS and Linux development environment
- One-command setup, safe to re-run
- Version-controlled and portable across machines

## Installation

Setup runs in four steps, all driven by interactive menus (arrow keys to move,
space to toggle, enter to confirm):

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

While a step runs you get a spinner, its elapsed time once it passes three
seconds, and the latest line of its output, so a long `brew bundle` shows what
it's fetching instead of looking hung. Each finished step collapses to one
status line — ✓ when it did the work, − when it had nothing to do (wrong
platform, already installed, prerequisite missing) or you skipped it, ✗ when it
failed — and the run ends with a summary table. A − line says why. A ✗ prints
the exit code and the last 15 lines inline, and keeps the full output in a temp
file whose path it shows. If a step fails you choose **retry** (fix the problem in another
terminal first if needed), **skip**, or **abort** — a flaky download doesn't
kill the run. Pass `-v`/`--verbose` to stream full command output instead of
the one-line-per-step view.

The whole UI is pure bash (macOS's stock bash 3.2, zero dependencies), so it
works on a fresh machine, offline, with nothing installed.

Steps 3 and 4 have nothing pre-selected and are skipped without a terminal, so
a plain or non-interactive run (piped over SSH, CI) installs **no extras and no
AI**, never prompts, and records failures in the summary instead of stopping.
Use `ssh -t host` to get the menus remotely.

Idempotent — re-run anytime to add extras or AI tools; an aborted run resumes
cleanly on the next run.

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
./update.sh -v           # Full command output instead of one line per step
```

AI tooling updates via `./install.sh` step 4 (re-select and re-run; idempotent).

## Project Structure

```
dotfiles/
├── install.sh                 # Setup in four steps: install / configure / extras / ai-tools
├── update.sh                  # Lightweight update (symlinks + optional packages/defaults)
├── .brewfile                  # Homebrew packages (casks skipped on Linux)
├── lib/
│   ├── common.sh              # OS detection, logging, Homebrew PATH
│   ├── ui.sh                  # Terminal UI: menus, confirms, step runner — see UI.md
│   ├── install.sh             # Step 1: software installation
│   ├── configure.sh           # Step 2: symlinks, VSCodium, user-level defaults, shell
│   ├── extras.sh              # Step 3: optional perks (sudo/admin needs labeled)
│   └── ai.sh                  # Step 4: AI tools (Claude Code, Codex, agent-reach) — opt-in
├── .editorconfig              # Cross-editor coding standards
├── .zshrc                     # Shell configuration
├── .zshrc.local.example       # Template for machine-specific overrides
├── .zshenv                    # Environment variables
├── .functions                 # Utility functions (mkd, killport, weather)
├── .aliases                   # Shell aliases (25+)
├── .ssh-agent                 # SSH agent management
├── .completion                # Shell completions
├── .starship                  # Starship prompt configuration
├── .defaults                  # macOS system preferences
├── capture-setting.sh         # Capture a changed macOS setting into .defaults
├── .ghostty/                  # Ghostty terminal (Nord theme, custom keybindings)
├── .ssh/config                # SSH configuration template
├── .ai/                       # AI CLI config (separate private repo,
│                              # cloned here by install.sh step 4)
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

## Terminal UI

`lib/ui.sh` is the installer's whole UI: the spinner, the ✓/−/✗ status lines,
the arrow-key menus, the retry/skip/abort recovery, and the summary table that
sets the exit code. It's one self-contained file in pure bash 3.2 with no
libraries, so you can copy it into any project that runs a list of steps and
wants to report them honestly.

**[UI.md](UI.md)** is the full reference: quickstart, the step contract, every
function, configuration, and a worked example. Drop both files into a project
and point Claude at `UI.md`.

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
- **`agent-reach`** — internet access channels for AI CLIs
- **`claude-plugins`** — Claude Code plugins (needs a logged-in CLI)

It's all user-level (no sudo) and idempotent — re-run to update or add more.

The configuration itself lives in a separate private repo,
`cassmtnr/ai-config`, cloned to `.ai/` and gitignored here. Step 4 offers to
clone it and skips cleanly when it can't, so an install without access to it
still finishes. That repo's README covers the instructions file, skills,
Agent Reach channels and the plugin list.

**Migrating a machine that predates the split.** Pulling the split deletes the
tracked files under `.ai/` but leaves everything that was gitignored, so `.ai/`
stays behind holding no repo and step 4 tells you to move it aside. Run
`mv .ai .ai.bak`, then `./install.sh`. Afterwards copy back what only lived
there: `codex/config.toml`, and any skills the machine installed into
`common/skills/` as symlinks.

**Two ways this repo can empty the clone.** Git does not know `.ai/` holds
another repo, so ordinary operations here reach inside it.

- Any checkout that crosses the commit which untracked `.ai/` deletes those 26
  files from disk, because git still sees them as tracked files being removed.
  A `rebase` does it every time: it checks out the pre-split base first, then
  replays the split. So do `git checkout <pre-split-commit>`, `bisect`, and
  `reset --hard` backwards past it.
- `git clean -xfd` deletes the whole clone, because ignored files are what
  `-x` removes.

Neither loses anything, since `ai-config` holds it all. Recover the first with
`git -C ~/dotfiles/.ai restore .`, the second by re-running `./install.sh`.

**Safety hooks** — `block-dangerous-commands.js` blocks dangerous Bash commands via PreToolUse hooks at three levels (fails closed on malformed input):

- **Critical**: filesystem destruction, disk operations, fork bombs, git history rewriting
- **High** (default): git write ops, elevated privileges, secrets exposure, publishing/deployment, database ops
- **Strict**: cautionary patterns (`git checkout .`, `docker prune`)

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
