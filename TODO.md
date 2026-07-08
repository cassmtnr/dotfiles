# TODO

- `.utils.sh` symlink pairs reference `$DOTFILES_ROOT/.ai/common/commands`
  (→ `~/.claude/commands`, `~/.codex/prompts`), but that directory doesn't
  exist in the repo — every `install.sh`/`update.sh` run prints
  "Source file not found" twice. Either restore the commands directory or
  remove the two pairs. Noticed 2026-07-06 while wiring skill-lint into
  update.sh; left unfixed (unrelated to that change).
