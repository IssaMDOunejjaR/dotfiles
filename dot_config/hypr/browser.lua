-- ====== Browser Window Rules ======

-- Tag Chromium-based browsers
hl.window_rule({
	match = {
		class = "((google-)?[cC]hrom(e|ium)|[bB]rave-(browser|origin)|Microsoft-edge|Vivaldi-stable|helium)",
	},
	tag = "+chromium-based-browser",
})

-- Tag Firefox-based browsers
hl.window_rule({
	match = {
		class = "([fF]irefox|zen|librewolf)",
	},
	tag = "+firefox-based-browser",
})

-- Force Chromium-based browsers into a tile to deal with --app bug
hl.window_rule({
	match = {
		tag = "chromium-based-browser",
	},
	tile = true,
})

-- Browser opacity is a multiplier unless explicitly overridden. Keep media
-- readable when focus moves to another window; this also covers normal tabs.
hl.window_rule({
	match = {
		tag = "chromium-based-browser",
	},
	opacity = "1.0 override 1.0 override 1.0 override",
})

hl.window_rule({
	match = { tag = "firefox-based-browser" },
	opacity = "1.0 override 1.0 override 1.0 override",
})
