return {
	name = "form", -- nick to link the componet with the group

	event = {
		BufEnter = { "*.lua", "*.js" },
	},

	user_event = {},

	configs = {},

	-- separator = { left = "", right = "" },
	separator = {
		left = {
			value = "",
			colors = { fg = "#ffffff" },
		},
		right = {
			value = "",
			colors = { fg = "#ffffff" },
		},
	},

	timing = false, -- The component will be update every time interval

	lazy = true,

	-- number or table
	padding = 1, -- { left = 1, right = 1 }

	colors = {}, -- { fg = colors.black, bg = colors.white }

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
