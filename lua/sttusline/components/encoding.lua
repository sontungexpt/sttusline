local colors = require("sttusline.utils.color")
return {
	name = "encoding",
	update_group = "BUF_WIN_ENTER",
	configs = {
		["utf-8"] = "󰉿",
		["utf-16"] = "󰊀",
		["utf-32"] = "󰊁",
		["utf-8mb4"] = "󰊂",
		["utf-16le"] = "󰊃",
		["utf-16be"] = "󰊄",
	},
	colors = { fg = colors.yellow }, -- { fg = colors.black, bg = colors.white }
	update = function(configs)
		local enc = vim.bo.fenc ~= "" and vim.bo.fenc or vim.o.enc
		return configs[enc] or enc or ""
	end,
}
