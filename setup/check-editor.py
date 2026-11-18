#!/usr/bin/env python3
"""Check the version pair required by the pinned Treesitter main branch."""

import re
import subprocess
import sys


def check(command, minimum):
    output = subprocess.check_output(command, text=True)
    match = re.search(r"(\d+)\.(\d+)\.(\d+)", output)
    if not match or tuple(map(int, match.groups())) < minimum:
        raise RuntimeError(
            f"{' '.join(command)} requires {'.'.join(map(str, minimum))}+"
        )


if __name__ == "__main__":
    try:
        check(["nvim", "--version"], (0, 12, 0))
        check(["tree-sitter", "--version"], (0, 26, 1))
    except (OSError, subprocess.CalledProcessError, RuntimeError) as error:
        sys.exit(f"Editor compatibility check failed: {error}")
