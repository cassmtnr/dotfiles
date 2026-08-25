# ui.sh — a terminal UI for setup scripts

One file, pure bash 3.2, no libraries. Drop it into any project that runs a
list of steps and wants to report them honestly: a spinner while work happens,
one status line per step, a retry/skip/abort menu on failure, and a summary
table that sets the exit code.

```
Step 1/4 — install software
  ⠹ Apps and CLI tools (14s) · ==> Fetching ghostty
  ✓ Apps and CLI tools
  − Homebrew (already installed)
  ✗ Node.js via NVM (exit 1)
    ╶─ last 15 lines ─╴
    curl: (7) Failed to connect
    ╶─────────────────╴
[WARNING] full output kept at: /tmp/tmp.k3Ndu1

"Node.js via NVM" failed — what now?
  1) Try again
  2) Skip this step and continue
  3) Stop the installer
[?] choice [1]
```

## Install

Copy the file in and source it. That's the whole installation.

```bash
curl -O https://raw.githubusercontent.com/cassmtnr/dotfiles/main/lib/ui.sh
```

```bash
#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/ui.sh"
```

Source it **before** any library that might define `log` or `warning`, and see
[Name collisions](#name-collisions) for the one name to watch.

## Quickstart

```bash
#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/ui.sh"

install_deps() {
    command -v git > /dev/null || { ui_skip "git missing"; return 0; }
    npm install || return 1
}

build() { npm run build || return 1; }

ui_header "Setting up"
ui_run_step "Install dependencies" install_deps
ui_run_step "Build"               build
ui_summary || exit 1
```

Run it. Every step reports itself, a failure offers you a way out, and the
script exits nonzero if anything broke.

## The step contract

`ui_run_step` runs a shell function and interprets its exit code. Write your step
functions to this contract and everything else follows:

| Your function does | Result |
|---|---|
| `return 0` | `✓ Label` |
| `ui_skip "reason"` then `return 0` | `− Label (reason)` |
| `return <nonzero>` | `✗ Label (exit N)`, then the retry/skip/abort menu |

The distinction that matters: **a missing prerequisite is a skip, not a
failure.** "Not on macOS", "already installed", "Docker isn't running" are all
`ui_skip` + `return 0`. Reserve a nonzero return for something that went wrong
and that retrying could plausibly fix, because retry is what the user is
offered.

```bash
apply_macos_defaults() {
    [[ "$(uname)" == "Darwin" ]] || { ui_skip "not macOS"; return 0; }
    [[ -f .defaults ]]           || { ui_skip ".defaults not found"; return 0; }
    bash .defaults || return 1
}
```

### `set -e` does not apply inside a step

`ui_run_step` captures your function's exit code with `"$@" || rc=$?`. Putting
a command on the left of `||` suppresses `errexit` for its whole dynamic
extent, so **a failing command in the middle of your step does not abort it**:

```bash
step() { echo before; false; echo "this still runs"; true; }
ui_run_step "probe" step          # -> ✓ probe
```

Only the function's final exit status is reported. Make every failure explicit:

```bash
install_deps() {
    npm ci || return 1          # not a bare `npm ci`
    npm run build || return 1
}
```

This is inherent to reporting an exit code rather than dying on one, which is
what buys you the retry/skip/abort menu. Use `ui_warn` for anything the user
must see but that should not fail the step.

### Output is captured

`ui_run_step` redirects your function's stdout and stderr into a temp file so the
status lines stay readable. Consequences worth knowing:

- Anything you `echo` is hidden unless the step fails or `UI_VERBOSE=true`.
- The spinner shows the **last line** of that file, so progress-style output
  (`==> Fetching x`) turns into a live progress indicator for free.
- `ui_skip` still reaches the user, because it records into `UI_SKIPPED` and
  `ui_run_step` reprints it after the capture ends. Plain `echo` does not.
- **A successful step's output is deleted entirely.** Anything the user must
  act on — "SSH login will not work", "config was not linked" — has to go
  through `ui_warn`, or it vanishes behind a green ✓.
- A password prompt inside a step is invisible and looks like a hang: it goes
  to `/dev/tty`, which the capture does not see and the spinner overwrites.
  Authenticate before the step, not inside it.

Your function runs in the **current shell**, not a subshell, in both quiet and
verbose mode. Exporting a variable or modifying `PATH` inside a step works and
persists to later steps.

## Reference

### `ui_run_step LABEL FUNCTION [ARGS...]`

Runs `FUNCTION` with `ARGS`, reports it, records it for `ui_summary`. Always
returns 0 except on abort, where it exits the script with status 1. It never
propagates a step's failure directly, so `set -e` will not kill your script
mid-run; ask `ui_summary` at the end instead.

On failure without a TTY on stdin (CI), it records the failure and continues
rather than prompting.

### `ui_summary`

Prints the summary table. Returns 1 if any step failed or aborted, 0 otherwise.
Prints nothing and returns 0 if no steps ran.

```bash
ui_summary || exit 1                      # fail the script

status=0; ui_summary || status=1          # or do cleanup first
cleanup
exit $status
```

If you `exec` anything after this, capture the status **before** the `exec`.
`exec` replaces the process and discards it.

### `ui_warn MESSAGE`

Prints a warning and records it so `ui_run_step` replays it after the ✓ line.
Use it for anything inside a step the user must see, since a successful step's
captured output is deleted. On failure it is not replayed — the excerpt and the
kept output file already show it in context.

```bash
link_ssh() {
    [[ -f ~/.ssh/authorized_keys ]] || ui_warn "authorized_keys missing — key login will not work"
    return 0
}
```

### `ui_reset`

Discards recorded steps. Use it when a script runs several independent phases
and wants a summary after each one.

```bash
ui_run_step "Fetch" fetch
ui_summary || exit 1
ui_reset                  # start the next phase with a clean slate

ui_run_step "Deploy" deploy
ui_summary || exit 1
```

### `ui_confirm QUESTION [y|n]`

Yes/no prompt. Returns 0 for yes, 1 for no. The second argument is what Enter
picks, defaulting to `n`. **Without a TTY it returns the default without
prompting**, so CI never hangs.

```bash
if ui_confirm "Install optional extras?" y; then install_extras; fi
```

### `ui_choose PROMPT VALUE:LABEL...`

Numbered single-choice menu. Prints the chosen **value** to stdout. Returns 1
and prints nothing if cancelled with Ctrl-C or EOF. Without a TTY it prints the
first value, so **put the safe default first**. Out-of-range and non-numeric
input both fall back to the first option.

```bash
mode="$(ui_choose "Install mode:" "safe:Safe defaults" "full:Everything")"
```

### `ui_choose_many PROMPT VALUE:LABEL...`

Arrow-key checkbox menu. Prints the selected **values**, one per line, nothing
if cancelled. Nothing is pre-selected. Without a TTY it selects nothing and
prints nothing, which is what makes an unattended run install no extras.

Keys: `↑`/`↓` or `k`/`j` move, `space` toggles, `a` toggles all, `enter`
confirms, `q` or `Esc` cancels.

```bash
selected=()
while IFS= read -r line; do selected+=("$line"); done \
    < <(ui_choose_many "Pick extras:" "docker:Docker" "k8s:Kubernetes")

# Guard the length. Under `set -u`, bash 3.2 treats "${selected[@]}" on an
# EMPTY array as an unbound variable and aborts — and selecting nothing is
# the normal case here, including every non-interactive run.
if [[ ${#selected[@]} -gt 0 ]]; then
    for item in "${selected[@]}"; do echo "chose: $item"; done
fi
```

Two bash 3.2 details in that snippet, both load-bearing on macOS:

- The `while read` loop instead of `mapfile`, which needs bash 4.
- The `${#selected[@]} -gt 0` guard. Bash 4.4 fixed the empty-array expansion,
  macOS never shipped it. Skipping the guard means your script dies precisely
  when the user picks nothing.

The menu draws to `/dev/tty`, not stderr, so it survives `./setup.sh 2> log`.
It restores terminal state on exit, Ctrl-C, and kill, and preserves any
`INT`/`TERM`/`EXIT` traps you had set.

### `ui_header TEXT`

Bold section heading with a leading blank line.

### `ui_ok TEXT` / `ui_skip TEXT` / `ui_fail TEXT`

The raw status lines (`✓` / `−` / `✗`) if you want them outside a step.
`ui_skip` additionally sets `UI_SKIPPED`, which is how a skip escapes
`ui_run_step`'s output capture.

## Configuration

Set these before or after sourcing.

| Variable | Default | Purpose |
|---|---|---|
| `UI_VERBOSE` | `false` | `true` streams step output live instead of capturing it, and disables the spinner. `VERBOSE` is honoured as a fallback |
| `UI_INDENT` | two spaces | Leading whitespace on status lines |
| `UI_TAIL_LINES` | `15` | Lines of a failed step's output shown inline |
| `UI_SPINNER_INTERVAL` | `0.1` | Seconds between spinner frames |
| `UI_BLACK` `UI_RED` `UI_GREEN` `UI_YELLOW` `UI_BLUE` `UI_MAGENTA` `UI_CYAN` `UI_WHITE` | ANSI SGR | Palette, for your own output as well as the library's |
| `UI_BOLD` `UI_DIM` `UI_UNDERLINE` `UI_REVERSE` `UI_NC` | ANSI SGR | Attributes; `UI_NC` resets |
| `UI_GLYPH_OK` `UI_GLYPH_FAIL` `UI_GLYPH_SKIP` `UI_GLYPH_RULE` `UI_GLYPH_BULLET` | `✓ ✗ − ─ ·` | Status glyphs, ASCII outside a UTF-8 locale |
| `NO_COLOR` | unset | Set to anything to disable colour ([no-color.org](https://no-color.org)) |

The palette comes from a single table in `ui.sh`, so adding a colour is one
line and the no-colour path needs no edit. Set any of them before sourcing to
restyle, and use them in your own `printf` calls too:

```bash
printf '%sdeploying%s\n' "$UI_CYAN" "$UI_NC"
```

Colour is dropped automatically when stderr is not a terminal, and the glyphs
fall back to ASCII (`+ x - -  :`) when the locale is not UTF-8, so the output
stays readable in a `LANG=C` shell and free of escape codes in a CI log.

Colour is also dropped automatically when stderr is not a terminal, so
redirected logs and CI output stay free of escape codes.

```bash
./setup.sh --verbose      # if you wire the flag
VERBOSE=true ./setup.sh   # or just set it
NO_COLOR=1 ./setup.sh
```

## Non-interactive behaviour

Everything degrades to a safe default rather than blocking. This is the
property that makes it usable in CI and over `ssh` without `-t`:

| | With a TTY | Without |
|---|---|---|
| `ui_confirm` | prompts | returns the default |
| `ui_choose` | prompts | first value |
| `ui_choose_many` | prompts | selects nothing |
| failed step | retry/skip/abort menu | records failure, continues |
| spinner | animates | silent |

A run that fails a step still exits nonzero through `ui_summary`, so CI catches
it.

## Requirements

Bash 3.2 or newer, which means it works on macOS's stock `/bin/bash` without
installing anything. No bash 4 constructs (`mapfile`, associative arrays,
`${var,,}`).

Shells out to: `stty`, `mktemp`, `tail`, `sed`, `tee`, `cut`, `tr`, `sleep`,
`kill`. All present on macOS and any normal Linux.

## Name collisions

`ui.sh` claims these names. Only one is unprefixed:

- **`run_step`** — the only unprefixed name, kept for compatibility. It is a
  one-line alias for `ui_run_step`. If your project already defines
  `run_step`, call `ui_run_step` instead and delete the alias line.
- `ui_*` — the public API.
- `_ui_*` and `_UI_*` — internals. Do not call or read these.
- `UI_SKIPPED` — set by `ui_skip`, read by `ui_run_step`.
- `UI_VERBOSE` — preferred. `VERBOSE` is read as a fallback if you already
  use that name, so an existing `VERBOSE=true` keeps working.

Your own `log`, `warning`, and `error` functions are untouched. `ui.sh` uses
private `_ui_log` and `_ui_warn` internally.

## Working example

A complete script using every feature:

```bash
#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/ui.sh"

[[ "${1:-}" == "-v" ]] && VERBOSE=true

fetch_deps() {
    command -v npm > /dev/null || { ui_skip "npm not installed"; return 0; }
    npm ci || return 1
}
run_tests()  { npm test || return 1; }
build_docs() {
    [[ -d docs ]] || { ui_skip "no docs/ directory"; return 0; }
    npm run docs || return 1
}
run_benchmarks() {
    [[ -f bench.js ]] || { ui_skip "no bench.js"; return 0; }
    node bench.js || return 1
}

ui_header "Project setup"

if ! ui_confirm "Run a full setup?" y; then
    echo "Nothing to do."
    exit 0
fi

ui_run_step "Fetch dependencies" fetch_deps
ui_run_step "Run tests"          run_tests

targets=()
while IFS= read -r line; do targets+=("$line"); done \
    < <(ui_choose_many "Optional targets:" "docs:Build documentation" "bench:Run benchmarks")

if [[ ${#targets[@]} -gt 0 ]]; then      # empty array + set -u = abort on bash 3.2
    for t in "${targets[@]}"; do
        case "$t" in
            docs)  ui_run_step "Build documentation" build_docs ;;
            bench) ui_run_step "Run benchmarks"      run_benchmarks ;;
        esac
    done
fi

ui_summary || exit 1
```

## Using it with Claude

Drop `ui.sh` and this file into a project and point Claude at them:

> Use `ui.sh` for the setup script's output. Read `UI.md` for the API and
> follow the step contract.

The step contract is the part worth calling out explicitly, since "missing
prerequisite is a skip, not a failure" is the rule that most often gets written
the wrong way round.

## Licence

MIT, same as the repository it lives in.
