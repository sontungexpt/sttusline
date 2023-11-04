local line = vim.fn.line
local colors = require("sttusline.utils.color")

local PosCursorProgress = require("sttusline.component").new()

PosCursorProgress.set_event { "CursorMoved", "CursorMovedI" }

PosCursorProgress.set_padding(0)
PosCursorProgress.set_colors { fg = colors.orange }

local chars = { "_", "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" }

PosCursorProgress.set_update(function() return chars[math.ceil(line(".") / line("$") * #chars)] end)

return PosCursorProgress
