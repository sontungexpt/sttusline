local colors = require("sttusline.utils.color")
local Indent = require("sttusline.component").new()

Indent.set_colors { fg = colors.cyan }

Indent.set_event("BufEnter")

Indent.set_update(function() return "Tab: " .. vim.api.nvim_buf_get_option(0, "shiftwidth") .. "" end)

return Indent
