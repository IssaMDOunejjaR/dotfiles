return {
	"rmagatti/auto-session",

	lazy = false,

	---enables autocomplete for opts
	---@module "auto-session"
	---@type AutoSession.Config
	opts = {
		-- suppressed_dirs = { '~/', '~/Projects', '~/Downloads', '/' },
		enabled = true,
		auto_save = true,
		auto_restore = true,
	},
}
