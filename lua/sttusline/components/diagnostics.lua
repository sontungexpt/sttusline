local HIGHLIGHT_PREFIX = "STTUSLINE_DIAGNOSTICS_"
local colors = require("sttusline.utils.color")
local utils = require("sttusline.utils")
local diag = vim.diagnostic
return {
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
		local result = {}

		local icons = configs.icons
		local diagnostics_color = configs.diagnostics_color
		local order = configs.order

		for _, key in ipairs(order) do
			local count = #diag.get(0, { severity = diag.severity[key] })

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
}
