local M = {}

local configs = {
	disabled = {
		filetypes = {},
		buftypes = {
			"terminal",
		},
	},
	components = {
		"mode",
		"filename",
		"git-branch",
		"git-diff",
		"%=",
		"diagnostics",
		"lsps-formatters",
		"copilot",
		"indent",
		"encoding",
		"pos-cursor",
		"pos-cursor-progress",
	},
}

M.setup = function(user_opts)
	user_opts = M.apply_user_config(user_opts)
	return user_opts
end

M.apply_user_config = function(opts)
	if type(opts) == "table" then
		for k, v in pairs(opts) do
			if type(v) == type(configs[k]) then
				if type(v) == "table" then
					if v[1] == nil then
						for k2, v2 in pairs(v) do
							if type(v2) == type(configs[k][k2]) then configs[k][k2] = v2 end
						end
					end
				else
					configs[k] = v
				end
			end
		end
	end
	return configs
end

return M
