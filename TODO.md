# TODO

- `.utils.sh` symlink pairs reference `$DOTFILES_ROOT/.ai/common/commands`
  (→ `~/.claude/commands`, `~/.codex/prompts`), but that directory doesn't
  exist in the repo — every `install.sh`/`update.sh` run prints
  "Source file not found" twice. Either restore the commands directory or
  remove the two pairs. Noticed 2026-07-06 while wiring skill-lint into
  update.sh; left unfixed (unrelated to that change).

- `install.sh`: `setup_nodejs`, `setup_bun`, and `install_ai_tools` use
  `return 1` inside a `set -e` script — any of their guarded failures
  (e.g. nvm missing) aborts the entire install instead of continuing with a
  warning. `install_agent_reach` avoids the pattern deliberately. Pre-existing;
  noticed 2026-07-06 during the Agent Reach self-review.
