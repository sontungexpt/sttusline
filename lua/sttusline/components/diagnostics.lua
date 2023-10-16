local HIGHLIGHT_PREFIX = "STTUSLINE_DIAGNOSTICS_"

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
		ERROR = "DiagnosticError",
		WARN = "DiagnosticWarn",
		HINT = "DiagnosticHint",
		INFO = "DiagnosticInfo",
	},
	order = { "ERROR", "WARN", "INFO", "HINT" },
}

Diagnostics.set_user_event("LspRequest")

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
				local highlight_color = utils.is_color(color) and HIGHLIGHT_PREFIX .. key or color
				table.insert(result, utils.add_highlight_name(icons[key] .. " " .. count, highlight_color))
			end
		end
	end

	return #result > 0 and table.concat(result, " ") or ""
end)

Diagnostics.set_onhighlight(function()
	local diagnostics_color = Diagnostics.get_config().diagnostics_color
	for key, color in pairs(diagnostics_color) do
		if utils.is_color(color) then vim.api.nvim_set_hl(0, HIGHLIGHT_PREFIX .. key, { fg = color }) end
	end
end)

return Diagnostics
