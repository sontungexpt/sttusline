local HIGHLIGHT_COMPONENT_PREFIX = "STTUSLINE_COMPONENT_"
local HIGHLIGHT_COMPONENT_SEPARATOR_PREFIX = "STTUSLINE_COMPONENT_SEPARATOR_"

local api = vim.api
local next = next
local type = type
local pcall = pcall
local concat = table.concat

local M = {}

M.is_highlight_option = function(hl_opts) return type(hl_opts) == "table" and next(hl_opts) ~= nil end

M.is_highlight_name = function(hl_name) return type(hl_name) == "string" and #hl_name > 0 end

M.is_color = function(color) return type(color) == "string" and color:match("^#%x%x%x%x%x%x$") end

M.add_highlight_name = function(str, hl_name)
	return #str > 0 and "%#" .. hl_name .. "#" .. str .. "%*" or ""
end

M.get_hl_name_color = function(hl_name)
	local ok, colors = pcall(api.nvim_get_hl_by_name, hl_name, true)
	return ok and colors or {}
end

M.gen_component_hl_name = function(...) return HIGHLIGHT_COMPONENT_PREFIX .. concat({ ... }, "_") end

M.gen_component_separator_hl_name = function(...)
	return HIGHLIGHT_COMPONENT_SEPARATOR_PREFIX .. concat({ ... }, "_")
end

M.set_hl = function(group, hl_opts, fallback_bg)
	if not M.is_highlight_option(hl_opts) then return end
	local real_opts = vim.deepcopy(hl_opts)

	if real_opts.fg and not M.is_color(real_opts.fg) then
		real_opts.fg = M.get_hl_name_color(real_opts.fg).foreground
	end

	if real_opts.bg then
		real_opts.bg = M.is_color(real_opts.bg) and real_opts.bg
			or M.get_hl_name_color(real_opts.bg).background
	elseif fallback_bg then
		-- fallback to fallback_bg if provided
		real_opts.bg = M.is_color(fallback_bg) and fallback_bg or M.get_hl_name_color(fallback_bg).background
	else
		-- fallback to StatusLine background
		real_opts.bg = M.get_hl_name_color("StatusLine").background
	end
	pcall(api.nvim_set_hl, 0, group, real_opts)
end

M.set_hl_separator = function(index, fallback_bg)
	local statusline_color = M.is_color(fallback_bg) and fallback_bg
		or M.get_hl_name_color(fallback_bg).background
		or M.get_hl_name_color("StatusLine").background

	local fg = M.get_hl_name_color(M.gen_component_hl_name(index)).background or statusline_color

	pcall(api.nvim_set_hl, 0, M.gen_component_separator_hl_name(index), {
		fg = fg,
		bg = statusline_color,
	})
end

return M
