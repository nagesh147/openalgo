#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/sync-development.sh [merge|rebase]

Sync routine:
1. Fast-forward local main from upstream/main
2. Push updated main to origin
3. Update development from main using merge (default) or rebase
4. Push development to origin
EOF
}

if [[ "${1:-merge}" == "-h" || "${1:-merge}" == "--help" ]]; then
  usage
  exit 0
fi

strategy="${1:-merge}"

if [[ "$strategy" != "merge" && "$strategy" != "rebase" ]]; then
  echo "Invalid strategy: $strategy" >&2
  usage >&2
  exit 1
fi

repo_root="$(git rev-parse --show-toplevel)"
current_branch="$(git rev-parse --abbrev-ref HEAD)"

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Working tree is not clean. Commit or stash changes before syncing." >&2
  exit 1
fi

cd "$repo_root"

restore_branch() {
  if [[ "$current_branch" != "main" && "$current_branch" != "development" ]]; then
    git switch "$current_branch" >/dev/null
  fi
}

trap restore_branch EXIT

echo "Fetching latest refs..."
git fetch upstream
git fetch origin

echo "Syncing main with upstream/main..."
git switch main >/dev/null
git merge --ff-only upstream/main
git push origin main

echo "Syncing development from main using $strategy..."
git switch development >/dev/null

if [[ "$strategy" == "merge" ]]; then
  git merge --no-edit main
  git push origin development
else
  git rebase main
  git push --force-with-lease origin development
fi

echo "Development sync complete."
