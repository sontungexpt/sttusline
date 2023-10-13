local HIGHLIGHT_PREFIX = "STTUSLINE_DIAGNOSTICS_"
local utils = require("sttusline.utils")
local colors = require("sttusline.color")
local diag = vim.diagnostic

local Diagnostics = require("sttusline.component"):new()

Diagnostics.config = {
	icons = {
		ERROR = " ",
		WARN = " ",
		HINT = "󰌵 ",
		INFO = " ",
	},
	diagnostics_color = {
		ERROR = "DiagnosticSignError",
		WARN = "DiagnosticSignWarn",
		HINT = "DiagnosticSignHint",
		INFO = "DiagnosticSignInfo",
	},
}

Diagnostics.colors = {
	bg = colors.lualine_bg,
}

Diagnostics.user_event = "LspRequest"

Diagnostics.update = function()
	local result = {}
	local icons = Diagnostics.config.icons
	local diagnostics_color = Diagnostics.config.diagnostics_color

	local order = { "ERROR", "WARN", "INFO", "HINT" }
	for _, key in ipairs(order) do
		local count = #diag.get(0, { severity = diag.severity[key] })

		if count > 0 then
			local color = diagnostics_color[key]
			if color then
				local highlight_color = utils.is_color(color) and HIGHLIGHT_PREFIX .. key or color
				table.insert(result, utils.add_highlight_name(icons[key] .. count, highlight_color))
			end
		end
	end

	return table.concat(result, " ")
end

Diagnostics.on_load = function()
	local diagnostics_color = Diagnostics.config.diagnostics_color
	for key, color in pairs(diagnostics_color) do
		if utils.is_color(color) then vim.api.nvim_set_hl(0, HIGHLIGHT_PREFIX .. key, { fg = color }) end
	end
end

return Diagnostics
