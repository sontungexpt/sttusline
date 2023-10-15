local colors = require("sttusline.utils.color")
local Indent = require("sttusline.component").new()

Indent.set_colors { fg = colors.cyan, bg = colors.bg }

Indent.set_update(function()
	local tab_count = vim.api.nvim_buf_get_option(0, "shiftwidth") .. ""
	return "Tab: " .. tab_count
end)

return Indent
