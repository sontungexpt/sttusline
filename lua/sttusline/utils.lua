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

M.foreach_component = function(opts, callback, empty_zone_component_callback)
	for index, component in ipairs(opts.components) do
		if type(component) == "string" then
			if component == "%=" then
				empty_zone_component_callback(component, index)
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

M.is_color = function(color) return color:match("^#%x%x%x%x%x%x$") end

M.is_component = function(obj)
	return type(obj) == "table" and getmetatable(obj) == require("sttusline.component")
end

return M
