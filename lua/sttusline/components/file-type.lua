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
		local has_devicons, web_devicons = pcall(require, "nvim-web-devicons")
		local ft

		if has_devicons then
			ft = web_devicons.get_icon(vim.fn.expand("%:t"), vim.fn.expand("%:e"), {
				default = true,
			})
		else
			ft = vim.bo.filetype
		end

		return string.format("%s", ft)
	end,
}
