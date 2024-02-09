local type = type

local M = {}

local configs = {
	disabled = {
		filetypes = {},
		buftypes = {
			terminal = true,
		},
	},
	separator = {
		-- {
		-- 	right = "",
		-- 	right_colors = {
		-- 		fg = "#dfdf23",
		-- 		bg = "#219dea",
		-- 	},
		-- },
		-- {
		-- 	left = "",
		-- 	left_colors = {
		-- 		fg = "#ffffff",
		-- 	},
		-- },
	},
	colors = {
		{
			fg = "#ffffff",
			bg = "#219dea",
		},
		{
			fg = "#ffffff",
			bg = "#546dea",
		},
	},
	padding = {
		-- [2] = 0,
	},
	components = require("sttusline.default"),
}

--- The config properties are read-only
-- local keep_default_values = function() end

M.setup = function(user_opts)
	M.merge_config(configs, user_opts)
	-- keep_default_values()

	return configs
end

M.merge_config = function(default_opts, user_opts, force)
	local default_options_type = type(default_opts)

	if default_options_type == type(user_opts) then
		if default_options_type == "table" and default_opts[1] == nil then
			for k, v in pairs(user_opts) do
				default_opts[k] = M.merge_config(default_opts[k], v)
			end
		elseif force then
			default_opts = user_opts
		elseif default_opts == nil then
			default_opts = user_opts
		end
	elseif default_opts == nil then
		default_opts = user_opts
	end
	return default_opts
end

M.get_config = function()
	return setmetatable({}, {
		__index = configs,
		__newindex = function() error("Attempt to modify read-only table") end,
	})
end

return M
