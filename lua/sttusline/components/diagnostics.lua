local HIGHLIGHT_PREFIX = require("sttusline.constant").DIAGNOSTICS_HIGHLIGHT_PREFIX
local utils = require("sttusline.utils")
local colors = require("sttusline.color")
local diag = vim.diagnostic

local diagnostics = require("sttusline.component"):new()

diagnostics.config = {
	icons = {
		error = " ",
		warn = " ",
		hint = "󰌵 ",
		info = " ",
	},
	diagnostics_color = {
		error = colors.red,
		warn = colors.yellow,
		info = colors.blue,
		hint = colors.cyan,
	},
}

diagnostics.event = {
	"CursorHold",
	"CursorHoldI",
	"BufWritePost",
}

diagnostics.update = function()
	local result = {}
	local icons = diagnostics.config.icons
	local diagnostics_color = diagnostics.config.diagnostics_color

	local order = { "error", "warn", "info", "hint" }
	for _, key in ipairs(order) do
		local ukey = string.upper(key)
		local count = #diag.get(0, { severity = diag.severity[ukey] })

		if count > 0 then
			local color = diagnostics_color[key]
			if color then
				local highlight_color = utils.is_color(color) and HIGHLIGHT_PREFIX .. ukey or color
				table.insert(result, utils.add_highlight_name(icons[key] .. count, highlight_color))
			end
		end
	end

	return table.concat(result, " ")
end

diagnostics.on_load = function()
	local diagnostics_color = diagnostics.config.diagnostics_color
	for key, color in pairs(diagnostics_color) do
		local ukey = string.upper(key)
		if utils.is_color(color) then vim.api.nvim_set_hl(0, HIGHLIGHT_PREFIX .. ukey, { fg = color }) end
	end
end

return diagnostics
