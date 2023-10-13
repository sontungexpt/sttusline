local FILENAME_HIGHLIGHT = "STTUSLINE_FILE_NAME"
local ICON_HIGHLIGHT = "STTUSLINE_FILE_ICON"
local fn = vim.fn
local hl = vim.api.nvim_set_hl
local colors = require("sttusline.color")
local utils = require("sttusline.utils")

local Filename = require("sttusline.component"):new()

Filename.event = { "BufEnter", "BufNewFile" }

Filename.update = function()
	local has_devicons, devicons = pcall(require, "nvim-web-devicons")
	local filename = fn.expand("%:t")
	if filename == "" then filename = "No File" end
	local icon, color_icon = nil, nil
	if has_devicons then
		icon, color_icon = devicons.get_icon_color(filename, fn.expand("%:e"))
	end
	if not icon then
		local buftype = vim.api.nvim_buf_get_option(0, "buftype")
		if buftype == "terminal" then
			icon, color_icon = "", colors.blue
			filename = "Terminal"
		else
			icon, color_icon = "", colors.blue
		end
	end

	hl(0, ICON_HIGHLIGHT, { fg = color_icon })
	hl(0, FILENAME_HIGHLIGHT, { fg = colors.orange })

	return utils.add_highlight_name(icon, ICON_HIGHLIGHT)
		.. " "
		.. utils.add_highlight_name(filename, FILENAME_HIGHLIGHT)
end

return Filename
