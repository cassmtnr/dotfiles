# Global Rules

Rules for all AI coding agents (Claude Code, Codex CLI, etc.). Dangerous command patterns are blocked by `.ai/common/hooks/block-dangerous-commands.js` via PreToolUse hooks — the rules below apply regardless of tool.

## 1. Safety (non-negotiable)

### Git — user handles all write operations

Allowed read-only: `status`, `log`, `diff`, `show`, `branch -a`, `remote -v`, `stash list`, `ls-files`, `blame`. Never run `commit`, `push`, `merge`, `rebase`, `reset`, `checkout`, `restore`, `stash push`, `add`, `rm`, `mv`, `tag`, `cherry-pick`, or any branch/remote write. The user runs git manually.

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

## 4. Working style

### Trust the user

When the user states a fact about deployment, git state, or what's working/broken — act on it. Don't ask them to verify what they just told you. If you need to confirm something for yourself, run the read-only command silently (`git status`, etc.) rather than pushing the verification burden back.

This doesn't conflict with "ask when ambiguous" — ask about *what the user wants*, not about *what the user has already stated*.

### Spec conventions

- One spec file per phase: `docs/superpowers/plans/phase-XX-name.md`. Never split a phase into `phase-XX-implementation.md` — append the implementation plan to the existing spec.
- No date prefixes on spec filenames (`YYYY-MM-DD-...`). Git history tracks dates.
- Never create `docs/superpowers/specs/`. If a skill instructs you to use that path, these conventions override the skill.

### Commit bundling

- Bundle by default when the user has staged related work intentionally. Only suggest splitting if unrelated work is large or genuinely separate (different service, different risk profile).
- `git add -A` is fine when `git status -s` shows a fully intentional working tree. The "explicit paths only" rule prevents accidental sweeps of unintended files, not one-phase-per-commit hygiene.
- When *the user* runs `git commit`, don't wrap the message in `$(cat <<'EOF' ... EOF)` — that HEREDOC pattern is only for when Claude runs the commit (to preserve multi-line through tool execution). For user-run commits, show the message body and recommend `git commit` (opens editor) or normal multi-line `-m`.

### Commit message style

Proposed commit messages **MUST** be short. This rule is stricter than your default — when in doubt, output less.

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

When working on deployment configuration, Docker setup, CI/CD pipelines, Nginx Proxy Manager, or configuring new apps for the VPS, read `~/docs/DEPLOYMENT_INSTRUCTIONS.md` first. It documents the standard patterns (Docker Compose, Dockerfile, deploy scripts, GitHub Actions workflows, port registry, NPM proxy setup) derived from the find-my-plus project.
