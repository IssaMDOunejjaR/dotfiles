#!/usr/bin/env python3
import i3ipc

i3 = i3ipc.Connection()

def update_fullscreen(i3, e):
    tree = i3.get_tree()
    for ws in tree.workspaces():
        # Get tiling windows only (ignore floating ones)
        windows = [w for w in ws.leaves() if not w.floating]
        if len(windows) == 1:
            windows[0].command("fullscreen enable")
        else:
            for w in windows:
                w.command("fullscreen disable")

# Run once at startup
update_fullscreen(i3, None)

# Re-run on window changes
i3.on("window::new", update_fullscreen)
i3.on("window::close", update_fullscreen)
i3.on("window::move", update_fullscreen)
i3.on("window::floating", update_fullscreen)

i3.main()
