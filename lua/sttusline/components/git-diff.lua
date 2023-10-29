local colors = require("sttusline.utils.color")
local utils = require("sttusline.utils")

local ADD_HIGHLIGHT_PREFIX = "STTUSLINE_GIT_DIFF_"

return {
	name = "git-diff",
	event = { "BufWritePost", "VimResized", "BufEnter" }, -- The component will be update when the event is triggered
	user_event = { "GitSignsUpdate" },
	configs = {
		icons = {
			added = "",
			changed = "",
			removed = "",
		},
		colors = {
			added = { fg = colors.tokyo_diagnostics_hint, bg = colors.bg },
			changed = { fg = colors.tokyo_diagnostics_hint, bg = colors.bg },
			removed = { fg = colors.tokyo_diagnostics_error, bg = colors.bg },
		},
		order = { "added", "changed", "removed" },
	},
	update = function(configs)
		local git_status = vim.b.gitsigns_status_dict

		local order = configs.order
		local icons = configs.icons
		local diff_colors = configs.colors

		local result = {}
		for _, v in ipairs(order) do
			if git_status[v] and git_status[v] > 0 then
				local color = diff_colors[v]

				if color then
					if utils.is_color(color) or type(color) == "table" then
						table.insert(
							result,
							utils.add_highlight_name(icons[v] .. " " .. git_status[v], ADD_HIGHLIGHT_PREFIX .. v)
						)
					else
						table.insert(result, utils.add_highlight_name(icons[v] .. " " .. git_status[v], color))
					end
				end
			end
		end

		return #result > 0 and table.concat(result, " ") or ""
	end,
	condition = function() return vim.b.gitsigns_status_dict ~= nil and vim.o.columns > 70 end,
	on_highlight = function(configs)
		local conf_colors = configs.colors
		for key, color in pairs(conf_colors) do
			if utils.is_color(color) then
				vim.api.nvim_set_hl(0, ADD_HIGHLIGHT_PREFIX .. key, { fg = color, bg = colors.bg })
			elseif type(color) == "table" then
				vim.api.nvim_set_hl(0, ADD_HIGHLIGHT_PREFIX .. key, color)
			end
		end
	end,
}
