local M = {}

local configs = {
	components = {
		"filename",
		"diagnostics",
		"%=",
		"lsps-formatters",
		"encoding",
	},
}

M.apply_user_config = function(opts)
	for k, v in pairs(opts) do
		configs[k] = v
	end
	return configs
end

return M
