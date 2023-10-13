local config = require("sttusline.config")
local runner = require("sttusline.runner")
local utils = require("sttusline.utils")

local M = {}

M.setup = function(user_opts)
	local opts = config.apply_user_config(user_opts)
	utils.format_opts(opts)
	runner.setup(opts)
end

return M
