local config = require("sttusline.config")
local api = require("sttusline.api")
local M = {}

M.setup = function(user_opts)
	local opts = config.setup(user_opts)
	api.setup(opts)
end

return M
