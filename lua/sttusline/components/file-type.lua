return {
	name = "file-type",
	event = {
		"BufEnter",
		"BufWritePost",
		"BufReadPost",
	},
	configs = {
		style = "default",
	},
	padding = 2,
	user_event = "VeryLazy",
	update = function()
		local icon = require("nvim-web-devicons").get_icon(
			vim.fn.expand("%:t"),
			vim.fn.expand("%:e"),
			{ default = true }
		)
		return string.format("%s", icon)
	end,
}
