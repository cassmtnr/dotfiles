#!/usr/bin/env bash
# vps-run.sh — Run a command on a remote server in the project's app directory.
# Reads connection details from .claude/vps.env in the current working directory.
#
# Required .claude/vps.env variables:
#   VPS_SSH_HOST  — SSH host alias or user@host (e.g., "tars", "deploy@10.0.0.1")
#   VPS_APP_DIR   — Remote directory to cd into (e.g., "apps/ai-trading")
#
# Usage: vps-run.sh <command>
# Examples:
#   vps-run.sh 'tail -100 logs/bot.log'
#   vps-run.sh 'docker compose logs --tail 50'
#   vps-run.sh 'systemctl status myapp'

set -euo pipefail

# Find .claude/vps.env by walking up from cwd
find_config() {
  local dir="$PWD"
  while [ "$dir" != "/" ]; do
    if [ -f "$dir/.claude/vps.env" ]; then
      echo "$dir/.claude/vps.env"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  return 1
}

CONFIG=$(find_config) || {
  echo "Error: No .claude/vps.env found in project hierarchy." >&2
  echo "Create one with VPS_SSH_HOST and VPS_APP_DIR." >&2
  exit 1
}

# shellcheck source=/dev/null
source "$CONFIG"

if [ -z "${VPS_SSH_HOST:-}" ]; then
  echo "Error: VPS_SSH_HOST not set in $CONFIG" >&2
  exit 1
fi

if [ -z "${VPS_APP_DIR:-}" ]; then
  echo "Error: VPS_APP_DIR not set in $CONFIG" >&2
  exit 1
fi

if [ $# -eq 0 ]; then
  echo "Usage: vps-run.sh <command>" >&2
  echo "Runs the command on $VPS_SSH_HOST in ~/$VPS_APP_DIR/" >&2
  exit 1
fi

ssh "$VPS_SSH_HOST" "cd \"$VPS_APP_DIR\" && $*"
