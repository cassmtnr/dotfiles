#!/usr/bin/env bash

# Skill lint — structural health check for AI CLI skills.
# Idea borrowed from ctx's skill-health (github.com/stevesolun/ctx) without
# adopting its recommendation layer: catch skill rot locally — missing
# frontmatter, dead relative links, and commands referenced in bash code
# blocks that aren't installed on this machine.
#
# Usage: skill-lint.sh [skills-dir]
# Default skills dir: the .ai/common/skills directory next to this script.
# Exit code: 0 clean, 1 issues found (warn-only; never modifies anything).

set -uo pipefail

SKILLS_DIR="${1:-"$(cd "$(dirname "${BASH_SOURCE[0]}")/../skills" && pwd)"}"
issues=0

warn() { printf '⚠️  %s\n' "$1"; issues=$((issues + 1)); }

for dir in "$SKILLS_DIR"/*/; do
    [[ -d "$dir" ]] || continue
    name="$(basename "$dir")"

    if [[ ! -f "$dir/SKILL.md" ]]; then
        warn "$name: missing SKILL.md"
        continue
    fi

    grep -q '^name:' "$dir/SKILL.md" || warn "$name: frontmatter missing 'name:'"
    grep -q '^description:' "$dir/SKILL.md" || warn "$name: frontmatter missing 'description:'"

    # Dead relative markdown links (resolved against the file that contains them)
    while IFS=$'\t' read -r file target; do
        clean="${target%%#*}"
        [[ -z "$clean" ]] && continue
        [[ -e "$(dirname "$file")/$clean" ]] || \
            warn "$name: dead link in ${file#"$dir"} → $target"
    done < <(
        find "$dir" -name '*.md' -print0 | while IFS= read -r -d '' md; do
            grep -o '](\([^)]*\))' "$md" 2>/dev/null | sed 's/^](//; s/)$//' | \
                grep -vE '^(https?:|mailto:|/|#|~)' | \
                grep -E '[/.]' | \
                while IFS= read -r t; do printf '%s\t%s\n' "$md" "$t"; done
        done
    )

    # Commands used in bash/sh code blocks that aren't on PATH
    while IFS= read -r cmd; do
        command -v "$cmd" &> /dev/null || \
            warn "$name: references command '$cmd' (not installed)"
    done < <(
        find "$dir" -name '*.md' -exec awk '
            FNR == 1         { fence = 0; hd = "" }
            /^```(bash|sh)([[:space:]].*)?$/ { fence = 1; next }
            /^```/           { fence = 0; hd = ""; next }
            fence && hd != "" { if ($0 == hd) hd = ""; next }
            fence {
                print $1
                # skip heredoc bodies (e.g. python3 - <<PY ... PY)
                if (match($0, /<<-?['\''"]?[A-Za-z_]+/)) {
                    hd = substr($0, RSTART, RLENGTH)
                    gsub(/<<-?['\''"]?/, "", hd)
                }
            }
        ' {} + | grep -E '^[a-zA-Z][a-zA-Z0-9_.-]*$' | sort -u
    )
done

total="$(find "$SKILLS_DIR" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
if [[ "$issues" -eq 0 ]]; then
    echo "✅ skill lint: $total skill(s) OK"
else
    echo "— skill lint: $issues issue(s) across $total skill(s)"
    exit 1
fi
