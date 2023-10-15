local colors = require("sttusline.utils.color")

local PosCursorProgress = require("sttusline.component").new()

PosCursorProgress.set_event { "CursorMoved", "CursorMovedI" }

PosCursorProgress.set_padding(0)
PosCursorProgress.set_colors { fg = colors.orange, bg = colors.bg }

local chars = { "_", "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" }

PosCursorProgress.set_update(function()
	local current_line = vim.fn.line(".")
	local total_lines = vim.fn.line("$")
	local line_ratio = current_line / total_lines
	local index = math.ceil(line_ratio * #chars)
	return chars[index]
end)

return PosCursorProgress
