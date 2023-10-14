local colors = require("sttusline.utils.color")

local PosCursorProgress = require("sttusline.component"):new()

PosCursorProgress.event = { "CursorMoved", "CursorMovedI" }

PosCursorProgress.padding = 0
PosCursorProgress.colors = { fg = colors.orange }

local chars = { "_", "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" }

PosCursorProgress.update = function()
	local current_line = vim.fn.line(".")
	local total_lines = vim.fn.line("$")
	local line_ratio = current_line / total_lines
	local index = math.ceil(line_ratio * #chars)
	return chars[index]
end

return PosCursorProgress
