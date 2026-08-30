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

## [2026-07-13] review | Full repo overhaul — 3 parallel audits, 15 bugs/doc-drifts fixed

Three reviewer agents (scripts, docs-vs-reality, AI tree). Fixed: ssh-agent
leak (36 running; exit-code 1-vs-2 confusion — one agent per shell), RSS
skill needed uninstalled feedparser (→ stdlib), 4 more set-e abort paths
(HOMEBREW_PREFIX unset, empty extensions.txt + BRE blank-line bug, MOTD read
non-interactive, set_default_shell without zsh), setup_bun never syncing
packages when bun preexists, .gitignore missing .ssh/config.work (public-repo
leak footgun), stale commands symlink pairs, README drift (codex config.toml
ghosts, wrong plugin list, counts, structure), CHANGELOG missing Removed
notes, extension-sync comment contradicting behavior. Deferred nits recorded
in TODO.md. Verified: bash 3.2 + zsh syntax across all scripts, update.sh
end-to-end zero warnings, skill lint clean, ssh-agent leak regression-tested
(3 shells → 1 agent).

## [2026-07-13] fix | Install failures: brew off PATH, cask conflict, set -e abort in .defaults

Work machine hit `brew: command not found`; this machine hit the
claude-code cask binary conflict and a sandboxed com.apple.helpviewer
`defaults write` that aborted install.sh mid-run. New ensure_brew_path(),
one-time cask migration to claude-code@latest, .defaults now a subprocess
with an ERR-trap failure counter.

## [2026-07-13] review | Install-fixes changeset — 8-angle review, 7 findings fixed, 2 deferred to TODO.md

## [2026-07-13] decision | No brew-free fallbacks for work Mac — wait for brew

Work Mac (no admin) stays on plain zsh until Homebrew is available; declined
adding curl/git-clone installers for starship, zsh plugins, and nvm to
install.sh. Default-shell fix there: chsh -s /bin/zsh (no admin needed).

## [2026-07-13] fix | Cleared the two review deferrals: Screenshots mkdir + source_nvm --no-use

Both TODO.md entries from today's review fixed and removed. source_nvm abort
reproduced with a fake $HOME before fixing. New instructions.md rule: fix
findings right away when feasible instead of filing them to TODO.md.

## [2026-07-13] review | Final pre-commit review of install-fixes changeset — 10 findings fixed

8-angle review of the full working tree. Highlights: guarded the Homebrew and
Oh My Zsh remote installers (empty-script false success + set -e abort),
broken-brew-on-PATH detection, nvm default-alias fallback, .zshenv unset-prefix
PATH leak, cask migration via dir test (0.7s/run saved).

## [2026-07-13] decision | Modular three-step setup: one repo, plain bash, no manager

Rework on branch `rework`. Researched holman/webpro/omakub layouts,
chezmoi/dotbot/stow, and user-level installs (Linuxbrew bootstrap needs
elevated rights — verified against Homebrew's installer source). Chose:
single repo, lib/ step split, packages/ tier brewfiles, pure-bash menus,
flags-first for SSH. Spec: docs/superpowers/plans/phase-01-modular-setup.md

## [2026-07-13] analysis | Dotfiles state-of-the-art research filed in phase-01 spec

Findings and citations embedded in the design doc (Decisions section) rather
than a separate analyses file — they are load-bearing for the rework.

## [2026-07-13] review | Two-lens review of the rework — 12 findings, all fixed

Correctness lens (empirically verified): update.sh -p tier escalation → tier
now recorded in ~/.config/dotfiles-tier; choose_one EOF infinite loop; real-
directory symlink nesting (found live on this Mac: ~/.config/ghostty had been
mis-linked for months — targeted migration added, self-heals); choose_many /
plugin-prompt EOF; agent-reach PATH. Parity lens: exact package parity
confirmed, no lost functionality; 6 doc/contract fixes (sudo-vs-extras
wording, update.sh claims, .defaults comment, CI shellcheck scope). Re-
verified after fixes: shellcheck clean, macOS full run, tars basic run +
idempotence, update.sh.

## [2026-07-14] decision | Arrow-key checkbox menu (choose_many) — pure bash

Replaced the numbered-toggle menu with arrow-key navigation (↑/↓/j/k, space,
a=all, enter, q/Esc). Researched frameworks: gum/fzf need bootstrap,
whiptail/dialog absent on stock macOS — pure bash is the only fit for the
zero-dep + bash-3.2 + fresh-machine constraint. Canonical multiselect.miu.io
has three 3.2 breakers (namerefs, fractional read -t, ESC[6n query) — avoided
all three. Verified via pty (macOS `script`): toggle, arrows, wrap, toggle-all,
cancel, empty-confirm, terminal restore, set-e safety. Interactive core can't
be unit-tested without a real TTY — inherent to zero-dep TUI.

## [2026-07-14] review | Overhaul: removed sandbox, dead-code sweep, doc sync

Removed the sandbox/ feature. Two-agent audit (correctness/dead-code + docs).
No dead functions (all traced to callers). Fixes: .zshrc claude() wrapper
swallowed claude's exit code; unguarded nvm use/alias could abort the install
under set -e before config ran; aligned a BSD-incompatible `grep '\|'` to -Ev.
Consolidated the churny CHANGELOG [Unreleased] sub-sections
(tiers/Bun/sandbox/standalone-ai added-then-reversed) into one coherent entry.
Synced README (4 steps, tree, AI menu). index.html fetches README from `main`
— correct (live default branch). TODO.md pruned (dropped the fixed claude()
item and the obsolete rm -rf migration nit).

## [2026-07-14] decision | No-admin Homebrew installs to ~/.homebrew (untar)

Cassiano wants Homebrew installable without admin (work Mac). install_homebrew:
admin → official installer (bottles); no-admin → untar into ~/.homebrew
(user-level, source builds, no bottles). ensure_brew_path + .zshenv detect the
new prefix. Kept the fast official path where admin exists (Linux servers keep
bottles). Verified: untar fetches a working brew, prefix detection finds
~/.homebrew when standard prefixes absent. Tradeoff (source builds) is inherent
to any non-standard prefix per Homebrew docs.

## [2026-07-14] decision | AI is opt-in step 4 of install.sh; step drivers renamed

Cassiano's call: fold AI back into install.sh as a 4th checkbox step
(install_ai_tools: claude-code/agent-reach/claude-plugins) instead of a
standalone ./lib/ai.sh — but still opt-in (nothing pre-selected, non-TTY
skips), so plain installs stay AI-free. lib/ai.sh is now a sourced module.
Renamed drivers: start_installation, start_configuration, install_extras,
install_ai_tools. Verified: shellcheck clean, non-TTY install installs no AI.

## [2026-07-13] decision | Removed Bun — redundant with Node+pnpm

Nothing depended on it: globals (yarn/ts/eslint/nodemon) were installable via
npm, playwright-install kept its npx fallback. Dropped setup_bun, .bun,
.zshrc source line, .gitignore bun.lock, README tree entry. Left the vscodium
lockfile-nesting rule (generic editor UX, not a bun install).

## [2026-07-13] decision | Dry core + AI split into lib/ai.sh; tiers collapsed

Cassiano's call: keep one repo but separate concerns. Regular ./install.sh
installs NO AI (Claude/Codex/agent-reach/plugins) — all moved to standalone
lib/ai.sh. Tier system removed: packages/{basic,standard,full} → single
.brewfile (Linux cask-filter still gives CLI-only on a VPS). update.sh -P and
tier logic dropped. Verified: shellcheck clean, macOS regular-install (no AI
symlinks) + lib/ai.sh, tars regular-install (no AI) + lib/ai.sh (npm path).
phase-01 spec marked partially superseded.

## [2026-07-13] decision | install.sh has no flags — menus only

Cassiano's call: "the user always have to be guessing what exists." All
selection flags removed (--tier/--extras/--yes/--sudo/--no-sudo); a TTY gets
the tier menu, one admin y/N question, and the extras checkboxes; no TTY
gets safe defaults (basic, no extras). Verified on tars + audited all 21
managed configs are live symlinks into ~/dotfiles (app changes land in the
repo — the ghostty nesting bug was the one violation, now auto-migrated).

## [2026-07-22] decision | Installer UI via vendored gum binaries

Plan filed: docs/superpowers/plans/phase-02-ui-layer.md. Gum v0.17.0
vendored in bin/ (darwin-arm64 + linux-x86_64) so the UI needs no bootstrap;
lib/ui.sh wrapper, run_step retry/skip/abort, quiet-by-default with --verbose.
Note: partially reverses the 2026-07-13 "no flags" decision (adds --verbose).

## [2026-07-22] decision | Inline Claude login for plugins (B) + finish-later hint (D)

setup_claude_plugins wait-loop replaced: ensure_claude_auth offers `claude
auth login` in-terminal (CLI owns the TTY); skips set CLAUDE_PLUGINS_PENDING
so post_install prints the finish command. Auth probe now `claude auth
status` via grep (its JSON has trailing escape bytes that break jq).
Phase-02 plan Task 5 updated to match.

## [2026-07-22] fix | TODO closeout — extract() archives, PATH order, cc alias

All three TODO.md nits resolved: extract() .rar/.7z now via 7zz (sevenzip
added to .brewfile, verified end-to-end), /usr/local/bin moved behind brew
in .zshenv, cc-shadows-compiler accepted and documented (user does no C).
TODO.md is now empty.

## [2026-07-22] decision | Removed extract() — unused

Deleted from .functions with its sevenzip dependency (added earlier today
for the .rar/.7z fix, now moot). Simplification direction.

## [2026-08-03] review | Phase-02 gum installer UI — 3-agent pass, findings fixed

Implemented phase-02 (vendored gum, lib/ui.sh, run_step retry/skip/abort,
--verbose). Review agents found: menu cancel fell back to retry
(uninterruptible loop) → cancel now aborts; ui_summary || true hid failures
from CI → failed steps exit nonzero; failure output was deleted before the
retry menu → temp file kept, path printed; stale CHANGELOG/README claims
annotated; dead ui_spin deleted. Interactive acceptance + tars run pending.

## [2026-08-03] unblock | Phase-02 tars verification passed pre-push

Working tree tar-piped to a throwaway dir on tars (live checkout untouched):
vendored gum-linux-x86_64 resolved, non-interactive contract held, install.sh
ran twice idempotently (exit 0), update.sh clean. Remaining: user commit +
interactive visual acceptance on the Mac.

## [2026-08-10] decision | Gum reverted — pure-bash UI kept

Interactive acceptance verdict: gum's menus look near-identical to the
existing bash menu — not worth ~30 MB of vendored binaries. Removed bin/
and all gum branches from lib/ui.sh before anything was committed (the
repo never carries the binaries). Kept: ui.sh step runner (retry/skip/
abort, summary, --verbose, exit codes), failure-signaling step functions,
menu copy, CI contract test. Supersedes the 2026-07-22 "vendored gum"
decision.

## [2026-08-10] fix | AI hooks "node: not found" — link nvm default node into ~/.local/bin

Hooks run under /bin/sh, which never loads nvm, so every node hook failed —
including block-dangerous-commands.js (the git/credentials safety net) on
each Bash call. ai_symlinks now links a shim (.ai/common/scripts/
node-default.sh) as ~/.local/bin/node that resolves nvm's default alias at
call time, falling back to the newest installed version. No-op without nvm.

## [2026-08-10] review | node-for-hooks fix — 3 findings, all fixed

Versioned symlink would go stale after node upgrades (→ runtime-resolving
shim), .zshenv (N) dropped ~/.local/bin from PATH on fresh machines
(→ unconditional entry), no cleanup path for a link into ~/.nvm (→ link
targets the repo, orphan loop can manage it). Testing the shim exposed that
`nvm which` hangs on uninstalled alias targets — avoided entirely.

## [2026-08-21] decision | vendor stop-slop + humanizer prose skills

Both live in .ai/common/skills/, so Claude and Codex share one rule set.
humanizer ships upstream as a Claude plugin; vendored its portable SKILL.md
instead and dropped the plugin, trading manual version bumps for Codex parity.
instructions.md makes stop-slop unconditional and scopes humanizer to text the
user supplied.

## [2026-08-22] review | installer step-runner review, 9 fixes applied

Two independent passes over the staged UI refactor. Worst finding: --verbose
piped each step into tee, subshelling it, so exported env (brew shellenv) was
lost and Node silently skipped while reporting ✓. Also: run_step swallowed all
21 ui_skip reasons, skill-lint's advisory exit 1 became a blocking retry menu,
and exec zsh -l discarded the run's exit status. CI contract assertions were
no-ops under errexit; rewritten and negative-tested against injected
regressions. One reported finding withdrawn: the `|| cols=80` in choose_many
guards errexit under pipefail, it is not dead code.

## [2026-08-23] fix | animate running steps, sharpen failure output

install.sh looked hung on a multi-minute brew bundle: quiet mode drew a static
"… label" and captured all output. Added a background spinner echoing the
capture file's tail, so progress (and any prompt waiting for input) is visible.
Failure lines now carry the exit code and an indented, ruled excerpt.

## [2026-08-23] fix | plugin step installs only what is missing

Real install failed the plugin step with all five plugins already working:
the official marketplace answered "not found" for frontend-design and
superpowers while both sit in its own listing (stale cache), and
shortcuts-playground ships a manifest the CLI rejects (userConfig key).
setup_claude_plugins now skips anything already in installed_plugins.json.

## [2026-08-23] decision | ui.sh reworked into a drop-in library, UI.md written

Dropped the separate-repo + brew-tap plan: install.sh runs before anything is
installed, so a brew dependency is a bootstrap cycle. Instead ui.sh is now
self-contained (owns its colours, private _ui_log/_ui_warn, NO_COLOR support)
and UI.md documents it standalone. run_step keeps its unprefixed name by
request; the collision risk is documented rather than renamed. Spec:
docs/superpowers/plans/phase-02-ui-layer.md

## [2026-08-23] review | ui.sh overhaul against library conventions

Six defects fixed. Worst: printf '%b' interpreted backslashes in caller text,
so a label containing C:\new\table emitted a real newline and tab. Also:
re-sourcing wiped recorded steps, ui_summary clobbered UI_SKIPPED, glyphs were
mojibake outside UTF-8, ui_choose accepted zero options. Namespaced the state
to _UI_*, added ui_run_step as canonical with run_step kept as an alias (no
call-site churn), dropped eval, deduped width detection. The CI contract caught
the STEP_STATUS rename, which is what it is for.

## [2026-08-23] review | post-overhaul review of ui.sh, 3 defects

Worst: mktemp -t ui-step works on BSD but GNU rejects a template with no X's,
so every step would have failed on Linux and in CI. Introduced by the overhaul,
caught before shipping. Also removed a dead _ui_log helper and documented
ui_reset, which had shipped as undocumented public API. 16-point regression
battery green; the 47 "stale reference" hits are all historical documents.

## [2026-08-23] fix | palette table, stale-spec banners, untracked-skill note

Colour definitions were duplicated across both branches of the NO_COLOR check:
adding a colour needed two edits and missing one left a var unset under set -u.
One name:sgr table drives both paths now. Left the old API names in CHANGELOG,
log.md and phase-01/02 alone (they are records) but banner-ed both specs to
point at UI.md. Documented that obsidian-second-brain is gitignored by size.

## [2026-08-23] review | whole-repo review, 7 defects fixed

Worst: Ctrl-C orphaned the spinner (async children ignore SIGINT in a
non-interactive shell) so it kept redrawing over the user's prompt after
install.sh died; it now watches its parent with kill -0. Also: successful steps
deleted their warnings including an SSH-lockout one, xcode-select's expected
exit 1 became a futile retry loop, post_install claimed success on failure,
parse_args ignored every argument after the first, and privilege prompts inside
a captured step were invisible. Corrected my own earlier claim that
xcode-select exits 0 — that test piped through head and read head's status.

## [2026-08-23] decision | gum plan removed, phase-02 record rewritten

Deleted the 757-line phase-02 gum spec: its headline feature was reverted
uncommitted and its listings for the shipped parts are five revisions stale.
Replaced with phase-02-ui-layer.md, a short record of what shipped
and why gum was dropped. Log entries about the gum decision and its reversal
stay — they are the record, and the reversal prevents a repeat.

## [2026-08-23] decision | one plan file for the UI layer, not three

phase-02 (gum) deleted, phase-03 (library extraction) deleted, replaced by
phase-02-ui-layer.md. phase-03 was three days old and already wrong on four
counts because it duplicated API detail UI.md owns. The merged file records the
arc and the binding decisions and lists no functions or variables, so nothing in
it can drift. UI.md is the API reference; CHANGELOG carries the change record.

## [2026-08-26] ingest | phase-03 spec + plan: .ai to a private repo

Design agreed: cassmtnr/ai-config (private), cloned to dotfiles/.ai and
gitignored there, so all eleven symlink targets in lib/ai.sh stay put. Chosen
over a submodule, which would cost a two-repo commit for every skill edit.
Spec and six-task plan in docs/superpowers/plans/phase-03-ai-config-repo.md.

## [2026-08-30] decision | .ai extracted to private cassmtnr/ai-config

Nested gitignored clone at dotfiles/.ai, so every symlink target in
lib/ai.sh stayed put. install.sh step 4 offers the clone; update.sh
fast-forwards it.

## [2026-08-30] analysis | rebase empties the nested .ai checkout

Diagnosed from the reflog after .ai/ lost all 26 tracked files. A rebase checks
out the pre-split base, then replays the commit that untracked them, and git
deletes them because it still sees them as tracked files being removed.
Recovery is `git -C ~/dotfiles/.ai restore .`; nothing is lost. The same rebase
left candidate-analysis/references/prep-template.html tracked in the public
repo, because the untracking commit records paths and not a rule. Both written
into the phase-03 spec Risks section and both READMEs.

## [2026-08-30] fix | CI green again, .ai step can no longer fail an update

Closed two of the three TODO items. The three shellcheck findings were all
deliberate code and took disable comments; set_default_shell now skips without
a TTY instead of reporting chsh's missing prompt as a failure. update_ai_repo
skips on a dirty worktree or a failed pull, so an optional repo cannot turn a
daily update red. Remaining: the from-scratch Linux run, which needs the server
replacing tars.

## [2026-08-30] fix | sudo prompts moved out from under the step spinner

Reported from a real Ubuntu install: "Extra: motd" sat at 90s, then failed
three password attempts on input the user could not see. run_step writes step
output to a file and paints a spinner on the terminal, while sudo prompts
straight to /dev/tty, so the prompt was repainted every 100ms. Both sudo extras
carried a comment describing this exact hazard, sitting above a call inside the
step it warned about. The step-3 loop moved to install_extras in lib/extras.sh,
which authenticates before run_step; extra_needs_sudo declares who needs it. A
CI contract step pins the ordering, the skip-on-refusal, and label agreement.

## [2026-08-30] fix | harden ~/.ssh configs, decouple the CLI from .ai

Same Ubuntu install, next failure: the ai-config clone died on "Bad owner or
permissions on ~/.ssh/config.local". The file was a hand-written local one at
664 under a umask-002 shell, and create_symlinks only chmods the repo copies,
so it never touched what ssh actually reads. One refused include breaks every
ssh call on the box, and the step still went green. Now the loop covers
~/.ssh/config* too and warns when a chmod fails.

That clone failure also cost the Claude CLI, because install_ai_tools returned
early on a missing .ai/. Reversed a phase-03 decision: install_ai_clis needs
nothing from .ai/, so only the steps that read it (symlinks, agent-reach,
plugins, skill lint) skip now. Both changes have tests that fail against HEAD.

## [2026-08-30] fix | IgnoreUnknown UseKeychain, so Linux can read the config

Third failure in the same chain on tars, found over vps-run. After the 664 fix,
ssh still died: `Bad configuration option: usekeychain`. UseKeychain is Apple's
patch, and portable OpenSSH terminates on an unknown keyword rather than
warning, so a Mac-authored config.local breaks every ssh call on a server.
IgnoreUnknown now precedes the Include; verified with a control on the box.
CI gained `ssh -F .ssh/config -G github.com` on ubuntu, since the file is
shared and this class of bug is invisible on macOS.

Not a repo problem, recorded for the next machine: the tars key is registered
on GitHub (fingerprints match) but is passphrase-protected, and the persistent
agent had no identities, so `ssh-add ~/.ssh/github` is a per-machine step.

## [2026-08-30] fix | nvm's default bin on PATH, so npm -g binaries exist

Fourth failure in the tars chain. Step 4 reported "✓ Claude Code CLI" and
`claude` was still not found. npm -g installs into nvm's default-version bin,
and `nvm current` is "system" on both platforms even after .zshrc sources
nvm.sh, so that directory never joined PATH. node only worked because ai.sh
shims it into ~/.local/bin; every other global was invisible. .zshenv now
appends the bin, resolving the alias with one file read rather than an
`nvm use`. Appended, not prepended, so brew still wins on the Mac. Verified on
both machines. CI asserts it after install; a local test covers the alias
forms, an uninstalled version, and no nvm at all.

## [2026-08-30] fix | the ssh agent never loaded any key, on any machine

Chasing why tars needed a manual ssh-add found two defects in .ssh-agent, both
long-standing. add_ssh_keys named ~/.ssh/personal/github and
~/.ssh/work/gitlab, paths from an old layout that exist nowhere, so it loaded
nothing everywhere. And start_ssh_agent only called it when `ssh-add -l` exited
2 (no agent); exit 1 means the agent is up and empty, the normal state after a
reboot, and that branch did nothing. Keys are now discovered by having a .pub
beside them, and both agent states load them. Test covers both states and
asserts config/known_hosts/agent.env/.pub are never offered; it fails against
the committed version. Verified against tars' real ~/.ssh over vps-run.

Decision: the tars key drops its passphrase. It has to work unattended for
cron and boot-time pulls, and a passphrase that a human types once per boot
does not survive the case it exists for. File mode 600 plus host access is the
posture; reversible with `ssh-keygen -p`.

## [2026-08-30] fix | ssh config rejected whole-file by OpenSSH before 9.8

The CI step added earlier the same day failed on its first run. The
`Match ... exec "test -S \"$HOME/...\""` lines use a backslash-escaped quote
inside a quoted token, which OpenSSH before 9.8 does not accept: it split the
macOS socket path on the space in "Group Containers" and terminated on the
whole file. Replaced with a `?` glob over the space, so no nested quotes remain
and the shell still gets one path. Quoting it would have stopped $HOME
expanding and killed 1Password detection on macOS; both local machines run
10.5 and parsed the old form fine, so only CI could have caught this.

## [2026-08-30] lint | phase-03 verification narrowed to one untested function

CI now runs install.sh twice on ubuntu and macOS and both pass. On a clean
checkout it genuinely installs apt deps, Oh My Zsh, the full brewfile and Node
via NVM. Combined with ensure_ai_repo's real clone on tars, the only path never
executed anywhere is install_homebrew's Linux bootstrap: both runners and tars
ship Homebrew preinstalled. TODO.md narrowed to exactly that.
