local colors = require("sttusline.utils.color")
local utils = require("sttusline.utils")
local M = {}

local configs = {
	disabled = {
		filetypes = {},
		buftypes = {
			"terminal",
		},
	},
	components = {
		{
			name = "mode",

			event = { "ModeChanged", "VimResized" }, -- The component will be update when the event is triggered
			user_event = { "VeryLazy" },

			configs = {
				modes = {
					["n"] = { "NORMAL", "STTUSLINE_NORMAL_MODE" },
					["no"] = { "NORMAL (no)", "STTUSLINE_NORMAL_MODE" },
					["nov"] = { "NORMAL (nov)", "STTUSLINE_NORMAL_MODE" },
					["noV"] = { "NORMAL (noV)", "STTUSLINE_NORMAL_MODE" },
					["noCTRL-V"] = { "NORMAL", "STTUSLINE_NORMAL_MODE" },
					["niI"] = { "NORMAL i", "STTUSLINE_NORMAL_MODE" },
					["niR"] = { "NORMAL r", "STTUSLINE_NORMAL_MODE" },
					["niV"] = { "NORMAL v", "STTUSLINE_NORMAL_MODE" },

					["nt"] = { "TERMINAL", "STTUSLINE_NTERMINAL_MODE" },
					["ntT"] = { "TERMINAL (ntT)", "STTUSLINE_NTERMINAL_MODE" },

					["v"] = { "VISUAL", "STTUSLINE_VISUAL_MODE" },
					["vs"] = { "V-CHAR (Ctrl O)", "STTUSLINE_VISUAL_MODE" },
					["V"] = { "V-LINE", "STTUSLINE_VISUAL_MODE" },
					["Vs"] = { "V-LINE", "STTUSLINE_VISUAL_MODE" },
					[""] = { "V-BLOCK", "STTUSLINE_VISUAL_MODE" },

					["i"] = { "INSERT", "STTUSLINE_INSERT_MODE" },
					["ic"] = { "INSERT (completion)", "STTUSLINE_INSERT_MODE" },
					["ix"] = { "INSERT completion", "STTUSLINE_INSERT_MODE" },

					["t"] = { "TERMINAL", "STTUSLINE_TERMINAL_MODE" },
					["!"] = { "SHELL", "STTUSLINE_TERMINAL_MODE" },

					["R"] = { "REPLACE", "STTUSLINE_REPLACE_MODE" },
					["Rc"] = { "REPLACE (Rc)", "STTUSLINE_REPLACE_MODE" },
					["Rx"] = { "REPLACEa (Rx)", "STTUSLINE_REPLACE_MODE" },
					["Rv"] = { "V-REPLACE", "STTUSLINE_REPLACE_MODE" },
					["Rvc"] = { "V-REPLACE (Rvc)", "STTUSLINE_REPLACE_MODE" },
					["Rvx"] = { "V-REPLACE (Rvx)", "STTUSLINE_REPLACE_MODE" },

					["s"] = { "SELECT", "STTUSLINE_SELECT_MODE" },
					["S"] = { "S-LINE", "STTUSLINE_SELECT_MODE" },
					[""] = { "S-BLOCK", "STTUSLINE_SELECT_MODE" },

					["c"] = { "COMMAND", "STTUSLINE_COMMAND_MODE" },
					["cv"] = { "COMMAND", "STTUSLINE_COMMAND_MODE" },
					["ce"] = { "COMMAND", "STTUSLINE_COMMAND_MODE" },

					["r"] = { "PROMPT", "STTUSLINE_CONFIRM_MODE" },
					["rm"] = { "MORE", "STTUSLINE_CONFIRM_MODE" },
					["r?"] = { "CONFIRM", "STTUSLINE_CONFIRM_MODE" },
					["x"] = { "CONFIRM", "STTUSLINE_CONFIRM_MODE" },
				},
				mode_colors = {
					["STTUSLINE_NORMAL_MODE"] = { fg = colors.blue, bg = colors.bg },
					["STTUSLINE_INSERT_MODE"] = { fg = colors.green, bg = colors.bg },
					["STTUSLINE_VISUAL_MODE"] = { fg = colors.purple, bg = colors.bg },
					["STTUSLINE_NTERMINAL_MODE"] = { fg = colors.gray, bg = colors.bg },
					["STTUSLINE_TERMINAL_MODE"] = { fg = colors.cyan, bg = colors.bg },
					["STTUSLINE_REPLACE_MODE"] = { fg = colors.red, bg = colors.bg },
					["STTUSLINE_SELECT_MODE"] = { fg = colors.magenta, bg = colors.bg },
					["STTUSLINE_COMMAND_MODE"] = { fg = colors.yellow, bg = colors.bg },
					["STTUSLINE_CONFIRM_MODE"] = { fg = colors.yellow, bg = colors.bg },
				},
				auto_hide_on_vim_resized = true,
			},

			-- number or table
			padding = 0, -- { left = 1, right = 1 }

			update = function(configs)
				local mode_code = vim.api.nvim_get_mode().mode
				local mode = configs.modes[mode_code]
				if mode then
					local hl_name = mode[2]
					vim.api.nvim_set_hl(0, hl_name, configs.mode_colors[hl_name])
					return utils.add_highlight_name(" " .. mode[1] .. " ", hl_name)
				end
				return " " .. mode_code .. " "
			end,
			condition = function(configs)
				if configs.auto_hide_on_vim_resized then
					if vim.o.columns > 70 then
						vim.opt.showmode = false
						return true
					else
						vim.opt.showmode = true
						return false
					end
				end
			end,
		},
		{
			name = "filename",
			event = { "BufEnter", "WinEnter" }, -- The component will be update when the event is triggered
			user_event = { "VeryLazy" },
			configs = {
				color = { fg = colors.orange, bg = colors.bg },
			},

			space = {
				FILENAME_HIGHLIGHT = "STTUSLINE_FILE_NAME",
				ICON_HIGHLIGHT = "STTUSLINE_FILE_ICON",
			},

			update = function(_, _, space)
				local has_devicons, devicons = pcall(require, "nvim-web-devicons")

				local filename = vim.fn.expand("%:t")
				if filename == "" then filename = "No File" end
				local icon, color_icon = nil, nil
				if has_devicons then
					icon, color_icon = devicons.get_icon_color(filename, vim.fn.expand("%:e"))
				end

				if not icon then
					local buftype = vim.api.nvim_buf_get_option(0, "buftype")
					local filetype = vim.api.nvim_buf_get_option(0, "filetype")
					if buftype == "terminal" then
						icon, color_icon = "", colors.red
						filename = "Terminal"
					elseif filetype == "NvimTree" then
						icon, color_icon = "󰙅", colors.red
						filename = "NvimTree"
					elseif filetype == "TelescopePrompt" then
						icon, color_icon = "", colors.red
						filename = "Telescope"
					elseif filetype == "mason" then
						icon, color_icon = "󰏔", colors.red
						filename = "Mason"
					elseif filetype == "lazy" then
						icon, color_icon = "󰏔", colors.red
						filename = "Lazy"
					elseif filetype == "dashboard" then
						icon, color_icon = "", colors.red
					end
				end

				vim.api.nvim_set_hl(0, space.ICON_HIGHLIGHT, { fg = color_icon, bg = colors.bg })

				if icon then
					return utils.add_highlight_name(icon, space.ICON_HIGHLIGHT)
						.. " "
						.. utils.add_highlight_name(filename, space.FILENAME_HIGHLIGHT)
				else
					return utils.add_highlight_name(filename, space.FILENAME_HIGHLIGHT)
				end
			end,
			on_highlight = function(configs, _, space)
				vim.api.nvim_set_hl(0, space.FILENAME_HIGHLIGHT, configs.color)
			end,
		},
		{
			name = "git-branch",
			event = { "BufEnter" }, -- The component will be update when the event is triggered
			user_event = { "VeryLazy", "GitSignsUpdate" },
			configs = {
				icon = "",
			},
			colors = { fg = colors.pink, bg = colors.bg }, -- { fg = colors.black, bg = colors.white }
			space = {
				get_branch = function()
					local git_dir = vim.fn.finddir(".git", ".;")
					if git_dir ~= "" then
						local head_file = io.open(git_dir .. "/HEAD", "r")
						if head_file then
							local content = head_file:read("*all")
							head_file:close()
							return content:match("ref: refs/heads/(.-)%s*$")
						end
						return ""
					end
					return ""
				end,
			},
			update = function(configs, _, space)
				local branch = space.get_branch()
				return branch ~= "" and configs.icon .. " " .. branch or ""
			end,
			condition = function() return vim.api.nvim_buf_get_option(0, "buflisted") end,
		},
		{
			name = "git-diff",
			event = { "BufWritePost", "VimResized", "BufEnter" }, -- The component will be update when the event is triggered
			user_event = { "GitSignsUpdate" },
			space = {
				ADD_HIGHLIGHT_PREFIX = "STTUSLINE_GIT_DIFF_",
			},
			configs = {
				icons = {
					added = "",
					changed = "",
					removed = "",
				},
				colors = {
					added = { fg = colors.tokyo_diagnostics_hint, bg = colors.bg },
					changed = { fg = colors.tokyo_diagnostics_hint, bg = colors.bg },
					removed = { fg = colors.tokyo_diagnostics_error, bg = colors.bg },
				},
				order = { "added", "changed", "removed" },
			},
			update = function(configs, _, space)
				local git_status = vim.b.gitsigns_status_dict

				local order = configs.order
				local icons = configs.icons
				local diff_colors = configs.colors

				local result = {}
				for _, v in ipairs(order) do
					if git_status[v] and git_status[v] > 0 then
						local color = diff_colors[v]

						if color then
							if utils.is_color(color) or type(color) == "table" then
								table.insert(
									result,
									utils.add_highlight_name(
										icons[v] .. " " .. git_status[v],
										space.ADD_HIGHLIGHT_PREFIX .. v
									)
								)
							else
								table.insert(result, utils.add_highlight_name(icons[v] .. " " .. git_status[v], color))
							end
						end
					end
				end

				return #result > 0 and table.concat(result, " ") or ""
			end,
			condition = function() return vim.b.gitsigns_status_dict ~= nil and vim.o.columns > 70 end,
			on_highlight = function(configs, _, space)
				local conf_colors = configs.colors
				for key, color in pairs(conf_colors) do
					if utils.is_color(color) then
						vim.api.nvim_set_hl(0, space.ADD_HIGHLIGHT_PREFIX .. key, { fg = color, bg = colors.bg })
					elseif type(color) == "table" then
						vim.api.nvim_set_hl(0, space.ADD_HIGHLIGHT_PREFIX .. key, color)
					end
				end
			end,
		},
		"%=",
		{
			name = "diagnostics",
			event = { "DiagnosticChanged" }, -- The component will be update when the event is triggered

			configs = {
				icons = {
					ERROR = "",
					INFO = "",
					HINT = "󰌵",
					WARN = "",
				},
				diagnostics_color = {
					ERROR = { fg = colors.tokyo_diagnostics_error, bg = colors.bg },
					WARN = { fg = colors.tokyo_diagnostics_warn, bg = colors.bg },
					HINT = { fg = colors.tokyo_diagnostics_hint, bg = colors.bg },
					INFO = { fg = colors.tokyo_diagnostics_info, bg = colors.bg },
				},
				order = { "ERROR", "WARN", "INFO", "HINT" },
			},
			space = {
				HIGHLIGHT_PREFIX = "STTUSLINE_DIAGNOSTICS_",
			},
			update = function(configs, _, space)
				local result = {}

				local icons = configs.icons
				local diagnostics_color = configs.diagnostics_color
				local order = configs.order

				for _, key in ipairs(order) do
					local count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity[key] })

					if count > 0 then
						local color = diagnostics_color[key]
						if color then
							if utils.is_color(color) or type(color) == "table" then
								table.insert(
									result,
									utils.add_highlight_name(icons[key] .. " " .. count, space.HIGHLIGHT_PREFIX .. key)
								)
							else
								table.insert(result, utils.add_highlight_name(icons[key] .. " " .. count, color))
							end
						end
					end
				end

				return #result > 0 and table.concat(result, " ") or ""
			end,
			condition = function()
				local filetype = vim.api.nvim_buf_get_option(0, "filetype")
				return filetype ~= "lazy"
			end,

			on_highlight = function(configs, _, space)
				local diagnostics_color = configs.diagnostics_color
				for key, color in pairs(diagnostics_color) do
					if utils.is_color(color) then
						vim.api.nvim_set_hl(0, space.HIGHLIGHT_PREFIX .. key, { fg = color, bg = colors.bg })
					elseif type(color) == "table" then
						vim.api.nvim_set_hl(0, space.HIGHLIGHT_PREFIX .. key, color)
					end
				end
			end,
		},
		{
			name = "lsps-formatters",
			event = { "LspAttach", "LspDetach", "BufWritePost", "BufEnter", "VimResized" }, -- The component will be update when the event is triggered

			timing = false, -- The component will be update every time interval

			lazy = true,

			utils = {},
			configs = {},

			-- number or table
			padding = 1, -- { left = 1, right = 1 }
			colors = { fg = colors.magenta, bg = colors.bg }, -- { fg = colors.black, bg = colors.white }

			init = function() end,
			update = function()
				local buf_clients = vim.lsp.buf_get_clients()
				if not buf_clients or #buf_clients == 0 then return "NO LSP  " end

				local server_names = {}

				for _, client in pairs(buf_clients) do
					local client_name = client.name
					if client_name ~= "null-ls" and client_name ~= "copilot" then
						table.insert(server_names, client_name)
					end
				end

				if package.loaded["null-ls"] then
					local has_null_ls, null_ls = pcall(require, "null-ls")

					if has_null_ls then
						local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
						local null_ls_methods = {
							null_ls.methods.DIAGNOSTICS,
							null_ls.methods.DIAGNOSTICS_ON_OPEN,
							null_ls.methods.DIAGNOSTICS_ON_SAVE,
							null_ls.methods.FORMATTING,
						}

						local get_null_ls_sources = function(methods, name_only)
							local sources = require("null-ls.sources")
							local available_sources = sources.get_available(buf_ft)

							methods = type(methods) == "table" and methods or { methods }

							-- methods = nil or {}
							if #methods == 0 then
								if name_only then
									return vim.tbl_map(function(source) return source.name end, available_sources)
								end
								return available_sources
							end

							local source_results = {}

							for _, source in ipairs(available_sources) do
								for _, method in ipairs(methods) do
									if source.methods[method] then
										if name_only then
											table.insert(source_results, source.name)
										else
											table.insert(source_results, source)
										end
										break
									end
								end
							end

							return source_results
						end

						local null_ls_builtins = get_null_ls_sources(null_ls_methods, true)
						vim.list_extend(server_names, null_ls_builtins)
					end
				end

				if package.loaded["conform"] then
					local has_conform, conform = pcall(require, "conform")
					if has_conform then
						vim.list_extend(
							server_names,
							vim.tbl_map(function(formatter) return formatter.name end, conform.list_formatters(0))
						)
					end
				end

				return table.concat(vim.fn.uniq(server_names), ", ")
			end,
			condition = function() return vim.o.columns > 70 end,

			on_highlight = function() end,
		},
		{
			name = "copilot",
			event = { "InsertEnter", "InsertLeave", "CursorHoldI" }, -- The component will be update when the event is triggered

			space = function(configs)
				local copilot_status = ""
				local copilot_client = nil
				local copilot_handler_registered = false
				local S = {}

				local handle_status_data = function(data) copilot_status = string.lower(data.status) end

				S.check_status = function()
					local cp_client_ok, cp_client = pcall(require, "copilot.client")
					if not cp_client_ok then
						require("sttusline.utils.notify").error("Cannot load copilot.client")
						return
					end

					copilot_client = cp_client.get()

					if not copilot_client then
						copilot_status = "error"
						return
					end

					local cp_api_ok, cp_api = pcall(require, "copilot.api")
					if not cp_api_ok then
						require("sttusline.utils.notify").error("Cannot load copilot.api")
						return
					end

					cp_api.check_status(copilot_client, {}, function(cserr, status)
						if cserr then
							copilot_status = "error"
							require("sttusline.utils.notify").warn(cserr)
							return
						elseif not status.user then
							copilot_status = "error"
							require("sttusline.utils.notify").warn("Copilot: No user found")
							return
						elseif status.status == "NoTelemetryConsent" then
							copilot_status = "error"
							require("sttusline.utils.notify").warn("Copilot: No telemetry consent")
							return
						elseif status.status == "NotAuthorized" then
							copilot_status = "error"
							require("sttusline.utils.notify").warn("Copilot: Not authorized")
							return
						end

						local attached = cp_client.buf_is_attached(0)
						if not attached then
							copilot_status = "error"
							require("sttusline.utils.notify").warn("Copilot: Not attached")
						else
							copilot_status = "normal"
						end
					end)
				end

				S.register_status_notification_handler = function()
					if not copilot_handler_registered then
						local cp_api_ok, cp_api = pcall(require, "copilot.api")
						if cp_api_ok then
							cp_api.register_status_notification_handler(handle_status_data)
							copilot_handler_registered = true
						end
					end
				end
				S.get_status = function() return configs.icons[copilot_status] or "" end
				return S
			end,

			configs = {
				icons = {
					normal = "",
					error = "",
					warning = "",
					inprogress = "",
				},
			},

			update = function(_, _, space)
				if package.loaded["copilot"] then
					space.register_status_notification_handler()
					space.check_status()
				end
				return space.get_status()
			end,
		},
		{
			name = "indent",
			event = { "BufEnter" }, -- The component will be update when the event is triggered
			user_event = { "VeryLazy" },
			colors = { fg = colors.cyan, bg = colors.bg }, -- { fg = colors.black, bg = colors.white }
			update = function() return "Tab: " .. vim.api.nvim_buf_get_option(0, "shiftwidth") .. "" end,
		},
		{
			name = "encoding",
			user_event = { "VeryLazy" },
			configs = {
				["utf-8"] = "󰉿",
				["utf-16"] = "",
				["utf-32"] = "",
				["utf-8mb4"] = "",
				["utf-16le"] = "",
				["utf-16be"] = "",
			},
			colors = { fg = colors.yellow, bg = colors.bg }, -- { fg = colors.black, bg = colors.white }
			update = function(configs)
				local enc = vim.bo.fenc ~= "" and vim.bo.fenc or vim.o.enc
				return configs[enc] or enc
			end,
		},
		{
			name = "pos-cursor",
			event = { "CursorMoved", "CursorMovedI" }, -- The component will be update when the event is triggered
			user_event = { "VeryLazy" },
			colors = { fg = colors.fg }, -- { fg = colors.black, bg = colors.white }
			update = function()
				local pos = vim.api.nvim_win_get_cursor(0)
				return pos[1] .. ":" .. pos[2]
			end,
		},
		{
			name = "pos-cursor-progress",

			event = { "CursorMoved", "CursorMovedI" }, -- The component will be update when the event is triggered
			user_event = { "VeryLazy" },

			timing = false, -- The component will be update every time interval

			lazy = true,

			configs = {
				chars = { "_", "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" },
			},

			-- number or table
			padding = 0, -- { left = 1, right = 1 }
			colors = { fg = colors.orange, bg = colors.bg }, -- { fg = colors.black, bg = colors.white }

			update = function(configs)
				return configs.chars[math.ceil(vim.fn.line(".") / vim.fn.line("$") * #configs.chars)] or ""
			end,
		},
	},
}

M.setup = function(user_opts)
	user_opts = M.apply_user_config(user_opts)
	return user_opts
end

M.apply_user_config = function(opts)
	if type(opts) == "table" then
		for k, v in pairs(opts) do
			if type(v) == type(configs[k]) then
				if type(v) == "table" then
					if v[1] == nil then
						for k2, v2 in pairs(v) do
							if type(v2) == type(configs[k][k2]) then configs[k][k2] = v2 end
						end
					else
						configs[k] = v
					end
				else
					configs[k] = v
				end
			end
		end
	end
	return configs
end

return M
