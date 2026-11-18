#!/usr/bin/env python3
"""Isolated CLI regressions. Never install packages or contact the compositor."""

import io
import json
import os
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
    if args[0] == "-T":
        sys.exit(0 if args[1] in state["installed"] + state.get("provided", []) else 127)
    if args[0] == "-Si":
        sys.exit(0)
elif name == "yay":
    if os.environ.get("MOCK_FAIL") == "1":
        sys.exit(1)
    state["installed"] += [a for a in args if not a.startswith("-")]
    state_path.write_text(json.dumps(state))
elif name == "sudo":
    os.execvp(args[0], args)
elif name == "curl":
    import shutil
    target = pathlib.Path(args[args.index("--output") + 1])
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
            "xdg-user-dirs-update",
            "systemctl",
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
            XDG_RUNTIME_DIR=str(self.path),
            MOCK_STATE=str(self.state),
            MOCK_LOG=str(self.log),
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
        self.assertEqual(
            self.calls("yay"), [["yay", "-S", "--needed", self.packages[0]]]
        )
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
