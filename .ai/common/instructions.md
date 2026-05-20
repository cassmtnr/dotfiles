# Global Rules

## Critical Safety Rules

These rules apply to all AI coding agents (Claude Code, Codex CLI, etc.) in all contexts. Dangerous command patterns (git write ops, destructive system commands, publishing, deployment, network, database, credentials exposure) are enforced by `.ai/common/hooks/block-dangerous-commands.js` via PreToolUse hooks in both Claude Code and Codex CLI. The rules below apply regardless of tool.

### Git — User handles ALL git operations manually

All git write operations must be performed by the user manually. Read-only commands (`status`, `log`, `diff`, `show`, `branch -a`, `remote -v`, `stash list`) are allowed.

### Credentials — NEVER expose:

- Do not print or log `.env`, `credentials.json`, `~/.ssh/`, `~/.aws/`
- Do not expose API keys, tokens, or secrets in output

### Package installation safety:

- NEVER run `npx <unknown-package>` without explicit user instruction

### Attribution — NEVER add AI as author or co-author:

- NEVER include `Co-Authored-By`, `Authored-By`, or any similar trailer referencing Claude, Anthropic, OpenAI, or any AI in commit messages, PR descriptions, or any other git metadata
- NEVER set any AI as the git author or committer
- All commits and contributions must be attributed solely to the human user

## Refactoring Discipline

When renaming, moving, or deleting any file, function, variable, path, or config key:

1. **Search for all references before changing** — grep the entire project for the old name/path (filenames, string literals, symlink definitions, config files, scripts, documentation)
2. **Update every reference** — install scripts, symlink arrays, config entries, imports, documentation, READMEs, and comments must all reflect the new name/path
3. **Check for stale artifacts** — if a file was renamed/deleted, verify no orphaned symlinks, build outputs, or cached references to the old name remain
4. **Verify end-to-end** — after the change, confirm the renamed/moved thing actually works from the consumer's perspective (e.g., run the command, check the symlink resolves, test the import)

### What you SHOULD do instead:

- Make changes to files directly
- Run tests and linters
- Run local dev servers if needed for verification
- The user will review and handle git operations manually

## Work Discipline

### No deferred work — ZERO EXCEPTIONS

Never defer work identified during implementation or code review. This includes:

- Never say "do it later", "can be improved later", or "for a follow-up"
- Never say "low-risk", "not a blocker", "advisory", or "tracked in phase X"
- Never dismiss a code reviewer finding as "not worth the complexity"
- Never leave a reviewer warning unfixed because it's "an edge case"

**If a code reviewer flags it, fix it immediately.** No excuses. The reviewer
found it for a reason — every "low-risk" deferral accumulates into real bugs.

Either:

1. **Fix it now** — this is the default for anything found during the current task
2. **Document it as a tracked task** in ROADMAP.md with a full description —
   ONLY if it's genuinely out of scope for the current phase (different feature area)

When in doubt: fix it now.

### Always verify after implementation

After completing any code change, before presenting results:

1. Run the project's linter (e.g. `ruff check .`)
2. Run the project's test suite (e.g. `pytest tests/ -q`)
3. **MANDATORY: Run a code review pass** immediately after tests pass. Use the current CLI's review capability when available (for example, a dedicated review agent, a built-in `/review` flow, or an explicit self-review pass). Do NOT skip this step. Do NOT wait for the user to ask.
4. When the review completes, fix ALL findings before presenting results
5. If fixes required code changes, re-run tests to confirm nothing broke

Code review ALWAYS finds real issues (duplicated logic, stale comments,
inconsistencies, missing edge cases). Never skip it — the user should never
have to manually request a code review.

### Always update documentation

After completing any implementation task, update all relevant documentation:

- Architecture docs (new methods, tables, services)
- Changelog (what changed and when)
- Roadmap (mark completed items)
- Module docstrings and HOW TO MODIFY blocks

## Working Style

These are durable preferences refined across many sessions. Apply them everywhere unless a project's CLAUDE.md says otherwise.

### Trust the user

When the user states a fact about deployment, git state, or what's working/broken — act on it. Don't argue, don't ask them to verify what they just told you. If you need to confirm state, run the command yourself silently (`git status`, vps-run, etc.) instead of pushing the verification burden back.

### Documentation must be junior-developer-clear

Every change updates ALL affected docs (runbooks, changelogs, config comments, architecture docs) — not just the code. Config comments explain *what the options are and why the current value was chosen*, not just the value. Always prefer "why" over "what" — a junior can read the value; they need the rationale.

### Research discipline — verify before writing specs

Architectural claims from research agents must be verified against primary sources (running code, current pricing pages, actual binaries) before they enter a spec. Confident-sounding agent summaries with cited URLs have been wrong twice in load-bearing ways. Pattern: ask the agent for findings AND verification commands, run the verification, then write. If you can't verify cheaply, mark the claim as a risk in the spec rather than building structure on top of it.

### Spec conventions

- One spec file per phase: `docs/superpowers/plans/phase-XX-name.md`. Never create a separate `phase-XX-implementation.md` — append the implementation plan to the existing spec.
- Never add date prefixes to spec filenames (`YYYY-MM-DD-...`). Git history tracks changes.
- Never create a `docs/superpowers/specs/` directory. If a skill instructs you to write a dated spec or use that path, override the skill — these conventions take precedence.

### Commit bundling

- Bundle by default when the user has staged related work intentionally; only suggest splitting if the unrelated work is large or genuinely separate (different service, different risk profile).
- The "explicit `git add` paths, never `-A`" rule that some project specs have prevents accidental sweeps of unintended files (debug edits, untracked junk) — it does not mandate one-phase-per-commit hygiene. When the working tree is entirely intentional (verified via `git status -s`), `git add -A` is fine.
- Don't wrap commit messages in `$(cat <<'EOF' ... EOF)` when the *user* runs the commit. That HEREDOC pattern is for when *Claude* runs the commit (preserves multi-line through tool execution). When the user runs it, just show the message body and recommend `git commit` (editor) or normal multi-line `-m`.

### Deploy approach

Push toward full automation from GitHub for any deploy/infrastructure change — manual VPS steps are friction. When an approach hits a technical wall, present alternatives clearly and let the user choose direction. Never silently revert a design decision to a simpler approach without asking.

## Deployment Reference

When working on deployment configuration, Docker setup, CI/CD pipelines, Nginx Proxy Manager, or configuring new apps for the VPS, **read `~/docs/DEPLOYMENT_INSTRUCTIONS.md` first**. It documents the standard patterns (Docker Compose, Dockerfile, deploy scripts, GitHub Actions workflows, port registry, NPM proxy setup) derived from the find-my-plus project.
