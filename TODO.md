# TODO

## CI has been red since before phase-03

Found on `8e8467f` while establishing a shellcheck baseline for phase-03.
Both failures predate that phase and were left alone under the surgical-edits
rule.

- **lint job** — three shellcheck findings, all of them deliberate code that
  wants a `# shellcheck disable=` comment rather than a rewrite:
  `lib/extras.sh:77` and `lib/extras.sh:94` raise SC2024 for
  `sudo -v < /dev/tty > /dev/tty 2>&1`, where feeding the TTY to sudo's prompt
  is the point; `lib/ui.sh:77` raises SC1003 for the literal backslash in
  `_UI_FRAMES`, which is a spinner frame and not an escape.
- **install job, macOS and Ubuntu** — `set_default_shell` fails with "Failed to
  change default shell" because `chsh` cannot run unattended on a runner. The
  step needs to skip rather than fail when there is no TTY, per the `run_step`
  contract in `UI.md`.
