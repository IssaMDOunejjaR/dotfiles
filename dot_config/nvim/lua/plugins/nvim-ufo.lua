return {
	"kevinhwang91/nvim-ufo",
	dependencies = {
		"kevinhwang91/promise-async",
	},
	event = "BufReadPost",
	opts = {
		provider_selector = function()
			return { "treesitter", "indent" }
		end,
		fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
			local newVirtText = {}
			local suffix = (" 󰁂 %d lines "):format(endLnum - lnum)
			local sufWidth = vim.fn.strdisplaywidth(suffix)
			local targetWidth = width - sufWidth
			local curWidth = 0

			for _, chunk in ipairs(virtText) do
				local chunkText = chunk[1]
				local chunkWidth = vim.fn.strdisplaywidth(chunkText)

				if targetWidth > curWidth + chunkWidth then
					table.insert(newVirtText, chunk)
				else
					chunkText = truncate(chunkText, targetWidth - curWidth)
					local hlGroup = chunk[2]
					table.insert(newVirtText, { chunkText, hlGroup })
					chunkWidth = vim.fn.strdisplaywidth(chunkText)

					if curWidth + chunkWidth < targetWidth then
						suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
					end

					break
				end

				curWidth = curWidth + chunkWidth
			end

			table.insert(newVirtText, { suffix, "UfoFoldedEllipsis" })
			return newVirtText
		end,
	},
	keys = {
		{
			"zR",
			function()
				require("ufo").openAllFolds()
			end,
			desc = "Fold: Open all",
		},
		{
			"zM",
			function()
				require("ufo").closeAllFolds()
			end,
			desc = "Fold: Close all",
		},
		{
			"zr",
			function()
				require("ufo").openFoldsExceptKinds()
			end,
			desc = "Fold: Open folds except kinds",
		},
		{
			"zm",
			function()
				require("ufo").closeFoldsWith()
			end,
			desc = "Fold: Close folds with",
		},
		{
			"zK",
			function()
				local winid = require("ufo").peekFoldedLinesUnderCursor()
				if not winid then
					vim.lsp.buf.hover()
				end
			end,
			desc = "Fold: Peek folded lines / Hover",
		},
	},
}
