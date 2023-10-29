local config = require("sttusline.config")
local runner = require("sttusline.runner")

local M = {}

M.setup = function(user_opts)
	local opts = config.setup(user_opts)
	runner.setup(opts)
end

return M
