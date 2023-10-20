local HIGHLIGHT_PREFIX = "STTUSLINE_DIAGNOSTICS_"

local colors = require("sttusline.utils.color")
local utils = require("sttusline.utils")
local diag = vim.diagnostic

local Diagnostics = require("sttusline.component").new()

Diagnostics.set_config {
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
}

Diagnostics.set_event("DiagnosticChanged")
Diagnostics.set_user_event {}

Diagnostics.set_update(function()
	local result = {}

	local config = Diagnostics.get_config()
	local icons = config.icons
	local diagnostics_color = config.diagnostics_color
	local order = config.order

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
end)

Diagnostics.set_onhighlight(function()
	local diagnostics_color = Diagnostics.get_config().diagnostics_color
	for key, color in pairs(diagnostics_color) do
		if utils.is_color(color) then
			vim.api.nvim_set_hl(0, HIGHLIGHT_PREFIX .. key, { fg = color, bg = colors.bg })
		elseif type(color) == "table" then
			vim.api.nvim_set_hl(0, HIGHLIGHT_PREFIX .. key, color)
		end
	end
end)

return Diagnostics
