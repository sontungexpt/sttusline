local colors = require("sttusline.utils.color")

return {
	name = "git-diff",
	event = { "BufWritePost", "VimResized", "BufEnter" }, -- The component will be update when the event is triggered
	user_event = { "GitSignsUpdate" },
	colors = {
		{ fg = colors.tokyo_diagnostics_hint, bg = colors.bg },
		{ fg = colors.tokyo_diagnostics_info, bg = colors.bg },
		{ fg = colors.tokyo_diagnostics_error, bg = colors.bg },
	},
	configs = {
		icons = {
			added = "",
			changed = "",
			removed = "",
		},
		order = { "added", "changed", "removed" },
	},
	update = function(configs)
		local git_status = vim.b.gitsigns_status_dict

		local order = configs.order
		local icons = configs.icons

		local result = {}
		for k, v in ipairs(order) do
			if git_status[v] and git_status[v] > 0 then
				if result[k - 1] and result[k - 1] ~= "" then
					table.insert(result, " " .. icons[v] .. " " .. git_status[v])
				else
					table.insert(result, icons[v] .. " " .. git_status[v])
				end
			else
				table.insert(result, "")
			end
		end
		return result
	end,
	condition = function() return vim.b.gitsigns_status_dict ~= nil and vim.o.columns > 70 end,
}
