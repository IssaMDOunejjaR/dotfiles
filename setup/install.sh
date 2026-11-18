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
  --docker           Include Docker/lazydocker and add your user to the docker group.
  --posting          Include Posting and its fx JSON pager.
  --java             Install SDKMAN only; select/install your JDK manually.
  --sddm-theme       Install SDDM + Qt6 Chili; enable SDDM for the next boot.
  --bootstrap-user   Download configured Zsh/tmux plugins (apply dotfiles first).
  --set-shell        Opt into changing your login shell to Zsh using chsh.
  --help             Show this help.

Run as your regular user, not with sudo. Sudo is validated once and refreshed until exit.
Installed packages/providers and already-running enabled services are skipped.
Package confirmations are automatic, including AUR builds (only use trusted sources).
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

# Validate the bundled source, not a greeter that may not be installed yet.
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
    echo 'Would run a full pacman -Syu --noconfirm before installing missing packages (no partial upgrades).'
  fi
  ((${#missing[@]} == 0)) || echo 'Would install only the missing packages using yay -S --needed --noconfirm (AUR review menus skipped).'
  echo 'Would validate sudo once and keep its timestamp alive until setup exits.'
  [[ ! -v selected[docker] ]] || echo 'Would add your user to the docker group if needed (root-equivalent access; log out/in afterward).'
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

build_dir=''
sudo_refresh_pid=''
cleanup() {
  local status=$?
  trap - EXIT
  if [[ -n "$sudo_refresh_pid" ]]; then
    kill "$sudo_refresh_pid" 2>/dev/null || true
    wait "$sudo_refresh_pid" 2>/dev/null || true
  fi
  [[ -z "$build_dir" ]] || rm -rf -- "$build_dir"
  exit "$status"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
trap 'exit 129' HUP

# Keep the normal sudo policy: never store a password or modify sudoers.
sudo -v
(
  sleeper=''
  trap 'if [[ -n "$sleeper" ]]; then kill "$sleeper" 2>/dev/null || true; wait "$sleeper" 2>/dev/null || true; fi' EXIT
  trap 'exit 0' INT TERM HUP
  while true; do
    sleep 50 &
    sleeper=$!
    wait "$sleeper" || exit 0
    kill -0 "$$" 2>/dev/null || exit 0
    sudo -n -v || { echo 'Sudo refresh failed; later privileged steps may require authentication again.' >&2; exit 1; }
  done
) &
sudo_refresh_pid=$!

if ((${#missing[@]})) || "$upgrade" || ! "$have_yay"; then
  # Never refresh the databases and then perform a partial upgrade with -Sy.
  sudo pacman -Syu --noconfirm
fi

if ! "$have_yay"; then
  if pacman -Si yay >/dev/null 2>&1; then
    sudo pacman -S --needed --noconfirm yay
  else
    sudo pacman -S --needed --noconfirm git base-devel
    build_dir=$(mktemp -d "${TMPDIR:-/tmp}/hypr-yay.XXXXXXXX")
    git clone https://aur.archlinux.org/yay.git "$build_dir/yay"
    (cd -- "$build_dir/yay" && makepkg -si --noconfirm)
  fi
fi

if ((${#missing[@]})); then
  yay -S --needed --noconfirm --answerclean None --answerdiff None --answeredit None \
    --noremovemake --sudo sudo "${missing[@]}"
fi

if [[ -v selected[docker] ]]; then
  docker_user=$(id -un)
  if [[ " $(id -nG "$docker_user") " == *" docker "* ]]; then
    printf 'User %s is already in the docker group (skip).\n' "$docker_user"
  else
    echo 'The docker group grants root-equivalent access.'
    sudo usermod -aG docker "$docker_user"
    echo 'Docker group membership added. Log out and back in (or reboot the VM) for it to take effect.'
  fi
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
    sudo chsh -s "$zsh_path" "$(id -un)"
  fi
fi

echo 'Requested dependencies/actions are ready. Waybar remains manual; networking services were not changed.'
