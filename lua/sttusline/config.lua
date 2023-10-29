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
		"mode",
		"filename",
		"git-branch",
		"git-diff",
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

			update = function(configs)
				local HIGHLIGHT_PREFIX = "STTUSLINE_DIAGNOSTICS_"
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
									utils.add_highlight_name(icons[key] .. " " .. count, HIGHLIGHT_PREFIX .. key)
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

			on_highlight = function(configs)
				local diagnostics_color = configs.diagnostics_color
				for key, color in pairs(diagnostics_color) do
					if utils.is_color(color) then
						vim.api.nvim_set_hl(0, HIGHLIGHT_PREFIX .. key, { fg = color, bg = colors.bg })
					elseif type(color) == "table" then
						vim.api.nvim_set_hl(0, HIGHLIGHT_PREFIX .. key, color)
					end
				end
			end,
		},
		"lsps-formatters",
		{
			name = "copilot",
			event = { "InsertEnter", "InsertLeave", "CursorHoldI" }, -- The component will be update when the event is triggered

			space = function(configs)
				local copilot_status = ""
				local copilot_client = nil
				local copilot_handler_registered = false
				local M = {}

				local handle_status_data = function(data) copilot_status = string.lower(data.status) end

				M.check_status = function()
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

				M.register_status_notification_handler = function()
					if not copilot_handler_registered then
						local cp_api_ok, cp_api = pcall(require, "copilot.api")
						if cp_api_ok then
							cp_api.register_status_notification_handler(handle_status_data)
							copilot_handler_registered = true
						end
					end
				end
				M.get_status = function() return configs.icons[copilot_status] or "" end
				return M
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
		"indent",
		"encoding",
		"pos-cursor",
		"pos-cursor-progress",
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
