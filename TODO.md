# TODO

Nits from the 2026-07-13 overhaul audit, deferred because they change
behavior you may prefer as-is:

- `.functions` `extract()` references `unrar`, `7z`, `uncompress` — none in
  `.brewfile` or any install path; those archive types fail
- `.aliases:89` `alias cc=` shadows the system C compiler in interactive shells
- `.zshrc` `claude()` wrapper's trailing `printf` always returns 0, discarding
  claude's real exit code
- `.zshenv` PATH puts `/usr/local/bin` ahead of Homebrew — on Apple Silicon,
  stale Intel binaries there would shadow ARM brew (none present today)
- `.utils.sh` layout-migration `rm -rf` of `~/.claude/config` etc. has no
  backup — destroys non-dotfiles content if present (one-time migration code)
