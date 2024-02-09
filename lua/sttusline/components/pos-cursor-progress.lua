local line = vim.fn.line
local colors = require("sttusline.v1.utils.color")

return {
	name = "pos-cursor-progress",
	event = { "CursorMoved", "CursorMovedI" },
	user_event = "VeryLazy",
	configs = {
		chars = { "_", "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" },
	},
	padding = 0,
	colors = { fg = colors.orange },
	update = function(configs)
		return configs.chars[math.ceil(line(".") / line("$") * #configs.chars)] or ""
	end,
}
