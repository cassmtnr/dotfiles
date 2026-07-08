# Project Log

## [2026-07-06] decision | Agent Reach integrated — public channels + Twitter + Instagram

Installed via pipx, wired into install.sh and symlinks. Scope chosen: all
public channels (web, Exa, YouTube, GitHub, RSS, V2EX, Bilibili full) plus
Twitter (guest search, no cookies) and Instagram (OpenCLI, Chrome extension
pending). Credentials stay in ~/.agent-reach/, never in the repo.

## [2026-07-06] review | Self-review of Agent Reach integration diff

Fixed: return 1 under set -e would have aborted install.sh on pipx failure.
Noted (not fixed, pre-existing): setup_nodejs/setup_bun/install_ai_tools have
the same return-1-under-set-e pattern.

## [2026-07-06] decision | Dropped Instagram channel, removed OpenCLI

Instagram required the OpenCLI Chrome extension driving the user's real
browser session — declined. Uninstalled @jackwener/opencli (npm), removed
~/.opencli, dropped instagram from install.sh channels. Twitter stays:
cookie-based, no browser needed at runtime.

## [2026-07-06] decision | Added Reddit (rdt-cli), trimmed skill to installed channels

Reddit via cookie-based rdt-cli (pinned commit from upstream docs) — not the
OpenCLI browser bridge. Skill files trimmed: removed XiaoHongShu, Facebook,
Instagram, Xueqiu, Xiaoyuzhou, LinkedIn (career.md deleted) and all OpenCLI
references. Trim markers left as HTML comments; an agent-reach upgrade may
regenerate upstream content — re-trim if so.

## [2026-07-06] fix | Skill translated to English; career.md must stay as stub

All agent-reach skill files translated from Chinese to English. Discovered:
`agent-reach doctor` recreates deleted skill files but preserves existing
ones — so career.md (LinkedIn, not installed) is kept as an English stub
instead of deleted.

## [2026-07-06] analysis | Evaluated ctx (stevesolun/ctx) — recommended against

ctx = dynamic skill/agent/MCP recommendation layer for Claude Code (79k-node
graph of 68k scraped community skills, PostToolUse/Stop hooks, 122-296MB
artifact, local dashboard). Rejected for this setup: (1) breaks determinism —
dotfiles would no longer describe what loads per session; (2) supply-chain
surface — auto-recommends unvetted scraped SKILL.md files; (3) Claude-only,
breaks .ai/common Claude+Codex parity; (4) ctx-init --hooks fights the
versioned settings.json symlink; (5) solves context bloat we don't have
(~10 curated skills). Discovery alternative: browse
stevesolun.github.io/ctx/catalog manually, vet, add by hand.

## [2026-07-06] decision | Extracted skill-lint from ctx analysis

Implemented .ai/common/scripts/skill-lint.sh (structural skill health: missing
frontmatter, dead relative links, uninstalled commands in code blocks), wired
into update.sh default run. The one ctx idea worth having locally; the
recommendation layer itself stays rejected. Regression-tested against a
deliberately broken skill. Skipped: usage-based rot tracking (needs a
per-tool-call hook; revisit if the skill count grows).

## [2026-07-06] review | Code review pass over the full Agent Reach change set

Reviewer agent + self-review, 7 findings, all fixed: awk fence/heredoc state
leaked across files in skill-lint.sh (FNR reset added, fence regex widened to
info strings); update.sh/README default-behavior texts missed the skill lint;
CHANGELOG overstated pipx upgrade-all (agent-reach only re-installs on
upstream version bumps); install.sh summary line and README scripts/ entry
were stale; log.md entries reordered to append-only chronological.

## [2026-07-06] fix | No-sudo mode + Claude plugin auth gate

Work-machine fixes: install.sh --no-sudo skips all admin-requiring steps
(audited: sudo -v welcome, Homebrew bootstrap, apt-get, /etc/shells, MOTD,
.defaults loginwindow write; killall Finder never needed sudo — dropped).
install_claude_plugins now gates on CLI auth (oauthAccount in ~/.claude.json)
and waits interactively instead of failing; deferred path: update.sh
--plugins. Live-testing surfaced that mapfile (bash 4+) broke the plugin
loop under macOS bash 3.2 — replaced with while-read; plugins had likely
never installed via script on stock macOS.

## [2026-07-07] fix | Platform-conditional sudo + return-1 trio fixed

Sudo is now decided by platform: Linux defaults to sudo, macOS to no-sudo
(work laptops just work); --sudo/--no-sudo override, .defaults standalone
defaults to no-sudo too. Fixed the TODO item: setup_nodejs/setup_bun/
install_ai_tools return-1-under-set-e no longer aborts the whole install
on guarded failures (missing NVM, failed Bun download).
