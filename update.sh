#!/usr/bin/env bash

# Pull the dotfiles repo, then the .ai config repo on main.
# Replaces the old update.sh: symlink/extension/package refresh lives in
# install.sh (steps 1-2), so updating is pull here, then ./install.sh when
# symlinks or packages changed. Safe to re-run: a dirty tree is skipped
# instead of touched, and --ff-only means a diverged branch stops with an
# error instead of auto-merging.

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
failed=0

pull_repo() {
    local name="$1" dir="$2" checkout_main="$3"

    if [[ ! -d "$dir/.git" ]]; then
        echo "-- $name: no git repo at $dir, skipped"
        return 0
    fi
    if ! git -C "$dir" diff --quiet HEAD 2> /dev/null; then
        echo "!! $name: local changes — commit or stash them, then re-run"
        failed=1
        return 0
    fi
    if [[ "$checkout_main" == "yes" ]]; then
        git -C "$dir" checkout -q main || { echo "!! $name: checkout main failed"; failed=1; return 0; }
    elif [[ "$(git -C "$dir" branch --show-current)" != "main" ]]; then
        # Not switching under you: pull updates the branch you're on
        echo "-- $name: on branch $(git -C "$dir" branch --show-current), not main"
    fi
    if git -C "$dir" pull --ff-only; then
        echo "ok $name updated"
    else
        echo "!! $name: pull failed (offline, or diverged from remote)"
        failed=1
    fi
}

pull_repo "dotfiles"  "$ROOT"     "no"
pull_repo "ai-config" "$ROOT/.ai" "yes"

exit "$failed"
