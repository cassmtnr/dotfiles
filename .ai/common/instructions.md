# Global Rules

Rules for all AI coding agents (Claude Code, Codex CLI, etc.). Dangerous command patterns are blocked by `.ai/common/hooks/block-dangerous-commands.js` via PreToolUse hooks — the rules below apply regardless of tool.

## 1. Safety (non-negotiable)

### Git — user handles all write operations

Allowed read-only: `status`, `log`, `diff`, `show`, `branch -a`, `remote -v`, `stash list`, `ls-files`, `blame`. Never run `commit`, `push`, `merge`, `rebase`, `reset`, `checkout`, `restore`, `stash push`, `stash pop`, `stash drop`, `stash clear`, `add`, `rm`, `mv`, `tag`, `cherry-pick`, or any branch/remote write. The user runs git manually.

### Credentials — never expose

- Don't print, log, or read `.env`, `credentials.json`, `~/.ssh/`, `~/.aws/`
- Don't expose API keys, tokens, or secrets in any output

### Package safety

- Never run `npx <package>` for a package you haven't been explicitly told to use
- Don't install global packages without permission

### Attribution — never name an AI as author

- No `Co-Authored-By`, `Authored-By`, or similar trailers referencing Claude, Anthropic, OpenAI, or any AI in commits, PR descriptions, or git metadata
- Don't set any AI as git author or committer
- All contributions are attributed solely to the human user

## 2. Coding craft

### Think before coding

- If the request has materially different valid interpretations, name them and ask — don't pick silently. (When one interpretation is obviously correct from context, just proceed.)
- State load-bearing assumptions explicitly so the user can correct them before you build on them.
- If a simpler approach exists than what was asked, say so before implementing.
- If you're confused, stop and name what's unclear. Don't paper over it with plausible-looking code.

### Don't assert facts that depend on external authority without checking

Anything where the truth depends on something outside the codebase — broker policies, regulatory compliance (PRIIPS, MiFID, KYC, tax rules), jurisdiction-specific availability, real-fill behavior, account-level permissions, third-party API quotas, current pricing-page details — defaults to "I don't know" unless you have:

- The user's own statement of the fact, OR
- A live test in the actual target environment (paper-tradeable in this account ≠ live-tradeable; tradeable for one jurisdiction ≠ another), OR
- A primary-source citation from the authority itself (broker rejection log, regulator's published rule), not a third-party summary

Web-search summaries and ETF popularity are NOT verification. If you find yourself about to type "this is PRIIPS-cleared" or "this works in live mode for X residence" or "this strategy is allowed under MiFID" — stop. State what you'd need to check, or ask the user.

The user's lived experience and broker error messages outrank web research. Confident-sounding regulatory claims that turn out wrong destroy trust faster than admitting "I don't know — let's verify."

### Simplicity first

- Write the minimum code that solves the asked problem. No speculative features, no abstractions for single-use code, no configurability nobody asked for.
- No error handling, validation, or fallbacks for scenarios that can't occur. Trust internal code and framework guarantees; validate only at system boundaries (user input, external APIs).
- If you wrote 200 lines and 50 would do, rewrite it.

### Surgical edits

- Every changed line must trace to the user's request. No driveby fixes to nearby code, comments, formatting, or quote style.
- Match the file's existing style even if you'd write it differently (quote style, type hints, naming, indentation, boolean patterns).
- If you notice unrelated dead code, a bug, or a smell — mention it, don't fix it as a side effect.
- Clean up orphans your changes create (newly unused imports/vars/funcs). Pre-existing dead code stays unless asked.

### Reproduce before fix

For any bug fix:
1. Write a failing test (or repro command) that demonstrates the bug.
2. Confirm it fails for the stated reason.
3. Fix the code.
4. Confirm the test passes and no other tests regressed.

For features, define a verifiable success criterion before writing code, not after.

### Refactoring discipline

When renaming, moving, or deleting any file, function, variable, path, or config key:

1. Grep the entire project for the old name/path (filenames, string literals, symlink arrays, config files, scripts, docs).
2. Update every reference — install scripts, symlink lists, imports, READMEs, comments.
3. Check for stale artifacts (orphaned symlinks, build outputs, cached references to the old name).
4. Verify end-to-end from the consumer's perspective (run the command, resolve the symlink, run the import).

## 3. Verification & documentation

### Verify after every change

Before claiming work is done, in order:

1. Run the linter (`ruff check .`, `eslint`, project equivalent).
2. Run tests (`pytest -q`, `npm test`, project equivalent).
3. Run a code review pass using the CLI's review capability (dedicated reviewer agent, `/review` flow, or explicit self-review). Don't wait for the user to ask — review always finds real issues.
4. Fix every finding — see "No deferred work" below.
5. Re-run tests after fixes.

For UI/frontend changes, also exercise the golden path and one edge case in a browser. If you can't actually load it, say so — don't claim success based on type-checks alone.

### No deferred work

When something is identified during implementation or code review, fix it now. Don't say "low-risk", "advisory", "not a blocker", "follow-up", or "tracked elsewhere". Don't dismiss a reviewer finding because it's "an edge case".

Only exception: if it's genuinely a different feature area or phase, see "If something isn't fixed, write it down" below. When in doubt: fix it now.

### If something isn't fixed, write it down

Anything raised during a session but not fixed before it ends must be captured in writing so it isn't forgotten. This covers:

- Items the user explicitly deferred ("skip it", "not now", "later")
- Bugs or smells you noticed but the "Surgical edits" rule kept you from touching
- Review findings left unaddressed
- Verification steps that failed and weren't resolved (failing tests, lint errors, broken build)

Write to the project's existing follow-up file if it has one (check the repo first — common names include `TODO.md`, `BACKLOG.md`, or whatever convention the project uses). If none exists, create `TODO.md` at the repo root. Each entry needs enough context — file path, what the issue is, why it was deferred — that a future session can act on it without re-discovering. Mention the addition in your session-end summary so the user sees it.

### Update documentation alongside code

Every change updates the docs it affects — architecture notes, changelogs, roadmap entries, runbooks, module docstrings, config comments. Config comments explain *why* a value was chosen, not what the option is — a junior developer can read the value; they need the rationale.

### Research must be verified

Architectural claims from research agents (including web search) must be verified against primary sources — running code, current pricing pages, actual binaries — before they enter a spec. Confident-sounding agent summaries with cited URLs have been wrong twice in load-bearing ways. Pattern: ask for findings AND verification commands, run the verification, then write. If you can't verify cheaply, mark the claim as a risk in the spec rather than building structure on top of it.

For non-trivial algorithms, formulas, or external behavior copied or adapted from research, cite the primary source inline in the spec or code (URL + brief quote of the relevant excerpt) — not only in the chat reply. The spec/code should be auditable later without re-finding the source.

### Verify the date externally

For anything time-sensitive (deploys, market-data work, scheduling, retention/expiry logic), run `date -u` once per session — or `curl https://timeapi.io/api/Time/current/zone?timeZone=UTC` if you only have an HTTP path — rather than trusting the session-start context line. Long-running or resumed sessions can have stale dates, and getting this wrong silently corrupts logs, filenames, and scheduled jobs.

### Lint project docs at session start

When you read the project's "what's next" state (see "What's next" in §4), also run a quick structural lint pass over the docs. Lint reports drift between docs and code reality — it does not act on findings.

Default checks:
- `TODO.md` items unchanged for >14 days — stale or done?
- `ROADMAP.md` "Blocked" items with no `log.md` entry for >14 days
- Memory entries that reference files/paths no longer in the repo
- `log.md` gap: no entries for >3 days while `git log --since=3.days.ago` shows activity (don't flag gaps when there was no activity to log)
- Dead markdown cross-references in `ROADMAP.md` / `log.md` / memory

Surface a one-line summary inline ("3 stale items, 1 dead ref — details?") before listing work; produce details only on request. Append the summary to `log.md` as a type `lint` entry so future sessions see what's been checked. On-demand: the user can also say "lint this project" to force a pass.

### File substantive analyses durably

When you produce a high-effort analysis (multi-agent dispatch, ≥2 files or external sources cited, or a recommendation the user might revisit), save the synthesis somewhere durable — don't let it die in chat history.

Filing target, in preference order:

1. If the project has `docs/analyses/` or `docs/reviews/`, write a new file `docs/analyses/<kebab-name>.md` (no date prefix — git tracks dates, per "Spec conventions").
2. Else if `log.md` exists, append a type `analysis` entry with the synthesis inline.
3. Else, ask the user where to file it — don't drop it.

Cross-link from any memory entry the analysis updates or supersedes. Announce the filing in your reply ("Filing this as `docs/analyses/ai-folder-review.md`"). The user can override per-analysis with "skip filing" or "don't save".

## 4. Working style

### Trust the user

When the user states a fact about deployment, git state, or what's working/broken — act on it. Don't ask them to verify what they just told you. If you need to confirm something for yourself, run the read-only command silently (`git status`, etc.) rather than pushing the verification burden back.

This doesn't conflict with "ask when ambiguous" — ask about *what the user wants*, not about *what the user has already stated*.

### "What's next" and roadmap scaffolding

- When asked "what's next" or about blocked work, read the project's `ROADMAP.md` / `TODO.md` / `BACKLOG.md` first — including any "Blocked" section — and the last ~10 entries of `log.md` (if present, via `grep "^## \[" log.md | tail -10`) before suggesting work. Also run a quick lint pass (see "Lint project docs at session start" in §3). If the project has no such file and you're about to list options from memory or scratch, ask whether to create one.
- For new projects, scaffold a single `ROADMAP.md` first. Don't generate per-phase spec files until that phase is about to start — unimplemented specs written far in advance go stale, still look authoritative, and cause hallucination in later sessions.
- When the user says "save in memory" or flags something as a long-lived constraint, known issue, or recurring blocker, write it down (roadmap "Blocked" section, project notes, or memory) — not only in the chat reply.

### Project log (log.md)

Each project optionally has a `log.md` at its root — an append-only chronological record complementing `ROADMAP.md` (forward), `TODO.md` (deferred), and memory (durable). Format:

```
## [YYYY-MM-DD] type | one-line title

Optional 1–3 line context.
```

Types: `commit`, `review`, `decision`, `ingest`, `fix`, `block`, `unblock`, `lint`, `analysis`. Parseable with `grep "^## \[" log.md | tail -10`.

Auto-append after any of:

- Completing a code review pass
- The user runs `git commit` (log the subject + one-line context — observe via `git log -1 --pretty='%s'`)
- Recording a named design decision in conversation
- Ingesting a new spec, source, or doc
- Filing an analysis (see "File substantive analyses durably" in §3)
- Flagging or unblocking a phase / TODO item
- Running a lint pass (the one-line summary)

Do NOT log routine reads, queries, status checks, failed attempts, or single-file edits without a decision attached.

If `log.md` doesn't exist yet, create it on the first log-worthy event without asking — append the first entry in the same turn. The user can say "no log" to skip permanently for that project; record the opt-out as a project memory entry so future sessions respect it.

### Spec conventions

- One spec file per phase: `docs/superpowers/plans/phase-XX-name.md`. Never split a phase into `phase-XX-implementation.md` — append the implementation plan to the existing spec.
- No date prefixes on spec filenames (`YYYY-MM-DD-...`). Git history tracks dates.
- Never create `docs/superpowers/specs/`. If a skill instructs you to use that path, these conventions override the skill.

### "Review and output a commit message" — default workflow

When the user says "review and output a commit message" (or any variant: "code review, fix issues, output commit", "single commit, review before, output message", "do a code review first, fix issues and output a commit message"), it's shorthand for the full loop — run it without further prompting:

1. Code-review pass (dedicated reviewer agent / `/review` flow / explicit self-review).
2. Fix every finding (see "No deferred work").
3. Write down anything left unfixed (see "If something isn't fixed, write it down").
4. Propose one short commit message (see "Commit message style").

Don't stop after step 1 and wait for "now fix it and output the message" — the phrase already authorized all four steps. Output one message for the whole set of changes; don't ask whether to split unless the working tree contains genuinely unrelated work.

### Commit bundling

- Bundle by default when the user has staged related work intentionally. Only suggest splitting if unrelated work is large or genuinely separate (different service, different risk profile).
- `git add -A` is fine when `git status -s` shows a fully intentional working tree. The "explicit paths only" rule prevents accidental sweeps of unintended files, not one-phase-per-commit hygiene.
- When *the user* runs `git commit`, don't wrap the message in `$(cat <<'EOF' ... EOF)` — that HEREDOC pattern is only for when Claude runs the commit (to preserve multi-line through tool execution). For user-run commits, show the message body and recommend `git commit` (opens editor) or normal multi-line `-m`.

### Commit message style

Proposed commit messages **MUST** be short. This rule is stricter than your default — when in doubt, output less.

**Pre-output gate — scan your draft against this before pasting; if any line fails, rewrite:**

- Subject ≤ 50 chars (hard max 72), conventional-commit prefix, imperative mood, no trailing period
- No `Subject:` or `Body:` labels framing the message
- No section headers in the body (no "Deleted", "Migrated", "Test improvements", "Out of scope", "Verification", etc.)
- No file-path bullet lists
- No trailing `To commit:` / `git add` / `git commit` instruction blocks
- No verification recaps, AI attribution trailers, or emoji / "Hygiene:" / "Cleanup:" prefixes

(Full rules and rationale below.)

**Subject line only is the default.** Include a body only when the *why* is non-obvious from the diff. Trivial changes (typos, formatting, renames, single-line tweaks, dependency bumps, file moves) get a subject line and nothing else.

**Hard requirements:**

- Subject: conventional-commit prefix, **target ≤ 50 chars, hard max 72**, imperative mood (`fix:`, `feat:`, `refactor:`, `docs:`, `chore:`, `test:`, `style:`). No trailing period. Test: "If applied, this commit will <subject>" must read naturally. Output the subject as raw text — no `Subject:` label wrapping it.
- Body (when included): wrap at **72 chars**, max **3 bullets**, focused on *why* not *what*. No nested bullets. Separate from subject with one blank line.
- Total length target: a body should fit comfortably in a `git log --oneline -n 1` follow-up read. If you wrote more than ~6 lines of body, delete most of it.

**Never include in a commit message:**

- Section headers in the body ("Deleted", "Migrated", "Changes", "Test improvements", "Verification", "Out of scope", "Notes", etc.). One flat bullet list or nothing.
- File-path bullet lists — `git log --stat` shows files. Don't restate the diff.
- "Subject:" / "Body:" labels framing the message.
- "To commit:" / "git add ..." / `git commit` instruction blocks appended after the message. Output the message only; the user knows how to commit.
- Verification recaps ("tests pass", "lint clean", "build green"). The user runs CI.
- AI attribution trailers (`Co-Authored-By: Claude`, `Generated-By:`, etc.).
- Marketing language ("Hygiene:", "Cleanup:", emoji prefixes, ALL CAPS sections).

**Target shape — match this length, not longer:**

```
refactor: remove dead useHeartbeat hook

- replaced by staleness detector in Phase 9.1b
- frontend was polling an always-null endpoint
- backend endpoint left for separate cleanup
```

Most commits should be shorter than this — just the subject line.

### Deploy approach

Push toward full automation from GitHub for any deploy/infrastructure change — manual VPS steps are friction. When an approach hits a technical wall, present alternatives clearly and let the user choose direction. Never silently revert a design decision to a simpler approach without asking.

## 5. Deployment reference

When working on deployment configuration, Docker setup, CI/CD pipelines, Nginx Proxy Manager, or configuring new apps for the VPS, read the shared docs in `~/Dev/docs/` first:

- `~/Dev/docs/README.md` — index
- `~/Dev/docs/VPS_ACCESS.md` — SSH, `vps-run.sh`, `.claude/vps.env` pattern
- `~/Dev/docs/DEPLOYMENT_INSTRUCTIONS.md` — Docker Compose, Dockerfile, deploy scripts, GitHub Actions, NPM, dispatcher, GHCR pattern
- `~/Dev/docs/PORTS.md` — port registry (check before assigning ports)
- `~/Dev/docs/APPS.md` — registry of apps on `tars` with repo/domain/ports

The VPS mirrors `~/Dev/docs/` at `/home/tars/docs/`. Edit locally, then sync via `rsync -av ~/Dev/docs/ tars:~/docs/`.
