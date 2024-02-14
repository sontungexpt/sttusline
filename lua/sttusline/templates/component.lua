local colors = require("sttusline.util.color")
return {
	name = "form", -- nickname to link the componet with the group
	timing = false, -- The component will be update every time interval
	lazy = true,

	event = {},
	user_event = {},

	configs = {},

	flexible = false, -- if a component is flexible, it's children will be added when the parent is updated
	colors = {},

	-- number or table
	padding = 1, -- { left = 1, right = 1 } or inherit
	separator = {
		left = "", -- or inherit
		right = "", -- or inherit
		colors_left = { fg = colors.black, bg = colors.white },
		colors_right = { fg = colors.black, bg = colors.white },
	},

	init = function() end,

	propagation = false,
	pre_update = function() end,
	update = function() return "" end,
	post_update = function() end,
	condition = function() return true end,

	{},
	{},
}
