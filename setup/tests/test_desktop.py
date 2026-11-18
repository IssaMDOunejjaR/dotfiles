#!/usr/bin/env python3
"""Isolated CLI regressions. Never install packages or contact the compositor."""

import io
import json
import os
import shutil
from pathlib import Path
import subprocess
import tarfile
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]

MOCK = r"""#!/usr/bin/env python3
import json, os, pathlib, sys, time
name = pathlib.Path(sys.argv[0]).name
args = sys.argv[1:]
state_path = pathlib.Path(os.environ["MOCK_STATE"])
state = json.loads(state_path.read_text())
with open(os.environ["MOCK_LOG"], "a") as log:
    log.write(json.dumps([name, *args]) + "\n")
if name == "pacman":
    if args[0] == "-Qq":
        sys.exit(0 if args[1] in state.get("installed", []) else 1)
    elif args[0] == "-T":
        sys.exit(0 if args[1] in state["installed"] + state.get("provided", []) else 127)
    if args[0] == "-Si":
        sys.exit(1 if os.environ.get("MOCK_YAY_AUR") else 0)
    if args[0] == "-S" and "yay" in args:
        (pathlib.Path(os.environ["MOCK_BIN"]) / "yay").symlink_to("mock")
elif name == "yay":
    if os.environ.get("MOCK_FAIL") == "1":
        sys.exit(1)
    values = iter(args)
    for arg in values:
        if arg in ("--answerclean", "--answerdiff", "--answeredit", "--sudo"):
            next(values)
        elif not arg.startswith("-"):
            state["installed"].append(arg)
    state_path.write_text(json.dumps(state))
elif name == "sudo":
    if args in (["-v"], ["-n", "-v"]):
        sys.exit(1 if os.environ.get("MOCK_AUTH_FAIL") else 0)
    if args[0] == "python3" and args[1].endswith("deploy-sddm-theme.py"):
        # Pure deployment tests exercise this against temporary files instead.
        sys.exit(0)
    os.execvp(args[0], args)
elif name == "sleep":
    if args == ["50"]:
        with open(os.environ["MOCK_SLEEP_PIDS"], "a") as pids:
            pids.write(str(os.getpid()) + "\n")
        marker = pathlib.Path(os.environ["MOCK_SLEEP_PIDS"] + ".refreshed")
        if os.environ.get("MOCK_REFRESH") == "1" and not marker.exists():
            marker.touch()
            sys.exit(0)
    time.sleep(float(args[0]))
elif name == "curl":
    import shutil
    target = pathlib.Path(args[args.index("--output") + 1])
    if "get.sdkman.io" in args[-1]:
        target.write_text('#!/bin/bash\nmkdir -p "$SDKMAN_DIR/bin"\nprintf "# SDKMAN stub\\n" > "$SDKMAN_DIR/bin/sdkman-init.sh"\n')
        sys.exit(0)
    fixture = pathlib.Path(os.environ["MOCK_ARCHIVE"])
    if args[-1].endswith("/SHA256SUMS"):
        import hashlib
        digest = hashlib.sha256(fixture.read_bytes()).hexdigest()
        if os.environ.get("MOCK_BAD_CHECKSUM") == "1":
            digest = "0" * 64
        target.write_text(digest + "  " + fixture.name + "\n")
    else:
        shutil.copyfile(fixture, target)
elif name == "make":
    # Simulate the installed command, never run a real Makefile or sudo.
    pathlib.Path(sys.argv[0]).with_name("velocitty").symlink_to(sys.argv[0])
elif name == "makepkg":
    (pathlib.Path(os.environ["MOCK_BIN"]) / "yay").symlink_to("mock")
elif name == "fnm":
    if args[0] == "exec":
        if os.environ.get("MOCK_NODE_MISSING") == "1" and not state.get("node_ready"):
            sys.exit(1)
        print("v24.21.0" if "node" in args else "11.19.0")
    elif args[0] == "install":
        if os.environ.get("MOCK_FNM_FAIL") == "1":
            sys.exit(1)
        state["node_ready"] = True
        state_path.write_text(json.dumps(state))
elif name == "nvim":
    print(os.environ.get("MOCK_NVIM_VERSION", "NVIM v0.12.6"))
elif name == "tree-sitter":
    print(os.environ.get("MOCK_TS_VERSION", "tree-sitter 0.26.9"))
elif name == "ldd":
    print("libQt5Quick.so.5" if os.environ.get("MOCK_QT5_ONLY") else "libQt6Quick.so.6")
elif name == "systemctl":
    if args == ["get-default"]:
        print(state.get("default_target", "multi-user.target"))
    elif args == ["set-default", "graphical.target"]:
        state["default_target"] = "graphical.target"
        state_path.write_text(json.dumps(state))
    elif "show" in args:
        print(os.environ.get("MOCK_DISPLAY_MANAGER", ""))
    elif "is-enabled" in args and "sddm.service" in args:
        sys.exit(0 if state.get("sddm_enabled") else 1)
    elif args == ["enable", "sddm.service"]:
        state["sddm_enabled"] = True
        state_path.write_text(json.dumps(state))
elif name == "getent":
    print("tester:x:1000:1000::/home/tester:" + os.environ.get("MOCK_LOGIN_SHELL", "/bin/bash"))
elif name == "git":
    if "clone" in args:
        if os.environ.get("MOCK_GIT_FAIL") == "1":
            sys.exit(1)
        destination = pathlib.Path(args[-1])
        (destination / ".git").mkdir(parents=True)
    elif "rev-parse" in args:
        sys.exit(0 if (pathlib.Path(args[1]) / ".git").exists() else 1)
elif name in ("pgrep", "pkill"):
    sys.exit(1)
elif name == "slurp":
    if os.environ.get("MOCK_CANCEL") == "1":
        sys.exit(1)
    print(os.environ.get("MOCK_REGION", "100x100+0+0"))
elif name == "hyprctl":
    if "monitors" in args:
        print('[{"focused":true,"scale":1,"activeWorkspace":{"id":1},"x":0,"y":0,"width":2560,"height":1080}]')
    elif "clients" in args:
        print(os.environ.get("MOCK_CLIENTS", '[]'))
elif name == "gpu-screen-recorder":
    # Stay alive past the script's startup check, then exit without GPU access.
    time.sleep(0.7)
elif name == "v4l2-ctl":
    print("Size: Discrete 640x360")
elif name == "rofi":
    sys.exit(1)  # Test cancellation without touching the actual clipboard.
"""


class DesktopTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix="hypr-tests-")
        self.addCleanup(self.tmp.cleanup)
        self.path = Path(self.tmp.name)
        self.bin = self.path / "bin"
        self.bin.mkdir()
        self.state = self.path / "state.json"
        self.log = self.path / "log.jsonl"
        self.log.touch()
        self.packages = []
        for line in (ROOT / "setup/packages.txt").read_text().splitlines():
            line = line.split("#", 1)[0].strip()
            if line:
                self.packages.append(line)
        self.set_installed(self.packages)
        stub = self.bin / "mock"
        stub.write_text(MOCK)
        stub.chmod(0o755)
        for name in (
            "pacman",
            "yay",
            "sudo",
            "velocitty",
            "curl",
            "make",
            "makepkg",
            "fnm",
            "nvim",
            "tree-sitter",
            "sddm-greeter",
            "sddm-greeter-qt6",
            "ldd",
            "git",
            "chsh",
            "getent",
            "xdg-user-dirs-update",
            "systemctl",
            "sleep",
            "pgrep",
            "pkill",
            "slurp",
            "hyprctl",
            "gpu-screen-recorder",
            "notify-send",
            "rofi",
            "cliphist",
            "wl-copy",
            "wayfreeze",
            "grim",
            "satty",
            "ffplay",
            "v4l2-ctl",
        ):
            (self.bin / name).symlink_to(stub)
        self.env = dict(
            os.environ,
            PATH=f"{self.bin}:{os.environ['PATH']}",
            HOME=str(self.path),
            XDG_CONFIG_HOME=str(self.path / ".config"),
            XDG_CACHE_HOME=str(self.path / ".cache"),
            XDG_DATA_HOME=str(self.path / ".local/share"),
            XDG_STATE_HOME=str(self.path / ".local/state"),
            XDG_RUNTIME_DIR=str(self.path),
            FNM_DIR=str(self.path / ".local/share/fnm"),
            SDKMAN_DIR=str(self.path / ".sdkman"),
            MOCK_STATE=str(self.state),
            MOCK_LOG=str(self.log),
            MOCK_SLEEP_PIDS=str(self.path / "sudo-sleep-pids"),
            MOCK_BIN=str(self.bin),
        )
        (self.path / "Videos").mkdir()
        (self.path / "Pictures").mkdir()

    def set_installed(self, packages):
        self.state.write_text(json.dumps({"installed": packages}))

    def run_script(self, relative, *args, **env):
        return subprocess.run(
            ["bash", str(ROOT / relative), *args],
            env=self.env | env,
            text=True,
            capture_output=True,
            timeout=15,
        )

    def calls(self, command):
        return [
            c
            for line in self.log.read_text().splitlines()
            if (c := json.loads(line))[0] == command
        ]

    def test_satisfied_dry_run_never_installs(self):
        result = self.run_script("setup/install.sh", "--dry-run")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("already installed", result.stdout)
        self.assertFalse(self.calls("sudo"))
        self.assertFalse(self.calls("yay"))

    def test_missing_dry_run_is_read_only(self):
        self.set_installed([])
        result = self.run_script(
            "setup/install.sh", "--dry-run", "--amd", "--enable-services"
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("lib32-vulkan-radeon", result.stdout)
        self.assertFalse(self.calls("sudo"))
        self.assertFalse(self.calls("yay"))
        self.assertFalse(self.calls("systemctl"))

    def velocitty_fixture(self):
        # Exclude the host's /usr/local executable to exercise fresh installation.
        (self.bin / "velocitty").unlink()
        self.env["PATH"] = f"{self.bin}:/usr/bin:/bin"
        self.env["TMPDIR"] = str(self.path)
        name = "velocitty-1.3.0-hotfix2-" + os.uname().machine + "-linux-gnu"
        archive = self.path / (name + ".tar.gz")
        with tarfile.open(archive, "w:gz") as tar:
            info = tarfile.TarInfo(name + "/Makefile")
            data = b"# Must never be executed in tests\n"
            info.size = len(data)
            tar.addfile(info, io.BytesIO(data))
        self.env["MOCK_ARCHIVE"] = str(archive)

    def test_velocitty_missing_dry_run_is_read_only(self):
        self.velocitty_fixture()
        result = self.run_script("setup/install-velocitty.sh", "--dry-run")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("valvesky/velocitty", result.stdout)
        self.assertFalse(self.calls("curl"))
        self.assertFalse(self.calls("sudo"))

    @unittest.skipIf(os.geteuid() == 0, "installer intentionally rejects root")
    def test_velocitty_verified_install_then_rerun_skips(self):
        self.velocitty_fixture()
        first = self.run_script("setup/install-velocitty.sh")
        self.assertEqual(first.returncode, 0, first.stderr)
        self.assertEqual(len(self.calls("curl")), 2)
        self.assertEqual(self.calls("make"), [["make", "install", "PREFIX=/usr/local"]])
        second = self.run_script("setup/install-velocitty.sh")
        self.assertEqual(second.returncode, 0, second.stderr)
        self.assertIn("skip installation", second.stdout)
        self.assertEqual(len(self.calls("curl")), 2)
        self.assertEqual(len(self.calls("make")), 1)

    @unittest.skipIf(os.geteuid() == 0, "installer intentionally rejects root")
    def test_velocitty_bad_checksum_prevents_install(self):
        self.velocitty_fixture()
        result = self.run_script("setup/install-velocitty.sh", MOCK_BAD_CHECKSUM="1")
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.calls("sudo"))
        self.assertFalse(self.calls("make"))

    def test_default_terminal_matches_launchers(self):
        self.assertIn(
            'local terminal = "velocitty"',
            (ROOT / "dot_config/hypr/hyprland.lua").read_text(),
        )
        self.assertIn(
            'hl.env("TERMINAL", "velocitty")',
            (ROOT / "dot_config/hypr/env.lua").read_text(),
        )
        rofi = (ROOT / "dot_config/rofi/config.rasi").read_text()
        self.assertIn('terminal: "velocitty"', rofi)
        self.assertIn('command: "velocitty -e nvim"', rofi)

    def test_virtual_provider_is_skipped(self):
        self.state.write_text(
            json.dumps({"installed": self.packages[1:], "provided": [self.packages[0]]})
        )
        result = self.run_script("setup/install.sh", "--dry-run")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("already installed", result.stdout)

    @unittest.skipIf(os.geteuid() == 0, "installer intentionally rejects root")
    def test_install_then_rerun_skips_transaction(self):
        self.set_installed(self.packages[1:])
        first = self.run_script("setup/install.sh")
        self.assertEqual(first.returncode, 0, first.stderr)
        self.assertEqual(self.calls("yay"), [self.yay_command(self.packages[0])])
        second = self.run_script("setup/install.sh")
        self.assertEqual(second.returncode, 0, second.stderr)
        self.assertEqual(len(self.calls("yay")), 1)
        self.assertEqual(len([c for c in self.calls("pacman") if "-Syu" in c]), 1)

    @unittest.skipIf(os.geteuid() == 0, "installer intentionally rejects root")
    def test_failed_install_retried_without_done_markers(self):
        self.set_installed(self.packages[1:])
        failed = self.run_script("setup/install.sh", MOCK_FAIL="1")
        self.assertNotEqual(failed.returncode, 0)
        retried = self.run_script("setup/install.sh")
        self.assertEqual(retried.returncode, 0, retried.stderr)
        self.assertEqual(len(self.calls("yay")), 2)

    def test_invalid_argument(self):
        self.assertEqual(self.run_script("setup/install.sh", "--unknown").returncode, 2)

    @unittest.skipIf(os.geteuid() == 0, "installer intentionally rejects root")
    def test_ready_services_are_not_reenabled(self):
        result = self.run_script("setup/install.sh", "--enable-services")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(len(self.calls("systemctl")), 10)
        self.assertFalse(any("enable" in c for c in self.calls("systemctl")))

    def test_all_profiles_dry_run_is_read_only(self):
        result = self.run_script(
            "setup/install.sh",
            "--dry-run",
            "--rust",
            "--docker",
            "--posting",
            "--java",
            "--sddm-theme",
            "--bootstrap-user",
            "--set-shell",
            "--enable-services",
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        for package in (
            "rust-analyzer",
            "rust-src",
            "docker",
            "lazydocker",
            "posting",
            "fx",
            "sddm",
            "qt6-5compat",
            "qt6-virtualkeyboard",
            "xorg-server",
        ):
            self.assertIn(package, result.stdout)
        for command in ("sudo", "yay", "curl", "fnm", "git", "chsh", "systemctl"):
            self.assertFalse(self.calls(command), command)
        self.assertFalse((self.path / ".sdkman").exists())

    @unittest.skipIf(os.geteuid() == 0, "installer intentionally rejects root")
    def test_docker_service_is_explicit_and_never_changes_groups(self):
        result = self.run_script(
            "setup/install.sh", "--docker", "--docker", "--enable-services"
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.calls("yay"), [self.yay_command("docker", "lazydocker")])
        self.assertEqual(
            len([c for c in self.calls("systemctl") if "docker.service" in c]), 2
        )
        self.assertFalse(self.calls("chsh"))

    @unittest.skipIf(os.geteuid() == 0, "installer intentionally rejects root")
    def test_fnm_runtime_install_and_rerun_skip(self):
        for _ in range(2):
            result = self.run_script("setup/install-node.sh", MOCK_NODE_MISSING="1")
            self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(len([c for c in self.calls("fnm") if "install" in c]), 1)
        self.assertIn(["fnm", "default", "lts-latest"], self.calls("fnm"))

    @unittest.skipIf(os.geteuid() == 0, "installer intentionally rejects root")
    def test_fnm_failed_install_does_not_change_default(self):
        result = self.run_script(
            "setup/install-node.sh", MOCK_NODE_MISSING="1", MOCK_FNM_FAIL="1"
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(any("default" == c[1] for c in self.calls("fnm")))

    @unittest.skipIf(os.geteuid() == 0, "installer intentionally rejects root")
    def test_sdkman_manager_only_and_rerun_skip(self):
        for _ in range(2):
            result = self.run_script("setup/install-sdkman.sh")
            self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(len(self.calls("curl")), 1)
        self.assertIn("rcupdate=false", self.calls("curl")[0][-1])
        self.assertFalse((self.path / ".zshrc").exists())
        self.assertFalse((self.path / ".sdkman/candidates/java").exists())

    @unittest.skipIf(os.geteuid() == 0, "installer intentionally rejects root")
    def test_sdkman_partial_directory_is_not_overwritten(self):
        (self.path / ".sdkman").mkdir()
        result = self.run_script("setup/install-sdkman.sh")
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.calls("curl"))

    def plugin_configs(self):
        import shutil

        for app, filename in (("zsh", "plugins.zsh"), ("tmux", "tmux.conf")):
            target = self.path / ".config" / app / filename
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(ROOT / "dot_config" / app / filename, target)

    @unittest.skipIf(os.geteuid() == 0, "installer intentionally rejects root")
    def test_plugin_bootstrap_rerun_and_no_tmux_server(self):
        self.plugin_configs()
        for _ in range(2):
            result = self.run_script("setup/bootstrap-user.sh")
            self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(len([c for c in self.calls("git") if "clone" in c]), 15)
        self.assertTrue((self.path / ".config/tmux/plugins/tpm/.git").is_dir())
        self.assertFalse(self.calls("tmux"))

    @unittest.skipIf(os.geteuid() == 0, "installer intentionally rejects root")
    def test_bootstrap_requires_configs_and_failed_clone_can_retry(self):
        result = self.run_script("setup/bootstrap-user.sh")
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.calls("git"))
        self.plugin_configs()
        failed = self.run_script("setup/bootstrap-user.sh", MOCK_GIT_FAIL="1")
        self.assertNotEqual(failed.returncode, 0)
        self.assertFalse(list((self.path / ".config").rglob(".bootstrap.*")))
        retried = self.run_script("setup/bootstrap-user.sh")
        self.assertEqual(retried.returncode, 0, retried.stderr)

    def test_theme_preflight_does_not_require_an_installed_greeter(self):
        result = self.run_script("setup/install-sddm-theme.sh", "--check")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(self.calls("ldd"))
        self.assertFalse(self.calls("systemctl"))
        self.assertFalse(self.calls("sudo"))

    @unittest.skipIf(os.geteuid() == 0, "installer intentionally rejects root")
    def test_theme_profile_installs_deploys_enables_without_restart(self):
        for _ in range(2):
            result = self.run_script("setup/install.sh", "--sddm-theme")
            self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("sddm", self.calls("yay")[0])
        self.assertEqual(len(self.calls("yay")), 1)
        deployed = [c for c in self.calls("sudo") if "python3" in c]
        self.assertEqual(len(deployed), 2)
        self.assertTrue(all(c[2].endswith("deploy-sddm-theme.py") for c in deployed))
        self.assertEqual(len([c for c in self.calls("systemctl") if "enable" in c]), 1)
        self.assertEqual(
            self.calls("systemctl").count(
                ["systemctl", "set-default", "graphical.target"]
            ),
            1,
        )
        for call in self.calls("systemctl"):
            self.assertTrue(
                set(call).isdisjoint({"start", "restart", "stop", "--now", "--force"})
            )

    @unittest.skipIf(os.geteuid() == 0, "installer intentionally rejects root")
    def test_theme_refuses_to_replace_other_display_manager(self):
        result = self.run_script(
            "setup/install-sddm-theme.sh", MOCK_DISPLAY_MANAGER="gdm.service"
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("refusing to replace", result.stderr)
        self.assertFalse(self.calls("sudo"))

    @unittest.skipIf(os.geteuid() == 0, "installer intentionally rejects root")
    def test_theme_checks_actual_greeter_after_install(self):
        result = self.run_script("setup/install-sddm-theme.sh", MOCK_QT5_ONLY="1")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Qt6 SDDM greeter", result.stderr)
        self.assertFalse(self.calls("sudo"))

    @staticmethod
    def yay_command(*packages):
        return [
            "yay",
            "-S",
            "--needed",
            "--noconfirm",
            "--answerclean",
            "None",
            "--answerdiff",
            "None",
            "--answeredit",
            "None",
            "--noremovemake",
            "--sudo",
            "sudo",
            *packages,
        ]

    def assert_refresh_stopped(self):
        path = self.path / "sudo-sleep-pids"
        for pid in path.read_text().splitlines() if path.exists() else []:
            with self.assertRaises(ProcessLookupError):
                os.kill(int(pid), 0)

    @unittest.skipIf(os.geteuid() == 0, "installer intentionally rejects root")
    def test_noninteractive_packages_and_sudo_refresh_stops_on_exit(self):
        self.set_installed(self.packages[1:])
        result = self.run_script("setup/install.sh", MOCK_REFRESH="1")
        self.assertEqual(result.returncode, 0, result.stderr)
        sudo_calls = self.calls("sudo")
        self.assertEqual(sudo_calls[0], ["sudo", "-v"])
        self.assertEqual(sudo_calls.count(["sudo", "-v"]), 1)
        self.assertIn(["sudo", "-n", "-v"], sudo_calls)
        transactions = [c for c in self.calls("pacman") if "-Syu" in c]
        self.assertEqual(transactions, [["pacman", "-Syu", "--noconfirm"]])
        self.assertEqual(self.calls("yay"), [self.yay_command(self.packages[0])])
        self.assert_refresh_stopped()

    @unittest.skipIf(os.geteuid() == 0, "installer intentionally rejects root")
    def test_sudo_refresh_cleanup_on_package_failure(self):
        self.set_installed(self.packages[1:])
        result = self.run_script("setup/install.sh", MOCK_FAIL="1", MOCK_REFRESH="1")
        self.assertNotEqual(result.returncode, 0)
        self.assert_refresh_stopped()

    @unittest.skipIf(os.geteuid() == 0, "installer intentionally rejects root")
    def test_auth_failure_prevents_all_mutations(self):
        self.set_installed(self.packages[1:])
        result = self.run_script("setup/install.sh", MOCK_AUTH_FAIL="1")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.calls("sudo"), [["sudo", "-v"]])
        self.assertFalse(self.calls("yay"))
        self.assertFalse(any("-Syu" in c for c in self.calls("pacman")))

    def isolate_missing_yay(self):
        (self.bin / "yay").unlink()
        # Do not let command -v find a real host yay outside the mocks.
        for command in ("bash", "python3", "dirname", "mktemp", "rm", "id"):
            (self.bin / command).symlink_to(shutil.which(command))
        self.env["PATH"] = str(self.bin)
        self.env["TMPDIR"] = str(self.path)

    @unittest.skipIf(os.geteuid() == 0, "installer intentionally rejects root")
    def test_yay_repository_bootstrap_automatically_approves(self):
        self.isolate_missing_yay()
        result = self.run_script("setup/install.sh")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn(
            ["pacman", "-S", "--needed", "--noconfirm", "yay"], self.calls("pacman")
        )
        self.assertFalse(self.calls("makepkg"))
        self.assertEqual(self.calls("sudo")[0], ["sudo", "-v"])
        self.assert_refresh_stopped()

    @unittest.skipIf(os.geteuid() == 0, "installer intentionally rejects root")
    def test_yay_aur_bootstrap_approves_and_cleans_build_and_refresh(self):
        self.isolate_missing_yay()
        result = self.run_script("setup/install.sh", MOCK_YAY_AUR="1")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn(
            ["pacman", "-S", "--needed", "--noconfirm", "git", "base-devel"],
            self.calls("pacman"),
        )
        self.assertEqual(self.calls("makepkg"), [["makepkg", "-si", "--noconfirm"]])
        self.assertFalse(list(self.path.glob("hypr-yay.*")))
        self.assert_refresh_stopped()

    def test_existing_rustup_requires_explicit_resolution(self):
        self.set_installed(self.packages + ["rustup"])
        result = self.run_script("setup/install.sh", "--dry-run", "--rust")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("rustup", result.stderr)
        self.assertFalse(self.calls("sudo"))

    @unittest.skipIf(os.geteuid() == 0, "installer intentionally rejects root")
    def test_login_shell_change_is_opt_in_and_symlink_aware(self):
        result = self.run_script(
            "setup/install.sh", "--set-shell", MOCK_LOGIN_SHELL="/bin/zsh"
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(self.calls("chsh"))
        changed = self.run_script(
            "setup/install.sh", "--set-shell", MOCK_LOGIN_SHELL="/bin/bash"
        )
        self.assertEqual(changed.returncode, 0, changed.stderr)
        self.assertEqual(len(self.calls("chsh")), 1)
        self.assertEqual(self.calls("chsh")[0][1], "-s")

    def test_recorder_audio_is_two_arguments(self):
        result = self.run_script(
            "dot_config/hypr/scripts/executable_screen-recorder", "--with-audio"
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        args = self.calls("gpu-screen-recorder")[0]
        self.assertEqual(args[args.index("-a") + 1], "default_output|default_input")
        self.assertNotIn("-a default_output|default_input", args)

    def test_recorder_silent_has_no_empty_audio_argument(self):
        result = self.run_script("dot_config/hypr/scripts/executable_screen-recorder")
        self.assertEqual(result.returncode, 0, result.stderr)
        args = self.calls("gpu-screen-recorder")[0]
        self.assertNotIn("", args)
        self.assertNotIn("-a", args)

    def test_webcam_resolution_is_two_arguments(self):
        result = self.run_script(
            "dot_config/hypr/scripts/executable_screen-recorder", "--with-webcam"
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        args = self.calls("ffplay")[0]
        self.assertEqual(args[args.index("-video_size") + 1], "640x360")
        self.assertNotIn("-video_size 640x360", args)

    def test_clipboard_cancel_does_not_copy(self):
        result = self.run_script("dot_config/hypr/scripts/executable_clipboard")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(self.calls("wl-copy"))

    def test_popup_uses_valid_lua_syntax(self):
        result = self.run_script("dot_config/hypr/scripts/executable_window-popup")
        self.assertEqual(result.returncode, 0, result.stderr)
        call = self.calls("hyprctl")[0]
        self.assertEqual(call[1], "eval")
        checked = subprocess.run(
            ["luac", "-p", "-"], input=call[2], text=True, capture_output=True
        )
        self.assertEqual(checked.returncode, 0, checked.stderr)

    def test_screenshot_cancel_does_not_capture(self):
        result = self.run_script(
            "dot_config/hypr/scripts/executable_screenshot", MOCK_CANCEL="1"
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(self.calls("grim"))
        self.assertFalse(self.calls("satty"))


class CleanupTests(unittest.TestCase):
    def test_generated_files_are_gitignored(self):
        paths = [
            ".ruff_cache/check",
            ".pytest_cache/check",
            "setup/tests/__pycache__/test_desktop.cpython-314.pyc",
            "dot_config/calcure/info.log",
            "dot_config/calcure/events.csv",
            "dot_config/calcure/tasks.csv",
        ]
        result = subprocess.run(
            ["git", "check-ignore", "--no-index", "--stdin"],
            input="\n".join(paths) + "\n",
            cwd=ROOT,
            text=True,
            capture_output=True,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.splitlines(), paths)
        result = subprocess.run(
            ["git", "check-ignore", "--no-index", "dot_config/nvim/lazy-lock.json"],
            cwd=ROOT,
            capture_output=True,
        )
        self.assertEqual(result.returncode, 1)

    def test_swaync_has_no_demo_hooks_or_unused_widgets(self):
        config = json.loads((ROOT / "dot_config/swaync/config.json").read_text())
        self.assertNotIn("scripts", config)
        self.assertTrue(set(config["widget-config"]).issubset(config["widgets"]))


if __name__ == "__main__":
    unittest.main()
