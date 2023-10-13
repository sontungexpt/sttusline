local config = require("sttusline.config")
local runner = require("sttusline.runner")

local M = {}

M.setup = function(user_opts)
	local opts = config.apply_user_config(user_opts)
	config.format_opts_components(opts)
	config.init_config(opts)
	runner.setup(opts)
end

return M
