return {
	name = "form",

	event = {}, -- The component will be update when the event is triggered
	user_event = { "VeryLazy" },

	timing = false, -- The component will be update every time interval

	lazy = true,

	utils = {},
	configs = {},
	override_glob_colors = {},

	-- number or table
	padding = 1, -- { left = 1, right = 1 }
	colors = {}, -- { fg = colors.black, bg = colors.white }

	init = function() end,
	update = function() return "" end,
	condition = function() return true end,

	on_highlight = function() end,
}
