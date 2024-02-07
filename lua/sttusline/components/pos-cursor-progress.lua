local line = vim.fn.line
local colors = require("sttusline.v1.utils.color")

return {
	name = "pos-cursor-progress",

	event = { "CursorMoved", "CursorMovedI" }, -- The component will be update when the event is triggered
	user_event = { "VeryLazy" },

	configs = {
		chars = { "_", "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" },
	},
	padding = 0, -- { left = 1, right = 1 }
	colors = { fg = colors.orange }, -- { fg = colors.black, bg = colors.white }

	update = function(configs)
		return configs.chars[math.ceil(line(".") / line("$") * #configs.chars)] or ""
	end,
}
