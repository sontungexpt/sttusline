local config = require("sttusline.config")
local core = require("sttusline.core")

local M = {}

M.setup = function(user_opts)
	local opts = config.setup(user_opts)
	core.setup(opts)
end

return M
