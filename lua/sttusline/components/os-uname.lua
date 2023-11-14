local uv = vim.uv or vim.loop
local colors = require("sttusline.utils.color")

return {
	name = "os-uname",
	user_event = { "VeryLazy" },
	colors = {
		fg = colors.green,
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
			return { { configs.icons.mac, { fg = colors.white } } }
		elseif uname == "Linux" then
			if os_uname.release:find("arch") then return { { "", { fg = colors.blue } } } end
			return { { configs.icons.linux, { fg = colors.yellow } } }
		elseif uname == "Windows" then
			return { { configs.icons.windows, { fg = colors.blue } } }
		else
			return uname or "Unknown OS"
		end
	end,
}
