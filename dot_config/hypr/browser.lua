-- ====== Browser Window Rules ======

-- Tag Chromium-based browsers
hl.window_rule({
	match = {
		class = "((google-)?[cC]hrom(e|ium)|[bB]rave-browser|Microsoft-edge|Vivaldi-stable|helium)",
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
	opacity = "1 0.97",
})

-- Only a subtle opacity change for Firefox
hl.window_rule({
	match = {
		tag = "firefox-based-browser",
	},
	opacity = "1 0.97",
})

-- Video sites should never have opacity applied
hl.window_rule({
	match = {
		initial_title = "((?i)(?:[a-z0-9-]+\\.)*youtube\\.com_/|app\\.zoom\\.us_/wc/home)",
	},
	opacity = "1.0 1.0",
})
