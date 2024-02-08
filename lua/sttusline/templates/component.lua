local colors = require("sttusline.v1.utils.color")
return {
	name = "form", -- nick to link the componet with the group

	event = {
		BufEnter = { "*.lua", "*.js" },
	},

	user_event = {},

	configs = {},

	colors = {}, -- { fg = colors.black, bg = colors.white }

	-- separator = { left = "", right = "" },
	separator = {
		left = "",
		right = "",
		colors_left = { fg = colors.black, bg = colors.white },
		colors_right = { fg = colors.black, bg = colors.white },
	},

	timing = false, -- The component will be update every time interval

	lazy = true,

	-- number or table
	padding = 1, -- { left = 1, right = 1 }

	color_expanded = true, -- if true, the colors will be include padding

	init = function() end,

	-- update = function() return "" end,

	update = function()
		return {
			{
				value = "",
				colors = {},
				padding = 1,
				separator = {},
				update = true,
			},
		}
	end,

	condition = function() return true end,

	on_highlight = function() end,
}
