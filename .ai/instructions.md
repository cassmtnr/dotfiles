# Global Rules

## Critical Safety Rules

These rules apply directly to Claude Code and any AI agent in all contexts. Dangerous command patterns (git write ops, destructive system commands, publishing, deployment, network, database, credentials exposure) are enforced by `.ai/hooks/block-dangerous-commands.js`. The rules below cover what the hook cannot enforce programmatically.

### Git — User handles ALL git operations manually

All git write operations are blocked by the hook. Read-only commands (`status`, `log`, `diff`, `show`, `branch -a`, `remote -v`, `stash list`) are allowed.

### Credentials — NEVER expose:

- Do not print or log `.env`, `credentials.json`, `~/.ssh/`, `~/.aws/`
- Do not expose API keys, tokens, or secrets in output

### Package installation safety:

- NEVER run `npx <unknown-package>` without explicit user instruction

### Attribution — NEVER add Claude as author or co-author:

- NEVER include `Co-Authored-By`, `Authored-By`, or any similar trailer referencing Claude, Anthropic, or any AI in commit messages, PR descriptions, or any other git metadata
- NEVER set Claude as the git author or committer
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
3. **MANDATORY: Spawn the code-reviewer agent** (run_in_background=true) immediately
   after tests pass. Do NOT skip this step. Do NOT wait for the user to ask.
   Launch it in the background while continuing with documentation updates.
4. When the reviewer completes, fix ALL findings before presenting results
5. If fixes required code changes, re-run tests to confirm nothing broke

The code reviewer ALWAYS finds real issues (duplicated logic, stale comments,
inconsistencies, missing edge cases). Never skip it — the user should never
have to manually request a code review.

### Always update documentation

After completing any implementation task, update all relevant documentation:

- Architecture docs (new methods, tables, services)
- Changelog (what changed and when)
- Roadmap (mark completed items)
- Module docstrings and HOW TO MODIFY blocks

## AI CLI Configuration — Dotfiles Convention

All AI CLI global configuration lives in `~/dotfiles/.ai/` (version-controlled)
and is symlinked to `~/.claude/` and `~/.codex/`. When adding, modifying, or removing
any AI CLI settings, commands, skills, hooks, or config files:

1. **Always edit in `~/dotfiles/.ai/`** — never edit directly in `~/.claude/` or `~/.codex/`
2. **Run `./update.sh`** to refresh symlinks after any structural changes
3. **Current symlink structure:**
   - `~/.claude/CLAUDE.md` → `~/dotfiles/.ai/instructions.md`
   - `~/.claude/settings.json` → `~/dotfiles/.ai/claude/settings.json`
   - `~/.claude/commands/` → `~/dotfiles/.ai/commands/`
   - `~/.claude/skills/` → `~/dotfiles/.ai/skills/`
   - `~/.claude/config/` → `~/dotfiles/.ai/claude/config/`
   - `~/.claude/hooks/` → `~/dotfiles/.ai/hooks/`
   - `~/.codex/prompts/` → `~/dotfiles/.ai/commands/`
   - `~/.codex/skills/` → `~/dotfiles/.ai/skills/`
   - `~/.codex/hooks/` → `~/dotfiles/.ai/hooks/`
   - `~/.codex/config.toml` → `~/dotfiles/.ai/codex/config.toml`
   - `~/.codex/hooks.json` → `~/dotfiles/.ai/codex/hooks.json`

This ensures all customizations are version-controlled and portable across machines.

## Deployment Reference

When working on deployment configuration, Docker setup, CI/CD pipelines, Nginx Proxy Manager, or configuring new apps for the VPS, **read `~/docs/DEPLOYMENT_INSTRUCTIONS.md` first**. It documents the standard patterns (Docker Compose, Dockerfile, deploy scripts, GitHub Actions workflows, port registry, NPM proxy setup) derived from the find-my-plus project.
