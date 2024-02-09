local colors = require("sttusline.util.color")
local api = vim.api
local fn = vim.fn

return {
	name = "filename",
	event = { "BufEnter", "WinEnter", "TextChangedI", "BufWritePost" },
	user_event = "VeryLazy",
	colors = {
		fg = colors.orange,
	},
	configs = {
		extensions = {
			-- filetypes = { icon, color, filename(optional) },
			filetypes = {
				["NvimTree"] = { "󰙅", colors.red, "NvimTree" },
				["TelescopePrompt"] = { "", colors.red, "Telescope" },
				["mason"] = { "󰏔", colors.red, "Mason" },
				["lazy"] = { "󰏔", colors.red, "Lazy" },
				["checkhealth"] = { "", colors.red, "CheckHealth" },
				["plantuml"] = { "", colors.green },
				["dashboard"] = { "", colors.red },
			},

			-- buftypes = { icon, color, filename(optional) },
			buftypes = {
				["terminal"] = { "", colors.red, "Terminal" },
			},
		},
	},
	update = function(configs)
		local filename = fn.expand("%:t")

		local has_devicons, devicons = pcall(require, "nvim-web-devicons")
		local icon, color_icon = nil, nil
		if has_devicons then
			icon, color_icon = devicons.get_icon_color(filename, fn.expand("%:e"))
		end

		if not icon then
			local extensions = configs.extensions
			local buftype = api.nvim_buf_get_option(0, "buftype")

			local extension = extensions.buftypes[buftype]
			if extension then
				icon, color_icon, filename =
					extension[1], extension[2], extension[3] or filename ~= "" and filename or buftype
			else
				local filetype = api.nvim_buf_get_option(0, "filetype")
				extension = extensions.filetypes[filetype]
				if extension then
					icon, color_icon, filename =
						extension[1], extension[2], extension[3] or filename ~= "" and filename or filetype
				end
			end
		end

		if filename == "" then filename = "No File" end

		-- check if file is read-only
		if not api.nvim_buf_get_option(0, "modifiable") or api.nvim_buf_get_option(0, "readonly") then
			return {
				{
					value = icon,
					colors = { fg = color_icon },
					hl_update = true,
				},
				" " .. filename,
				{
					value = " ",
					colors = { fg = colors.red },
					hl_update = true,
				},
			}
			-- check if unsaved
		elseif api.nvim_buf_get_option(0, "modified") then
			return {
				{

					value = icon,
					colors = { fg = color_icon },
					hl_update = true,
				},
				" " .. filename,
				{
					value = " ",
					colors = { fg = "Statusline" },
					hl_update = true,
				},
			}
		end
		return {
			{

				value = icon,
				colors = { fg = color_icon },
				hl_update = true,
			},
			" " .. filename,
		}
	end,
}
