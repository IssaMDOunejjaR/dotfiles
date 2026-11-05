-- nvim-treesitter-textobjects (branch 'main' — standalone module API,
-- compatible with the new main-branch nvim-treesitter).
-- Letters chosen to avoid mini.ai built-ins (a=argument, b=brackets,
-- f=function call, t=tag, q=quotes): function definitions use F, classes use c.
return {
	"nvim-treesitter/nvim-treesitter-textobjects",
	branch = "main",
	event = "VeryLazy",
	config = function()
		require("nvim-treesitter-textobjects").setup({
			select = {
				lookahead = true,
				selection_modes = {
					["@parameter.outer"] = "v", -- charwise
					["@function.outer"] = "V", -- linewise
					["@class.outer"] = "V", -- linewise
				},
			},
			move = {
				set_jumps = true,
			},
		})

		local select = require("nvim-treesitter-textobjects.select")
		local move = require("nvim-treesitter-textobjects.move")

		-- SELECT (x = visual, o = operator-pending: e.g. `daF`, `vif`, `cic`)
		vim.keymap.set({ "x", "o" }, "aF", function()
			select.select_textobject("@function.outer", "textobjects")
		end, { desc = "Select around function definition" })
		vim.keymap.set({ "x", "o" }, "iF", function()
			select.select_textobject("@function.inner", "textobjects")
		end, { desc = "Select inside function definition" })
		vim.keymap.set({ "x", "o" }, "ac", function()
			select.select_textobject("@class.outer", "textobjects")
		end, { desc = "Select around class" })
		vim.keymap.set({ "x", "o" }, "ic", function()
			select.select_textobject("@class.inner", "textobjects")
		end, { desc = "Select inside class" })

		-- MOVE (n/x/o, jumplist-aware) — overrides the built-in ]m/[m/]]/[[
		local function move_map(lhs, fn, obj, desc)
			vim.keymap.set({ "n", "x", "o" }, lhs, function()
				fn(obj, "textobjects")
			end, { desc = desc })
		end
		move_map("]m", move.goto_next_start, "@function.outer", "Next function start")
		move_map("[m", move.goto_previous_start, "@function.outer", "Previous function start")
		move_map("]M", move.goto_next_end, "@function.outer", "Next function end")
		move_map("[M", move.goto_previous_end, "@function.outer", "Previous function end")
		move_map("]]", move.goto_next_start, "@class.outer", "Next class start")
		move_map("[[", move.goto_previous_start, "@class.outer", "Previous class start")
	end,
}
