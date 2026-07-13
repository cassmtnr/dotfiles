#!/usr/bin/env bash

# Capture a macOS setting into .defaults.
#
#   1. Run ./capture-setting.sh
#   2. Change ONE setting in System Settings (give it a couple of seconds)
#   3. Press Enter
#
# The changed preference keys are detected, churn (timestamps, counters,
# caches, app state) is filtered out, and ready-made `defaults write` lines
# are appended to .defaults automatically. Review with `git diff .defaults`,
# move the lines into a fitting section, commit.
#
# Replaces the old defaults-diff.sh + defaults-sync.sh pair.

set -euo pipefail
DEFAULTS_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.defaults"
export DEFAULTS_FILE

exec python3 - <<'PY'
import os, plistlib, re, shlex, subprocess, sys

DEFAULTS_FILE = os.environ["DEFAULTS_FILE"]

# Domains that only churn with app state, never hold user preferences
NOISE_DOMAINS = re.compile(
    r"(knowledge-agent|cloudkit|\.spaces$|spotlight|siri|assistant|gamed|"
    r"parsecd|identityservices|accountsd?|\.bird$|sharingd|duetexpertd|"
    r"routined|remindd|calaccessd|suggestions|biome|tipsd?|setupassistant|"
    r"coreduet|studentd|newscore|stocks|weather|usernoted|systempreferences)",
    re.I)
# Key names that are counters/timestamps/caches, not preferences
NOISE_KEYS = re.compile(
    r"(date|timestamp|counter|engagement|activity|lastused|workaround|"
    r"validation|cache|_dk|usage|viewlive|whatsnew|seenversion)", re.I)

SCALARS = (bool, int, float, str)

def snapshot(host_flags):
    out = subprocess.run(["defaults", *host_flags, "domains"],
                         capture_output=True, text=True).stdout
    domains = [d.strip() for d in out.split(",") if d.strip()]
    domains.append("NSGlobalDomain")
    snap, failed = {}, set()
    for dom in domains:
        p = subprocess.run(["defaults", *host_flags, "export", dom, "-"],
                           capture_output=True)
        if p.returncode:
            failed.add(dom)
            continue
        try:
            snap[dom] = plistlib.loads(p.stdout)
        except Exception:
            failed.add(dom)
    return snap, failed

def fmt(dom, key, val, host):
    # shlex.quote: domains/keys/values can contain spaces, quotes, $ — the
    # emitted line must survive being executed by bash when .defaults runs
    flag = " -currentHost" if host else ""
    d, k = shlex.quote(dom), shlex.quote(key)
    if isinstance(val, bool):
        return f'defaults{flag} write {d} {k} -bool {"true" if val else "false"}'
    if isinstance(val, int):
        return f'defaults{flag} write {d} {k} -int {val}'
    if isinstance(val, float):
        return f'defaults{flag} write {d} {k} -float {val}'
    return f'defaults{flag} write {d} {k} -string {shlex.quote(val)}'

def diff(before, after, host, failed):
    # `failed` = domains whose export failed in either pass; diffing them
    # would fabricate changes from a missing snapshot side
    writes, deletes = [], []
    for dom, keys in after.items():
        if dom in failed or NOISE_DOMAINS.search(dom):
            continue
        prev = before.get(dom, {})
        for key, val in keys.items():
            if not isinstance(val, SCALARS) or NOISE_KEYS.search(key):
                continue
            if key in prev and prev[key] == val and type(prev[key]) is type(val):
                continue
            writes.append(fmt(dom, key, val, host))
    # macOS often expresses "back to default" by deleting the key —
    # report those so a no-write change isn't a silent false negative
    flag = " -currentHost" if host else ""
    for dom, keys in before.items():
        if dom in failed or dom not in after or NOISE_DOMAINS.search(dom):
            continue
        for key, val in keys.items():
            if not isinstance(val, SCALARS) or NOISE_KEYS.search(key):
                continue
            if key not in after[dom]:
                deletes.append(
                    f"defaults{flag} delete {shlex.quote(dom)} {shlex.quote(key)}")
    return writes, deletes

print("Capturing current settings...")
b_user, bf_user = snapshot([])
b_host, bf_host = snapshot(["-currentHost"])

# stdin carries this program (heredoc), so read the keypress from the
# terminal directly
print("Change ONE setting in System Settings now, wait 2s, then press Enter... ",
      end="", flush=True)
try:
    with open("/dev/tty") as tty:
        tty.readline()
except OSError:
    print("(no terminal available — snapshotting immediately)", end="")
print()

a_user, af_user = snapshot([])
a_host, af_host = snapshot(["-currentHost"])

w1, d1 = diff(b_user, a_user, False, bf_user | af_user)
w2, d2 = diff(b_host, a_host, True, bf_host | af_host)
lines, deletes = w1 + w2, d1 + d2

if deletes:
    print("\nKeys this change removed (info only, NOT appended — macOS often")
    print("deletes a key to mean 'back to default'):")
    for d in deletes:
        print("  " + d)

if not lines:
    if not deletes:
        print("No preference change detected — the change may not have registered yet;")
        print("re-run and wait a moment before pressing Enter.")
    else:
        print("\nNo new values to append.")
    sys.exit(1)

if len(lines) > 12:
    print(f"Detected {len(lines)} changed keys — too many for one setting; this is")
    print("probably background churn. Nothing appended; re-run and change only one thing:")
    for l in lines:
        print("  " + l)
    sys.exit(1)

print("\nDetected:")
for l in lines:
    print("  " + l)

with open(DEFAULTS_FILE) as f:
    content = f.read()

MARK = ("###############################################################################\n"
        "# Kill affected applications")
block = ("# Captured with capture-setting.sh — review, comment, move to a section\n"
         + "\n".join(lines) + "\n\n")
if MARK in content:
    content = content.replace(MARK, block + MARK, 1)
else:
    # Never append at EOF: the FAILED_ITEMS summary there can `exit 1`
    # before reaching lines placed after it
    raise SystemExit("ERROR: insertion mark not found in .defaults — "
                     "was the 'Kill affected applications' banner reworded?")
with open(DEFAULTS_FILE, "w") as f:
    f.write(content)

print(f"\nAppended {len(lines)} line(s) to .defaults ✓ — review with: git diff .defaults")
PY
