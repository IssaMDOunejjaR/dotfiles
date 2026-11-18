hl.monitor({
	output = "",
	mode = "preferred",
	scale = 1,
	vrr = 3,
})

-- Match the physical display rather than a connector that may change.
hl.monitor({
	output = "desc:Microstep MSI MAG301CR2",
	mode = "2560x1080@200",
	position = "0x0",
	scale = 1,
	vrr = 3,
})
