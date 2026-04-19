return {
	"nickjvandyke/opencode.nvim",
	version = "*",
	event = "VeryLazy",
	dependencies = {
		-- snacks.nvim is already in this config; opt-in to the opencode enhancements
		{
			"folke/snacks.nvim",
			optional = true,
			opts = {
				input = {}, -- enhances opencode's ask() input prompt
				picker = {
					actions = {
						opencode_send = function(...)
							return require("opencode").snacks_picker_send(...)
						end,
					},
					win = {
						input = {
							keys = {
								-- <A-a> in any snacks picker → send selected files to opencode
								["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
							},
						},
					},
				},
			},
		},
	},
	config = function()
		vim.o.autoread = true -- required for automatic buffer reload after opencode edits

		---@type opencode.Opts
		vim.g.opencode_opts = {
			-- opencode will be started automatically with --port when toggled
		}

		local keymap = vim.keymap.set

		-- ── Toggle / open ────────────────────────────────────────────────
		keymap({ "n", "t" }, "<leader>ao", function()
			require("opencode").toggle()
		end, { desc = "AI: Toggle OpenCode" })

		-- ── Ask with context ─────────────────────────────────────────────
		-- Normal mode: sends cursor position context
		-- Visual mode: sends the selection as context
		keymap({ "n", "x" }, "<leader>aa", function()
			require("opencode").ask("@this: ", { submit = true })
		end, { desc = "AI: Ask OpenCode" })

		-- ── Action picker ────────────────────────────────────────────────
		keymap({ "n", "x" }, "<leader>ax", function()
			require("opencode").select()
		end, { desc = "AI: Select action" })

		-- ── Operator: send any motion/range to OpenCode ──────────────────
		-- go{motion} — e.g. goip sends inner paragraph, gofoo sends to next "foo"
		-- goo        — send current line
		keymap("n", "go", function()
			return require("opencode").operator("@this ")
		end, { desc = "AI: Send motion to OpenCode", expr = true })
		keymap("n", "goo", function()
			return require("opencode").operator("@this ") .. "_"
		end, { desc = "AI: Send line to OpenCode", expr = true })

		-- ── Scroll OpenCode panel without switching focus ─────────────────
		keymap("n", "<C-S-u>", function()
			require("opencode").command("session.half.page.up")
		end, { desc = "AI: Scroll OpenCode up" })
		keymap("n", "<C-S-d>", function()
			require("opencode").command("session.half.page.down")
		end, { desc = "AI: Scroll OpenCode down" })

		-- ── Session commands ─────────────────────────────────────────────
		keymap("n", "<leader>an", function()
			require("opencode").command("session.new")
		end, { desc = "AI: New session" })
		keymap("n", "<leader>al", function()
			require("opencode").command("session.list")
		end, { desc = "AI: List sessions" })
		keymap("n", "<leader>au", function()
			require("opencode").command("session.undo")
		end, { desc = "AI: Undo last OpenCode action" })
	end,
}
