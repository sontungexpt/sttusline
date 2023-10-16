local colors = require("sttusline.utils.color")
local utils = require("sttusline.utils")

local ADD_HIGHLIGHT_PREFIX = "STTUSLINE_GIT_DIFF_"

local GitDiff = require("sttusline.component").new()

GitDiff.set_event { "BufWritePost", "VimResized" }
GitDiff.set_config {
	icons = {
		added = "",
		changed = "",
		removed = "",
	},
	colors = {
		added = "DiagnosticHint",
		changed = "DiagnosticInfo",
		removed = "DiagnosticError",
	},
	order = { "added", "changed", "removed" },
}

GitDiff.set_update(function()
	if not vim.b.gitsigns_head or vim.b.gitsigns_git_status or vim.o.columns < 120 then return "" end
	local git_status = vim.b.gitsigns_status_dict

	local config = GitDiff.get_config()
	local order = config.order
	local icons = config.icons
	local diff_colors = config.colors

	local result = {}
	for _, v in ipairs(order) do
		if git_status[v] and git_status[v] > 0 then
			local color = diff_colors[v]
			if color then
				local highlight_color = utils.is_color(color) and ADD_HIGHLIGHT_PREFIX .. v or color
				table.insert(result, utils.add_highlight_name(icons[v] .. " " .. git_status[v], highlight_color))
			end
		end
	end

	return #result > 0 and table.concat(result, " ") or ""
end)

GitDiff.set_onhighlight(function()
	local conf_colors = GitDiff.get_config().colors
	for key, color in pairs(conf_colors) do
		if utils.is_color(color) then vim.api.nvim_set_hl(0, ADD_HIGHLIGHT_PREFIX .. key, { fg = color }) end
	end
end)

return GitDiff
