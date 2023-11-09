local colors = require("sttusline.utils.color")

return {
	name = "git-diff",
	event = { "BufWritePost", "VimResized", "BufEnter" }, -- The component will be update when the event is triggered
	user_event = { "GitSignsUpdate" },
	colors = {
		{ fg = colors.tokyo_diagnostics_hint },
		{ fg = colors.tokyo_diagnostics_info },
		{ fg = colors.tokyo_diagnostics_error },
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

		local should_add_spacing = false
		local result = {}
		for index, v in ipairs(order) do
			if git_status[v] and git_status[v] > 0 then
				if should_add_spacing then
					result[index] = " " .. icons[v] .. " " .. git_status[v]
				else
					should_add_spacing = true
					result[index] = icons[v] .. " " .. git_status[v]
				end
			else
				result[index] = ""
			end
		end
		return result
	end,
	condition = function() return vim.b.gitsigns_status_dict ~= nil and vim.o.columns > 70 end,
}
