local colors = require("sttusline.utils.color")
return {
	name = "indent",
	update_group = "BUF_WIN_ENTER",
	colors = { fg = colors.cyan }, -- { fg = colors.black, bg = colors.white }
	update = function() return "Tab: " .. vim.api.nvim_buf_get_option(0, "shiftwidth") .. "" end,
}
