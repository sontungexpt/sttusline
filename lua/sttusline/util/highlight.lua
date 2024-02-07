local api = vim.api
local hl = api.nvim_set_hl
local get_hl = api.nvim_get_hl
local get_hl_by_name = api.nvim_get_hl_by_name
local is_color = api.nvim_get_color_by_name

local type = type

local ns = api.nvim_create_namespace("sttusline")
api.nvim_set_hl_ns(ns)

local M = {}

M.get_ns_id = function()
	return ns
		or (function()
			ns = api.nvim_create_namespace("sttusline")
			api.nvim_set_hl_ns(ns)
			return ns
		end)()
end

-- highlight
M.add_hl_name = function(str, hl_name) return str ~= "" and "%#" .. hl_name .. "#" .. str .. "%*" or str end

M.is_hl_name = function(hl_name) return type(hl_name) == "string" and hl_name ~= "" end

M.is_hl_styles = function(hl_styles) return type(hl_styles) == "table" and next(hl_styles) ~= nil end

M.concat_str = function(sep, ...) return table.concat({ ... }, sep) end

M.get_hl = function(hl_name)
	local ok, styles = pcall(get_hl_by_name, hl_name, true)
	return ok and styles or {}
end

M.hl = function(group_name, hl_styles)
	if group_name == "" then return end

	if type(hl_styles) == "string" then
		pcall(hl, 0, group_name, {
			link = hl_styles,
		})
		return
	elseif type(hl_styles) == "table" and next(hl_styles) then
		if type(hl_styles.fg) == "string" and hl_styles.fg ~= "NONE" and is_color(hl_styles.fg) == -1 then
			hl_styles.fg = M.get_hl(hl_styles.fg).foreground
		end

		if type(hl_styles.bg) == "string" and hl_styles.bg ~= "NONE" and is_color(hl_styles.bg) == -1 then
			-- set the background color to the color of the hl group
			hl_styles.bg = M.get_hl(hl_styles.bg).background
		elseif hl_styles.bg == nil then
			hl_styles.bg = M.get_hl("Statusline").background
		end

		pcall(hl, 0, group_name, hl_styles)
	end
end

return M
