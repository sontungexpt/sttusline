local colors = require("sttusline.utils.color")

return {
	name = "filesize",
	event = "BufEnter",
	user_event = "VeryLazy",
	colors = {
		fg = colors.green,
	},
	configs = {
		icon = " ",
	},
	update = function(configs)
		local current_file = vim.api.nvim_buf_get_name(0)
		local file_size = vim.fn.getfsize(current_file)
		if file_size <= 0 then return "" end

		local suffixes = { "B", "KB", "MB", "GB" }
		local i = 1
		while file_size > 1024 and i < #suffixes do
			file_size = file_size / 1024
			i = i + 1
		end

		local format = i == 1 and "%d%s" or "%.1f%s"
		return configs.icon .. string.format(format, file_size, suffixes[i])
	end,
}
