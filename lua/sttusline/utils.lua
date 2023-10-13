local notify = require("sttusline.notify")
local COMPONENT_PARENT_MODULE = "sttusline.components"

local M = {}

M.add_padding = function(str, value)
	if type(value) == "number" then
		local padding = (" "):rep(value)
		return padding .. str .. padding
	elseif type(value) == "table" then
		local left_padding = type(value.left) == "number" and value.left >= 0 and (" "):rep(value.left)
			or " "
		local right_padding = type(value.right) == "number" and value.left >= 0 and (" "):rep(value.right)
			or " "
		return left_padding .. str .. right_padding
	end
end

M.add_highlight_name = function(str, highlight_name) return "%#" .. highlight_name .. "#" .. str .. "%*" end

M.foreach_component = function(opts, callback)
	for index, component in ipairs(opts.components) do
		if type(component) == "string" then
			if component == "%=" then
				callback(component, index, true)
			else
				local status_ok, real_comp = pcall(require, COMPONENT_PARENT_MODULE .. "." .. component)
				if status_ok then
					opts.components[index] = real_comp
					callback(real_comp, index)
				else
					notify.error("Failed to load component: " .. component)
				end
			end
		else
			callback(component, index)
		end
	end
end

M.format_opts = function(opts)
	local formatted_opts = {}
	for k, v in pairs(opts.components) do
		if type(v) == "string" then
			if k == 1 or k == #opts.components then
				if v ~= "%=" then table.insert(formatted_opts, v) end
			else
				table.insert(formatted_opts, v)
			end
		elseif type(v) == "table" then
			table.insert(formatted_opts, v)
		end
	end
	opts.components = formatted_opts
end

M.is_color = function(color) return color:match("^#%x%x%x%x%x%x$") end

return M
