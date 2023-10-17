local is_component = require("sttusline.utils").is_component
local M = {}

local configs = {
	-- 0 | 1 | 2 | 3
	-- recommended: 3
	laststatus = 3,
	disabled = {
		filetypes = {
			-- "NvimTree",
			-- "lazy",
		},
		buftypes = {
			-- "terminal",
		},
	},
	components = {
		"mode",
		"filename",
		-- "git-branch",
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
	M.format_opts_components(user_opts)
	M.init_config(user_opts)
	return user_opts
end

M.init_config = function(opts) vim.opt.laststatus = opts.laststatus end

--- Format opts.components to be a table of strings and tables
--- @tparam table opts : user opts
--- @treturn table opts : formatted user opts
M.format_opts_components = function(opts)
	local formatted_opts = {}
	for _, v in pairs(opts.components) do
		if type(v) == "string" and #v > 0 then
			table.insert(formatted_opts, v)
		elseif is_component(v) then
			table.insert(formatted_opts, v)
		end
	end
	opts.components = formatted_opts
	return opts
end

M.apply_user_config = function(opts)
	if type(opts) == "table" then
		for k, v in pairs(opts) do
			configs[k] = v
		end
	end
	return configs
end

return M
