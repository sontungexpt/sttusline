return {
	name = "git-diff",
	event = { "BufWritePost", "VimResized", "BufEnter" },
	user_event = "GitSignsUpdate",
	configs = {
		added = {
			value = "",
			colors = { fg = "DiffAdd" },
		},
		changed = {
			value = "",
			colors = { fg = "DiffChange" },
		},
		removed = {
			value = "",
			colors = { fg = "DiffDelete" },
		},
		order = { "added", "changed", "removed" },
	},
	update = function(configs)
		local git_status = vim.b.gitsigns_status_dict

		local result = {}
		local should_add_padding = false
		for _, key in ipairs(configs.order) do
			if git_status[key] and git_status[key] > 0 then
				result[#result + 1] = {
					value = configs[key].value .. " " .. git_status[key],
					colors = configs[key].colors,
					hl_update = true,
					padding = should_add_padding and { left = 1 } or nil,
				}
				should_add_padding = true
			end
		end

		return result
	end,
	condition = function() return vim.b.gitsigns_status_dict ~= nil and vim.o.columns > 70 end,
}
