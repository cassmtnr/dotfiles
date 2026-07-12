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

## [2026-07-10] fix | Trackpad corner right-click + defaults-diff.sh

Root cause of "always re-set secondary click on new machines": .defaults
wrote only the old Bluetooth-trackpad domain; built-in trackpads read
com.apple.AppleMultitouchTrackpad. Added those keys with values captured
from this hand-configured machine (CornerSecondaryClick=2, RightClick=false).
New defaults-diff.sh (repo root) diffs all preference domains around a manual
Settings change to capture any future setting into .defaults. Noticed, not
changed: .defaults sets tap-to-click true but this machine's built-in
trackpad has Clicking=0 — same missing-domain class; confirm preference
before fixing.

## [2026-07-11] decision | defaults-sync.sh — managed-keys sync, not wholesale import

User asked to update .defaults from the machine's full current config.
Wholesale defaults read rejected: tens of thousands of keys mixing app
state, machine identifiers, and churn (public repo). Built defaults-sync.sh
instead: compares the 72 scalar keys .defaults manages against the machine,
--fix adopts machine values (templated $HOME values compared expanded,
never rewritten). First run found 6 drifted keys incl. trackpad corner
click reading two-finger today despite reading corner-click yesterday —
machine-side change, not applied to the file pending user confirmation.

## [2026-07-11] fix | Corner-click key set corrected from a live defaults-diff capture

User re-set the trackpad in System Settings while running defaults-diff.sh —
the capture showed corner mode writes TrackpadRightClick=false in BOTH
trackpad domains and enableSecondaryClick=FALSE per-host; .defaults had
true for both (pre-existing, likely why the setting half-applied for years).
All six trackpad keys corrected; defaults-sync now reports zero trackpad
drift. Remaining drift (awaiting user): Finder ShowMountedServersOnDesktop
(machine=true), ActivityMonitor ShowCategory (machine=100).

## [2026-07-12] decision | Replaced defaults-diff/sync pair with capture-setting.sh

User disliked the two-tool workflow (raw diff reading, drift decisions).
Single replacement: capture-setting.sh — snapshot, user flips one setting,
snapshot; noise-filtered (domain + key blocklists, scalar-only, >12-changes
guard) and ready-made defaults-write lines auto-appended to .defaults before
the kill-apps section. Tested end-to-end with a simulated change: 1 line
detected, zero noise. Old scripts deleted; the two open drift keys resolved
by adopting machine values (ShowMountedServersOnDesktop=true,
ShowCategory=100).

## [2026-07-12] review | capture-setting.sh review — 4 findings, all fixed

Self-review caught the critical one: heredoc consumed stdin so input() never
waited for the user (test had passed only by racing the snapshot) — now reads
/dev/tty. Reviewer agent added: (1) unquoted keys/values in emitted lines
break bash on quotes/$ — fixed with shlex.quote; (2) key deletions were
invisible ("no change detected" false negative) — now reported as info;
(3) a domain export failing in one snapshot pass fabricated changes — failed
domains now excluded from the diff. All verified in one pty regression run
(tricky-string write + key delete). Usage documented in README.

## [2026-07-12] ingest | Finder view options captured into .defaults

From the user's ⌘J panel: FXPreferredViewStyle=icnv (always icon view),
ShowRecentTags=false, and the "Use as Defaults" icon-view template
(StandardViewSettings:IconViewSettings — nested dict, so PlistBuddy
Set-then-Add instead of defaults write; values read from this machine:
iconSize 64, gridSpacing 54, textSize 12, arrangeBy name, labelOnBottom,
showItemInfo, showIconPreview). Verified live against the real plist.
Not capturable: per-folder overrides (.DS_Store). Already covered:
Show Library Folder (chflags nohidden line 171).

## [2026-07-13] review | Pre-commit review of capture/Finder changeset — 5 findings fixed

Reviewer agent, all fixed: (1) emitted defaults-write lines didn't quote the
DOMAIN — a spaced domain (com.raspberrypi.Raspberry Pi Imager exists on this
machine) would poison .defaults and abort install.sh; shlex.quote added.
(2) PlistBuddy Add fallback typed gridSpacing/iconSize/textSize as integer
while Finder stores real — wrong type exactly on fresh machines; changed to
real. (3) CHANGELOG understated the trackpad fix (flipped values, not just
missing domain). (4) "four keys" comment vs six lines. (5) Pre-existing:
.defaults killall loop exits 1 on not-running apps, aborting install.sh
under set -e — || true added.

## [2026-07-13] fix | agent-reach upgrade clobbered the trimmed skill — safeguard added

The documented risk fired: after pipx upgrade-all pulled a newer agent-reach,
its installer overwrote all 7 trimmed English skill files with upstream's
Chinese 15-platform versions (older version preserved existing files; new one
doesn't). Safeguard: install_agent_reach() now git-checkouts the skill dir
after channel installs when it differs from HEAD. User restores this
occurrence manually (git restore). Also fixed: set_default_shell chsh'd from
/bin/zsh to brew zsh and failed ("non-standard shell") — any zsh now counts.
