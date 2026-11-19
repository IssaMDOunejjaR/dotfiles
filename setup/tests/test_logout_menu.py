import fcntl
import importlib.machinery
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch


ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "dot_config/hypr/scripts/executable_logout-menu"
SPEC = importlib.util.spec_from_loader(
    "logout_menu", importlib.machinery.SourceFileLoader("logout_menu", str(SCRIPT))
)
MENU = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MENU)


class LogoutMenuTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.path = Path(self.tmp.name)
        config = self.path / "wlogout"
        config.mkdir()
        for name in ("layout", "style.css"):
            (config / name).write_bytes(
                (ROOT / "dot_config/wlogout" / name).read_bytes()
            )
        self.addCleanup(patch.stopall)
        patch.dict(
            os.environ,
            XDG_RUNTIME_DIR=str(self.path),
            XDG_CONFIG_HOME=str(self.path),
            XDG_SESSION_ID="gui-session",
        ).start()
        self.calls = []
        self.capabilities = {"CanHibernate": 's "na"', "CanSuspend": 's "yes"'}
        self.confirmation = "1"
        self.layout = None
        self.run = patch.object(MENU, "run", side_effect=self.fake_run).start()

    def fake_run(self, args, **kwargs):
        self.calls.append(args)
        if args[0] == "busctl":
            return self.capabilities[args[-1]]
        if args[0] == "hyprctl":
            return '[{"width":1280,"height":720,"scale":1.25}]'
        if args[0] == "rofi":
            self.assertTrue(kwargs["input"].startswith("Cancel\n"))
            return self.confirmation
        if args[0] == "wlogout":
            path = Path(args[args.index("--layout") + 1])
            self.layout = MENU.read_layout(path)
            self.temporary_layout = path
        if args[:2] == ["loginctl", "show-session"]:
            return "fallback-session"
        return ""

    def test_launcher_filters_hibernate_pads_grid_and_cleans_tempfile(self):
        MENU.launch()
        self.assertNotIn("hibernate", {b["label"] for b in self.layout})
        self.assertIn("cancel", {b["label"] for b in self.layout})
        self.assertEqual(len(self.layout), 6)
        call = next(c for c in self.calls if c[0] == "wlogout")
        self.assertEqual(call[call.index("--buttons-per-row") + 1], "3")
        self.assertEqual(call[call.index("--margin") + 1], "46")
        self.assertIn("--show-binds", call)
        self.assertIn("--no-span", call)
        self.assertFalse(self.temporary_layout.exists())
        self.assertTrue(all(" --action " in b["action"] for b in self.layout))
        self.assertFalse(
            any(c[0] in ("systemctl", "loginctl", "rofi") for c in self.calls)
        )

    def test_four_buttons_use_a_complete_two_column_grid(self):
        self.capabilities["CanSuspend"] = 's "no"'
        MENU.launch()
        self.assertEqual(len(self.layout), 4)
        call = next(c for c in self.calls if c[0] == "wlogout")
        self.assertEqual(call[call.index("--buttons-per-row") + 1], "2")

    def test_authorizable_sleep_actions_are_kept(self):
        self.capabilities["CanHibernate"] = 's "challenge"'
        MENU.launch()
        self.assertEqual(len(self.layout), 6)
        self.assertIn("hibernate", {b["label"] for b in self.layout})
        self.assertNotIn("cancel", {b["label"] for b in self.layout})

    def test_duplicate_menu_does_not_launch(self):
        with open(self.path / "hyprland-logout-menu.lock", "a") as lock:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
            MENU.launch()
        self.assertFalse(self.calls)

    def test_failed_menu_releases_lock_and_removes_layout(self):
        original = self.fake_run

        def fail_menu(args, **kwargs):
            result = original(args, **kwargs)
            if args[0] == "wlogout":
                raise subprocess.CalledProcessError(1, args)
            return result

        self.run.side_effect = fail_menu
        with self.assertRaises(subprocess.CalledProcessError):
            MENU.launch()
        self.assertFalse(self.temporary_layout.exists())
        self.run.side_effect = original
        MENU.launch()
        self.assertEqual(sum(c[0] == "wlogout" for c in self.calls), 2)

    def test_confirmed_logout_terminates_only_the_current_session(self):
        MENU.action("logout")
        self.assertIn(["loginctl", "terminate-session", "gui-session"], self.calls)
        self.assertFalse(any("terminate-user" in c for c in self.calls))

    def test_missing_session_uses_logind_not_user_wide_logout(self):
        os.environ.pop("XDG_SESSION_ID")
        MENU.action("logout")
        self.assertIn(["loginctl", "terminate-session", "fallback-session"], self.calls)

    def test_unidentifiable_session_never_terminates_anything(self):
        os.environ.pop("XDG_SESSION_ID")
        original = self.fake_run
        self.run.side_effect = lambda args, **kwargs: (
            "" if args[:2] == ["loginctl", "show-session"] else original(args, **kwargs)
        )
        with self.assertRaises(RuntimeError):
            MENU.action("logout")
        self.assertFalse(any("terminate-session" in c for c in self.calls))

    def test_cancellation_prevents_every_destructive_action(self):
        for response in ("0", "", "Reboot"):
            self.confirmation = response
            for action in ("logout", "shutdown", "reboot"):
                MENU.action(action)
        self.assertTrue(all(c[0] == "rofi" for c in self.calls))

    def test_escape_from_confirmation_is_safe(self):
        self.run.side_effect = subprocess.CalledProcessError(1, ["rofi"])
        MENU.action("shutdown")
        self.assertEqual(self.run.call_count, 1)

    def test_confirmed_power_actions_need_no_sudo(self):
        MENU.action("shutdown")
        MENU.action("reboot")
        self.assertIn(["systemctl", "poweroff"], self.calls)
        self.assertIn(["systemctl", "reboot"], self.calls)
        self.assertFalse(any(c[0] == "sudo" for c in self.calls))

    def test_lock_and_suspend_preserve_hypridle_coordination(self):
        MENU.action("lock")
        MENU.action("suspend")
        self.assertIn(["loginctl", "lock-session", "gui-session"], self.calls)
        self.assertIn(["systemctl", "suspend"], self.calls)
        self.assertFalse(any(c[0] in ("rofi", "hyprlock") for c in self.calls))

    def test_sleep_capability_is_rechecked_before_action(self):
        with self.assertRaises(RuntimeError):
            MENU.action("hibernate")
        self.assertFalse(any(c[0] == "systemctl" for c in self.calls))

    def test_capability_errors_and_bad_geometry_have_safe_defaults(self):
        self.run.side_effect = FileNotFoundError("missing command")
        self.assertFalse(MENU.available("hibernate"))
        self.assertEqual(MENU.margin(), 40)
        self.run.side_effect = lambda *a, **k: "[]"
        self.assertEqual(MENU.margin(), 40)

    def test_both_entry_points_use_shared_launcher(self):
        for path in ("dot_config/hypr/hyprland.lua", "dot_config/waybar/config.jsonc"):
            self.assertIn(
                "~/.config/hypr/scripts/logout-menu", (ROOT / path).read_text()
            )
        self.assertNotIn(
            "terminate-user", (ROOT / "dot_config/wlogout/layout").read_text()
        )


if __name__ == "__main__":
    unittest.main()
