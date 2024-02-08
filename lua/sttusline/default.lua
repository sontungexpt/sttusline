local vim = vim
local g = vim.g
local api = vim.api

local colors = {
	yellow = "#ffc021",
	cyan = "#56b6c2",
	green = "#47d864",
	orange = "#FF8800",
	magenta = "#c678dd",
	blue = "#51afef",
	red = "#ee2c4a",
	gray = "#5c6370",
	purple = "#c688eb",
	pink = "#eb7fdc",
}

return {
	{
		name = "mode",
		event = { "ModeChanged", "VimResized" },
		user_event = "VeryLazy",
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
				["STTUSLINE_NORMAL_MODE"] = { fg = colors.blue },
				["STTUSLINE_INSERT_MODE"] = { fg = colors.green },
				["STTUSLINE_VISUAL_MODE"] = { fg = colors.purple },
				["STTUSLINE_NTERMINAL_MODE"] = { fg = colors.gray },
				["STTUSLINE_TERMINAL_MODE"] = { fg = colors.cyan },
				["STTUSLINE_REPLACE_MODE"] = { fg = colors.red },
				["STTUSLINE_SELECT_MODE"] = { fg = colors.magenta },
				["STTUSLINE_COMMAND_MODE"] = { fg = colors.yellow },
				["STTUSLINE_CONFIRM_MODE"] = { fg = colors.yellow },
			},
			auto_hide_on_vim_resized = true,
		},
		update = function(configs)
			local mode_code = api.nvim_get_mode().mode
			local mode = configs.modes[mode_code]

			return mode
					and {
						{
							value = mode[1],
							colors = configs.mode_colors[mode[2]],
							hl_update = true,
						},
					}
				or mode_code
		end,
		condition = function(configs)
			if configs.auto_hide_on_vim_resized then
				vim.opt.showmode = not (vim.o.columns > 70)
				return not vim.opt.showmode:get()
			end
		end,
	},
	{
		name = "filename",
		event = { "BufEnter", "WinEnter", "TextChangedI", "BufWritePost" },
		user_event = "VeryLazy",
		colors = {
			fg = colors.orange,
		},
		configs = {
			extensions = {
				-- filetypes = { icon, color, filename(optional) },
				filetypes = {
					["NvimTree"] = { "󰙅", colors.red, "NvimTree" },
					["TelescopePrompt"] = { "", colors.red, "Telescope" },
					["mason"] = { "󰏔", colors.red, "Mason" },
					["lazy"] = { "󰏔", colors.red, "Lazy" },
					["checkhealth"] = { "", colors.red, "CheckHealth" },
					["plantuml"] = { "", colors.green },
					["dashboard"] = { "", colors.red },
				},

				-- buftypes = { icon, color, filename(optional) },
				buftypes = {
					["terminal"] = { "", colors.red, "Terminal" },
				},
			},
		},
		update = function(configs)
			local filename = vim.fn.expand("%:t")

			local has_devicons, devicons = pcall(require, "nvim-web-devicons")
			local icon, color_icon = nil, nil
			if has_devicons then
				icon, color_icon = devicons.get_icon_color(filename, vim.fn.expand("%:e"))
			end

			if not icon then
				local extensions = configs.extensions
				local buftype = api.nvim_buf_get_option(0, "buftype")

				local extension = extensions.buftypes[buftype]
				if extension then
					icon, color_icon, filename =
						extension[1], extension[2], extension[3] or filename ~= "" and filename or buftype
				else
					local filetype = api.nvim_buf_get_option(0, "filetype")
					extension = extensions.filetypes[filetype]
					if extension then
						icon, color_icon, filename =
							extension[1], extension[2], extension[3] or filename ~= "" and filename or filetype
					end
				end
			end

			if filename == "" then filename = "No File" end

			-- check if file is read-only
			if not api.nvim_buf_get_option(0, "modifiable") or api.nvim_buf_get_option(0, "readonly") then
				return {
					{
						value = icon,
						colors = { fg = color_icon },
						hl_update = true,
					},
					" " .. filename,
					{
						value = " ",
						colors = { fg = colors.red },
						hl_update = true,
					},
				}
				-- check if unsaved
			elseif api.nvim_buf_get_option(0, "modified") then
				return {
					{

						value = icon,
						colors = { fg = color_icon },
						hl_update = true,
					},
					" " .. filename,
					{
						value = " ",
						colors = { fg = "Statusline" },
						hl_update = true,
					},
				}
			end
			return {
				{

					value = icon,
					colors = { fg = color_icon },
					hl_update = true,
				},
				" " .. filename,
			}
		end,
	},
	{
		name = "git-branch",
		event = "BufEnter",
		user_event = { "VeryLazy", "GitSignsUpdate" },
		configs = {
			icon = "",
		},
		colors = { fg = colors.pink },
		update = function(configs, state)
			local branch = ""
			local git_dir = vim.fn.finddir(".git", ".;")
			if git_dir ~= "" then
				local head_file = io.open(git_dir .. "/HEAD", "r")
				if head_file then
					local content = head_file:read("*all")
					head_file:close()
					-- branch name  or commit hash
					branch = content:match("ref: refs/heads/(.-)%s*$") or content:sub(1, 7) or ""
				end
			end
			return branch ~= "" and configs.icon .. " " .. branch or ""
		end,
		condition = function() return api.nvim_buf_get_option(0, "buflisted") end,
	},
	{
		name = "git-diff",
		event = { "BufWritePost", "VimResized", "BufEnter" },
		user_event = "GitSignsUpdate",
		configs = {
			added = {
				value = "",
				colors = { fg = "DiffAdd" },
			},
			changed = {
				value = "",
				colors = { fg = "DiffChange" },
			},
			removed = {
				value = "",
				colors = { fg = "DiffDelete" },
			},
			order = { "added", "changed", "removed" },
		},
		update = function(configs)
			local git_status = vim.b.gitsigns_status_dict

			local result = {}
			local should_add_padding = false
			for _, key in ipairs(configs.order) do
				if git_status[key] and git_status[key] > 0 then
					result[#result + 1] = {
						value = configs[key].value .. " " .. git_status[key],
						colors = configs[key].colors,
						hl_update = true,
						padding = should_add_padding and { left = 1 } or nil,
					}
					should_add_padding = true
				end
			end

			return result
		end,
		condition = function() return vim.b.gitsigns_status_dict ~= nil and vim.o.columns > 70 end,
	},
	"%=",
	{
		name = "diagnostics",
		event = "DiagnosticChanged",
		configs = {
			ERROR = {
				value = "",
				colors = { fg = "DiagnosticError" },
			},
			WARN = {
				value = "",
				colors = { fg = "DiagnosticWarn" },
			},
			INFO = {
				value = "",
				colors = { fg = "DiagnosticInfo" },
			},
			HINT = {
				value = "󰌵",
				colors = { fg = "DiagnosticHint" },
			},
			order = { "ERROR", "WARN", "INFO", "HINT" },
		},
		update = function(configs)
			local result = {}

			local should_add_spacing = false
			for _, key in ipairs(configs.order) do
				local count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity[key] })

				if count > 0 then
					result[#result + 1] = {
						value = configs[key].value .. " " .. count,
						colors = configs[key].colors,
						hl_update = true,
						padding = should_add_spacing and { left = 1 } or nil,
					}
					should_add_spacing = true
				end
			end

			return result
		end,
		condition = function()
			return api.nvim_buf_get_option(0, "filetype") ~= "lazy"
				and not api.nvim_buf_get_name(0):match("%.env$")
		end,
	},
	{
		name = "lsps-formatters",
		event = { "LspAttach", "LspDetach", "BufWritePost", "BufEnter", "VimResized" },
		colors = { fg = colors.magenta },
		update = function()
			local buf_clients = vim.lsp.buf_get_clients()
			local server_names = {}
			local has_null_ls = false
			local ignore_lsp_servers = {
				["null-ls"] = true,
				["copilot"] = true,
			}

			for _, client in pairs(buf_clients) do
				local client_name = client.name
				if not ignore_lsp_servers[client_name] then server_names[#server_names + 1] = client_name end
			end

			if package.loaded["null-ls"] then
				local null_ls = nil
				has_null_ls, null_ls = pcall(require, "null-ls")

				if has_null_ls then
					local buf_ft = api.nvim_buf_get_option(0, "filetype")
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
										source_results[#source_results + 1] = source.name
									else
										source_results[#source_results + 1] = source
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
					if has_null_ls then server_names = vim.fn.uniq(server_names) end
				end
			end

			return #server_names > 0 and table.concat(server_names, ", ") or "NO LSP, FORMATTER  "
		end,

		condition = function() return vim.o.columns > 70 end,
	},
	{
		name = "indent",
		event = { "BufEnter", "WinEnter" },
		user_event = "VeryLazy",
		colors = { fg = colors.cyan },
		update = function() return "Tab: " .. api.nvim_buf_get_option(0, "shiftwidth") .. "" end,
	},
	{
		name = "encoding",
		event = { "BufEnter", "WinEnter" },
		user_event = "VeryLazy",
		configs = {
			["utf-8"] = "󰉿",
			["utf-16"] = "󰊀",
			["utf-32"] = "󰊁",
			["utf-8mb4"] = "󰊂",
			["utf-16le"] = "󰊃",
			["utf-16be"] = "󰊄",
		},
		colors = { fg = colors.yellow },
		update = function(configs)
			local enc = vim.bo.fenc ~= "" and vim.bo.fenc or vim.o.enc
			return configs[enc] or enc
		end,
	},
	{
		name = "pos-cursor",
		event = { "CursorMoved", "CursorMovedI" },
		user_event = "VeryLazy",
		colors = { fg = colors.fg },
		update = function()
			local pos = api.nvim_win_get_cursor(0)
			return pos[1] .. ":" .. pos[2]
		end,
	},
	{
		name = "pos-cursor-progress",
		event = { "CursorMoved", "CursorMovedI" },
		user_event = "VeryLazy",
		configs = {
			chars = { "_", "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" },
		},
		padding = 0,
		colors = { fg = colors.orange },
		update = function(configs)
			local line = vim.fn.line
			return configs.chars[math.ceil(line(".") / line("$") * #configs.chars)] or ""
		end,
	},
}
