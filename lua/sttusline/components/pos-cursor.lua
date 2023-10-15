local colors = require("sttusline.utils.color")

local PosCursor = require("sttusline.component").new()

PosCursor.set_event { "CursorMoved", "CursorMovedI" }

PosCursor.set_colors { fg = colors.fg }

PosCursor.set_update(function()
	local pos = vim.api.nvim_win_get_cursor(0)

	return pos[1] .. "." .. pos[2]
end)

return PosCursor
