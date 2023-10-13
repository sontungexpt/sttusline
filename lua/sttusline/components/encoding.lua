local colors = require("sttusline.color")

local Encoding = require("sttusline.component"):new()

local icons = {
	["utf-8"] = "󰉿",
	["utf-16"] = "",
	["utf-32"] = "",
	["utf-8mb4"] = "",
	["utf-16le"] = "",
	["utf-16be"] = "",
}

Encoding.colors = { bg = colors.yellow, fg = colors.black }

Encoding.update = function()
	local enc = vim.bo.fenc ~= "" and vim.bo.fenc or vim.o.enc
	return icons[enc] or enc
end

return Encoding
