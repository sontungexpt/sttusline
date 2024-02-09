local uv = vim.uv or vim.loop
local colors = require("sttusline.util.color")

return {
	name = "os-uname",
	user_event = { "VeryLazy" },
	colors = {
		fg = colors.orange,
	},
	configs = {
		icons = {
			mac = "",
			linux = "",
			windows = "",
		},
	},
	update = function(configs)
		local os_uname = uv.os_uname()

		local uname = os_uname.sysname
		if uname == "Darwin" then
			return {
				{
					value = configs.icons.mac,
					colors = { fg = colors.white },
					hl_update = true,
				},
			}
		elseif uname == "Linux" then
			if os_uname.release:find("arch") then
				return {
					{
						value = "",
						colors = { fg = colors.blue },
						hl_update = true,
					},
				}
			end
			return {
				{
					value = configs.icons.linux,
					colors = { fg = colors.yellow },
					hl_update = true,
				},
			}
		elseif uname == "Windows" then
			return {
				{
					value = configs.icons.windows,
					colors = { fg = colors.blue },
					hl_update = true,
				},
			}
		else
			return uname or "󱚟 Unknown OS"
		end
	end,
}
