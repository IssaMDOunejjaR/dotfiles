#!/bin/bash
# Download configured plugins only on request, never inside normal shell startup.
set -euo pipefail
dry_run=false
case "${1:-}" in
  --dry-run) dry_run=true ;;
  '') ;;
  *) echo 'Usage: bash setup/bootstrap-user.sh [--dry-run]' >&2; exit 2 ;;
esac
(($# <= 1)) || exit 2
config_home=${XDG_CONFIG_HOME:-$HOME/.config}
zsh_dir=$config_home/zsh
tmux_dir=$config_home/tmux
if "$dry_run"; then
  echo "Would bootstrap configured Zsh and TPM/tmux plugins below $config_home (apply configs first)."
  exit 0
fi
((EUID != 0)) || { echo 'Run plugin bootstrap as your regular user.' >&2; exit 1; }
for config in "$zsh_dir/plugins.zsh" "$tmux_dir/tmux.conf"; do
  [[ -s "$config" ]] || { echo "Apply the managed config before bootstrapping: $config" >&2; exit 1; }
done
work=''
trap '[[ -z "$work" ]] || rm -rf -- "$work"' EXIT
clone_plugin() {
  local repository=$1 destination=$2
  [[ "$repository" =~ ^[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+$ ]] || {
    echo "Unsupported plugin repository: $repository" >&2; exit 1;
  }
  if [[ -e "$destination" ]]; then
    git -C "$destination" rev-parse --git-dir >/dev/null 2>&1 || {
      echo "Not a Git checkout; inspect before retrying: $destination" >&2; exit 1;
    }
    echo "Plugin present: $repository (skip)"
    return
  fi
  mkdir -p -- "$(dirname -- "$destination")"
  work=$(mktemp -d "$(dirname -- "$destination")/.bootstrap.XXXXXXXX")
  git clone --depth=1 --recurse-submodules "https://github.com/$repository.git" "$work/plugin"
  mv -- "$work/plugin" "$destination"
  rmdir -- "$work"
  work=''
}
while read -r owner plugin; do
  clone_plugin "$owner/$plugin" "$zsh_dir/plugins/$plugin"
done < <(awk '/^_zplugin_load / { print $2, $3 }' "$zsh_dir/plugins.zsh")
# Parse the same @plugin declarations TPM reads. No server/session is started,
# and plugin code (including session restore hooks) is not executed here.
while read -r repository; do
  clone_plugin "$repository" "$tmux_dir/plugins/${repository##*/}"
done < <(awk '/^set(-option)? +-g +@plugin / { gsub(/[\047\042]/, ""); print $4 }' "$tmux_dir/tmux.conf")
echo 'User plugins are downloaded. Reload Zsh/tmux when convenient; existing plugins were not updated.'
