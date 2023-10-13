local constants = require("sttusline.constant")
local notify = require("sttusline.notify")

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
	for zone, zone_values in pairs(opts.components) do
		for index_in_zone, component in ipairs(zone_values) do
			callback(component, zone, index_in_zone)
		end
	end
end

M.format_opts = function(opts)
	for zone, zone_values in pairs(opts.components) do
		for index_in_zone, component in ipairs(zone_values) do
			local component_type = type(component)
			if component_type == "string" then
				local status_ok, real_component =
					pcall(require, constants.COMPONENT_MODULE_PREFIX .. "." .. component)
				if status_ok then
					opts.components[zone][index_in_zone] = real_component
				else
					table.remove(opts.components[zone], index_in_zone)
					notify.error(component .. " not found")
				end
			elseif component_type ~= "table" then
				table.remove(opts.components[zone], index_in_zone)
				notify.error(
					'component must be string(name of component) or create by call require("sttusline.component"):new()'
				)
			end
		end
	end
	return opts
end

M.copy_highlight = function(old, new)
	local opts = vim.api.nvim_get_hl_by_name(old, true)
	vim.api.nvim_set_hl(0, new, { fg = opts.foreground, bg = opts.background })
end

M.is_color = function(color) return string.match(color, "^#%x%x%x%x%x%x$") end

return M
