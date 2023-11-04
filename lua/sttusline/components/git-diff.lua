local colors = require("sttusline.utils.color")

local GitDiff = require("sttusline.component").new()

GitDiff.set_event { "BufWritePost", "VimResized", "BufEnter" }
GitDiff.set_user_event { "GitSignsUpdate" }
GitDiff.set_colors {
	{ fg = colors.tokyo_diagnostics_hint },
	{ fg = colors.tokyo_diagnostics_info },
	{ fg = colors.tokyo_diagnostics_error },
}

GitDiff.set_config {
	icons = {
		added = "",
		changed = "",
		removed = "",
	},
	order = { "added", "changed", "removed" },
}

GitDiff.set_update(function()
	local git_status = vim.b.gitsigns_status_dict

	local config = GitDiff.get_config()
	local order = config.order
	local icons = config.icons

	local should_add_spacing = false
	local result = {}
	for _, v in ipairs(order) do
		if git_status[v] and git_status[v] > 0 then
			if should_add_spacing then
				table.insert(result, " " .. icons[v] .. " " .. git_status[v])
			else
				should_add_spacing = true
				table.insert(result, icons[v] .. " " .. git_status[v])
			end
		else
			table.insert(result, "")
		end
	end
	return result
end)

GitDiff.set_condition(function() return vim.b.gitsigns_status_dict ~= nil and vim.o.columns > 70 end)

return GitDiff
