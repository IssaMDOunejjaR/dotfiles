#!/usr/bin/env python3
"""Pure/temp-directory checks for setup helpers; no package or system changes."""

import importlib.util
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[2]


def load_helper(filename):
    spec = importlib.util.spec_from_file_location("helper", ROOT / "setup" / filename)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class SetupTests(unittest.TestCase):
    @unittest.skipUnless(
        Path("/usr/lib/qt6/bin/qmltestrunner").exists(),
        "Qt6 QML test runner is not installed",
    )
    def test_chili_qt6_login_and_menus(self):
        with tempfile.TemporaryDirectory() as tmp:
            env = dict(
                os.environ,
                QT_QPA_PLATFORM="offscreen",
                QT_QUICK_BACKEND="software",
                XDG_CACHE_HOME=tmp,
                QML_DISK_CACHE_PATH=tmp,
            )
            result = subprocess.run(
                [
                    "/usr/lib/qt6/bin/qmltestrunner",
                    "-input",
                    str(ROOT / "setup/tests/qml"),
                ],
                env=env,
                text=True,
                capture_output=True,
                timeout=20,
            )
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_editor_minimum_versions(self):
        check = load_helper("check-editor.py").check
        for version, valid in (
            ("NVIM v0.12.6", True),
            ("NVIM v0.11.9", False),
            ("invalid", False),
        ):
            with patch("subprocess.check_output", return_value=version):
                if valid:
                    check(["nvim", "--version"], (0, 12, 0))
                else:
                    with self.assertRaises(RuntimeError):
                        check(["nvim", "--version"], (0, 12, 0))
        with patch("subprocess.check_output", return_value="tree-sitter 0.26.0"):
            with self.assertRaises(RuntimeError):
                check(["tree-sitter", "--version"], (0, 26, 1))

    def test_core_and_optional_manifest_scope(self):
        core = {
            s
            for line in (ROOT / "setup/packages.txt").read_text().splitlines()
            if (s := line.split("#")[0].strip())
        }
        for package in (
            "zsh",
            "tmux",
            "fnm",
            "go",
            "luarocks",
            "tree-sitter-cli",
            "unzip",
            "python-pip",
            "opencode",
            "lazygit",
            "networkmanager",
            "abook",
            "calcurse",
        ):
            self.assertIn(package, core)
        self.assertTrue(
            core.isdisjoint(
                {
                    "rust",
                    "rustup",
                    "nodejs",
                    "npm",
                    "iwd",
                    "impala",
                    "docker",
                    "posting",
                    "jdk-openjdk",
                }
            )
        )

    def test_theme_backup_and_idempotent_merge(self):
        helper = load_helper("deploy-sddm-theme.py")
        with tempfile.TemporaryDirectory() as tmp:
            base = Path(tmp)
            source, destination = base / "source", base / "installed"
            source.mkdir()
            destination.mkdir()
            (source / "Main.qml").write_text("new theme")
            (destination / "Main.qml").write_text("old theme")
            (destination / "local.txt").write_text("preserve")
            config = base / "sddm.conf"
            original = "# keep comment\n[Theme]\nCurrent=other\nCursorTheme=custom\n[General]\nDisplayServer=x11\n"
            config.write_text(original)
            backup = base / "backups"
            helper.deploy(source, destination, config, backup)
            copies = list(backup.iterdir())
            self.assertEqual(len(copies), 1)
            self.assertEqual((copies[0] / "sddm.conf").read_text(), original)
            self.assertEqual((copies[0] / "chili/Main.qml").read_text(), "old theme")
            self.assertEqual((destination / "local.txt").read_text(), "preserve")
            self.assertIn("Current=chili", config.read_text())
            self.assertIn("CursorTheme=custom", config.read_text())
            self.assertIn("DisplayServer=x11", config.read_text())
            helper.deploy(source, destination, config, backup)
            self.assertEqual(list(backup.iterdir()), copies)

    def test_theme_refuses_symlinks(self):
        helper = load_helper("deploy-sddm-theme.py")
        with tempfile.TemporaryDirectory() as tmp:
            base = Path(tmp)
            source, destination = base / "source", base / "installed"
            source.mkdir()
            (source / "Main.qml").write_text("theme")
            destination.symlink_to(source, target_is_directory=True)
            with self.assertRaises(RuntimeError):
                helper.deploy(source, destination, base / "sddm.conf", base / "backups")
            self.assertFalse((base / "backups").exists())

    def test_zsh_bootstrap_and_optional_alias_guards(self):
        with tempfile.TemporaryDirectory() as tmp:
            base = Path(tmp)
            config = base / "xdg"
            shutil.copytree(ROOT / "dot_config/zsh", config / "zsh")
            (config / "zsh/dot_zshenv").rename(config / "zsh/.zshenv")
            empty_bin = base / "bin"
            empty_bin.mkdir()
            env = dict(
                os.environ,
                HOME=tmp,
                XDG_CONFIG_HOME=str(config),
                XDG_CACHE_HOME=str(base / "cache"),
                XDG_STATE_HOME=str(base / "state"),
            )
            script = """
source "$1/dot_zshenv"
[[ "$ZDOTDIR" == "$XDG_CONFIG_HOME/zsh" ]] || exit 1
[[ "$STARSHIP_CONFIG" == "$ZDOTDIR/starship.toml" ]] || exit 2
compdef() { :; }
path=("$2")
source "$ZDOTDIR/aliases.zsh"
(( ! $+aliases[kubectl] && ! $+aliases[kc] && ! $+aliases[ldc] && ! $+aliases[stream] && ! $+functions[lf] )) || exit 3
source "$ZDOTDIR/plugins.zsh"
"""
            result = subprocess.run(
                ["zsh", "-f", "-c", script, "test", str(ROOT), str(empty_bin)],
                env=env,
                text=True,
                capture_output=True,
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertFalse((config / "zsh/plugins").exists())

    def test_editor_lua_regressions(self):
        with tempfile.TemporaryDirectory() as tmp:
            env = dict(
                os.environ, XDG_DATA_HOME=tmp, XDG_CACHE_HOME=tmp, XDG_STATE_HOME=tmp
            )
            result = subprocess.run(
                [
                    "nvim",
                    "--headless",
                    "-u",
                    "NONE",
                    "-i",
                    "NONE",
                    "-l",
                    str(ROOT / "setup/tests/test_editor.lua"),
                    str(ROOT),
                ],
                env=env,
                text=True,
                capture_output=True,
                timeout=30,
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn(
                "Editor regression checks passed", result.stdout + result.stderr
            )

    def test_interactive_zsh_creates_state_and_initializes_managers(self):
        with tempfile.TemporaryDirectory() as tmp:
            base = Path(tmp)
            config = base / ".config"
            shutil.copytree(ROOT / "dot_config/zsh", config / "zsh")
            (config / "zsh/dot_zshenv").rename(config / "zsh/.zshenv")
            bin_dir = base / "bin"
            bin_dir.mkdir()
            for name in ("fnm", "zoxide", "starship", "fzf", "tmux", "git"):
                stub = bin_dir / name
                stub.write_text(
                    '#!/bin/sh\n[ "${0##*/}" != fnm ] || echo "export TEST_FNM_INITIALIZED=1"\n'
                )
                stub.chmod(0o755)
            sdkman = base / ".sdkman"
            (sdkman / "bin").mkdir(parents=True)
            (sdkman / "bin/sdkman-init.sh").write_text(
                "export TEST_SDKMAN_INITIALIZED=1\n"
            )
            env = dict(
                os.environ,
                HOME=tmp,
                XDG_CONFIG_HOME=str(config),
                XDG_CACHE_HOME=str(base / "cache"),
                XDG_STATE_HOME=str(base / "state"),
                SDKMAN_DIR=str(sdkman),
                TMUX="test-no-server",
                PATH=str(bin_dir) + ":/usr/bin:/bin",
            )
            script = """
source "$1/dot_zshenv"
source "$ZDOTDIR/dot_zshrc"
[[ "$TEST_FNM_INITIALIZED" == 1 && "$TEST_SDKMAN_INITIALIZED" == 1 ]] || exit 1
[[ -d "$XDG_CACHE_HOME/zsh" && -d "$XDG_STATE_HOME/zsh" ]] || exit 2
"""
            result = subprocess.run(
                ["zsh", "-d", "-f", "-i", "-c", script, "test", str(ROOT)],
                env=env,
                text=True,
                capture_output=True,
                timeout=30,
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertNotIn("command not found", result.stderr)
            self.assertFalse((config / "zsh/plugins").exists())


if __name__ == "__main__":
    unittest.main()
