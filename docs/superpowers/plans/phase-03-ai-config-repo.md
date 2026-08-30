# Phase 03 — Extracting `.ai/` into a private repo

**Status: shipped.** Design agreed 2026-08-26; all six tasks in the
implementation plan below are done.

## Why

`.ai/` holds the instructions, skills, hooks and settings that Claude Code and
Codex load on every machine. It carries personal working rules and machine
notes that do not belong in a public repo, but `dotfiles` is public and stays
public. Splitting the two lets the AI configuration go private without hiding
the shell, editor and macOS setup that the public repo exists to show.

## Shape

A private repo, `cassmtnr/ai-config`, is cloned into `dotfiles/.ai`. The outer
repo ignores that path, so git sees an ignored directory rather than an
embedded gitlink, and the inner repo behaves like any other checkout.

The path does not move. All eleven `link` calls in `lib/ai.sh` keep their
targets unchanged, `skill-lint.sh` still resolves its skills directory relative
to its own location, and no script inside `.ai/` refers to `$DOTFILES_ROOT`.
That property is what makes the nested clone cheaper than every alternative.

## The new repo

It receives the 26 files currently tracked under `.ai/`, unchanged, as one
initial commit. History stays behind in `dotfiles`, where `git log -- .ai/`
still reads it.

It needs its own `.gitignore` first, reproducing the AI stanzas from the
dotfiles ignore file with the `.ai/` prefix stripped:

```
.DS_Store
codex/config.toml
common/skills/*
!common/skills/agent-reach
!common/skills/candidate-analysis
!common/skills/markdown-to-html
!common/skills/stop-slop
!common/skills/humanizer
common/hooks/block-dangerous-commands
```

Write it before the first `git add`. The whitelist is the only thing keeping
193 MB of installed skills under `common/skills/` out of the commit.

Its README takes over the `.ai` detail that `README.md` carries today: the
`common`/`claude`/`codex` split, the agent-reach channel list and its manual
cookie logins, the plugin list, and the prose skills.

## Changes in dotfiles

**`.gitignore`.** The "AI files" block and the skills whitelist collapse to a
single `/.ai/`.

**`lib/ai.sh`.** Two edits. The agent-reach restore at lines 156-157 runs
against the inner repo, so `git -C "$DOTFILES_ROOT"` becomes
`git -C "$DOTFILES_ROOT/.ai"` and the pathspec drops its `.ai/` prefix. A new
`ensure_ai_repo` runs first inside `install_ai_tools`: when `.ai/` is absent it
offers `git clone git@github.com:cassmtnr/ai-config.git .ai` through
`ui_confirm`. When the directory is still missing it returns nonzero, and
`install_ai_tools` calls `ui_skip` and returns 0 so the install stays green.

**`update.sh`.** One step after the symlink step runs
`git -C "$DOTFILES_ROOT/.ai" pull --ff-only`, skipping without comment when
`.ai/.git` is not there.

**`README.md`.** Lines 116, 198-200, 204 and 212-219 shrink to a pointer at the
private repo. The detail they hold moves to the new README.

## Decisions

**Nested ignored clone, not a submodule.** A submodule would pin an exact
version and keep the path identical too, but every edit to a skill or an
instruction becomes a commit in two repos, submodule checkouts land detached,
and `git clone --recursive` of the public repo fails for anyone without access
to the private one. The configuration changes several times a week, so the
ceremony would be paid constantly and the pinning is worth little.

**A subtree was rejected outright.** It copies the private content back into
the public repo, which is the thing this phase exists to prevent.

**Fresh history.** `git subtree split --prefix=.ai` would carry real `git blame`
across, at the cost of an extra step during a cutover that touches two repos at
once. The old history stays readable in `dotfiles`.

**A missing `.ai/` skips all of step 4.** When the clone is declined or fails,
the step prints one message and stops rather than running in a degraded mode.
Partial operation would need branching in `ai_symlinks`, in
`setup_claude_plugins` (which reads `.ai/claude/settings.json`), and around the
agent-reach restore, all to serve someone who can install the Claude CLI with
one brew command.

**`config/mcporter.json` stays in dotfiles.** It holds a public Exa URL and no
credentials, and `lib/ai.sh` already links it from `config/` rather than `.ai/`.

## Cutover

The git writes belong to the user. Order matters: untrack before initialising,
and write the inner `.gitignore` before staging anything.

```
# 1. dotfiles: untrack .ai, keep the files on disk
git rm -r --cached .ai
#    edit .gitignore -> /.ai/ ; commit

# 2. the new repo, .gitignore first
cd .ai && git init -b main
#    write .gitignore and README, then:
git add -A && git status --short      # expect ~26 files, not 12k
git commit -m "init: AI CLI configuration"
gh repo create cassmtnr/ai-config --private --source=. --push

# 3. dotfiles: lib/ai.sh, update.sh, README ; commit
```

## Verification

Shellcheck the two changed shell files with the static binary in the session
scratchpad. Then run the three cases against a throwaway `HOME` on this Mac.
tars was shut down during this phase and its replacement is not up yet, so the
Linux from-scratch run moves to that server.

Three cases have to pass. With `.ai/` present, `ai_symlinks` links twice
without warning and `readlink $HOME/.claude/CLAUDE.md` resolves to a real file.
With `.ai/` absent and no TTY, `install_ai_tools` never reaches
`ensure_ai_repo`: `ui_choose_many` selects nothing without a TTY, so its
empty-selection guard returns first. Called directly, `ensure_ai_repo` also
doesn't hang on a prompt: `ui_confirm` takes its `y` default without a TTY and
reaches a real clone attempt instead of declining. `update_ai_repo`
fast-forwards when the clone is there and `ui_skip`s with status 0 when it is
not.

What this does not cover: a from-scratch `./install.sh` on a machine with
nothing preinstalled, and `ensure_ai_repo` actually performing a clone. Both
wait for the new server.

## Risks

Any checkout in `dotfiles` that crosses the commit untracking `.ai/` deletes
those 26 files from the nested checkout. Git still sees them as tracked files
being removed and has no idea another repo owns the path. This is the risk that
actually fired: a `rebase` starts by checking out the pre-split base, then
replays the split, so it empties `.ai/` every time. `git checkout` of a
pre-split commit, `bisect` and a backwards `reset --hard` do the same. Recovery
is `git -C ~/dotfiles/.ai restore .`, and nothing is lost because `ai-config`
holds it all. This was missed at design time, when only the `clean` case below
was written down.

`git clean -xfd` inside `dotfiles` deletes the `.ai` clone, because ignored
files are what `-x` removes. Nothing in the repo's scripts runs it; the README
pointer should say so anyway.

A file added under `.ai/` between the split commit being written and it being
replayed stays tracked in `dotfiles`, because `git rm` records paths rather
than a rule. `.ai/common/skills/candidate-analysis/references/prep-template.html`
did exactly that during the rebase, which left one AI-config file public and a
fresh clone materialising a non-empty `.ai/` that `ensure_ai_repo`'s own guard
then refuses. `git ls-files .ai` must return 0 after any rebase touching this
phase.

`.ai/common/instructions.md` line 3 cites the hook as
`.ai/common/hooks/block-dangerous-commands.js`, which reads correctly from
`dotfiles` and wrongly from the new repo root. Fix it during the move.

---

# Implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use
> `superpowers:subagent-driven-development` (recommended) or
> `superpowers:executing-plans` to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move `.ai/` out of the public dotfiles repo into a private
`cassmtnr/ai-config`, cloned back to `dotfiles/.ai` and ignored there, with
every symlink target unchanged.

**Architecture:** A nested, gitignored clone. `install.sh` step 4 gains a
prerequisite check that offers the clone; `update.sh` gains a fast-forward
step; `lib/ai.sh` gains one corrected `git -C` path. Nothing else in the
installer moves.

**Tech Stack:** bash, git, `gh`, the `lib/ui.sh` step runner.

**Spec:** the sections above this line, same file.

## Global constraints

- **bash 3.2 is the floor.** macOS ships it. No `mapfile`, no associative
  arrays, no `${var,,}`.
- **No new dependencies.** `git` and `gh` are already required by the repo.
- **shellcheck must stay clean.** CI runs
  `shellcheck install.sh update.sh lib/*.sh .defaults capture-setting.sh`.
  There is no system shellcheck on this machine; fetch the static binary
  into the session scratchpad once and reuse it:

  ```bash
  SC=$SCRATCHPAD/shellcheck-v0.10.0/shellcheck
  curl -sL https://github.com/koalaman/shellcheck/releases/download/v0.10.0/shellcheck-v0.10.0.darwin.aarch64.tar.xz \
    | tar xJ -C "$SCRATCHPAD"
  ```

  Steps below write `"$SC"` for that binary.
- **The `run_step` contract, from `UI.md`.** A missing prerequisite calls
  `ui_skip` and returns 0. A nonzero return means a real failure, because
  retry is what the user is offered. Writing this backwards is the most
  common mistake in this repo.
- **Cassiano runs every git write.** Tasks 1 and 2 are handoffs: print the
  commands, stop, and wait. Do not run `git rm`, `git init`, `git commit`,
  `git push` or `gh repo create` yourself.
- **Commit subjects: conventional prefix, 50 characters, imperative, no
  attribution trailer.**

---

### Task 1: Seed the private repo

Handoff task. Produce the two files, verify the staging count, then stop.

**Files:**
- Create: `.ai/.gitignore`
- Create: `.ai/README.md`
- Modify: `.ai/common/instructions.md:3`

**Interfaces:**
- Produces: the repo `git@github.com:cassmtnr/ai-config.git`, whose root
  contains `common/`, `claude/`, `codex/`. Tasks 3 and 4 clone from this URL.

- [ ] **Step 1: Write `.ai/.gitignore` before anything else**

The whitelist below is the only thing keeping 193 MB of installed skills out
of the initial commit. Write it first.

```
.DS_Store
codex/config.toml

# Skills: ignore everything (work machine installs skills here via symlinks),
# whitelist only the skills that belong to this repo
common/skills/*
!common/skills/agent-reach
!common/skills/candidate-analysis
!common/skills/markdown-to-html
!common/skills/stop-slop
!common/skills/humanizer

# Symlink from the work machine
common/hooks/block-dangerous-commands
```

- [ ] **Step 2: Prove the ignore file works before committing anything**

Run: `cd .ai && git init -b main && git ls-files --others --exclude-standard | wc -l`
Expected: a number near 28 (26 tracked files plus the new `.gitignore` and
`README.md`). `ls-files --others --exclude-standard` lists exactly what
staging would pick up while honouring the ignore file, and it writes nothing.
Four figures means the whitelist is wrong — fix it before
going further, because a 193 MB blob cannot be removed from a pushed repo
without a history rewrite.

- [ ] **Step 3: Fix the self-reference in `instructions.md`**

Line 3 cites the hook by its dotfiles path, which is wrong from this repo's
root. Change `.ai/common/hooks/block-dangerous-commands.js` to
`common/hooks/block-dangerous-commands.js`.

- [ ] **Step 4: Write `.ai/README.md`**

It takes over the detail that Task 5 removes from the dotfiles README. Move,
do not rewrite, these four passages from `README.md`:

1. The `common` / `claude` / `codex` split (currently lines 198-200).
2. **Agent Reach** — the channel list, the trimmed-skill restore, and the
   manual Twitter and Reddit cookie logins (line 204).
3. **Plugins** — the enabled list and `claude plugin update` (line 212).
4. **Not in this repo** (`obsidian-second-brain`) and **Prose skills**
   (lines 214-219).

Add one paragraph at the top: this repo is cloned to `dotfiles/.ai` by
`./install.sh` step 4, and it is consumed only through the symlinks in
`dotfiles/lib/ai.sh`.

- [ ] **Step 5: Hand off to Cassiano**

Print these and stop. Do not run them.

```bash
cd .ai
git add -A && git status --short   # expect ~28 files, not 12k
git commit -m "init: AI CLI configuration"
gh repo create cassmtnr/ai-config --private --source=. --push
```

- [ ] **Step 6: Confirm the push landed**

Run: `gh repo view cassmtnr/ai-config --json isPrivate,name`
Expected: `{"isPrivate":true,"name":"ai-config"}`. Task 2 must not start
before this passes, because it deletes the only other copy's tracking.

---

### Task 2: Untrack `.ai` in dotfiles

Handoff task. Prepare the `.gitignore` edit, then stop.

**Files:**
- Modify: `.gitignore:53-68` (the "AI files" block)

**Interfaces:**
- Consumes: the pushed repo from Task 1.
- Produces: a dotfiles working tree where `.ai/` exists on disk, is ignored,
  and is tracked by nobody.

- [ ] **Step 1: Replace the AI block in `.gitignore`**

Delete the whole "AI files" section, from the `# AI files #` banner through
`.ai/common/hooks/block-dangerous-commands`, and put this in its place:

```
# AI files #
############
# .ai/ is a separate private repo (cassmtnr/ai-config) cloned in place by
# ./install.sh step 4. Ignored here, so `git clean -xfd` would delete it.
/.ai/
```

- [ ] **Step 2: Hand off to Cassiano**

Print these and stop. `--cached` is what keeps the files on disk.

```bash
git rm -r --cached .ai
git add .gitignore
git commit -m "chore: move AI config to private repo"
```

- [ ] **Step 3: Verify the split took**

Run: `git ls-files .ai | wc -l && git status --short && ls .ai/claude/settings.json`
Expected: `0`, a clean status, and the settings file still on disk. A
non-empty status here means `.gitignore` did not match; stop and fix it.

---

### Task 3: Teach `lib/ai.sh` about the separate repo

**Files:**
- Modify: `lib/ai.sh` (add `ensure_ai_repo` above `ai_symlinks`; fix the
  pathspec at lines 156-157; add the call site in `install_ai_tools`)

**Interfaces:**
- Produces: `ensure_ai_repo` — no arguments, returns 0 when `$DOTFILES_ROOT/.ai`
  exists or was cloned, 1 otherwise. Task 4 reuses `$AI_CONFIG_REPO`.

- [ ] **Step 1: Write the failing check**

Run: `bash -c 'source lib/common.sh; source lib/ai.sh; declare -F ensure_ai_repo'`
Expected: FAIL, no output, exit 1.

- [ ] **Step 2: Add `ensure_ai_repo` directly above `ai_symlinks`**

```bash
# The AI configuration is a separate private repo cloned in place at .ai/,
# which .gitignore keeps out of this one. Every link below points into it, so
# without it there is nothing for this step to do.
AI_CONFIG_REPO="git@github.com:cassmtnr/ai-config.git"

ensure_ai_repo() {
    [[ -d "$DOTFILES_ROOT/.ai" ]] && return 0

    log "AI configuration lives in a separate private repo."
    ui_confirm "Clone $AI_CONFIG_REPO into .ai now?" y || return 1

    git clone "$AI_CONFIG_REPO" "$DOTFILES_ROOT/.ai" || {
        warning "Clone failed — check your GitHub SSH access to cassmtnr/ai-config"
        return 1
    }
    success "AI config repo cloned"
}
```

- [ ] **Step 3: Verify it is defined and a no-op when `.ai/` exists**

Run: `bash -c 'source lib/common.sh; source lib/ui.sh; source lib/ai.sh; ensure_ai_repo && echo OK'`
Expected: `OK`, with no prompt and no clone, because `.ai/` is there.

- [ ] **Step 4: Call it in `install_ai_tools`**

It goes after the empty-selection guard and before the symlink step, outside
`run_step` — `ui_confirm` needs the terminal, which `run_step` captures.
Replace the comment line `# Config symlinks are the foundation any selected tool relies on`
and the `run_step` under it with:

```bash
    # Config symlinks are the foundation any selected tool relies on, and
    # they all point into .ai/ — a missing repo means there is no step to run
    if ! ensure_ai_repo; then
        ui_skip "AI config repo not available (see README: cassmtnr/ai-config)"
        return 0
    fi
    run_step "AI config symlinks (~/.claude, ~/.codex)" ai_symlinks
```

- [ ] **Step 5: Fix the agent-reach restore for the inner repo**

At lines 156-157 the restore still runs `git -C "$DOTFILES_ROOT"` against a
pathspec that dotfiles no longer tracks, so it silently stops restoring.
Change both calls:

```bash
    if ! git -C "$DOTFILES_ROOT/.ai" diff --quiet -- common/skills/agent-reach/ 2>/dev/null; then
        if git -C "$DOTFILES_ROOT/.ai" checkout -- common/skills/agent-reach/; then
```

- [ ] **Step 6: Prove the restore path resolves**

Run: `git -C .ai diff --quiet -- common/skills/agent-reach/ && echo CLEAN`
Expected: `CLEAN`. An error naming the pathspec means the prefix is still
wrong.

- [ ] **Step 7: shellcheck**

Run: `"$SC" install.sh update.sh lib/*.sh`
Expected: no output.

- [ ] **Step 8: Commit**

```bash
git add lib/ai.sh
git commit -m "feat: clone AI config repo in install step 4"
```

---

### Task 4: Fast-forward the clone from `update.sh`

**Files:**
- Modify: `lib/ai.sh` (add `update_ai_repo`)
- Modify: `update.sh:12-15` (source `lib/ai.sh`), `update.sh:main` (one step)

**Interfaces:**
- Consumes: `$AI_CONFIG_REPO` and the clone from Task 3.
- Produces: `update_ai_repo` — no arguments, `ui_skip` + 0 when `.ai/.git` is
  absent, otherwise the exit status of `git pull --ff-only`.

- [ ] **Step 1: Write the failing check**

Run: `bash -c 'source lib/common.sh; source lib/ai.sh; declare -F update_ai_repo'`
Expected: FAIL, exit 1.

- [ ] **Step 2: Add `update_ai_repo` below `ensure_ai_repo` in `lib/ai.sh`**

`--ff-only` on purpose: a diverged `.ai/` is a merge decision, and the step
runner's job is to surface that as a failed step, not to resolve it.

```bash
# Day-to-day refresh of the .ai clone. Skips rather than fails when the repo
# isn't there: on a machine that never ran step 4 this is not an error.
update_ai_repo() {
    if [[ ! -d "$DOTFILES_ROOT/.ai/.git" ]]; then
        ui_skip "AI config repo not cloned (./install.sh step 4)"
        return 0
    fi
    git -C "$DOTFILES_ROOT/.ai" pull --ff-only
}
```

- [ ] **Step 3: Source `lib/ai.sh` in `update.sh`**

Add after the `lib/configure.sh` line. Sourcing it is inert: the file only
defines functions and sets `CLAUDE_PLUGINS_PENDING`.

```bash
source "$DOTFILES_ROOT/lib/ai.sh"
```

- [ ] **Step 4: Add the step to `update.sh` main, after the symlink step**

```bash
    run_step "Symlink dotfiles into \$HOME"  create_symlinks
    run_step "AI config repo (.ai)"          update_ai_repo
    run_step "VSCodium extension sync"       sync_vscodium_extensions
```

- [ ] **Step 5: Run it**

Run: `./update.sh`
Expected: a ✓ on "AI config repo (.ai)" (or "Already up to date" under
`-v`), and a green summary. Then move `.ai` aside and prove the skip:

Run: `mv .ai ../ai-tmp && ./update.sh; mv ../ai-tmp .ai`
Expected: a dim − line reading "AI config repo not cloned", the run still
finishes green, and `.ai/` is back afterwards.

- [ ] **Step 6: shellcheck**

Run: `"$SC" install.sh update.sh lib/*.sh`
Expected: no output.

- [ ] **Step 7: Commit**

```bash
git add lib/ai.sh update.sh
git commit -m "feat: pull AI config repo in update.sh"
```

---

### Task 5: Trim the public README

**Files:**
- Modify: `README.md:116-127` (the `.ai/` subtree), `README.md:182-220`
  (the `## AI setup` section)

**Interfaces:**
- Consumes: `.ai/README.md` from Task 1, which must already hold the moved
  prose. Do not delete anything here that has not landed there.

- [ ] **Step 1: Collapse the `.ai/` subtree in Project Structure**

Replace the twelve lines from `├── .ai/` through `│       └── hooks.json`
with two:

```
├── .ai/                       # AI CLI config — separate private repo,
│                              # cloned here by install.sh step 4
```

- [ ] **Step 2: Cut the `## AI setup` section down to the pointer**

Keep the existing opening paragraph and its three bullets unchanged. Keep the
**Safety hooks** block: the three levels describe behaviour a reader of the
public repo still gets, and it names no path. Delete the four passages Task 1
moved. After the bullets and the "user-level (no sudo)" line, add:

```markdown
The configuration itself lives in a separate private repo,
`cassmtnr/ai-config`, cloned to `.ai/` and gitignored here. Step 4 offers to
clone it and skips cleanly when it can't, so an install without access to it
still finishes. That repo's README covers the instructions file, skills,
Agent Reach channels and the plugin list.

One caveat: `git clean -xfd` in this repo deletes the `.ai/` clone, because
ignored files are what `-x` removes.
```

- [ ] **Step 3: Check no dead references survive**

Run: `grep -n '\.ai/' README.md`
Expected: only the Project Structure lines from Step 1 and the pointer
paragraph. Any surviving `.ai/common/...` path describes a file the public
repo no longer ships.

- [ ] **Step 4: Commit**

```bash
git add README.md
git commit -m "docs: point README at private AI config repo"
```

---

### Task 6: Verify locally against a fake HOME

tars was shut down mid-phase and its replacement is not up yet, so the three
cases run on this Mac instead, against a throwaway `HOME`. That covers symlink
resolution and the skip path. It does not cover a from-scratch install on a
machine with nothing preinstalled, which moves to the new server.

**Files:**
- Modify: `README.md:116` (one style fix, below)
- Otherwise test only.

- [ ] **Step 1: Make the throwaway HOME**

```bash
FAKE=$SCRATCH/fake-home && rm -rf "$FAKE" && mkdir -p "$FAKE"
```

Every command below sets `HOME="$FAKE"` inline. Before running any of them,
prove the override works, because a leaked real `HOME` would rewrite the live
`~/.claude` symlinks:

```bash
HOME="$FAKE" bash -c 'echo "$HOME"'
```

Expected: the fake path, not `/Users/cassiano`.

- [ ] **Step 2: Case A, `.ai/` present, run twice**

```bash
HOME="$FAKE" bash -c 'source lib/common.sh; source lib/ui.sh; source lib/ai.sh; ai_symlinks; ai_symlinks'
readlink "$FAKE/.claude/CLAUDE.md" && test -f "$FAKE/.claude/CLAUDE.md" && echo RESOLVES
```

Expected: both passes report the same links with no warning, and the readlink
target ends `dotfiles/.ai/common/instructions.md` and exists. The second pass is
the idempotence check: `link()` replaces its own symlinks and must not start
warning "Target exists and is not a symlink".

- [ ] **Step 3: Case B, `.ai/` absent**

**Do not run this step on a machine that can reach GitHub over SSH.** With
`.ai` moved aside and no TTY, `ui_confirm` takes its `y` default and
`ensure_ai_repo` performs a real clone into `$DOTFILES_ROOT/.ai`. Overriding
`HOME` does not move `$DOTFILES_ROOT`, so the clone lands on the live path and
races the restoring `mv` below. It would also replace a working tree holding
193 MB of installed skills and work-machine symlinks that exist in no repo,
and a fresh clone cannot bring those back. Run this case only where outbound
SSH is blocked, or verify the same assertion by reading the function.

Move the clone aside and put it back in the same command, so an error cannot
strand this machine's live AI configuration:

```bash
mv .ai ../ai-aside && HOME="$FAKE" bash -c 'source lib/common.sh; source lib/ui.sh; source lib/ai.sh; ensure_ai_repo; echo "exit=$?"' < /dev/null; mv ../ai-aside .ai
```

Expected: `ensure_ai_repo` returns nonzero without prompting, because the clone
it attempts cannot reach GitHub. `ui_confirm` returns its `y` default without a
TTY, so this reaches a real `git clone` rather than declining; `< /dev/null`
only guarantees nothing hangs waiting for input. The guard against an unattended clone lives upstream, in
`install_ai_tools`: `ui_choose_many` selects nothing without a TTY, so that
caller never reaches `ensure_ai_repo` at all. Confirm `.ai` is back afterwards.

- [ ] **Step 4: Case C, `update_ai_repo` both ways**

```bash
HOME="$FAKE" bash -c 'source lib/common.sh; source lib/ui.sh; source lib/ai.sh; update_ai_repo; echo "exit=$?"'
mv .ai ../ai-aside && HOME="$FAKE" bash -c 'source lib/common.sh; source lib/ui.sh; source lib/ai.sh; update_ai_repo; echo "exit=$?"'; mv ../ai-aside .ai
```

Expected: with `.ai` present, up to date and `exit=0`; with it absent, the
`ui_skip` line and still `exit=0`, per the `run_step` contract.

- [ ] **Step 5: Fix the tree comment's em dash**

`README.md:116` reads `# AI CLI config — separate private repo,`. Every
neighbouring tree comment uses a parenthetical instead, so match them:

```
├── .ai/                       # AI CLI config (separate private repo,
│                              # cloned here by install.sh step 4)
```

Keep the `#` comment column where it is.

- [ ] **Step 6: Remove the throwaway HOME**

```bash
rm -rf "$FAKE"
```

- [ ] **Step 7: Record what local testing did not cover**

Append to `TODO.md`: phase-03 was verified against a fake `HOME` on macOS only.
A from-scratch `./install.sh` on a clean Linux machine, run twice for
idempotence, still needs doing on the server replacing tars, and that run is
also the first test of `ensure_ai_repo` offering its clone for real.

- [ ] **Step 8: Log it**

Append to `log.md`, with the date from `date -u`:

```
## [YYYY-MM-DD] decision | .ai extracted to private cassmtnr/ai-config

Nested gitignored clone at dotfiles/.ai, so every symlink target in
lib/ai.sh stayed put. install.sh step 4 offers the clone; update.sh
fast-forwards it.
```
