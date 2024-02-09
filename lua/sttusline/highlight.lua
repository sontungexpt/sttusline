local api = vim.api
local hl = api.nvim_set_hl
local get_hl_by_name = api.nvim_get_hl_by_name
local is_color = api.nvim_get_color_by_name
local config = require("sttusline.config")

local type = type

local M = {}
local cache = {}

M.get_cache = function() return cache end

M.add_hl_name = function(str, hl_name) return str ~= "" and "%#" .. hl_name .. "#" .. str .. "%*" or str end

M.is_hl_group_name = function(hl_name) return type(hl_name) == "string" and hl_name ~= "" end

M.is_hl_styles = function(hl_styles) return type(hl_styles) == "table" and next(hl_styles) end

M.get_hl = function(hl_name)
	local ok, styles = pcall(get_hl_by_name, hl_name, true)
	return ok and styles or {}
end

M.hl = function(group_name, hl_styles, force)
	if group_name ~= "" and (not cache[group_name] or force) then
		if type(hl_styles) == "string" then
			if pcall(hl, 0, group_name, {
				link = hl_styles,
			}) then cache[group_name] = hl_styles end
			return
		elseif type(hl_styles) == "table" and next(hl_styles) then
			cache[group_name] = hl_styles

			local styles = config.merge_config({}, hl_styles)
			styles.foreground = styles.fg
			styles.background = styles.bg
			styles.fg = nil
			styles.bg = nil

			if
				type(styles.foreground) == "string"
				and styles.foreground ~= "NONE"
				and is_color(styles.foreground) == -1
			then
				styles.foreground = M.get_hl(styles.foreground).foreground
			end

			if
				type(styles.background) == "string"
				and styles.background ~= "NONE"
				and is_color(styles.background) == -1
			then
				styles.background = M.get_hl(hl_styles.bg).background
			end

			if styles.background == nil then styles.background = M.get_hl("StatusLine").background end

			if not pcall(hl, 0, group_name, styles) then cache[group_name] = nil end
		end
	end
end

M.colorscheme = function()
	for hl_name, hl_styles in pairs(cache) do
		M.hl(hl_name, hl_styles, true)
	end
end

return M
