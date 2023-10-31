local colors = require("sttusline.utils.color")
return {
	name = "indent",
	event = { "BufEnter" }, -- The component will be update when the event is triggered
	user_event = { "VeryLazy" },
	colors = { fg = colors.cyan }, -- { fg = colors.black, bg = colors.white }
	update = function() return "Tab: " .. vim.api.nvim_buf_get_option(0, "shiftwidth") .. "" end,
}
