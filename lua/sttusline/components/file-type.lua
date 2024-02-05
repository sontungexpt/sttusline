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
		local ft, ft_highlight
		local has_web_devicons, web_devicons = pcall(require, "nvim-web-devicons")

		if has_web_devicons then
			ft, ft_highlight =
				web_devicons.get_icon(vim.fn.expand("%:t"), vim.fn.expand("%:e"), { default = true })
		else
			ft = vim.bo.filetype
		end

		local color = ""
		if ft_highlight then
			local highlight_color = vim.api.nvim_get_hl(0, { name = ft_highlight })
			color = highlight_color.foreground
		end

		return string.format("%s %s", ft, color)
	end,
}
