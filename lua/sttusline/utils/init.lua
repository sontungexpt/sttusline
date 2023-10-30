local color_utils = require("sttusline.utils.color")
local M = {}

M.eval_func = function(func, ...)
	if type(func) == "function" then return func(...) end
end

M.eval_component_func = function(component, func_name, ...)
	local configs = type(component.configs) == "table" and component.configs or {}
	local override_colors = vim.tbl_deep_extend("force", color_utils, component.override_glob_colors or {})
	local space = nil

	if type(component.space) == "function" then
		space = component.space(configs, override_colors)
	elseif type(component.space) == "table" then
		space = component.space
	end

	return M.eval_func(component[func_name], configs, override_colors, space, ...)
end

M.add_padding = function(str, value)
	if #str == 0 then return str end
	value = value or 1

	if type(value) == "number" then
		if value < 1 then return str end
		local padding = (" "):rep(math.floor(value))

		if type(str) == "string" then
			return padding .. str .. padding
		else -- table
			local first_element = str[1]
			local last_element = str[#str]

			if type(first_element) == "string" then
				str[1] = padding .. first_element
			elseif type(first_element) == "table" and type(first_element[1]) == "string" then
				first_element[1] = padding .. first_element[1]
			end

			if type(last_element) == "string" then
				str[#str] = last_element .. padding
			elseif type(last_element) == "table" and type(last_element[1]) == "string" then
				last_element[1] = last_element[1] .. padding
			end
			return str
		end
		return str
	elseif type(value) == "table" then
		local left_padding = type(value.left) == "number"
				and value.left >= 0
				and (" "):rep(math.floor(value.left))
			or " "
		local right_padding = type(value.right) == "number"
				and value.right >= 0
				and (" "):rep(math.floor(value.right))
			or " "

		if type(str) == "string" then
			return left_padding .. str .. right_padding
		elseif type(str) == "table" then
			local first_element = str[1]
			local last_element = str[#str]

			if type(first_element) == "string" then
				str[1] = left_padding .. first_element
			elseif type(first_element) == "table" and type(first_element[1]) == "string" then
				first_element[1] = left_padding .. first_element[1]
			end

			if type(last_element) == "string" then
				str[#str] = last_element .. right_padding
			elseif type(last_element) == "table" and type(last_element[1]) == "string" then
				last_element[1] = last_element[1] .. right_padding
			end

			return str
		end
		return str
	end
end

M.add_highlight_name = function(str, highlight_name)
	vim.validate { str = { str, "string" }, highlight_name = { highlight_name, "string" } }
	return "%#" .. highlight_name .. "#" .. str .. "%*"
end

M.array_filter = function(func, arr, ...)
	local new_arr = {}
	for k, v in ipairs(arr) do
		if func(v, k, ...) then table.insert(new_arr, v) end
	end
	return new_arr
end

M.is_color = function(color) return type(color) == "string" and color:match("^#%x%x%x%x%x%x$") end

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
