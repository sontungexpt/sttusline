local vim = vim
local api = vim.api
local uv = vim.uv or vim.loop
local fn = vim.fn

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
	user_event = "VeryLazy",
	event = "VimResized",
	{
		name = "mode",
		event = { "ModeChanged" },
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
		styles = function(configs)
			local mode_code = api.nvim_get_mode().mode
			return configs.mode_colors[configs.modes[mode_code][2]]
		end,
		update = function(configs)
			local mode_code = api.nvim_get_mode().mode
			local mode = configs.modes[mode_code]

			return mode and mode[1] or mode_code
		end,
		condition = function(configs)
			if configs.auto_hide_on_vim_resized then
				vim.opt.showmode = not (vim.o.columns > 70)
				---@diagnostic disable-next-line: undefined-field
				return not vim.opt.showmode:get()
			end
		end,
	},
	{
		event = "BufEnter",
		{
			name = "filename",
			event = { "WinEnter", "TextChangedI", "BufWritePost" },
			styles = {
				fg = colors.orange,
			},
			configs = {
				extensions = {
					-- filetypes = { icon, color, filename(optional) },
					filetypes = {
						["NvimTree"] = { "", colors.red, "NvimTree" },
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
			static = {
				get = function(configs)
					local filename = fn.expand("%:t")

					local has_devicons, devicons = pcall(require, "nvim-web-devicons")
					local icon, color_icon = nil, nil
					if has_devicons then
						icon, color_icon = devicons.get_icon_color(filename, fn.expand("%:e"))
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
					return icon, color_icon, filename
				end,
			},
			{
				padding = { left = 1, right = 0 },
				styles = function(configs, context, shared, self)
					local icon, color_icon, filename = self.static.get(configs)
					return { fg = color_icon }
				end,
				update = function(configs, context, shared, self)
					local icon, color_icon, filename = self.static.get(configs)
					return icon
				end,
			},
			{
				update = function(configs, context, shared, self)
					local icon, color_icon, filename = self.static.get(configs)
					return filename
				end,
			},
			{
				styles = function()
					if not api.nvim_buf_get_option(0, "modifiable") or api.nvim_buf_get_option(0, "readonly") then
						return { fg = colors.red }
					elseif api.nvim_buf_get_option(0, "modified") then
						return { fg = "Statusline" }
					end
				end,
				padding = { left = 0, right = 1 },
				update = function()
					if not api.nvim_buf_get_option(0, "modifiable") or api.nvim_buf_get_option(0, "readonly") then
						return ""
					elseif api.nvim_buf_get_option(0, "modified") then
						return ""
					end
					return ""
				end,
			},
		},
		{
			name = "git-branch",
			user_event = "GitSignsUpdate",
			configs = {
				icon = "",
			},
			styles = { fg = colors.pink },
			update = function(configs, context)
				local branch = ""
				local git_dir = fn.finddir(".git", ".;")
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
			event = "BufWritePost",
			user_event = "GitSignsUpdate",
			configs = {
				added = "",
				changed = "",
				removed = "",
			},
			{
				styles = { fg = "DiffAdd" },
				update = function(configs)
					local git_status = vim.b.gitsigns_status_dict
					return git_status.added and git_status.added > 0 and configs.added .. " " .. git_status.added
						or ""
				end,
			},
			{
				styles = { fg = "DiffChange" },
				update = function(configs)
					local git_status = vim.b.gitsigns_status_dict
					return git_status.changed
							and git_status.changed > 0
							and configs.changed .. " " .. git_status.changed
						or ""
				end,
			},
			{
				styles = { fg = "DiffDelete" },
				update = function(configs)
					local git_status = vim.b.gitsigns_status_dict
					return git_status.removed
							and git_status.removed > 0
							and configs.removed .. " " .. git_status.removed
						or ""
				end,
			},
			condition = function() return vim.b.gitsigns_status_dict ~= nil and vim.o.columns > 70 end,
		},
	},

	"%=",
	{
		name = "diagnostics",
		event = "DiagnosticChanged",
		configs = {
			ERROR = "",
			WARN = "",
			INFO = "",
			HINT = "",
		},
		condition = function()
			return api.nvim_buf_get_option(0, "filetype") ~= "lazy"
				and not api.nvim_buf_get_name(0):match("%.env$")
		end,

		{
			styles = {
				fg = "DiagnosticError",
			},
			update = function(configs)
				local count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
				return count > 0 and configs.ERROR .. " " .. count or ""
			end,
		},
		{
			styles = {
				fg = "DiagnosticWarn",
			},
			update = function(configs)
				local count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
				return count > 0 and configs.WARN .. " " .. count or ""
			end,
		},
		{
			styles = {
				fg = "DiagnosticInfo",
			},
			update = function(configs)
				local count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
				return count > 0 and configs.INFO .. " " .. count or ""
			end,
		},
		{
			styles = {
				fg = "DiagnosticHint",
			},
			update = function(configs)
				local count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
				return count > 0 and configs.HINT .. " " .. count or ""
			end,
		},
	},

	{
		name = "lsps-formatters",
		event = { "LspAttach", "LspDetach", "BufWritePost", "BufEnter" },
		styles = { fg = colors.magenta },
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
					if has_null_ls then server_names = fn.uniq(server_names) end
				end
			end

			return #server_names > 0 and table.concat(server_names, ", ") or "NO LSP, FORMATTER  "
		end,

		condition = function() return vim.o.columns > 70 end,
	},
	{
		name = "copilot-loading",
		user_event = "SttuslineCopilotLoad",
		configs = {
			icons = {
				normal = "",
				error = "",
				warning = "",
				inprogress = { "", "󰪞", "󰪟", "󰪠", "󰪢", "󰪣", "󰪤", "󰪥" },
			},
			fps = 3, -- should be 3 - 5
		},
		init = function(configs)
			local nvim_exec_autocmds = api.nvim_exec_autocmds
			local schedule = vim.schedule
			local buf_get_option = api.nvim_buf_get_option
			local timer = uv.new_timer()
			local curr_inprogress_index = 0
			local icons = configs.icons
			local status = ""

			api.nvim_create_autocmd("InsertEnter", {
				once = true,
				desc = "Init copilot status",
				callback = function()
					local cp_api_ok, cp_api = pcall(require, "copilot.api")
					if cp_api_ok then
						cp_api.register_status_notification_handler(function(data)
							schedule(function()
								-- don't need to get status when in TelescopePrompt
								if buf_get_option(0, "buftype") == "prompt" then return end
								status = string.lower(data.status or "")

								if status == "inprogress" then
									timer:start(
										0,
										math.floor(1000 / configs.fps),
										vim.schedule_wrap(
											function()
												nvim_exec_autocmds(
													"User",
													{ pattern = "SttuslineCopilotLoad", modeline = false }
												)
											end
										)
									)
									return
								end
								timer:stop()
								nvim_exec_autocmds("User", { pattern = "SttuslineCopilotLoad", modeline = false })
							end)
						end)
					end
				end,
			})

			return {
				get_icon = function()
					if status == "inprogress" then
						curr_inprogress_index = curr_inprogress_index < #icons.inprogress
								and curr_inprogress_index + 1
							or 1
						return icons.inprogress[curr_inprogress_index]
					else
						curr_inprogress_index = 0
						return icons[status] or status or ""
					end
				end,
				check_status = function()
					local cp_client_ok, cp_client = pcall(require, "copilot.client")
					if not cp_client_ok then
						status = "error"
						require("sttusline.util.notify").error("Cannot load copilot.client")
						return
					end

					local copilot_client = cp_client.get()
					if not copilot_client then
						status = "error"
						return
					end

					local cp_api_ok, cp_api = pcall(require, "copilot.api")
					if not cp_api_ok then
						status = "error"
						require("sttusline.util.notify").error("Cannot load copilot.api")
						return
					end

					cp_api.check_status(copilot_client, {}, function(cserr, status_copilot)
						if cserr or not status_copilot.user or status_copilot.status ~= "OK" then
							status = "error"
							return
						end
					end)
				end,
			}
		end,
		update = function(_, init_state)
			if package.loaded["copilot"] then init_state.check_status() end
			return init_state.get_icon()
		end,
	},
	{
		event = { "BufEnter", "WinEnter" },
		{
			name = "indent",
			styles = { fg = colors.cyan },
			update = function() return "Tab: " .. api.nvim_buf_get_option(0, "shiftwidth") .. "" end,
		},
		{
			name = "encoding",
			configs = {
				["utf-8"] = "󰉿",
				["utf-16"] = "󰊀",
				["utf-32"] = "󰊁",
				["utf-8mb4"] = "󰊂",
				["utf-16le"] = "󰊃",
				["utf-16be"] = "󰊄",
			},
			styles = { fg = colors.yellow },
			update = function(configs)
				local enc = vim.bo.fenc ~= "" and vim.bo.fenc or vim.o.enc
				return configs[enc] or enc
			end,
		},
	},
	{
		event = { "CursorMoved", "CursorMovedI" },
		{
			name = "pos-cursor",
			styles = { fg = colors.fg },
			update = function()
				local pos = api.nvim_win_get_cursor(0)
				return pos[1] .. ":" .. pos[2]
			end,
		},
		{
			name = "pos-cursor-progress",
			configs = {
				chars = { "_", "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" },
			},
			padding = 0,
			styles = { fg = colors.orange },
			update = function(configs)
				local line = fn.line
				return configs.chars[math.ceil(line(".") / line("$") * #configs.chars)] or ""
			end,
		},
	},
}
