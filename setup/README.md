# CachyOS Hyprland setup

Run from this checkout as your regular user (not `sudo`):

```bash
bash setup/install.sh --dry-run
bash setup/install.sh
# This desktop has an AMD GPU; optional 32-bit Steam/Proton support:
bash setup/install.sh --amd
# Optional: enable/start Bluetooth, power profiles, and user audio:
bash setup/install.sh --enable-services
```

`packages.txt` covers the active Hyprland modules, scripts, Waybar helper apps,
capture/clipboard tools, portals, fonts, and basic gaming diagnostics.
Yay resolves both CachyOS/repository and AUR packages (including `wayfreeze` and
`calcure` where necessary). If yay is absent, the installer tries the repositories
first, then builds the official AUR PKGBUILD. Review AUR prompts before accepting.

## Reruns and safety

- Installed dependencies **and virtual providers** are checked with `pacman -T`.
  Only missing packages are requested with `yay -S --needed`.
- There are no fragile "done" marker files. Failed or interrupted runs can be
  retried; removing a dependency makes the next run reinstall it.
- A full `pacman -Syu` runs before a package transaction. No `-Sy` partial upgrades.
  A fully satisfied rerun skips upgrades unless `--upgrade` is supplied.
- `--dry-run` makes no changes. `--enable-services` checks existing state before
  enabling/starting services. Log into a normal user session for user services.
- This does **not** apply dotfiles, switch display managers, enable Waybar,
  configure fingerprint authentication, install Steam, or change networking.
- `--amd` requires multilib. Without it, GPU drivers remain the OS install's choice.
  Do not use it on an NVIDIA-only machine. Other GPUs need their own driver stack.
- `impala` needs an existing working iwd setup. Installing it does not switch a
  NetworkManager/wpa_supplicant installation to iwd; do not enable competing network
  daemons. `power-profiles-daemon` may conflict with another power manager; review
  package/service prompts if using TLP or tuned.
- `setup/install.sh` is the supported installer; obsolete installers and legacy
  Hyprland fragments have been removed.

## Apply the configuration

Back up existing files, preview changes, and apply only the desktop targets:

```bash
chezmoi diff ~/.config/hypr ~/.config/waybar ~/.config/rofi ~/.config/swaync ~/.config/wlogout
chezmoi apply ~/.config/hypr ~/.config/waybar ~/.config/rofi ~/.config/swaync ~/.config/wlogout
hyprctl reload
hyprctl configerrors
```

Hyprland **0.57+** and its Lua API are required. `hyprland.lua` is authoritative;
`hyprland.conf` is only a retirement notice. Wallpaper templates use the current
ChezMoi source directory, so keep the checkout and its wallpaper asset available.
[Velocitty by valvesky](https://github.com/valvesky/velocitty) is the default for
Hyprland, `$TERMINAL`/Waybar helpers, and Rofi. The installer skips an existing
`velocitty` executable; otherwise `install-velocitty.sh` downloads the pinned
`v1.3.0-hotfix2` GNU/Linux release, verifies its published SHA256 checksum, and
uses upstream's `sudo make install PREFIX=/usr/local` (binary, desktop entry,
icon, and manual page). Existing installs are not auto-upgraded.
The AUR package named `velocitty` belongs to **xapp-project**, not valvesky, so
do not install that package for this setup. Yay still handles other dependencies.
The helper supports x86_64 and aarch64; CachyOS itself targets x86_64.
Waybar's `waybar-kitty` class is just a retained window-rule identifier and works
with Velocitty's `--class` option; no Kitty configuration is needed.
`Super+Shift+B` is still the only Waybar start/stop binding.

Log out and back in after initial setup/environment changes. Hyprland reloads do
not rerun startup hooks or remove driver variables inherited by existing apps.
The monitor profile matches the MSI display by description; unknown displays use
their preferred mode. Only the Logitech G502 receives flat pointer acceleration.

Calcure's `config.ini` is managed, but its event/task CSVs and logs stay local and
are ignored by both Git and ChezMoi. Back up personal calendar/task data separately.
Tool caches (`.ruff_cache`, `.pytest_cache`, `__pycache__`) and Python bytecode are
also excluded from version control and deployment. Keep Neovim's `lazy-lock.json`:
it is a reproducibility lockfile, not a disposable cache.

## Interactive acceptance checklist

- Lock/unlock with the password, then test suspend/resume and screen-off/wake.
  Idle and helper scripts use the Lua dispatcher API required by Hyprland 0.57+.
- Play a fullscreen movie/YouTube video longer than five minutes: it should not
  lock. Apps must advertise video content or a native idle inhibitor; add a narrow
  app-specific fullscreen rule if they do neither. Do not blanket-inhibit browsers
  when no video is playing.
- In a fullscreen game, check `hyprctl monitors -j` for VRR. Mode 3 depends on game/
  video content hints; if a game lacks them, assess mode 2 or its app configuration.
- Tearing is restricted to game-content fullscreen windows and CS2. It remains
  experimental; monitor diagnostics describe blockers. Do not force cursor hacks
  merely to remove a blocker. Movies are not opted into tearing.
- Test `Print`, `Shift+Print`, clipboard history (`Super+A`), output selection
  (`Super+Mute`), recording (`Alt+Print`), and a short recording with audio:
  `~/.config/hypr/scripts/screen-recorder --with-audio`.
- Check a browser/OBS screen share through the Hyprland portal.
- The desktop idle policy locks after 300s and disables displays after 370s;
  backlight dimming is intentionally omitted for an external monitor. Use DDC/CI
  separately if you want physical monitor brightness control.

## Checks without installing anything

```bash
bash -n setup/install.sh setup/install-velocitty.sh
python3 setup/tests/test_desktop.py
```
