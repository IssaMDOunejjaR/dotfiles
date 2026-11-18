#!/bin/bash
# Provision Node through distro-packaged fnm without modifying shell rc files.
set -euo pipefail
dry_run=false
case "${1:-}" in
  --dry-run) dry_run=true ;;
  '') ;;
  *) echo 'Usage: bash setup/install-node.sh [--dry-run]' >&2; exit 2 ;;
esac
(($# <= 1)) || exit 2
if "$dry_run"; then
  echo 'Would check fnm default Node (22+ with npm), installing LTS only if needed.'
  exit 0
fi
((EUID != 0)) || { echo 'Run Node provisioning as your regular user.' >&2; exit 1; }
command -v fnm >/dev/null || { echo 'Install fnm first.' >&2; exit 1; }
version=$(fnm exec --using default node --version 2>/dev/null || true)
if [[ "$version" =~ ^v([0-9]+)\. ]] && ((BASH_REMATCH[1] >= 22)) &&
  fnm exec --using default npm --version >/dev/null 2>&1; then
  printf 'fnm default Node %s and npm are ready (skip).\n' "$version"
else
  echo 'Installing a supported Node LTS through fnm and setting its default alias.'
  fnm install --lts
  fnm default lts-latest
  fnm exec --using default node --version
  fnm exec --using default npm --version
fi
