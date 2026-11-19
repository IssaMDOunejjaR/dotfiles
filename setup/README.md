# CachyOS Hyprland setup

Run from this checkout as your regular user (not `sudo`):

```bash
bash setup/install.sh --dry-run
bash setup/install.sh
# This desktop has an AMD GPU; optional 32-bit Steam/Proton support:
bash setup/install.sh --amd
# Optional profiles (combine only the ones you want):
bash setup/install.sh --rust --docker --posting --java
# Optional: enable/start Bluetooth, power profiles, user audio;
# Docker is included here only if --docker is also passed:
bash setup/install.sh --enable-services
```

`packages.txt` covers the desktop, shell, editor prerequisites, Go, lazygit,
Calcure + abook/Calcurse, NetworkManager UI tools, and basic gaming diagnostics.
Core shell tools include Zsh, tmux, Starship, zoxide, fzf, fd, ripgrep, bat, eza,
and less. Editor prerequisites include Python/pip/venv support, LuaRocks, unzip,
Tree-sitter CLI, build tools, and OpenCode. OpenCode/Copilot credentials remain
manual; project dependencies such as Jest and pytest stay in each project.
Yay resolves both CachyOS/repository and AUR packages (including `wayfreeze` and
`calcure` where necessary). If yay is absent, the installer tries the repositories
first, then builds the official AUR PKGBUILD. **Package installation is
noninteractive:** pacman/makepkg/yay confirmations are accepted automatically,
and yay's clean-build/diff/edit menus are skipped. AUR packages run third-party
build scripts: only use package sources you trust. Checksums/signature checks
are not disabled, and unresolvable conflicts still stop the run.

| Flag | Additional behavior |
| --- | --- |
| `--rust` | Distro Rust/Cargo, Rust Analyzer, and standard-library sources; refuses an existing rustup setup instead of replacing it. |
| `--docker` | Docker and lazydocker; add your user to the `docker` group. Daemon activation requires `--enable-services` too. |
| `--posting` | Posting and the `fx` JSON pager used by its config. |
| `--java` | SDKMAN manager only, plus its prerequisites; **no JDK is installed or selected**. |
| `--sddm-theme` | Install SDDM + Qt6 Chili with backups; enable SDDM for next boot without restarting the current session. |
| `--bootstrap-user` | Download declared Zsh/tmux plugins after dotfiles are applied. |
| `--set-shell` | Use the setup sudo session to change your login shell to Zsh only if it differs. |

Unselected profiles do not uninstall anything. Aliases for lf, kubectl/kubecolor,
and the mpv camera stream are available only when their commands exist; these
apps are not installed. Set `CAMERA_DEVICE` if you use something other than
`/dev/video4`. Lazydocker's alias is similarly conditional on its profile/app.

## Node, Java, and Neovim

- The core installs **fnm**, not a distro Node/npm package. `install-node.sh`
  preserves a working fnm default Node 22+ with npm; otherwise it installs the
  current LTS and sets the default alias. Reruns do not upgrade a working runtime.
  Zsh initializes `fnm env --use-on-cd`; per-project version files are respected.
- Neovim also discovers fnm's default for launches that bypass Zsh, without
  overriding an active fnm project selection. SDKMAN's selected Java is exposed
  to such launches via `JAVA_HOME` or its `candidates/java/current` link.
- `--java` downloads and runs the official `get.sdkman.io` installer with
  `rcupdate=false&ci=true`. It does not edit shell rc files, and refuses to replace
  an incomplete existing SDKMAN directory. In a new Zsh shell, use `sdk list java`
  and `sdk install java <JDK-id>` yourself. **Current JDTLS requires Java 25+**;
  project source compatibility can still target older Java versions.
- Missing Node/npm, Go, Cargo, LuaRocks, or a suitable JDK produces a specific
  editor hint instead of repeated doomed Mason installation attempts. Restart
  Neovim after adding toolchains. Rust Analyzer comes from `--rust`, not Mason.
- Mason installs isolated editor tools on demand; Python project test runners
  belong in project virtual environments. No global pip installs are performed.
- The pinned Treesitter main branch requires **Neovim 0.12+** and distro
  **Tree-sitter CLI 0.26.1+**, checked after package installation. It loads eagerly,
  uses the new parser-install API, and starts highlighting/indentation after an
  asynchronous install completes. First use may require network access.

## Reruns and safety

- Installed dependencies **and virtual providers** are checked with `pacman -T`.
  Only missing packages are requested with `yay -S --needed --noconfirm`.
- After the read-only checks, setup authenticates with `sudo -v` once and refreshes
  the timestamp every 50 seconds until it exits (including on failure/signals).
  The refresher never prompts in the background. Passwords are never stored and
  sudoers is not modified. Standard sudo policies normally need one password for
  the run; policies that disable or isolate credential caching, credential
  revocation, and package-specific authentication can still require another.
- There are no fragile "done" marker files. Failed or interrupted runs can be
  retried; removing a dependency makes the next run reinstall it.
- A full `pacman -Syu` runs before a package transaction. No `-Sy` partial upgrades.
  A fully satisfied rerun skips upgrades unless `--upgrade` is supplied.
- `--dry-run` makes no changes. `--enable-services` checks existing state before
  enabling/starting services. Log into a normal user session for user services.
- This does **not** apply dotfiles, replace another display manager, enable Waybar,
  configure fingerprint authentication, install Steam, change network services,
  or add your user to groups except `docker` when `--docker` is selected.
  Login shell/theme changes require their own flags.
- `--amd` requires multilib. Without it, GPU drivers remain the OS install's choice.
  Do not use it on an NVIDIA-only machine. Other GPUs need their own driver stack.
- Network actions now use `nmcli`/`nmtui`, supplied by NetworkManager. No iwd/impala
  dependency or automatic network migration is introduced. If another manager
  controls your network, plan the switch manually; never enable competing daemons.
  `power-profiles-daemon` may conflict with TLP/tuned; resolve conflicts explicitly
  instead of forcing package removals.
- Docker access through the `docker` group is **root-equivalent**. Selecting
  `--docker` explicitly opts into adding the current user to that group; existing
  memberships are skipped and other groups are preserved. Log out and back in
  (or reboot the VM) afterward. Setup does not launch a `newgrp` shell or configure
  rootless Docker. Starting/enabling the daemon still requires `--enable-services`.
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

Apply shell/editor targets separately, after inspecting any personal differences:

```bash
chezmoi diff ~/.zshenv ~/.config/zsh ~/.config/tmux ~/.config/nvim ~/.config/calcure
chezmoi apply ~/.zshenv ~/.config/zsh ~/.config/tmux ~/.config/nvim ~/.config/calcure
bash setup/install.sh --bootstrap-user
# Only if you also want Zsh as your login shell:
bash setup/install.sh --set-shell
```

`~/.zshenv` redirects to the XDG Zsh config; no system `/etc/zsh/zshenv` edit is
needed. Interactive startup creates its history/cache directories. Bootstrap
clones the five declared Zsh plugins and ten TPM/tmux plugins into XDG paths,
skipping existing Git checkouts without updating them. It does **not** start a
tmux server, execute downloaded plugin code, or restore sessions. Startup skips
missing Zsh plugins with a hint instead of cloning on its own. Some tmux plugins
can still fetch their own helper binaries on first actual use. Review those
upstream behaviors before running them. TPM updates remain a deliberate action.

## Optional SDDM + Chili profile

```bash
bash setup/install.sh --dry-run --sddm-theme
bash setup/install.sh --sddm-theme
```

This profile works on a fresh VM: it installs **SDDM**, its Xorg greeter server,
and Qt6 QML/effects/SVG/virtual-keyboard dependencies. The bundled Chili theme is
ported to Qt6 Quick Controls; its `QtVersion=6` metadata selects the Qt6 greeter.
There is no requirement to preinstall a Qt5 greeter or legacy Qt5 packages.

It backs up changed theme/config files to `/var/backups/chezmoi-sddm/`, merges
the retained assets into `/usr/share/sddm/themes/chili`, and changes only the
`Current`/`ThemeDir` keys in `/etc/sddm.conf`. Existing extra theme files are
preserved; symlinked theme trees are refused. Reruns skip matching contents.
The profile **enables SDDM for the next boot**, independently of
`--enable-services`, and selects `graphical.target` as the boot default. It never
starts/restarts SDDM during setup or uses `--force`
to replace another display manager. If GDM/LightDM/etc. already owns
`display-manager.service`, disable that manager explicitly before rerunning.
Reboot the VM after applying your dotfiles to exercise the real login flow.
You can preview the theme first (no authentication or service changes):

```bash
sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/chili
```

Restoring the backup requires an administrator. The installer does not change
existing autologin, display-server, or session settings.

## Desktop notes

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

`Super+Shift+P` and Waybar's power button use `~/.config/hypr/scripts/logout-menu`.
It reads the managed wlogout layout, hides sleep actions logind cannot currently
perform, and uses a private temporary layout with shortcut hints, adaptive margins,
and a single-monitor menu. A Cancel tile fills a five-button layout because
wlogout 1.2.2 expects a complete rectangular grid. Concurrent launches are skipped;
temporary files and the menu lock are released when the menu exits.
Logout, shutdown, and reboot require a Rofi confirmation with Cancel selected by
default. Logout terminates only the current login session, never every session
belonging to the user. If the session cannot be identified, it fails safely.
Sleep capabilities are rechecked when selected. Lock and suspend retain Hypridle's
existing lock/readiness coordination; the menu never starts a second lock process.
Python, Rofi, busctl/loginctl, and wlogout are already covered by the base setup.

Log out and back in after initial setup/environment changes. Hyprland reloads do
not rerun startup hooks or remove driver variables inherited by existing apps.
The monitor profile matches the MSI display by description; unknown displays use
their preferred mode. Only the Logitech G502 receives flat pointer acceleration.

Calcure's `config.ini` is managed, but its event/task CSVs and logs stay local and
are ignored by both Git and ChezMoi. Back up personal calendar/task data separately.
Its enabled abook birthdays and Calcurse paths now have matching packages; setup
does not create or populate your address book/calendar data.
Tool caches (`.ruff_cache`, `.pytest_cache`, `__pycache__`) and Python bytecode are
also excluded from version control and deployment. Keep Neovim's `lazy-lock.json`:
it is a reproducibility lockfile, not a disposable cache.

## Interactive acceptance checklist

- Lock/unlock with the password, then test suspend/resume and screen-off/wake.
  Idle and helper scripts use the Lua dispatcher API required by Hyprland 0.57+.
- Open the logout menu from both entry points. Check shortcut hints, small-screen
  sizing, and cancellation of logout/shutdown/reboot before testing real actions.
  Verify unsupported Hibernate is hidden, and any separate SSH/TTY session survives
  a confirmed desktop logout. Power actions are never executed by automated tests.
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
for script in setup/*.sh; do bash -n "$script"; done
python3 -m unittest discover -s setup/tests -p 'test_*.py'
python3 setup/check-editor.py
bash setup/install.sh --dry-run
```

Tests mock package managers/network/system actions and use temporary HOME/XDG
directories. The editor regression uses `nvim -u NONE` with stubbed plugins;
it never loads your personal config or downloads parsers/tools. No dedicated
project typechecker is configured; run shell/Zsh/Lua syntax checks as well.
