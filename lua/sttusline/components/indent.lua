local api = vim.api
local colors = require("sttusline.util.color")

return {
	name = "indent",
	event = { "BufEnter", "WinEnter" },
	user_event = "VeryLazy",
	colors = { fg = colors.cyan },
	update = function() return "Tab: " .. api.nvim_buf_get_option(0, "shiftwidth") .. "" end,
}
