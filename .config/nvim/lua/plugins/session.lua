return {
	"rmagatti/auto-session",
	event = "VimEnter",

	---enables autocomplete for opts
	---@module "auto-session"
	---@type AutoSession.Config
	opts = {
		-- suppressed_dirs = { '~/', '~/Projects', '~/Downloads', '/' },
		-- log_level = 'debug',
		auto_session_enabled = true,
		auto_save_enabled = true,
		auto_restore_enabled = true,
	},
}
