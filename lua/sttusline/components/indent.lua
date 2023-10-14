local colors = require("sttusline.utils.color")
local utils = require("sttusline.utils")
local Indent = require("sttusline.component"):new()
local TAB_HIGHLIGHT = "STTUSLINE_TAB"

Indent.colors = { fg = colors.blue }

Indent.update = function()
	return utils.add_highlight_name(" Tab ", TAB_HIGHLIGHT)
		.. " "
		.. vim.api.nvim_buf_get_option(0, "shiftwidth")
end
Indent.on_load = function()
	vim.api.nvim_set_hl(0, TAB_HIGHLIGHT, { bg = colors.blue, fg = colors.black })
end

return Indent
