local fn = vim.fn
local get_option = vim.api.nvim_buf_get_option

local colors = require("sttusline.v1.utils.color")

return {
	name = "filename",
	event = { "BufEnter", "WinEnter", "TextChangedI", "BufWritePost" },
	user_event = "VeryLazy",
	colors = {
		{},
		{ fg = colors.orange },
	},
	configs = {
		-- 0 = full path,
		-- 1 = filename only,
		-- 2 = file name without extension,
		-- 3 = parent directory + filename
		path = 1,
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

		if configs.path == 0 then
			filename = fn.expand("%:p")
		elseif configs.path == 2 then
			filename = fn.expand("%:t:r")
		elseif configs.path == 3 then
			filename = fn.expand("%:p:h:t") .. "/" .. fn.expand("%:t")
		end

		local has_devicons, devicons = pcall(require, "nvim-web-devicons")
		local icon, color_icon = nil, nil
		if has_devicons then
			icon, color_icon = devicons.get_icon_color(filename, fn.expand("%:e"))
		end

		if not icon then
			local extensions = configs.extensions
			local buftype = get_option(0, "buftype")

			local extension = extensions.buftypes[buftype]
			if extension then
				icon, color_icon, filename =
					extension[1], extension[2], extension[3] or filename ~= "" and filename or buftype
			else
				local filetype = get_option(0, "filetype")
				extension = extensions.filetypes[filetype]
				if extension then
					icon, color_icon, filename =
						extension[1], extension[2], extension[3] or filename ~= "" and filename or filetype
				end
			end
		end

		if filename == "" then filename = "No File" end

		if not get_option(0, "modifiable") or get_option(0, "readonly") then
			return {
				icon and { icon .. " ", { fg = color_icon } } or "",
				filename,
				{ " ", { fg = colors.red } },
			}
		elseif get_option(0, "modified") then
			return {
				icon and { icon .. " ", { fg = color_icon } } or "",
				filename,
				{ " ", { fg = colors.fg } },
			}
		end
		return { icon and { icon .. " ", { fg = color_icon } } or "", filename }
	end,
}
