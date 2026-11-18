#!/usr/bin/env python3
"""Explicit, backed-up deployment of the legacy theme; never touch services."""

from datetime import datetime
import filecmp
import os
from pathlib import Path
import re
import shutil
import sys
import tempfile


def theme_config(text):
    """Change only Current/ThemeDir within [Theme], preserving other settings."""
    lines = text.splitlines(keepends=True)
    start = next((i for i, line in enumerate(lines) if line.strip() == "[Theme]"), None)
    if start is None:
        return text + "\n[Theme]\nCurrent=chili\nThemeDir=/usr/share/sddm/themes\n"
    end = next(
        (i for i in range(start + 1, len(lines)) if re.match(r"\s*\[", lines[i])),
        len(lines),
    )
    body = [
        line
        for line in lines[start + 1 : end]
        if not re.match(r"\s*(Current|ThemeDir)\s*=", line)
    ]
    lines[start:end] = [
        "[Theme]\n",
        "Current=chili\n",
        "ThemeDir=/usr/share/sddm/themes\n",
        *body,
    ]
    return "".join(lines)


def same_tree(source, destination):
    if not destination.is_dir() or destination.is_symlink():
        return False
    comparison = filecmp.dircmp(source, destination)
    return (
        not (comparison.left_only or comparison.funny_files or comparison.common_funny)
        and all(
            filecmp.cmp(source / name, destination / name, shallow=False)
            for name in comparison.common_files
        )
        and all(
            same_tree(source / name, destination / name)
            for name in comparison.common_dirs
        )
    )


def deploy(source, destination, config, backup_root):
    if not (source / "Main.qml").is_file():
        raise RuntimeError("Chili source is missing Main.qml")
    if config.is_symlink():
        raise RuntimeError(f"Refusing to replace a symlinked SDDM config: {config}")
    for tree in (source, destination):
        if tree.is_symlink() or any(path.is_symlink() for path in tree.rglob("*")):
            raise RuntimeError(f"Refusing to overwrite/follow theme symlinks: {tree}")
    old_text = config.read_text() if config.exists() else ""
    new_text = theme_config(old_text)
    changed_theme = not same_tree(source, destination)
    if not changed_theme and new_text == old_text:
        print("SDDM theme and selection already match (skip).")
        return
    backup_root.mkdir(parents=True, exist_ok=True)
    backup = Path(
        tempfile.mkdtemp(
            prefix=datetime.now().strftime("chili-%Y%m%d-%H%M%S-"), dir=backup_root
        )
    )
    if config.exists():
        shutil.copy2(config, backup / "sddm.conf")
    if destination.exists() or destination.is_symlink():
        if destination.is_symlink():
            raise RuntimeError("Refusing to overwrite a symlinked theme directory")
        shutil.copytree(destination, backup / "chili", symlinks=True)
    print(f"SDDM backup: {backup}")
    if changed_theme:
        # Merge rather than deleting an existing system directory. Extra local
        # files are preserved; all overwritten files are recoverable above.
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copytree(source, destination, dirs_exist_ok=True)
    config.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(
        mode="w", dir=config.parent, delete=False
    ) as pending:
        pending.write(new_text)
        pending_path = Path(pending.name)
    pending_path.chmod(config.stat().st_mode & 0o777 if config.exists() else 0o644)
    pending_path.replace(config)


if __name__ == "__main__":
    if os.geteuid() != 0 or len(sys.argv) != 2:
        sys.exit(
            "Called through install-sddm-theme.sh with sudo and a theme source path."
        )
    deploy(
        Path(sys.argv[1]),
        Path("/usr/share/sddm/themes/chili"),
        Path("/etc/sddm.conf"),
        Path("/var/backups/chezmoi-sddm"),
    )
