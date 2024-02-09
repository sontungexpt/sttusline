local api = vim.api
local colors = require("sttusline.util.color")

return {
	name = "pos-cursor",
	event = { "CursorMoved", "CursorMovedI" },
	user_event = "VeryLazy",
	colors = { fg = colors.fg },
	update = function()
		local pos = api.nvim_win_get_cursor(0)
		return pos[1] .. ":" .. pos[2]
	end,
}
