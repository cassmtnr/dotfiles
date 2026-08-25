#!/bin/sh
# node launcher for AI hooks. Hooks run under /bin/sh, which never loads
# nvm — this shim (linked as ~/.local/bin/node) resolves nvm's current
# default at call time, so node upgrades don't leave a dangling versioned
# symlink behind.
NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

# Fast path: follow the alias file chain in plain sh — hooks fire on every
# Bash call, so sourcing nvm.sh each time is too slow
v=default
i=0
while [ -r "$NVM_DIR/alias/$v" ] && [ "$i" -lt 5 ]; do
    v="$(cat "$NVM_DIR/alias/$v")"
    i=$((i + 1))
done
for cand in "$NVM_DIR/versions/node/$v/bin/node" "$NVM_DIR/versions/node/v$v/bin/node"; do
    if [ -x "$cand" ]; then
        exec "$cand" "$@"
    fi
done

# Fallback: the alias resolved to a version that isn't installed (lts/*
# alias files track the latest *released* LTS, not what's on disk) or to
# nothing at all. Use the newest installed version — hooks need a working
# node, not a specific one. Not `nvm which`: it hangs on uninstalled
# targets, and sourcing nvm.sh per hook call is too slow anyway.
newest=""
for cand in "$NVM_DIR/versions/node"/*/bin/node; do
    if [ -x "$cand" ]; then
        newest="$cand"
    fi
done
if [ -n "$newest" ]; then
    exec "$newest" "$@"
fi

echo "node-default.sh: no nvm-managed node found under $NVM_DIR" >&2
exit 127
