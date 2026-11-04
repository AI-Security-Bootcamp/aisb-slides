#!/usr/bin/env bash
# One-time setup per clone: use the versioned hooks in .githooks/
# (Git LFS hooks + a pre-push LaTeX build check) and fetch LFS files.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
git config core.hooksPath .githooks
git lfs install --local --skip-repo >/dev/null 2>&1 || git lfs install --skip-repo
git lfs pull
echo "Hooks enabled (core.hooksPath=.githooks)."
