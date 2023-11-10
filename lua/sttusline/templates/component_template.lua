return {
	name = "form",

	-- The component in same group will be update in the same time
	update_group = "group_name",

	-- If update_group is set the event, user_event and timing will be ignored
	-- It will update in the same option as update_group
	event = {}, -- The component will be update when the event is triggered
	separator = { left = "", right = "" },
	user_event = { "VeryLazy" },
	timing = false, -- The component will be update every time interval

	lazy = true,

	space = {},
	configs = {},

	-- number or table
	padding = 1, -- { left = 1, right = 1 }
	colors = {}, -- { fg = colors.black, bg = colors.white }

	init = function() end,
	update = function() return "" end,
	condition = function() return true end,

	on_highlight = function() end,
}
