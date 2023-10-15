local config = require("sttusline.config")
local runner = require("sttusline.runner")
local command = require("sttusline.command")

local M = {}

M.setup = function(user_opts)
	local opts = config.setup(user_opts)
	command.setup(opts)
	runner.setup(opts)
end

return M
