local type = type

local M = {}

local configs = {
	disabled = {
		filetypes = {},
		buftypes = {
			terminal = true,
		},
	},
	separator = { left = "", right = "" },
	components = {
		require("sttusline.components.filename"),
		require("sttusline.components.diagnostics"),
		"%=",
		require("sttusline.components.indent"),
		require("sttusline.components.encoding"),
		require("sttusline.components.pos-cursor"),
		require("sttusline.components.pos-cursor-progress"),
	},
}

--- The config properties are read-only
-- local keep_default_values = function() end

M.setup = function(user_opts)
	M.merge_config(configs, user_opts)
	-- keep_default_values()

	return configs
end

M.merge_config = function(default_opts, user_opts)
	local default_options_type = type(default_opts)

	if default_options_type == type(user_opts) then
		if default_options_type == "table" and default_opts[1] == nil then
			for k, v in pairs(user_opts) do
				default_opts[k] = M.merge_config(default_opts[k], v)
			end
		else
			default_opts = user_opts
		end
	elseif default_opts == nil then
		default_opts = user_opts
	end
	return default_opts
end

M.get_config = function()
	return M.read_only(configs, "Attempt to modify config, this is a read-only table")
end

M.read_only = function(tbl, err_msg)
	local cache = {}

	function M.read_only(table, error_msg)
		if not cache[table] then
			cache[table] = setmetatable({}, {
				__index = table,
				__newindex = function(metatable, key, value)
					error(
						type(error_msg) == "function" and error_msg(metatable, key, value)
							or error_msg
							or "Attempt to modify read-only table"
					)
				end,
			})
		end

		return cache[table]
	end
end
return M
