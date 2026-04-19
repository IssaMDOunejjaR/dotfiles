-- ============================================================
-- DEBUG ADAPTER PROTOCOL
-- nvim-dap        — core engine
-- nvim-dap-ui     — panels: scopes, watches, stack, console
-- nvim-nio        — async lib required by dap-ui
-- nvim-dap-virtual-text — inline variable values while paused
-- nvim-dap-go     — Go / Delve integration
-- ============================================================
return {
	{
		"mfussenegger/nvim-dap",
		-- Load on explicit keymap use; adapters are configured in the config below
		keys = {
			{ "<leader>dc", function() require("dap").continue() end,          desc = "DAP: Continue / Start" },
			{ "<leader>do", function() require("dap").step_over() end,         desc = "DAP: Step over" },
			{ "<leader>di", function() require("dap").step_into() end,         desc = "DAP: Step into" },
			{ "<leader>du", function() require("dap").step_out() end,          desc = "DAP: Step out" },
			{ "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "DAP: Toggle breakpoint" },
			{
				"<leader>dB",
				function()
					require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
				end,
				desc = "DAP: Conditional breakpoint",
			},
			{ "<leader>dl", function() require("dap").run_last() end,          desc = "DAP: Run last" },
			{ "<leader>dr", function() require("dap").repl.open() end,         desc = "DAP: Open REPL" },
			{ "<leader>dt", function() require("dap").terminate() end,         desc = "DAP: Terminate session" },
		},
		config = function()
			local dap = require("dap")

			-- ── Visual breakpoint signs ────────────────────────────────
			vim.fn.sign_define("DapBreakpoint",          { text = "●", texthl = "DiagnosticError",   linehl = "", numhl = "" })
			vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarning", linehl = "", numhl = "" })
			vim.fn.sign_define("DapLogPoint",            { text = "◎", texthl = "DiagnosticInfo",    linehl = "", numhl = "" })
			vim.fn.sign_define("DapStopped",             { text = "▶", texthl = "DiagnosticOk",      linehl = "DapStoppedLine", numhl = "" })
			vim.fn.sign_define("DapBreakpointRejected",  { text = "○", texthl = "DiagnosticHint",    linehl = "", numhl = "" })

			-- ── Highlight for the line where execution is paused ───────
			vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

			-- ── JS / TS / React / Angular ──────────────────────────────
			-- Uses js-debug-adapter installed by Mason.
			-- Covers: Node.js (server-side), Chrome/Edge (browser) launch configs.
			local js_adapter_path = vim.fn.stdpath("data")
				.. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js"

			if vim.fn.filereadable(js_adapter_path) == 1 then
				-- pwa-node: debugs Node.js processes (server-side JS/TS)
				dap.adapters["pwa-node"] = {
					type = "server",
					host = "localhost",
					port = "${port}",
					executable = {
						command = "node",
						args = { js_adapter_path, "${port}" },
					},
				}

				-- pwa-chrome: debugs browser JS via Chrome DevTools Protocol.
				-- Must be its own entry — NOT an alias for pwa-node. The adapter
				-- switches into CDP/browser mode based on the adapter type name it
				-- receives at initialisation; aliasing causes a timeout.
				dap.adapters["pwa-chrome"] = {
					type = "server",
					host = "localhost",
					port = "${port}",
					executable = {
						command = "node",
						args = { js_adapter_path, "${port}" },
					},
				}

				-- node: convenience alias for pwa-node (used by some config presets)
				dap.adapters["node"] = dap.adapters["pwa-node"]

				-- sourceMapPathOverrides: maps the in-browser URL paths back to
				-- the on-disk source files so breakpoints land in .ts/.tsx files.
				local source_map_overrides = {
					-- webpack (CRA, Angular CLI, most setups)
					["webpack:///./~/*"]    = "${workspaceFolder}/node_modules/*",
					["webpack:///./*"]      = "${workspaceFolder}/*",
					["webpack:///*"]        = "*",
					["webpack:///src/*"]    = "${workspaceFolder}/src/*",
					-- Vite (React Vite, Vitest)
					["vite:///src/*"]       = "${workspaceFolder}/src/*",
					["/src/*"]              = "${workspaceFolder}/src/*",
				}

				-- ── Shared Node configs (all JS/TS filetypes) ─────────
				local node_configs = {
					{
						type       = "pwa-node",
						request    = "launch",
						name       = "Launch file (Node)",
						program    = "${file}",
						cwd        = "${workspaceFolder}",
						sourceMaps = true,
						sourceMapPathOverrides = source_map_overrides,
					},
					{
						type      = "pwa-node",
						request   = "attach",
						name      = "Attach to Node process",
						processId = require("dap.utils").pick_process,
						cwd       = "${workspaceFolder}",
						sourceMaps = true,
						sourceMapPathOverrides = source_map_overrides,
					},
				}

				-- ── Angular: Chrome → localhost:4200 ──────────────────
				-- Angular CLI dev server always binds to 4200 by default.
				local angular_chrome = {
					type        = "pwa-chrome",
					request     = "launch",
					name        = "Launch Chrome (Angular :4200)",
					url         = "http://localhost:4200",
					webRoot     = "${workspaceFolder}",
					sourceMaps  = true,
					sourceMapPathOverrides = source_map_overrides,
					-- Use the existing default Chrome profile instead of a temp one.
					-- Set to false to let js-debug-adapter manage a fresh profile,
					-- or set to a path string to reuse a specific profile.
					userDataDir = false,
				}

				-- ── React / Vite: Chrome → prompted port ──────────────
				-- CRA defaults to 3000, Vite to 5173 — prompt so neither
				-- project type needs a manual config edit.
				local react_chrome = {
					type        = "pwa-chrome",
					request     = "launch",
					name        = "Launch Chrome (React — enter port)",
					url         = function()
						local port = vim.fn.input("Dev server port [3000]: ")
						if port == "" then port = "3000" end
						return "http://localhost:" .. port
					end,
					webRoot     = "${workspaceFolder}",
					sourceMaps  = true,
					sourceMapPathOverrides = source_map_overrides,
					userDataDir = false,
				}

				-- Plain JS/TS: no Chrome config (server-side or library code)
				for _, ft in ipairs({ "javascript", "typescript" }) do
					dap.configurations[ft] = dap.configurations[ft] or {}
					vim.list_extend(dap.configurations[ft], node_configs)
				end

				-- React (JSX/TSX): Node configs + React Chrome config
				for _, ft in ipairs({ "javascriptreact", "typescriptreact" }) do
					dap.configurations[ft] = dap.configurations[ft] or {}
					vim.list_extend(dap.configurations[ft], node_configs)
					table.insert(dap.configurations[ft], react_chrome)
				end

				-- Angular: TypeScript files in an Angular project get the
				-- Angular Chrome config appended. Detection mirrors lsp-auto-install:
				-- look for angular.json above the buffer's directory.
				-- We append lazily via an autocmd so the buffer path is available.
				vim.api.nvim_create_autocmd("FileType", {
					pattern  = { "typescript", "htmlangular" },
					group    = vim.api.nvim_create_augroup("DapAngularConfigs", { clear = true }),
					callback = function(args)
						local bufname = vim.api.nvim_buf_get_name(args.buf)
						if bufname == "" then return end
						local angular_json = vim.fs.find("angular.json", {
							upward = true,
							path   = vim.fn.fnamemodify(bufname, ":h"),
						})[1]
						if not angular_json then return end
						-- Only add once per filetype (guard against duplicate entries)
						local ft_configs = dap.configurations[args.match] or {}
						for _, cfg in ipairs(ft_configs) do
							if cfg.name == angular_chrome.name then return end
						end
						dap.configurations[args.match] = ft_configs
						table.insert(dap.configurations[args.match], angular_chrome)
					end,
				})
			end

			-- ── C / C++ / Rust ─────────────────────────────────────────
			-- codelldb is a single adapter that handles all three languages.
			-- Installed by Mason (see lsp-auto-install.lua for c, cpp, rust fts).
			local codelldb_path = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb"

			if vim.fn.filereadable(codelldb_path) == 1 then
				dap.adapters.codelldb = {
					type    = "server",
					port    = "${port}",
					executable = {
						command = codelldb_path,
						args    = { "--port", "${port}" },
					},
				}

				-- Shared launch/attach configs reused for c, cpp, and rust
				local function prompt_args()
					local args_str = vim.fn.input("Program arguments (space-separated): ")
					if args_str == "" then return {} end
					-- Split on whitespace
					local args = {}
					for arg in args_str:gmatch("%S+") do
						table.insert(args, arg)
					end
					return args
				end

				local codelldb_configs = function(subdir)
					return {
						{
							type        = "codelldb",
							request     = "launch",
							name        = "Launch executable",
							-- evaluated at launch time so cwd reflects the actual project
							program     = function()
								return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. subdir, "file")
							end,
							cwd         = "${workspaceFolder}",
							stopOnEntry = false,
							args        = {},
						},
						{
							type        = "codelldb",
							request     = "launch",
							name        = "Launch executable (with args)",
							program     = function()
								return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. subdir, "file")
							end,
							cwd         = "${workspaceFolder}",
							stopOnEntry = false,
							args        = prompt_args,
						},
						{
							type        = "codelldb",
							request     = "attach",
							name        = "Attach to process",
							pid         = require("dap.utils").pick_process,
							cwd         = "${workspaceFolder}",
						},
					}
				end

				-- C and C++: binaries typically land in the project root or a build/ dir
				dap.configurations.c   = codelldb_configs("/build/")
				dap.configurations.cpp = codelldb_configs("/build/")

				-- Rust: cargo puts debug binaries in target/debug/
				dap.configurations.rust = codelldb_configs("/target/debug/")
			end
		end,
	},

	-- ── UI ────────────────────────────────────────────────────────────────
	{
		"rcarriga/nvim-dap-ui",
		dependencies = {
			"mfussenegger/nvim-dap",
			"nvim-neotest/nvim-nio",
		},
		keys = {
			{ "<leader>dU", function() require("dapui").toggle() end, desc = "DAP: Toggle UI" },
		},
		config = function()
			local dap, dapui = require("dap"), require("dapui")

			dapui.setup({
				icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
				mappings = {
					-- Use a table to apply multiple mappings
					expand    = { "<CR>", "<2-LeftMouse>" },
					open      = "o",
					remove    = "d",
					edit      = "e",
					repl      = "r",
					toggle    = "t",
				},
				-- Sidebar layout: left side gets scopes+watches, right side gets stack+console
				layouts = {
					{
						elements = {
							{ id = "scopes",      size = 0.40 },
							{ id = "breakpoints", size = 0.20 },
							{ id = "stacks",      size = 0.25 },
							{ id = "watches",     size = 0.15 },
						},
						size     = 40, -- columns
						position = "left",
					},
					{
						elements = {
							{ id = "repl",    size = 0.5 },
							{ id = "console", size = 0.5 },
						},
						size     = 12, -- rows
						position = "bottom",
					},
				},
				floating = {
					max_height  = 0.9,
					max_width   = 0.8,
					border      = "single",
					mappings    = { close = { "q", "<Esc>" } },
				},
				render = {
					max_type_length = nil,
					max_value_lines = 100,
				},
			})

			-- Auto-open UI when a debug session starts, auto-close when it ends
			dap.listeners.after.event_initialized["dapui_config"]  = function() dapui.open() end
			dap.listeners.before.event_terminated["dapui_config"]  = function() dapui.close() end
			dap.listeners.before.event_exited["dapui_config"]      = function() dapui.close() end
		end,
	},

	-- ── Inline variable values ────────────────────────────────────────────
	{
		"theHamsta/nvim-dap-virtual-text",
		dependencies = { "mfussenegger/nvim-dap" },
		opts = {
			enabled                   = true,
			enabled_commands          = true,  -- :DapVirtualTextEnable / Disable / Toggle
			highlight_changed_variables = true, -- highlight vars whose value changed
			highlight_new_as_changed  = false,
			show_stop_reason          = true,   -- show why execution stopped
			commented                 = false,  -- prefix with comment syntax
			only_first_definition     = true,   -- avoid duplicate annotations
			all_references            = false,
			display_callback          = function(variable, buf, stackframe, node, options)
				-- Keep it short: show name = value, trimmed to 80 chars
				local val = variable.value
				if #val > 80 then
					val = val:sub(1, 77) .. "..."
				end
				return " = " .. val
			end,
			-- Highlight groups
			virt_text_pos  = "eol",            -- end of line
		},
	},

	-- ── Go / Delve ────────────────────────────────────────────────────────
	{
		"leoluz/nvim-dap-go",
		dependencies = { "mfussenegger/nvim-dap" },
		ft = { "go" },
		keys = {
			{ "<leader>dgt", function() require("dap-go").debug_test() end,      desc = "DAP Go: Debug test under cursor" },
			{ "<leader>dgl", function() require("dap-go").debug_last_test() end, desc = "DAP Go: Debug last test" },
		},
		opts = {
			-- Use the Delve binary from $PATH (installed via: go install github.com/go-delve/delve/cmd/dlv@latest)
			delve = {
				path             = "dlv",
				initialize_timeout_sec = 20,
				port             = "${port}",
				args             = {},
				build_flags      = "",
			},
		},
	},
}
