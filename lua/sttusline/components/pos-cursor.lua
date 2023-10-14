local colors = require("sttusline.utils.color")

local PosCursor = require("sttusline.component"):new()

PosCursor.event = { "CursorMoved", "CursorMovedI" }

PosCursor.colors = { fg = colors.fg }

PosCursor.update = function()
	local pos = vim.api.nvim_win_get_cursor(0)

	return pos[1] .. ":" .. pos[2]
end

return PosCursor
