# shellcheck shell=bash
# ============================================================================
# ui.sh — terminal UI for setup scripts: prompts, menus, and a step runner.
#
# Self-contained: copy this one file into any project and source it. Pure
# bash 3.2 (macOS default), no libraries, only coreutils. Non-TTY runs take
# defaults and select nothing, so CI never hangs on a prompt.
#
# Full documentation: UI.md
# ============================================================================

# Sourced, not executed. `return` outside a sourced file is an error, so this
# doubles as the check.
if ! (return 0 2> /dev/null); then
    printf 'ui.sh is a library: source it, do not run it.\n' >&2
    exit 1
fi

# Re-sourcing must not wipe recorded steps — two files in one project each
# sourcing this is normal.
[[ -n "${UI_VERSION:-}" ]] && return 0
UI_VERSION="1.0.0"

# ── Configuration ───────────────────────────────────────────────────────────
# Every value below is overridable; set any of them before or after sourcing.

: "${UI_INDENT:=  }"        # leading whitespace on status lines
: "${UI_TAIL_LINES:=15}"    # lines of a failed step's output to show inline
: "${UI_SPINNER_INTERVAL:=0.1}"

# UI_VERBOSE streams step output instead of capturing it. Read at call time,
# not here: callers commonly set it while parsing argv, after sourcing. VERBOSE
# is honoured as a fallback for scripts that already use that name.
_ui_verbose() { [[ "${UI_VERBOSE:-${VERBOSE:-false}}" == "true" ]]; }

# ── Palette ─────────────────────────────────────────────────────────────────
# One table, not two branches. Listing every name twice (once coloured, once
# blank) meant adding a colour required two edits, and missing the second left
# the variable unset under `set -u`. Here a colour is one line, and the
# no-colour path needs no edit at all.
#
# Colour is dropped when NO_COLOR is set (no-color.org) or stderr is not a
# terminal, so redirected logs and CI output carry no escape codes.

# Assign only if the caller has not already set it, so overrides survive.
_ui_default() { [[ -n "${!1+set}" ]] || printf -v "$1" '%s' "$2"; }

_ui_init_palette() {
    local colour=1 entry name sgr
    [[ -n "${NO_COLOR:-}" || ! -t 2 ]] && colour=0
    for entry in \
        "BLACK:0;30"   "RED:0;31"     "GREEN:0;32"   "YELLOW:1;33" \
        "BLUE:0;34"    "MAGENTA:0;35" "CYAN:0;36"    "WHITE:0;37"  \
        "BOLD:1"       "DIM:2"        "UNDERLINE:4"  "REVERSE:7"   \
        "NC:0"
    do
        name="UI_${entry%%:*}"
        sgr="${entry#*:}"
        if [[ $colour -eq 1 ]]; then printf -v sgr '\033[%sm' "$sgr"; else sgr=""; fi
        _ui_default "$name" "$sgr"
    done
}
_ui_init_palette

# Glyphs: fall back to ASCII outside a UTF-8 locale, where the box-drawing and
# braille characters render as mojibake.
case "${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" in
    *[Uu][Tt][Ff]*)
        : "${UI_GLYPH_OK:=✓}" "${UI_GLYPH_FAIL:=✗}" "${UI_GLYPH_SKIP:=−}"
        : "${UI_GLYPH_RULE:=─}" "${UI_GLYPH_BULLET:=·}"
        : "${UI_CAP_L:=╶}" "${UI_CAP_R:=╴}"
        _UI_FRAMES=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏) ;;
    *)
        : "${UI_GLYPH_OK:=+}" "${UI_GLYPH_FAIL:=x}" "${UI_GLYPH_SKIP:=-}"
        : "${UI_GLYPH_RULE:=-}" "${UI_GLYPH_BULLET:=:}"
        : "${UI_CAP_L:=}" "${UI_CAP_R:=}"
        _UI_FRAMES=('|' '/' '-' '\') ;;
esac

# ── State ───────────────────────────────────────────────────────────────────
# Underscore-prefixed: these back ui_summary and are not a public interface.
_UI_STEP_NAMES=()
_UI_STEP_STATUS=()
# UI_SKIPPED carries a skip reason out of a captured step; see ui_skip.
UI_SKIPPED=""
# _UI_WARNINGS carries warnings out of a captured step; see ui_warn.
_UI_WARNINGS=()

# ── Internal helpers ────────────────────────────────────────────────────────

# Private warning, so a host project's own warning() stays untouched.
# %s, not %b: %b would interpret backslashes in caller-supplied text.
_ui_warn() { printf '%s[WARNING]%s %s\n' "$UI_YELLOW" "$UI_NC" "$1" >&2; }

# Terminal width, or 80 when it cannot be determined. The `|| cols=80` is
# load-bearing: under `set -o pipefail` a failed stty fails the whole
# assignment and errexit would kill the caller.
_ui_term_cols() {
    local cols
    cols=$(stty size < /dev/tty 2> /dev/null | cut -d' ' -f2) || cols=80
    case "$cols" in (*[!0-9]*|'') cols=80 ;; esac
    # a pty can report 0 columns
    [[ $cols -lt 40 ]] && cols=80
    printf '%s\n' "$cols"
}

# The one place a status line is formatted. _ui_line colours the glyph only,
# _ui_line_dim dims the whole row.
_ui_line()     { printf '%s%s%s%s %s\n' "$UI_INDENT" "$2" "$1" "$UI_NC" "$3" >&2; }
_ui_line_dim() { printf '%s%s%s %s%s\n' "$UI_INDENT" "$UI_DIM" "$1" "$2" "$UI_NC" >&2; }

# A horizontal rule of n glyphs, used to fence off a failed step's output.
_ui_rule() {
    local label="$1" bar="" i
    if [[ -n "$label" ]]; then
        printf '    %s%s%s %s %s%s%s\n' "$UI_DIM" "$UI_CAP_L" "$UI_GLYPH_RULE" \
            "$label" "$UI_GLYPH_RULE" "$UI_CAP_R" "$UI_NC" >&2
    else
        for ((i = 0; i < 17; i++)); do bar="$bar$UI_GLYPH_RULE"; done
        printf '    %s%s%s%s%s\n' "$UI_DIM" "$UI_CAP_L" "$bar" "$UI_CAP_R" "$UI_NC" >&2
    fi
}

# ── Output primitives ───────────────────────────────────────────────────────

ui_header() { printf '\n%s%s%s\n' "$UI_BOLD" "$1" "$UI_NC" >&2; }

ui_ok()   { _ui_line "$UI_GLYPH_OK"   "$UI_GREEN" "$1"; }
ui_fail() { _ui_line "$UI_GLYPH_FAIL" "$UI_RED"   "$1"; }

# ui_skip prints AND records the reason. ui_run_step captures a step's
# stdout/stderr, so a skip reported from inside a step would otherwise be
# swallowed; the runner reads UI_SKIPPED once the capture ends.
ui_skip() { UI_SKIPPED="$1"; _ui_line_dim "$UI_GLYPH_SKIP" "$1"; }

# ui_warn records AND prints. A step's output is captured and thrown away when
# it succeeds, so a plain `echo`/`warning` inside a step vanishes even when it
# says something the user must act on. Warnings recorded here are replayed by
# ui_run_step after the status line, whatever the step's exit code.
ui_warn() { _UI_WARNINGS+=("$1"); _ui_warn "$1"; }

# ── Prompts ─────────────────────────────────────────────────────────────────

# ui_confirm "Question?" [y|n] -> 0 yes / 1 no. The second argument is what
# Enter picks, and what a non-TTY run returns without prompting.
ui_confirm() {
    local q="$1" def="${2:-n}" answer hint
    if [[ ! -t 0 ]]; then [[ "$def" == "y" ]]; return; fi
    if [[ "$def" == "y" ]]; then hint="Y/n"; else hint="y/N"; fi
    printf '%s[?]%s %s [%s] ' "$UI_BLUE" "$UI_NC" "$q" "$hint" >&2
    read -r answer || answer=""
    case "$answer" in
        [Yy]*) return 0 ;;
        [Nn]*) return 1 ;;
        *)     [[ "$def" == "y" ]] ;;
    esac
}

# ui_choose "prompt" "value:label"... -> prints the ONE chosen value.
# Non-TTY prints the first value, so callers put the safe default first.
# Cancelling (Ctrl-C/EOF) prints nothing and returns 1: a cancelled menu must
# not silently pick an option, or a retry loop becomes uninterruptible.
ui_choose() {
    local prompt="$1"; shift
    [[ $# -gt 0 ]] || { _ui_warn "ui_choose: no options given"; return 2; }
    local options=("$@") i answer
    if [[ ! -t 0 ]]; then printf '%s\n' "${options[0]%%:*}"; return 0; fi
    printf '%s\n' "$prompt" >&2
    for ((i = 0; i < $#; i++)); do
        printf '  %d) %s\n' "$((i + 1))" "${options[$i]#*:}" >&2
    done
    printf '%s[?]%s choice [1] ' "$UI_BLUE" "$UI_NC" >&2
    read -r answer || { printf '\n' >&2; return 1; }
    case "$answer" in (*[!0-9]*|'') answer=1 ;; esac
    # 10#: "08"/"09" are invalid octal and would make the bounds test error out
    answer=$((10#$answer))
    [[ $answer -ge 1 && $answer -le $# ]] || answer=1
    printf '%s\n' "${options[$((answer - 1))]%%:*}"
}

# ui_choose_many "prompt" "value:label"... -> selected values, one per line.
# Nothing selected on cancel or without a TTY, which is what keeps an
# unattended run from opting into anything.
ui_choose_many() {
    [[ -t 0 ]] || return 0
    _ui_choose_many "$@"
}

# ── Step runner ─────────────────────────────────────────────────────────────

# Replay warnings a step recorded, now that its output capture has ended.
_ui_replay_warnings() {
    local w
    [[ ${#_UI_WARNINGS[@]} -gt 0 ]] || return 0
    for w in "${_UI_WARNINGS[@]}"; do _ui_warn "$w"; done
    _UI_WARNINGS=()
}

# Record a step outcome for ui_summary.
_ui_record() { _UI_STEP_NAMES+=("$1"); _UI_STEP_STATUS+=("$2"); }

# Animated "still working" line, drawn until the runner kills it. Runs as a
# background process so the step itself stays in the foreground of the current
# shell; running the step in a subshell would discard env it exports.
# Echoes the tail of the capture file, which turns a silent ten-minute
# `brew bundle` into visible progress.
#
# It cannot surface a password prompt: sudo writes to /dev/tty, bypassing the
# capture, and this loop overwrites that same line every interval. Callers
# must authenticate BEFORE a step that needs it, never inside one.
_ui_spinner() {
    local label="$1" out="$2" parent="$3"
    local n=${#_UI_FRAMES[@]} i=0 last="" cols avail
    SECONDS=0   # wall clock: counting frames undercounts, since the loop runs
                # slower than its sleep once the tail poll is added
    cols=$(_ui_term_cols)
    avail=$((cols - ${#label} - 22))   # room after "  x <label> (999s) . "
    [[ $avail -lt 12 ]] && avail=12
    # Watch the parent instead of trapping: bash makes async children ignore
    # SIGINT in a non-interactive shell, so Ctrl-C would kill the script and
    # leave this loop redrawing over the user's prompt forever.
    while kill -0 "$parent" 2> /dev/null; do
        # poll the capture file twice a second rather than every frame
        if [[ $((i % 5)) -eq 0 ]]; then
            last="$(tail -n 1 "$out" 2> /dev/null | tr -d '\r\t' | cut -c "1-$avail")"
        fi
        printf '\r\033[K%s%s%s %s' "$UI_INDENT" "$UI_DIM" "${_UI_FRAMES[i % n]}" "$label" >&2
        [[ $SECONDS -ge 3 ]] && printf ' (%ds)' "$SECONDS" >&2
        [[ -n "$last" ]] && printf ' %s %s' "$UI_GLYPH_BULLET" "$last" >&2
        printf '%s' "$UI_NC" >&2
        i=$((i + 1))
        sleep "$UI_SPINNER_INTERVAL"
    done
}

# ui_run_step "Label" fn [args...] — run one step through the UI: output
# captured to a temp file (streamed when UI_VERBOSE=true), a spinner echoing
# that file's tail while it runs, one ✓/−/✗ status line, and a
# retry/skip/abort menu on failure.
#
# Contract: a step that only lacks a prerequisite calls ui_skip and returns 0;
# a nonzero return means a real failure, and retry is what the user is offered.
# On failure the last UI_TAIL_LINES lines print inline and the capture file is
# kept with its path shown. A cancelled failure menu means abort, never retry.
ui_run_step() {
    local label="$1" out rc action spin_pid; shift
    # Explicit template, not `mktemp -t ui-step`: BSD treats a bare argument as
    # a prefix, GNU rejects it for having no X's, which breaks every step on Linux.
    out="$(mktemp "${TMPDIR:-/tmp}/ui-step.XXXXXX")" || { _ui_warn "mktemp failed"; return 1; }
    while true; do
        rc=0
        spin_pid=""
        UI_SKIPPED=""
        _UI_WARNINGS=()
        : > "$out"   # fresh capture per attempt, so a retry's tail is its own
        if ! _ui_verbose && [[ -t 2 ]]; then
            _ui_spinner "$label" "$out" "$$" &
            spin_pid=$!
        fi
        if _ui_verbose; then
            # >(tee) rather than a pipeline: a pipeline runs the step in a
            # subshell, discarding env it exports and masking its exit code
            # behind tee's. >&2 keeps stdout clean in both modes.
            "$@" > >(tee "$out" >&2) 2>&1 || rc=$?
        else
            "$@" > "$out" 2>&1 || rc=$?
        fi
        if [[ -n "$spin_pid" ]]; then
            kill "$spin_pid" 2> /dev/null || true
            wait "$spin_pid" 2> /dev/null || true
            printf '\r\033[K' >&2
        fi

        if [[ $rc -eq 0 ]]; then
            if [[ -n "$UI_SKIPPED" ]]; then
                _ui_line_dim "$UI_GLYPH_SKIP" "$label ($UI_SKIPPED)"
                _ui_record "$label" skipped
            else
                ui_ok "$label"
                _ui_record "$label" ok
            fi
            _ui_replay_warnings
            rm -f "$out"
            return 0
        fi

        ui_fail "$label (exit $rc)"
        # No replay here: the excerpt below and the kept file already carry the
        # step's warnings, and repeating them ahead of that context is noise.
        _UI_WARNINGS=()
        if _ui_verbose; then
            rm -f "$out"   # already streamed in full; nothing left to keep
        else
            # Indent and fence the excerpt so it reads as this step's output
            # rather than as more status lines
            _ui_rule "last $UI_TAIL_LINES lines"
            tail -n "$UI_TAIL_LINES" "$out" | sed 's/^/    /' >&2 || true
            _ui_rule ""
            _ui_warn "full output kept at: $out"
        fi

        if [[ ! -t 0 ]]; then
            _ui_record "$label" failed
            return 0   # non-interactive: record and move on
        fi
        action="$(ui_choose "\"$label\" failed — what now?" \
            "retry:Try again (fix the problem in another terminal first if needed)" \
            "skip:Skip this step and continue" \
            "abort:Stop here")" || action="abort"
        case "$action" in
            retry) continue ;;
            abort) _ui_record "$label" aborted; ui_summary; exit 1 ;;
            *)     _ui_record "$label" skipped; return 0 ;;
        esac
    done
}

# Back-compatible alias. ui_run_step is the canonical name; run_step is the
# one unprefixed symbol this file exports, so a host project that already
# defines run_step should call ui_run_step and delete this line.
run_step() { ui_run_step "$@"; }


# End-of-run summary. Returns 1 if anything failed or aborted, so a caller can
# `ui_summary || exit 1`. Prints nothing and returns 0 when no steps ran.
ui_summary() {
    local i bad=0
    [[ ${#_UI_STEP_NAMES[@]} -gt 0 ]] || return 0
    ui_header "Summary"
    for ((i = 0; i < ${#_UI_STEP_NAMES[@]}; i++)); do
        case "${_UI_STEP_STATUS[$i]}" in
            ok)      ui_ok "${_UI_STEP_NAMES[$i]}" ;;
            # _ui_line_dim, not ui_skip: the summary must not clobber UI_SKIPPED
            skipped) _ui_line_dim "$UI_GLYPH_SKIP" "${_UI_STEP_NAMES[$i]} (skipped)" ;;
            *)       ui_fail "${_UI_STEP_NAMES[$i]} (${_UI_STEP_STATUS[$i]})"; bad=1 ;;
        esac
    done
    return $bad
}

# Discard recorded steps. Useful when a script runs several independent phases
# and wants a summary per phase.
ui_reset() { _UI_STEP_NAMES=(); _UI_STEP_STATUS=(); UI_SKIPPED=""; }

# ── Arrow-key multi-select ──────────────────────────────────────────────────

# Restore the terminal after _ui_choose_many (echo/canonical mode + cursor).
# Relies on dynamic scope: it fires while _ui_choose_many, which owns
# _ui_saved_stty, is still on the call stack, both directly and from its trap.
_ui_choose_restore() {
    if [[ -n "${_ui_saved_stty:-}" ]]; then
        stty "$_ui_saved_stty" < /dev/tty 2> /dev/null || true
    fi
    printf '\033[?25h' > /dev/tty 2> /dev/null || true   # show cursor
}

# Checkbox menu with arrow-key navigation. Args: prompt, then "value:label"
# pairs. Keys: up/down (or k/j) move, space toggles, 'a' toggles all, enter
# confirms, q/Esc cancels. Prints the selected VALUES to stdout, one per line.
# Drawn to /dev/tty rather than stderr, which may be redirected, and keys are
# read from /dev/tty. Cancel prints nothing. The caller must ensure a TTY.
# Pure bash 3.2: no namerefs, no fractional `read -t`, no ESC[6n cursor query.
_ui_choose_many() {
    local prompt="$1"; shift
    local options=("$@") n=$# selected=() i cursor=0 first=1 cancelled=0

    [[ $n -gt 0 ]] || return 0
    for ((i = 0; i < n; i++)); do selected[i]=0; done

    # Labels must fit one physical row each: a wrapped line breaks the in-place
    # redraw, whose cursor-up count assumes one row per option.
    local cols maxw
    cols=$(_ui_term_cols)
    maxw=$((cols - 8))
    [[ $maxw -lt 10 ]] && maxw=10

    # Save terminal state; restore on normal return, Ctrl-C, or kill.
    # _ui_prev_traps: the `trap -` below would otherwise clear a caller's
    # handlers along with ours. `trap -p` prints re-executable trap commands.
    local _ui_saved_stty _ui_prev_traps
    _ui_prev_traps="$(trap -p INT TERM EXIT)"
    _ui_saved_stty=$(stty -g < /dev/tty)
    trap '_ui_choose_restore; exit 130' INT TERM
    trap '_ui_choose_restore' EXIT
    stty -echo < /dev/tty
    printf '\033[?25l' > /dev/tty   # hide cursor

    printf '%s  %s(up/down move %s space toggle %s a all %s enter confirm %s q cancel)%s\n' \
        "$prompt" "$UI_DIM" "$UI_GLYPH_BULLET" "$UI_GLYPH_BULLET" \
        "$UI_GLYPH_BULLET" "$UI_GLYPH_BULLET" "$UI_NC" > /dev/tty

    local key rest label box
    while true; do
        # Redraw in place: after the first pass, move the cursor back up n rows
        # rather than querying its position.
        if [[ $first -eq 1 ]]; then first=0; else printf '\033[%dA' "$n" > /dev/tty; fi
        for ((i = 0; i < n; i++)); do
            label="${options[$i]#*:}"
            label="${label:0:$maxw}"
            if [[ ${selected[$i]} -eq 1 ]]; then box='x'; else box=' '; fi
            if [[ $i -eq $cursor ]]; then
                printf '\r\033[K%s > [%s] %s %s\n' "$UI_REVERSE" "$box" "$label" "$UI_NC" > /dev/tty
            else
                printf '\r\033[K   [%s] %s\n' "$box" "$label" > /dev/tty
            fi
        done

        IFS= read -rsn1 key < /dev/tty || { cancelled=1; break; }
        case "$key" in
            ''|$'\n'|$'\r') break ;;                       # Enter confirms
            $'\x1b')                                       # arrow keys or bare Esc
                # -t 1 (integer: bash 3.2 has no fractional timeout). Arrows
                # deliver their 2 bytes instantly; a bare Esc waits, then cancels.
                read -rsn2 -t 1 rest < /dev/tty 2> /dev/null || rest=''
                case "$rest" in
                    '[A'|'OA') cursor=$(( (cursor - 1 + n) % n )) ;;   # up
                    '[B'|'OB') cursor=$(( (cursor + 1) % n )) ;;       # down
                    '')        cancelled=1; break ;;                   # bare Esc
                esac ;;
            k|K) cursor=$(( (cursor - 1 + n) % n )) ;;
            j|J) cursor=$(( (cursor + 1) % n )) ;;
            ' ') selected[cursor]=$(( 1 - ${selected[$cursor]} )) ;;
            a|A)                                           # toggle all on/off
                local all=1
                for ((i = 0; i < n; i++)); do
                    [[ ${selected[$i]} -eq 0 ]] && all=0
                done
                for ((i = 0; i < n; i++)); do selected[i]=$(( 1 - all )); done ;;
            q|Q) cancelled=1; break ;;
        esac
    done

    _ui_choose_restore
    trap - INT TERM EXIT
    eval "${_ui_prev_traps:-}"

    [[ $cancelled -eq 1 ]] && return 0
    for ((i = 0; i < n; i++)); do
        [[ ${selected[$i]} -eq 1 ]] && printf '%s\n' "${options[$i]%%:*}"
    done
    return 0
}
