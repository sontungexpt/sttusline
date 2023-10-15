local FILENAME_HIGHLIGHT = "STTUSLINE_FILE_NAME"
local ICON_HIGHLIGHT = "STTUSLINE_FILE_ICON"

local fn = vim.fn
local get_option = vim.api.nvim_buf_get_option
local hl = vim.api.nvim_set_hl

local colors = require("sttusline.utils.color")
local utils = require("sttusline.utils")

local Filename = require("sttusline.component").new()

Filename.set_config {
	color = { fg = colors.orange, bg = colors.bg },
}

Filename.set_event { "BufEnter", "BufNewFile" }

Filename.set_update(function()
	local has_devicons, devicons = pcall(require, "nvim-web-devicons")

	local filename = fn.expand("%:t")
	if filename == "" then filename = "No File" end
	local icon, color_icon = nil, nil
	if has_devicons then
		icon, color_icon = devicons.get_icon_color(filename, fn.expand("%:e"))
	end

	if not icon then
		local buftype = get_option(0, "buftype")
		local filetype = get_option(0, "filetype")
		if buftype == "terminal" then
			icon, color_icon = "", colors.blue
			filename = "Terminal"
		end
		if filetype == "NvimTree" then filename = "NvimTree" end
	end

	hl(0, ICON_HIGHLIGHT, { fg = color_icon })

	if icon then
		return utils.add_highlight_name(icon, ICON_HIGHLIGHT)
			.. " "
			.. utils.add_highlight_name(filename, FILENAME_HIGHLIGHT)
	else
		return utils.add_highlight_name(filename, FILENAME_HIGHLIGHT)
	end
end)

Filename.set_onload(function() hl(0, FILENAME_HIGHLIGHT, Filename.get_config().color) end)

return Filename
