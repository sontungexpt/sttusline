local api = vim.api
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
	return #str > 0 and "%#" .. highlight_name .. "#" .. str .. "%*" or ""
end

M.is_color = function(color) return type(color) == "string" and color:match("^#%x%x%x%x%x%x$") end

M.is_disabled = function(opts)
	return vim.tbl_contains(opts.disabled.filetypes or {}, api.nvim_buf_get_option(0, "filetype"))
		or vim.tbl_contains(opts.disabled.buftypes or {}, api.nvim_buf_get_option(0, "buftype"))
end

M.get_hl_name_color = function(hl_name)
	local ok, colors = pcall(api.nvim_get_hl_by_name, hl_name, true)
	return ok and colors or {}
end

M.set_hl = function(group, opts, global_background)
	if M.is_highlight_option(opts) then
		if opts.fg and not M.is_color(opts.fg) then opts.fg = M.get_hl_name_color(opts.fg).foreground end

		if opts.bg and not M.is_color(opts.bg) then
			opts.bg = M.get_hl_name_color(opts.bg).background
		elseif global_background then
			opts.bg = M.is_color(global_background) and global_background
				or M.get_hl_name_color(global_background).background
		else
			-- fallback to StatusLine background
			opts.bg = M.get_hl_name_color("StatusLine").background
		end
		pcall(api.nvim_set_hl, 0, group, opts)
	end
end

M.is_highlight_option = function(hl_opts) return type(hl_opts) == "table" and next(hl_opts) ~= nil end

M.is_highlight_name = function(hl_name) return type(hl_name) == "string" and #hl_name > 0 end

return M
