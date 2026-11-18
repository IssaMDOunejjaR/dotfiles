#!/bin/bash
# Deploy the bundled Qt6 Chili port after the profile's packages are installed.
set -euo pipefail
script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
case "${1:-}" in
  --check|--dry-run|'') ;;
  *) echo 'Usage: bash setup/install-sddm-theme.sh [--check|--dry-run]' >&2; exit 2 ;;
esac
(($# <= 1)) || exit 2
theme="$script_dir/../srcs/sddm/themes/chili"
[[ -f "$theme/Main.qml" && -f "$theme/metadata.desktop" ]] || { echo 'Bundled Chili theme files are missing.' >&2; exit 1; }
[[ "${1:-}" != --check ]] || exit 0
if [[ "${1:-}" == --dry-run ]]; then
  echo 'Would deploy Qt6 Chili with backups and enable SDDM + graphical boot for next boot (no restart or replacement of another display manager).'
  exit 0
fi
((EUID != 0)) || { echo 'Run theme setup as your regular user.' >&2; exit 1; }
greeter=$(command -v sddm-greeter-qt6 || command -v sddm-greeter || true)
if [[ -z "$greeter" ]] || ! ldd "$greeter" | grep -q 'libQt6Quick\.so'; then
  echo 'A Qt6 SDDM greeter is missing after package installation. Check your repository SDDM package.' >&2
  exit 1
fi
manager=$(systemctl show --property=Id --value display-manager.service 2>/dev/null || true)
if [[ -n "$manager" && "$manager" != sddm.service && "$manager" != display-manager.service ]]; then
  printf 'Another display manager is configured (%s); refusing to replace it. Disable it explicitly before rerunning this profile.\n' "$manager" >&2
  exit 1
fi
sudo python3 "$script_dir/deploy-sddm-theme.py" "$theme"
if ! systemctl is-enabled --quiet sddm.service; then
  sudo systemctl enable sddm.service
fi
if [[ "$(systemctl get-default)" != graphical.target ]]; then
  sudo systemctl set-default graphical.target
fi
echo 'SDDM + Chili are configured for the next boot. The current graphical session was not restarted.'
