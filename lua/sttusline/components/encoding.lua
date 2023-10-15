local colors = require("sttusline.utils.color")
local Encoding = require("sttusline.component").new()

Encoding.set_colors { bg = colors.yellow, fg = colors.black }

Encoding.set_config {
	["utf-8"] = "󰉿",
	["utf-16"] = "",
	["utf-32"] = "",
	["utf-8mb4"] = "",
	["utf-16le"] = "",
	["utf-16be"] = "",
}

Encoding.set_update(function()
	local enc = vim.bo.fenc ~= "" and vim.bo.fenc or vim.o.enc
	return Encoding.get_config()[enc] or enc
end)

return Encoding
