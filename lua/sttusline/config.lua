local M = {}

local configs = {
	components = {
		left = {
			-- "mode",
			-- "filename",
			-- "git-branch",
			-- "git-signs",
			-- Component
		},
		center = {
			"diagnostics",
		},
		right = {
			-- 	"lsps-formatters",
			-- 	"indentation",
			-- 	"encoding",
			-- 	"position",
			-- 	"position-progess",
		},
	},
}

M.apply_user_config = function(opts)
	for k, v in pairs(opts) do
		configs[k] = v
	end
	return configs
end

return M
