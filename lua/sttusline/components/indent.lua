local colors = require("sttusline.v1.utils.color")
return {
	name = "indent",
	event = {
		BufEnter = {
			"*.lua",
		},
	},
	user_event = { "VeryLazy" },
	padding = {
		left = "dfdf",
		spread_out = true,
	},

	separator = {
		left = {
			value = "",
			-- colors = { fg = "#ffffff" },
		},
		right = {
			value = "",
			colors = {},
		},
	},
	-- update_group = "BUF_WIN_ENTER",
	colors = { fg = colors.cyan, bg = "#dddddd" }, -- { fg = colors.black, bg = colors.white }
	update = function()
		return "Tab" -- print(vim.api.nvim_buf_get_option(0, "shiftwidth")) return "Tab: " .. vim.api.nvim_buf_get_option(0, "shiftwidth") .. ""
	end,
}
