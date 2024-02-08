local colors = require("sttusline.util.color")

return {
	name = "indent",
	event = { "FileType" },
	user_event = { "VeryLazy" },
	colors = { fg = colors.cyan }, -- { fg = colors.black, bg = colors.white }
	separator = {
		left = "",
		right = "",
		colors_left = { fg = colors.black, bg = colors.white },
		colors_right = { fg = colors.black, bg = colors.white },
	},
	update = function() return "Tab: " .. vim.api.nvim_buf_get_option(0, "shiftwidth") .. "" end,
}
