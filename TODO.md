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

## phase-03 needs a from-scratch Linux run

Verified against a fake `HOME` on macOS only (task 6). A from-scratch
`./install.sh` on a clean Linux machine, run twice for idempotence, still
needs doing on the server replacing tars, and that run is also the first test
of `ensure_ai_repo` offering its clone for real.

## `./update.sh` goes red offline or with a dirty `.ai/`

`update.sh` gained an "AI config repo (.ai)" step in phase-03 that fast-forwards
the clone. It is the first step in a default run that needs the network, so an
offline update now reports a failed step, and so does a dirty `.ai/` worktree
(agent-reach rewrites its own skill on upgrade). `run_step` offers
retry/skip/abort, so it is recoverable, but the daily run stops being green for
reasons that are not failures.

Deferred because the fix is a behaviour choice, not a bug fix: should the step
skip when the network is unreachable and fail only on real divergence, or keep
failing on both? Raised by the phase-03 final review.
