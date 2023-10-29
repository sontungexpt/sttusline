local FILENAME_HIGHLIGHT = "STTUSLINE_FILE_NAME"
local ICON_HIGHLIGHT = "STTUSLINE_FILE_ICON"

local fn = vim.fn
local get_option = vim.api.nvim_buf_get_option
local hl = vim.api.nvim_set_hl

local colors = require("sttusline.utils.color")
local utils = require("sttusline.utils")

return {
	name = "filename",
	event = { "BufEnter", "WinEnter" }, -- The component will be update when the event is triggered
	user_event = { "VeryLazy" },
	configs = {
		color = { fg = colors.orange, bg = colors.bg },
	},

	update = function()
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
				icon, color_icon = "", colors.red
				filename = "Terminal"
			elseif filetype == "NvimTree" then
				icon, color_icon = "󰙅", colors.red
				filename = "NvimTree"
			elseif filetype == "TelescopePrompt" then
				icon, color_icon = "", colors.red
				filename = "Telescope"
			elseif filetype == "mason" then
				icon, color_icon = "󰏔", colors.red
				filename = "Mason"
			elseif filetype == "lazy" then
				icon, color_icon = "󰏔", colors.red
				filename = "Lazy"
			elseif filetype == "dashboard" then
				icon, color_icon = "", colors.red
			end
		end

		hl(0, ICON_HIGHLIGHT, { fg = color_icon, bg = colors.bg })

		if icon then
			return utils.add_highlight_name(icon, ICON_HIGHLIGHT)
				.. " "
				.. utils.add_highlight_name(filename, FILENAME_HIGHLIGHT)
		else
			return utils.add_highlight_name(filename, FILENAME_HIGHLIGHT)
		end
	end,
	on_highlight = function(configs) hl(0, FILENAME_HIGHLIGHT, configs.color) end,
}
