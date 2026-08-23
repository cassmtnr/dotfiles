# Phase 02 — The UI layer

**Status: shipped.** A record of why `lib/ui.sh` exists and which decisions
still bind, not an implementation plan.

**For the API, read `UI.md`.** Nothing here lists functions, variables or
colours on purpose: this file drifted twice by duplicating detail that `UI.md`
owns, so it no longer tries.

## Why it exists

The installer printed a wall of log lines, prompted with hand-rolled `read`
loops, and had no answer to a failed step except dying. Three things were
missing: one status line per step instead of scrolling output, a way out of a
failure other than aborting the whole run, and an exit code CI could trust.

## What it became

**Stage 1 — the step runner.** One file holding every prompt and status line.
`run_step` captures a step's output, prints one ✓/−/✗ line, and offers
retry / skip / abort on failure. A summary table sets the exit code. `--verbose`
streams everything. Every step function in `lib/` was converted to the contract
below. A CI test pins the non-interactive behaviour.

**Stage 2 — hardening.** Review found the file lying about what it did:
`--verbose` ran steps in a subshell and discarded environment they exported,
so Node was silently skipped while the step reported ✓; skip reasons and
warnings were captured and deleted, so a Linux user declining admin rights saw
an all-green summary with nothing installed; `exec zsh -l` threw away the exit
status; a Ctrl-C orphaned the spinner, which then redrew over the user's
prompt forever. Each is recorded in `CHANGELOG.md`.

**Stage 3 — extraction.** Cut the dependency on `lib/common.sh` so the file
stands alone, namespaced everything, and wrote `UI.md` so it can be copied into
another project. It is now a drop-in library that this repo happens to be the
first consumer of.

## Decisions that still bind

**Pure bash 3.2, no dependencies.** macOS ships bash 3.2 and the installer runs
before anything is installed, so no bash 4 features, no external UI tool, and
nothing that needs bootstrapping.

**Gum was tried and reverted.** Vendored `gum` binaries were built and removed
before any commit: interactive acceptance found the menus near-identical to the
pure-bash ones, which did not justify ~30 MB of binaries plus an update path per
platform. The repo has never carried them. If terminal-UI polish comes up
again, that is the measurement to beat.

**One file, not modules.** The distribution model is "copy it into your
project", which a four-file split would make worse.

**`run_step` keeps its unprefixed name.** `ui_run_step` is canonical and
`run_step` is a one-line alias, so this repo's call sites did not churn.
`UI.md` names it as the one collision risk for a host project.

**The step contract.** A missing prerequisite calls `ui_skip` and returns 0; a
nonzero return means a real failure, because retry is what the user is offered.
This is the rule most often written backwards, so it is stated in `UI.md` too.

**Steps run with `errexit` suppressed.** Capturing an exit code with `|| rc=$?`
disables `set -e` for the step's whole dynamic extent. That is the price of
offering retry/skip/abort instead of dying, so step functions must make every
failure explicit.

## Where the current truth lives

- `UI.md` — the API.
- `CHANGELOG.md` — what changed and when.
- `log.md` — the dated decisions, including the gum reversal.
