local Component = require("sttusline.component")

local COMPONENT_PARENT_MODULE = "sttusline.components"

local M = {}

M.add_padding = function(str, value)
	if #str == 0 then return str end

	if type(value) == "number" then
		if value <= 0 then return str end
		local padding = (" "):rep(value)

		local startpos = str:find([[#([^#%%]+)%%%*]])
		if not startpos then return padding .. str .. padding end

		return str:sub(1, startpos) .. padding .. str:sub(startpos + 1, #str - 2) .. padding .. "%*"
	elseif type(value) == "table" then
		local left_padding = type(value.left) == "number" and value.left >= 0 and (" "):rep(value.left)
			or " "
		local right_padding = type(value.right) == "number" and value.left >= 0 and (" "):rep(value.right)
			or " "

		local startpos = str:find([[#([^#%%]+)%%%*]])
		if not startpos then return left_padding .. str .. right_padding end
		return str:sub(1, startpos)
			.. left_padding
			.. str:sub(startpos + 1, #str - 2)
			.. right_padding
			.. "%*"
	end
end

M.add_highlight_name = function(str, highlight_name)
	vim.validate { str = { str, "string" }, highlight_name = { highlight_name, "string" } }
	return "%#" .. highlight_name .. "#" .. str .. "%*"
end

M.foreach_component = function(opts, callback, empty_zone_component_callback)
	for index, component in ipairs(opts.components) do
		if type(component) == "string" then
			if component == "%=" then
				if type(empty_zone_component_callback) == "function" then
					empty_zone_component_callback(component, index)
				end
			else
				local status_ok, real_comp = pcall(require, COMPONENT_PARENT_MODULE .. "." .. component)
				if status_ok then
					opts.components[index] = real_comp
					callback(real_comp, index)
				else
					require("sttusline.utils.notify").error("Failed to load component: " .. component)
				end
			end
		else
			callback(component, index)
		end
	end
end

M.is_color = function(color) return type(color) == "string" and color:match("^#%x%x%x%x%x%x$") end

M.is_component = function(obj) return type(obj) == "table" and getmetatable(obj) == Component end

M.is_disabled = function(opts)
	local filetype = vim.api.nvim_buf_get_option(0, "filetype")
	local buftype = vim.api.nvim_buf_get_option(0, "buftype")
	if
		vim.tbl_contains(opts.disabled.filetypes or {}, filetype)
		or vim.tbl_contains(opts.disabled.buftypes or {}, buftype)
	then
		return true
	end
	return false
end

return M
