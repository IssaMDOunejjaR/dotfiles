#!/bin/bash
# Explicit Java profile: install the manager, never choose a JDK for the user.
set -euo pipefail
dry_run=false
case "${1:-}" in
  --dry-run) dry_run=true ;;
  '') ;;
  *) echo 'Usage: bash setup/install-sdkman.sh [--dry-run]' >&2; exit 2 ;;
esac
(($# <= 1)) || exit 2
export SDKMAN_DIR=${SDKMAN_DIR:-$HOME/.sdkman}
if [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]]; then
  echo 'SDKMAN is installed (skip); JDK selection remains manual.'
  exit 0
fi
if "$dry_run"; then
  echo 'Would install SDKMAN from get.sdkman.io without editing rc files or installing Java.'
  exit 0
fi
((EUID != 0)) || { echo 'Run SDKMAN provisioning as your regular user.' >&2; exit 1; }
if [[ -e "$SDKMAN_DIR" ]]; then
  echo "Incomplete SDKMAN directory: $SDKMAN_DIR; inspect it before retrying." >&2
  exit 1
fi
installer=$(mktemp "${TMPDIR:-/tmp}/sdkman-installer.XXXXXXXX")
trap 'rm -f -- "$installer"' EXIT
# Official installer, explicitly requested by --java. No curl | shell pipeline.
curl --fail --location --retry 3 --output "$installer" 'https://get.sdkman.io?rcupdate=false&ci=true'
bash "$installer"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] || { echo 'SDKMAN installation did not complete.' >&2; exit 1; }
echo 'SDKMAN is ready. In a new Zsh shell: sdk list java; sdk install java <compatible-JDK-id>.'
