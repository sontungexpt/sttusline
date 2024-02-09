local type = type
local next = next
local concat = table.concat
local ipairs = ipairs
local require = require
local rep = string.rep
local floor = math.floor

local vim = vim
local api = vim.api
local opt = vim.opt
local uv = vim.uv or vim.loop
local schedule = vim.schedule
local autocmd = api.nvim_create_autocmd
local augroup = api.nvim_create_augroup

local highlight = require("sttusline.util.highlight")
local config = require("sttusline.config")

local M = {}

local PLUG_NAME = "sttusline"
local COMP_DIR = "sttusline.components."

local is_hidden = false
local group_ids = {
	[PLUG_NAME] = augroup(PLUG_NAME, { clear = true }),
}
local timer_ids = {}
local statusline = {}
local components = {}

local cache = {
	name_index_maps = {},

	events = {
		-- the key is the name of the default event
		nvim = {
			keys_len = 0,
			keys = {},
		},
		-- the key is the name of user defined event
		user = {
			keys_len = 0,
			keys = {},
		},
	},

	timer = {},
}

-- private
------------------------------
local function call(func, ...) return type(func) == "function" and func(...) end

local function call_comp_func(func, comp)
	if type(func) == "function" then return func(comp.configs, comp.__state, comp, comp.__pos) end
end

local function tbl_contains(tbl, value)
	return tbl[value] or require("sttusline.util").arr_contains(tbl, value)
end

local function should_hidden(excluded, bufnr)
	return tbl_contains(excluded.filetypes, api.nvim_buf_get_option(bufnr or 0, "filetype"))
		or tbl_contains(excluded.buftypes, api.nvim_buf_get_option(bufnr or 0, "buftype"))
end

local auto_hidden = function(configs)
	local event_trigger = false
	autocmd({ "BufEnter", "WinEnter" }, {
		group = M.get_global_augroup(),
		callback = function()
			if not event_trigger then
				event_trigger = true
				schedule(function()
					if should_hidden(configs.disabled) then is_hidden = true end
					M.render()
				end, 20)
			end
		end,
	})

	autocmd({ "BufLeave", "WinLeave" }, {
		group = M.get_global_augroup(),
		callback = function()
			event_trigger = false
			if is_hidden then
				is_hidden = false
				M.update_all_components(configs)
			end
		end,
	})
end

local function cache_event(event, index, cache_key)
	local events_dict = cache.events[cache_key]
	local indexes = events_dict[event]
	if indexes == nil then
		events_dict[event] = { index }
		events_dict.keys_len = events_dict.keys_len + 1
		events_dict.keys[events_dict.keys_len] = event
	else
		indexes[#indexes + 1] = index
	end
end

local function handle_comp_events(comp, index)
	local nvim_event = comp.event
	if type(nvim_event) == "table" then
		for _, e in ipairs(nvim_event) do
			cache_event(e, index, "nvim")
		end
	elseif type(nvim_event) == "string" then
		cache_event(nvim_event, index, "nvim")
	end

	local user_event = comp.user_event
	if type(user_event) == "string" then
		cache_event(user_event, index, "user")
	elseif type(user_event) == "table" then
		for _, e in ipairs(user_event) do
			cache_event(e, index, "user")
		end
	end
end

local function init_cached_autocmds(configs)
	local nvim_keys = cache.events.nvim.keys
	local user_keys = cache.events.user.keys

	if next(nvim_keys) then
		autocmd(nvim_keys, {
			group = M.get_global_augroup(),
			callback = function(e) M.run(e.event) end,
		})
	end
	if next(user_keys) then
		autocmd("User", {
			pattern = user_keys,
			group = M.get_global_augroup(),
			callback = function(e) M.run(e.match, true) end,
		})
	end
end

local function handle_comp_highlight(comp, index)
	comp.__hl_name = PLUG_NAME .. "_" .. index
	highlight.hl(comp.__hl_name, comp.colors)

	if type(comp.separator) == "table" then
		local separator = comp.separator

		if type(separator) == "table" then -- has separator
			comp.__hl_name_sep = comp.__hl_name .. "_sep"
			comp.__hl_name_sep_left = comp.__hl_name_sep .. "_left"
			comp.__hl_name_sep_right = comp.__hl_name_sep .. "_right"

			local sep_styles = {
				fg = highlight.get_hl(comp.__hl_name).background,
			}

			highlight.hl(comp.__hl_name_sep, sep_styles)
			highlight.hl(comp.__hl_name_sep_left, separator.colors_left or comp.__hl_name_sep)
			highlight.hl(comp.__hl_name_sep_right, separator.colors_right or comp.__hl_name_sep)
		end
	end
end

local function handle_comp_timing(comp, index)
	if comp.timing == true then
		cache.timer[#cache.timer + 1] = index
	elseif type(comp.timing) == "number" then
		if timer_ids[index] == nil then timer_ids[index] = uv.new_timer() end
		timer_ids[index]:start(
			0,
			comp.timing,
			vim.schedule_wrap(function()
				M.update_comp_value(index)
				M.render()
			end)
		)
	end
end

local function init_cached_timers(configs)
	if next(cache.timer) then
		if timer_ids[PLUG_NAME] == nil then timer_ids[PLUG_NAME] = uv.new_timer() end
		timer_ids[PLUG_NAME]:start(0, 1000, vim.schedule_wrap(M.run))
	end
end

local function update_all_pos_comp(comp, update_value)
	for _, pos in ipairs(comp.__pos) do
		statusline[pos] = update_value
	end
end

local function add_separator(update_value, comp)
	local seps = comp.separator
	if type(seps) ~= "table" then
		return update_value
	elseif update_value == "" then
		return update_value
	end

	if type(seps.left) == "string" then
		update_value = highlight.add_hl_name(seps.left, comp.__hl_name_sep_left) .. update_value
	end
	if type(seps.right) == "string" then
		update_value = update_value .. highlight.add_hl_name(seps.right, comp.__hl_name_sep_right)
	end

	return update_value
end

local function add_padding(update_value, comp, padding_hl_name, default)
	local padding = comp.padding or default or 1

	local left_padding = ""
	local right_padding = ""

	if type(padding) == "number" then
		if padding < 1 then
			return update_value
		elseif type(padding_hl_name) == "string" then
			left_padding = highlight.add_hl_name(rep(" ", floor(padding)), padding_hl_name)
		else
			left_padding = rep(" ", floor(padding))
		end
		right_padding = left_padding
	elseif type(padding) == "table" then
		left_padding = type(padding.left) == "number" and rep(" ", floor(padding.left)) or ""
		right_padding = type(padding.right) == "number" and rep(" ", floor(padding.right)) or ""
		if type(padding_hl_name) == "string" then
			left_padding = highlight.add_hl_name(left_padding, padding_hl_name)
			right_padding = highlight.add_hl_name(right_padding, padding_hl_name)
		end
	end

	if type(update_value) == "string" and update_value ~= "" then
		return left_padding .. update_value .. right_padding
	elseif type(update_value) == "table" and next(update_value) then
		if left_padding ~= "" then table.insert(update_value, 1, left_padding) end
		if right_padding ~= "" then update_value[#update_value + 1] = right_padding end
	end
	return update_value
end

local function handle_str_returned(update_value, comp)
	update_value = highlight.add_hl_name(add_padding(update_value, comp, nil, 1), comp.__hl_name)
	if type(comp.separator) == "table" then return add_separator(update_value, comp) end
	return update_value
end

local function handle_table_returned(update_value, comp)
	local values = {}

	local comp_hl_name = comp.__hl_name

	-- handle the child of the returned table
	for index, child in ipairs(update_value) do
		if type(child) == "string" then
			values[#values + 1] = highlight.add_hl_name(child, comp_hl_name)
		elseif type(child) == "table" and (type(child.value) == "string" or type(child[1]) == "string") then
			local child_value = child.value or child[1]
			if child_value then
				local colors = config.merge_config_noforce(child.colors, comp.colors)

				local hl_name_child = comp_hl_name .. "_" .. index
				values[#values + 1] =
					highlight.add_hl_name(add_padding(child_value, child, nil, 0), hl_name_child)

				if child.hl_update then highlight.hl(hl_name_child, colors, true) end
			end
		end
	end

	values = add_padding(values, comp, comp_hl_name)

	if type(comp.separator) == "table" then return add_separator(concat(values, ""), comp) end
	return concat(values, "")
end

-- public
------------------------------
M.render = function()
	if is_hidden then
		opt.statusline = " "
	else
		local str_statusline = concat(statusline)
		opt.statusline = str_statusline ~= "" and str_statusline or " "
	end
end

M.update_all_components = function(configs)
	for index, _ in ipairs(components) do
		M.update_comp_value(index)
	end
end

M.get_global_augroup = function()
	return group_ids[PLUG_NAME]
		or (function()
			group_ids[PLUG_NAME] = augroup(PLUG_NAME, { clear = true })
			return group_ids[PLUG_NAME]
		end)()
end

M.update_comp_value = function(index)
	local comp = components[index]
	handle_comp_highlight(comp, index)

	local should_display = call_comp_func(comp.condition, comp)

	if should_display == false then
		update_all_pos_comp(comp, "")
		return
	end

	local update_value = call_comp_func(comp.update, comp)

	if type(update_value) == "string" then
		update_all_pos_comp(comp, handle_str_returned(update_value, comp))
	elseif type(update_value) == "table" then
		update_all_pos_comp(comp, handle_table_returned(update_value, comp))
	else
		require("sttusline.util.notify").error(
			string.format(
				"component %s update() must return string or table of string or table of {string, table}",
				type(comp) == "string" and comp or comp.name or ""
			)
		)
	end
end

M.run = function(event_name, is_user_event)
	if is_hidden then return end
	schedule(function()
		local event_dict = is_user_event and cache.events.user or cache.events.nvim
		local indexes = event_name and event_dict[event_name] or cache.timer

		---@diagnostic disable-next-line: param-type-mismatch
		for _, index in ipairs(indexes) do
			M.update_comp_value(index)
		end

		M.render()
	end, 0)
end

M.load_comps = function(configs, cb)
	local pos_in_line = 1
	local comp_index = 1
	local unique_comps = {}
	local curr_comp = nil

	for _, comp in ipairs(configs.components) do
		if type(comp) == "table" then
			curr_comp = comp
			if type(comp[2]) == "table" then -- has custom config
				local has_comp, default_comp = pcall(require, COMP_DIR .. tostring(comp[1]))
				curr_comp = has_comp and config.merge_config_force(default_comp, comp[2]) or nil
			end
		elseif type(comp) == "string" then -- special component
			if comp == "%=" then
				statusline[pos_in_line] = "%="
				pos_in_line = pos_in_line + 1
			else
				local has_comp, default_comp = pcall(require, COMP_DIR .. tostring(curr_comp))
				curr_comp = has_comp and default_comp or nil
			end
		elseif type(comp) == "number" then -- special component
			statusline[pos_in_line] = rep(" ", floor(comp))
			pos_in_line = pos_in_line + 1
		end

		if curr_comp then
			statusline[pos_in_line] = ""
			if not unique_comps[curr_comp] then
				unique_comps[curr_comp] = true
				curr_comp.__pos = { pos_in_line }
				comp_index = comp_index + 1
				components[comp_index] = curr_comp
				cb(comp_index, curr_comp, pos_in_line)
			else
				curr_comp.__pos[#curr_comp.__pos + 1] = pos_in_line
			end
			pos_in_line = pos_in_line + 1
		end
	end
end

M.setup = function(configs)
	local name_index_maps = cache.name_index_maps
	M.load_comps(configs, function(index, comp, pos_in_statusline)
		if comp.name then name_index_maps[comp.name] = index end

		comp.__state = call(comp.init, comp.configs, comp, pos_in_statusline)

		if comp.lazy == false then M.update_comp_value(index) end

		handle_comp_events(comp, index)
		handle_comp_timing(comp, index)
	end)

	init_cached_autocmds(configs)
	init_cached_timers(configs)

	auto_hidden(configs)
end

return M
