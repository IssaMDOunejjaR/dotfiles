#!/bin/bash
# CachyOS/Arch dependency installation. Does not apply or overwrite dotfiles.
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
dry_run=false
amd=false
enable_services=false
upgrade=false
bootstrap_user=false
set_shell=false
profiles=()

usage() {
  cat <<'EOF'
Usage: bash setup/install.sh [options]

  --dry-run          Report missing packages/actions without changing anything.
  --amd              Include AMD Mesa and 32-bit gaming packages (multilib needed).
  --enable-services  Enable Bluetooth/power/audio services, plus Docker with --docker.
  --upgrade          Request a full system upgrade even if no packages are missing.
  --rust             Include distro Rust, Rust Analyzer, and standard-library sources.
  --docker           Include Docker/lazydocker (no docker group changes).
  --posting          Include Posting and its fx JSON pager.
  --java             Install SDKMAN only; select/install your JDK manually.
  --sddm-theme       Deploy Chili only with an existing Qt5-compatible SDDM greeter.
  --bootstrap-user   Download configured Zsh/tmux plugins (apply dotfiles first).
  --set-shell        Opt into changing your login shell to Zsh using chsh.
  --help             Show this help.

Run as your regular user, not with sudo. Privileged commands request sudo as needed.
Installed packages/providers and already-running enabled services are skipped.
Yay handles repository and AUR packages; AUR review prompts remain interactive.
Velocitty (valvesky) uses its verified official release, not the unrelated AUR package.
EOF
}

for arg in "$@"; do
  case "$arg" in
    --dry-run) dry_run=true ;;
    --amd) amd=true ;;
    --enable-services) enable_services=true ;;
    --upgrade) upgrade=true ;;
    --rust|--docker|--posting|--java|--sddm-theme) profiles+=("${arg#--}") ;;
    --bootstrap-user) bootstrap_user=true ;;
    --set-shell) set_shell=true ;;
    --help|-h) usage; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$arg" >&2; usage >&2; exit 2 ;;
  esac
done

if ((EUID == 0)) && ! "$dry_run"; then
  echo 'Run this script as your regular user; yay/makepkg must not run as root.' >&2
  exit 1
fi
command -v pacman >/dev/null || { echo 'This installer requires CachyOS/Arch (pacman).' >&2; exit 1; }

packages=()
load_packages() {
  local line
  while IFS= read -r line || [[ -n "$line" ]]; do
    line=${line%%#*}
    [[ -n "$line" ]] || continue
    [[ "$line" =~ ^[a-zA-Z0-9@._+-]+$ ]] || {
      printf 'Invalid package entry: %s\n' "$line" >&2; exit 1;
    }
    packages+=("$line")
  done < "$1"
}
load_packages "$script_dir/packages.txt"
if "$amd"; then
  load_packages "$script_dir/packages-amd.txt"
fi
declare -A selected=()
for profile in "${profiles[@]}"; do
  if [[ ! -v selected[$profile] ]]; then
    selected[$profile]=1
    load_packages "$script_dir/profiles/$profile.txt"
  fi
done

if [[ -v selected[rust] ]] && pacman -Qq rustup >/dev/null 2>&1; then
  echo 'The distro Rust profile conflicts with an existing rustup setup. Resolve the toolchain choice manually; nothing was replaced.' >&2
  exit 1
fi

# Fail before installing anything if an explicitly requested legacy theme would
# be incompatible. This does not install/switch a display manager.
if [[ -v selected[sddm-theme] ]]; then
  bash "$script_dir/install-sddm-theme.sh" --check
fi

missing=()
for package in "${packages[@]}"; do
  # -T checks dependency satisfaction, including providers (e.g. hyprland-git).
  if pacman -T "$package" >/dev/null; then
    printf 'Installed: %s (skip)\n' "$package"
  else
    status=$?
    [[ "$status" == 127 ]] || { echo "pacman dependency check failed: $package" >&2; exit "$status"; }
    missing+=("$package")
  fi
done

if ((${#missing[@]})); then
  printf 'Missing packages: %s\n' "${missing[*]}"
else
  echo 'All requested packages are already installed.'
fi

have_yay=false
if command -v yay >/dev/null; then
  have_yay=true
  echo 'yay is available (skip bootstrap).'
fi

if "$dry_run"; then
  "$have_yay" || echo 'Would install yay from the repositories, or build it from the official AUR PKGBUILD.'
  if ((${#missing[@]})) || "$upgrade" || ! "$have_yay"; then
    echo 'Would run a full pacman -Syu before installing missing packages (no partial upgrades).'
  fi
  ((${#missing[@]} == 0)) || echo 'Would install only the missing packages using yay -S --needed.'
  if "$enable_services"; then
    echo 'Would check/enable Bluetooth, power profiles, and user audio services; Docker only with --docker.'
  fi
  bash "$script_dir/install-velocitty.sh" --dry-run
  bash "$script_dir/install-node.sh" --dry-run
  [[ ! -v selected[java] ]] || bash "$script_dir/install-sdkman.sh" --dry-run
  [[ ! -v selected[sddm-theme] ]] || bash "$script_dir/install-sddm-theme.sh" --dry-run
  ! "$bootstrap_user" || bash "$script_dir/bootstrap-user.sh" --dry-run
  ! "$set_shell" || echo 'Would check the login-shell database and request chsh to Zsh if needed.'
  exit 0
fi

if ((${#missing[@]})) || "$upgrade" || ! "$have_yay"; then
  # Never refresh the databases and then perform a partial upgrade with -Sy.
  sudo pacman -Syu
fi

if ! "$have_yay"; then
  if pacman -Si yay >/dev/null 2>&1; then
    sudo pacman -S --needed yay
  else
    sudo pacman -S --needed git base-devel
    build_dir=$(mktemp -d "${TMPDIR:-/tmp}/hypr-yay.XXXXXXXX")
    cleanup() { rm -rf -- "$build_dir"; }
    trap cleanup EXIT
    git clone https://aur.archlinux.org/yay.git "$build_dir/yay"
    (cd -- "$build_dir/yay" && makepkg -si)
  fi
fi

if ((${#missing[@]})); then
  yay -S --needed "${missing[@]}"
fi

bash "$script_dir/install-velocitty.sh"
bash "$script_dir/install-node.sh"
[[ ! -v selected[java] ]] || bash "$script_dir/install-sdkman.sh"

# The pinned Treesitter main branch requires Neovim 0.12+ and CLI 0.26.1+.
python3 "$script_dir/check-editor.py"
! "$bootstrap_user" || bash "$script_dir/bootstrap-user.sh"
[[ ! -v selected[sddm-theme] ]] || bash "$script_dir/install-sddm-theme.sh"

if [[ ! -s "${XDG_CONFIG_HOME:-$HOME/.config}/user-dirs.dirs" ]] && command -v xdg-user-dirs-update >/dev/null; then
  # Initialize standard folders once; leave existing user settings alone.
  xdg-user-dirs-update
fi

enable_service() {
  local scope=$1 unit=$2
  local command=(systemctl)
  if [[ "$scope" == user ]]; then
    command+=(--user)
  else
    command=(sudo systemctl)
  fi
  if "${command[@]}" is-enabled --quiet "$unit" && "${command[@]}" is-active --quiet "$unit"; then
    printf 'Service ready: %s (skip)\n' "$unit"
  else
    "${command[@]}" enable --now "$unit"
  fi
}

if "$enable_services"; then
  enable_service system bluetooth.service
  enable_service system power-profiles-daemon.service
  enable_service user pipewire.socket
  enable_service user pipewire-pulse.socket
  enable_service user wireplumber.service
  if [[ -v selected[docker] ]]; then
    enable_service system docker.service
  fi
fi

if "$set_shell"; then
  zsh_path=$(command -v zsh)
  current_shell=$(getent passwd "$(id -un)" | cut -d: -f7)
  if [[ "$(readlink -f -- "$current_shell")" == "$(readlink -f -- "$zsh_path")" ]]; then
    echo 'Zsh is already your login shell (skip).'
  else
    grep -Fxq "$zsh_path" /etc/shells || { echo "$zsh_path is not listed in /etc/shells." >&2; exit 1; }
    chsh -s "$zsh_path"
  fi
fi

echo 'Requested dependencies/actions are ready. Waybar remains manual; networking services were not changed.'
