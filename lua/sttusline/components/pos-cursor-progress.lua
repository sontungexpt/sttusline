local line = vim.fn.line
local colors = require("sttusline.utils.color")

return {
	name = "pos-cursor-progress",

	event = { "CursorMoved", "CursorMovedI" }, -- The component will be update when the event is triggered
	user_event = { "VeryLazy" },

	timing = false, -- The component will be update every time interval

	lazy = true,

	configs = {
		chars = { "_", "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" },
	},

	-- number or table
	padding = 0, -- { left = 1, right = 1 }
	colors = { fg = colors.orange, bg = colors.bg }, -- { fg = colors.black, bg = colors.white }

	update = function(configs)
		return configs.chars[math.ceil(line(".") / line("$") * #configs.chars)] or ""
	end,
}