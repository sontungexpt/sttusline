local M = {}

local configs = {
	laststatus = 3,
	components = {
		"filename",
		"diagnostics",
		"%=",
		"lsps-formatters",
		"encoding",
	},
}

M.init_config = function(opts) vim.opt.laststatus = opts.laststatus end

--- Format opts.components to be a table of strings and tables
--- @tparam table opts : user opts
--- @treturn table opts : formatted user opts
M.format_opts_components = function(opts)
	local formatted_opts = {}
	for k, v in pairs(opts.components) do
		if type(v) == "string" and #v > 0 then
			if k == 1 or k == #opts.components then
				if v ~= "%=" then table.insert(formatted_opts, v) end
			else
				table.insert(formatted_opts, v)
			end
		elseif type(v) == "table" and #v > 0 then
			table.insert(formatted_opts, v)
		end
	end
	opts.components = formatted_opts
	return opts
end

M.apply_user_config = function(opts)
	for k, v in pairs(opts) do
		configs[k] = v
	end
	return configs
end

return M
