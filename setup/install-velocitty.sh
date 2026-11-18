#!/bin/bash
# Install valvesky/velocitty, NOT the unrelated AUR package with the same name.
set -euo pipefail

dry_run=false
case "${1:-}" in
  --dry-run) dry_run=true ;;
  '') ;;
  *) echo 'Usage: bash setup/install-velocitty.sh [--dry-run]' >&2; exit 2 ;;
esac
(( $# <= 1 )) || exit 2

if command -v velocitty >/dev/null; then
  printf 'Velocitty executable available: %s (skip installation).\n' "$(command -v velocitty)"
  exit 0
fi

# Pin the release so reruns/fresh installs use the same artifact.
version=1.3.0-hotfix2
case "$(uname -m)" in
  x86_64) arch=x86_64 ;;
  aarch64) arch=aarch64 ;;
  *) echo 'No supported Velocitty GNU/Linux release for this architecture.' >&2; exit 1 ;;
esac

if "$dry_run"; then
  echo "Would install valvesky/velocitty v$version ($arch) to /usr/local after SHA256 verification."
  exit 0
fi
if (( EUID == 0 )); then
  echo 'Run as your regular user; only make install requests sudo.' >&2
  exit 1
fi

archive="velocitty-$version-$arch-linux-gnu.tar.gz"
base_url="https://github.com/valvesky/velocitty/releases/download/v$version"
work_dir=$(mktemp -d "${TMPDIR:-/tmp}/velocitty-install.XXXXXXXX")
trap 'rm -rf -- "$work_dir"' EXIT
curl --fail --location --retry 3 --output "$work_dir/$archive" "$base_url/$archive"
curl --fail --location --retry 3 --output "$work_dir/SHA256SUMS" "$base_url/SHA256SUMS"

# Verify exactly the requested archive before extraction or elevated installation.
checksum=$(awk -v file="$archive" '$2 == file || $2 == "*" file { print $1 }' "$work_dir/SHA256SUMS")
[[ "$checksum" =~ ^[0-9a-fA-F]{64}$ ]] || { echo 'Missing/invalid Velocitty checksum.' >&2; exit 1; }
(
  cd -- "$work_dir"
  if ! printf '%s  %s\n' "$checksum" "$archive" | sha256sum --check --status; then
    echo 'Velocitty checksum verification failed; nothing was installed.' >&2
    exit 1
  fi
  tar --extract --gzip --no-same-owner --file "$archive"
  cd -- "${archive%.tar.gz}"
  sudo make install PREFIX=/usr/local
)
