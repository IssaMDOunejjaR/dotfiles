#!/bin/bash
# Chili uses Qt Quick Controls 1 and cannot run in a Qt6 greeter.
set -euo pipefail
script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
case "${1:-}" in
  --check|--dry-run|'') ;;
  *) echo 'Usage: bash setup/install-sddm-theme.sh [--check|--dry-run]' >&2; exit 2 ;;
esac
(($# <= 1)) || exit 2
greeter=$(command -v sddm-greeter || true)
if [[ -z "$greeter" ]] || ! ldd "$greeter" | grep -q 'libQt5Quick\.so'; then
  echo 'Chili requires an existing Qt5 SDDM greeter. Qt6 is incompatible; no theme/system changes made.' >&2
  exit 1
fi
[[ "${1:-}" != --check ]] || exit 0
if [[ "${1:-}" == --dry-run ]]; then
  echo 'Would back up changed SDDM theme/config files under /var/backups, deploy Chili, and select it; never enable/restart SDDM.'
  exit 0
fi
((EUID != 0)) || { echo 'Run theme setup as your regular user.' >&2; exit 1; }
sudo python3 "$script_dir/deploy-sddm-theme.py" "$script_dir/../srcs/sddm/themes/chili"
