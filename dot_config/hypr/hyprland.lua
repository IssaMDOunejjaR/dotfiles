-- ====== Sources ======
-- In Lua, you can separate configs using the 'require' function if they return tables,
-- but for simplicity and Hyprland's native Lua API, we can define everything here.
-- If you want to keep them in separate files, you can use: require("confs.defaults.envs")

require("env")
require("monitor")
require("autostart")
require("bindings")

-- ====== Variables ======
local terminal = "kitty"
local browser = "brave-origin"
local fileManager = "nautilus"
local quickfileManager = "pidof rofi || rofi -show filebrowser"
local menu = "pidof rofi || rofi -show drun -i"
local run = "pidof rofi || rofi -show run"
local notifications = "swaync-client -t -sw"
local mainMod = "SUPER + "

-- ============================================================
-- General
-- ============================================================

hl.config({
	general = {
		gaps_in = 3,
		gaps_out = 3,
		border_size = 2,

		col = {
			active_border = "rgba(FC0A2EBB)",
			inactive_border = "rgba(255,255,255,0.3)",
		},

		resize_on_border = false,
		allow_tearing = true,
		layout = "dwindle",
	},
})

-- ============================================================
-- Decoration
-- ============================================================

hl.config({
	decoration = {
		rounding = 0,

		active_opacity = 1.0,
		inactive_opacity = 0.9,

		dim_around = 0.8,

		shadow = {
			enabled = true,
			range = 2,
			render_power = 3,
			color = "rgba(1a1a1aee)",
		},

		blur = {
			enabled = true,
			size = 3,
			passes = 3,
		},
	},
})

-- ============================================================
-- Animations
-- ============================================================

hl.config({
	animations = {
		enabled = true,
	},
})

hl.curve("easeOutQuint", {
	type = "bezier",
	points = {
		{ 0.23, 1 },
		{ 0.32, 1 },
	},
})

hl.curve("easeInOutCubic", {
	type = "bezier",
	points = {
		{ 0.65, 0.05 },
		{ 0.36, 1 },
	},
})

hl.curve("linear", {
	type = "bezier",
	points = {
		{ 0, 0 },
		{ 1, 1 },
	},
})

hl.curve("almostLinear", {
	type = "bezier",
	points = {
		{ 0.5, 0.5 },
		{ 0.75, 1.0 },
	},
})

hl.curve("quick", {
	type = "bezier",
	points = {
		{ 0.15, 0 },
		{ 0.1, 1 },
	},
})

hl.animation({
	leaf = "global",
	enabled = true,
	speed = 10,
	bezier = "default",
})

hl.animation({
	leaf = "border",
	enabled = true,
	speed = 5.39,
	bezier = "easeOutQuint",
})

hl.animation({
	leaf = "windows",
	enabled = true,
	speed = 4.79,
	bezier = "easeOutQuint",
})

hl.animation({
	leaf = "windowsIn",
	enabled = true,
	speed = 4.1,
	bezier = "easeOutQuint",
	style = "popin 87%",
})

hl.animation({
	leaf = "windowsOut",
	enabled = true,
	speed = 1.49,
	bezier = "linear",
	style = "popin 87%",
})

hl.animation({
	leaf = "fadeIn",
	enabled = true,
	speed = 1.73,
	bezier = "almostLinear",
})

hl.animation({
	leaf = "fadeOut",
	enabled = true,
	speed = 1.46,
	bezier = "almostLinear",
})

hl.animation({
	leaf = "fade",
	enabled = true,
	speed = 3.03,
	bezier = "quick",
})

hl.animation({
	leaf = "layers",
	enabled = true,
	speed = 3.81,
	bezier = "easeOutQuint",
})

hl.animation({
	leaf = "layersIn",
	enabled = true,
	speed = 4,
	bezier = "easeOutQuint",
	style = "fade",
})

hl.animation({
	leaf = "layersOut",
	enabled = true,
	speed = 1.5,
	bezier = "linear",
	style = "fade",
})

hl.animation({
	leaf = "fadeLayersIn",
	enabled = true,
	speed = 1.79,
	bezier = "almostLinear",
})

hl.animation({
	leaf = "fadeLayersOut",
	enabled = true,
	speed = 1.39,
	bezier = "almostLinear",
})

hl.animation({
	leaf = "workspaces",
	enabled = true,
	speed = 1.94,
	bezier = "almostLinear",
	style = "fade",
})

hl.animation({
	leaf = "workspacesIn",
	enabled = true,
	speed = 1.21,
	bezier = "almostLinear",
	style = "fade",
})

hl.animation({
	leaf = "workspacesOut",
	enabled = true,
	speed = 1.94,
	bezier = "almostLinear",
	style = "fade",
})

-- ============================================================
-- Window Rules
-- ============================================================

-- Waybar-Kitty
hl.window_rule({
	match = {
		class = "waybar-kitty",
	},
	float = true,
	size = {
		"monitor_w*0.6",
		"monitor_h*0.8",
	},
	dim_around = true,
	animation = "popin",
})

-- XWayland Video Bridge
hl.window_rule({
	match = {
		class = "^(xwaylandvideobridge)$",
	},
	opacity = "0.0 override",
	no_anim = true,
	no_initial_focus = true,
	max_size = { 1, 1 },
	no_blur = true,
	no_focus = true,
})

-- Blueberry
hl.window_rule({
	match = {
		class = "blueberry.py",
	},
	float = true,
})

-- Picture-in-Picture
hl.window_rule({
	match = {
		title = "^(Picture-in-Picture|Picture in picture)$",
	},
	float = true,
	move = {
		"(monitor_w*1)-630",
		"(monitor_h*1)-370",
	},
	size = {
		600,
		340,
	},
	pin = true,
	keep_aspect_ratio = true,
})

-- Ignore maximize requests from apps
hl.window_rule({
	match = {
		class = ".*",
	},
	suppress_event = "maximize",
})

-- Tearing for CS2
hl.window_rule({
	match = {
		class = "^(cs2)$",
	},
	immediate = true,
})

-- Tearing for all fullscreen games
hl.window_rule({
	match = {
		fullscreen = true,
	},
	immediate = true,
})

-- no gaps when there is only one window
hl.workspace_rule({
	workspace = "w[tv1]",
	gaps_out = 0,
	gaps_in = 0,
})

hl.workspace_rule({
	workspace = "f[1]",
	gaps_out = 0,
	gaps_in = 0,
})

hl.window_rule({
	match = {
		float = false,
		workspace = "w[tv1]",
	},
	border_size = 0,
	rounding = 0,
})

hl.window_rule({
	match = {
		float = false,
		workspace = "f[1]",
	},
	border_size = 0,
	rounding = 0,
})

-- ============================================================
-- XWayland
-- ============================================================

hl.config({
	xwayland = {
		force_zero_scaling = true,
	},
})

-- ============================================================
-- Layouts
-- ============================================================

hl.config({
	dwindle = {
		preserve_split = true,
	},
})

hl.config({
	master = {
		new_status = "master",
	},
})

-- ============================================================
-- Misc
-- ============================================================

hl.config({
	misc = {
		force_default_wallpaper = 0,
		disable_hyprland_logo = true,
		focus_on_activate = true,
		allow_session_lock_restore = true,
		font_family = "JetBrains Mono",
		vrr = 1,
	},
})

-- ============================================================
-- Input
-- ============================================================

hl.config({
	input = {
		kb_layout = "us",
		follow_mouse = 1,
		sensitivity = 0,

		touchpad = {
			natural_scroll = false,
		},
	},
})

-- ============================================================
-- Cursor
-- ============================================================

hl.config({
	cursor = {
		no_warps = true,
	},
})

-- ====== Keybindings ======
-- Apps
hl.bind(mainMod .. "return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. "B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. "SHIFT + B", hl.dsp.exec_cmd("~/.config/hypr/scripts/waybar"))
hl.bind(mainMod .. "Q", hl.dsp.window.kill())
hl.bind(mainMod .. "SHIFT + Q", hl.dsp.exit())
hl.bind(mainMod .. "E", hl.dsp.exec_cmd(quickfileManager))
hl.bind(mainMod .. "SHIFT + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. "F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. "V", hl.dsp.window.float())
hl.bind(mainMod .. "D", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. "SHIFT + D", hl.dsp.exec_cmd(run))
hl.bind(mainMod .. "N", hl.dsp.exec_cmd(notifications))
hl.bind(mainMod .. "P", hl.dsp.window.pseudo())
hl.bind(mainMod .. "SHIFT + P", hl.dsp.exec_cmd("wlogout"))
hl.bind(mainMod .. "SHIFT + W", hl.dsp.exec_cmd("hyprlock"))

-- Focus movement (Vim keys)
hl.bind(
	mainMod .. "H",
	hl.dsp.focus({
		direction = "left",
	})
)
hl.bind(
	mainMod .. "L",
	hl.dsp.focus({
		direction = "right",
	})
)
hl.bind(
	mainMod .. "K",
	hl.dsp.focus({
		direction = "up",
	})
)
hl.bind(
	mainMod .. "J",
	hl.dsp.focus({
		direction = "down",
	})
)

-- Window movement (Vim keys)
hl.bind(
	mainMod .. "SHIFT + H",
	hl.dsp.window.swap({
		direction = "left",
	})
)
hl.bind(
	mainMod .. "SHIFT + L",
	hl.dsp.window.swap({
		direction = "right",
	})
)
hl.bind(
	mainMod .. "SHIFT + K",
	hl.dsp.window.swap({
		direction = "up",
	})
)
hl.bind(
	mainMod .. "SHIFT + J",
	hl.dsp.window.swap({
		direction = "down",
	})
)

-- Workspaces
hl.bind(
	mainMod .. "1",
	hl.dsp.focus({
		workspace = 1,
	})
)
hl.bind(
	mainMod .. "2",
	hl.dsp.focus({
		workspace = 2,
	})
)
hl.bind(
	mainMod .. "3",
	hl.dsp.focus({
		workspace = 3,
	})
)
hl.bind(
	mainMod .. "4",
	hl.dsp.focus({
		workspace = 4,
	})
)
hl.bind(
	mainMod .. "5",
	hl.dsp.focus({
		workspace = 5,
	})
)
hl.bind(
	mainMod .. "6",
	hl.dsp.focus({
		workspace = 6,
	})
)
hl.bind(
	mainMod .. "7",
	hl.dsp.focus({
		workspace = 7,
	})
)
hl.bind(
	mainMod .. "8",
	hl.dsp.focus({
		workspace = 8,
	})
)
hl.bind(
	mainMod .. "9",
	hl.dsp.focus({
		workspace = 9,
	})
)
hl.bind(
	mainMod .. "0",
	hl.dsp.focus({
		workspace = 10,
	})
)

-- Move to Workspace
hl.bind(
	mainMod .. "SHIFT + 1",
	hl.dsp.window.move({
		workspace = 1,
	})
)
hl.bind(
	mainMod .. "SHIFT + 2",
	hl.dsp.window.move({
		workspace = 2,
	})
)
hl.bind(
	mainMod .. "SHIFT + 3",
	hl.dsp.window.move({
		workspace = 3,
	})
)
hl.bind(
	mainMod .. "SHIFT + 4",
	hl.dsp.window.move({
		workspace = 4,
	})
)
hl.bind(
	mainMod .. "SHIFT + 5",
	hl.dsp.window.move({
		workspace = 5,
	})
)
hl.bind(
	mainMod .. "SHIFT + 6",
	hl.dsp.window.move({
		workspace = 6,
	})
)
hl.bind(
	mainMod .. "SHIFT + 7",
	hl.dsp.window.move({
		workspace = 7,
	})
)
hl.bind(
	mainMod .. "SHIFT + 8",
	hl.dsp.window.move({
		workspace = 8,
	})
)
hl.bind(
	mainMod .. "SHIFT + 9",
	hl.dsp.window.move({
		workspace = 9,
	})
)
hl.bind(
	mainMod .. "SHIFT + 0",
	hl.dsp.window.move({
		workspace = 10,
	})
)

-- Color picker
hl.bind(mainMod .. "I", hl.dsp.exec_cmd("hyprpicker -a"))

-- Resize windows
hl.bind(mainMod .. "ALT + H", hl.dsp.window.resize({ x = -20, y = 0, relative = true }))
hl.bind(mainMod .. "ALT + L", hl.dsp.window.resize({ x = 20, y = 0, relative = true }))
hl.bind(mainMod .. "ALT + K", hl.dsp.window.resize({ x = 0, y = -20, relative = true }))
hl.bind(mainMod .. "ALT + J", hl.dsp.window.resize({ x = 0, y = 20, relative = true }))

-- Screenshot
hl.bind(mainMod .. "C", hl.dsp.exec_cmd("hyprshot -m window"))
hl.bind(mainMod .. "SHIFT + C", hl.dsp.exec_cmd("hyprshot -m region"))

-- Special workspace
hl.bind(mainMod .. "S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. "SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll workspaces
hl.bind(mainMod .. "mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. "mouse_up", hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. "mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. "mouse:273", hl.dsp.window.resize(), { mouse = true })
