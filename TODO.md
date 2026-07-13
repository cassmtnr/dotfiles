# TODO

Nits deferred because they change behavior you may prefer as-is:

- `.functions` `extract()` references `unrar` (`.rar`) and `7z` (`.7z`) — neither
  is in `.brewfile` or any install path, so those two archive types fail with
  command-not-found (`.Z`/`uncompress` works — it ships with macOS)
- `.aliases:89` `alias cc="claude …"` shadows the system C compiler in
  interactive shells (intentional shortcut; build scripts are unaffected —
  aliases don't load in non-interactive shells)
- `.zshenv` PATH puts `/usr/local/bin` ahead of Homebrew — on Apple Silicon,
  stale Intel binaries there would shadow ARM brew (none present today)
