# Global Rules

## Critical Safety Rules

These rules apply directly to Claude Code and any AI agent in all contexts. Dangerous command patterns (git write ops, destructive system commands, publishing, deployment, network, database, credentials exposure) are enforced by `.claude/hooks/block-dangerous-commands.js`. The rules below cover what the hook cannot enforce programmatically.

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

## Deployment Reference

When working on deployment configuration, Docker setup, CI/CD pipelines, Nginx Proxy Manager, or configuring new apps for the VPS, **read `~/docs/DEPLOYMENT_INSTRUCTIONS.md` first**. It documents the standard patterns (Docker Compose, Dockerfile, deploy scripts, GitHub Actions workflows, port registry, NPM proxy setup) derived from the find-my-plus project.

