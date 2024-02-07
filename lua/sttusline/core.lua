local type = type
local next = next
local concat = table.concat
local pairs = pairs
local ipairs = ipairs
local require = require
local rep = string.rep
local floor = math.floor

local vim = vim
local api = vim.api
local opt = vim.opt
local uv = vim.uv or vim.loop
local defer_fn = vim.defer_fn
local schedule = vim.schedule
local autocmd = api.nvim_create_autocmd
local augroup = api.nvim_create_augroup
local highlight = require("sttusline.util.highlight")

local M = {}

local PLUG_NAME = "sttusline"
local COMP_DIR = "sttusline.components."

local is_hidden = false
local group_ids = {
	[PLUG_NAME] = augroup(PLUG_NAME, { clear = true }),
}
local timer_ids = {}
local statusline = {}
local components = {
	length = 0,
}

local cached = {
	name_index_maps = {},

	event_index_maps = {
		-- the key is the name of the default event
		nvim = {
			-- The number of the event that the component listen to
			length = 0,
			keys = {},
		},
		-- the key is the name of user defined event
		user = {
			-- The number of the event that the component listen to
			length = 0,
			keys = {},
		},
	},

	timer = {},
}

local update_groups = {
	CursorMoving = {
		members = {},
		opts = {
			event = { "CursorMoved", "CursorMovedI" },
			user_event = "VeryLazy",
		},
	},
	BufWinEnter = {
		members = {},
		opts = {
			event = { "BufEnter", "WinEnter" },
			user_event = "VeryLazy",
		},
	},
}

-- private
------------------------------
local function arr_contains(tbl, value)
	for _, v in ipairs(tbl) do
		if v == value then return true end
	end
	return false
end

local function merge_tb(to, from)
	if type(to) == "table" and type(from) == "table" then
		for k, v in pairs(from) do
			if to[1] == nil then -- to is a dict
				to[k] = merge_tb(to[k], v)
			else -- to is a list
				to[#to + 1] = v
			end
		end
	else
		to = from
	end
	return to
end

local function tbl_contains(tbl, value) return tbl[value] or arr_contains(tbl, value) end

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
					if should_hidden(configs.disabled) then
						is_hidden = true
					else
						is_hidden = false
						M.update_all_components(configs)
					end
					M.render()
				end, 20)
			end
		end,
	})

	autocmd({ "BufLeave", "WinLeave" }, {
		group = M.get_global_augroup(),
		callback = function() event_trigger = false end,
	})
end

local function cache_event(event, index, cache_key)
	local events_dict = cached.event_index_maps[cache_key]
	local indexes = events_dict[event]
	if indexes == nil then
		events_dict[event] = { index }
		events_dict.length = events_dict.length + 1
		events_dict.keys[events_dict.length] = event
	else
		indexes[#indexes + 1] = index
	end
end

local function handle_comp_events(comp, index, configs)
	local events = comp.event
	if type(events) == "table" then
		events.User = nil -- remove user defined events
		for k, e in pairs(events) do
			if type(k) == "number" then
				cache_event(e, index, "nvim")
			else
				-- k : event
				-- e : pattern
				autocmd(k, {
					pattern = e,
					group = M.get_global_augroup(),
					callback = function()
						M.update_comp_value(comp, index, configs)
						M.render()
					end,
				})
			end
		end
	elseif type(events) == "string" then
		cache_event(events, index, "nvim")
	end
end

local function handle_comp_user_events(comp, index, configs)
	local events = comp.user_event
	if type(events) == "table" then
		for _, e in ipairs(events) do
			cache_event(e, index, "user")
		end
	elseif type(events) == "string" then
		cache_event(events, index, "user")
	end
end

local function init_cached_autocmds(configs)
	local nvim_keys = cached.event_index_maps.nvim.keys
	local user_keys = cached.event_index_maps.user.keys
	if next(nvim_keys) then
		autocmd(nvim_keys, {
			group = M.get_global_augroup(),
			callback = function(e) M.run(configs, e.event) end,
		})
	end
	if next(user_keys) then
		autocmd("User", {
			pattern = user_keys,
			group = M.get_global_augroup(),
			callback = function(e) M.run(configs, e.match, true) end,
		})
	end
end

local function handle_comp_timing(comp, index, configs)
	if comp.timing == true then
		cached.timer[#cached.timer + 1] = index
	elseif type(comp.timing) == "number" then
		if timer_ids[index] == nil then timer_ids[index] = uv.new_timer() end

		timer_ids[index]:start(
			0,
			comp.timing,
			vim.schedule_wrap(function()
				M.update_comp_value(comp, index, configs)
				M.render()
			end)
		)
	end
end

local function init_cached_timers(configs)
	if next(cached.timer) then
		if timer_ids[PLUG_NAME] == nil then timer_ids[PLUG_NAME] = uv.new_timer() end
		timer_ids[PLUG_NAME]:start(0, 1000, vim.schedule_wrap(function() M.run(configs) end))
	end
end

local function call(func, ...) return type(func) == "function" and func(...) end

local function call_comp_func(func, comp)
	if type(func) == "function" then return func(comp.configs, comp.__state, comp, comp.__pos) end
end

local function update_all_pos_comp(comp, update_value)
	for _, pos in ipairs(comp.__pos) do
		statusline[pos] = update_value
	end
end

local function is_table_child_sep(sep)
	return type(sep) == "table" and (type(sep.value) == "string" or type(sep[1]) == "string")
end

local function get_sep_value(sep, hl_name_sep, left)
	if sep == nil then
		return ""
	elseif type(sep) == "string" then
		return highlight.add_hl_name(sep, hl_name_sep)
	elseif is_table_child_sep(sep) then
		return type(sep.colors) == "table"
				and next(sep.colors)
				and highlight.add_hl_name(sep.value or sep[1], hl_name_sep .. (left and "_left" or "_right"))
			or highlight.add_hl_name(sep.value or sep[1], hl_name_sep)
	end
	return ""
end

local function add_sep_with_hl_name(str, seps, hl_name_sep)
	if type(seps) ~= "table" or str == "" then return str end

	return get_sep_value(seps.left, hl_name_sep, true)
		.. str
		.. get_sep_value(seps.right, hl_name_sep, false)
end

local function add_padding(str, padding)
	if padding == nil then
		return " " .. str .. " "
	elseif type(padding) == "number" then
		if padding < 1 then return str end -- no padding
		local space = rep(" ", floor(padding))
		return space .. str .. space
	elseif type(padding) == "table" then
		local left = type(padding.left) == "number" and padding.left or 1
		local right = type(padding.right) == "number" and padding.right or 1
		local left_padding = left < 1 and "" or rep(" ", floor(left))
		local right_padding = right < 1 and "" or rep(" ", floor(right))
		return left_padding .. str .. right_padding
	end
	return str
end

local function add_padding_with_hl_name(str, padding, padding_hl_name)
	if padding == nil then
		local space = highlight.add_hl_name(" ", padding_hl_name)
		return space .. str .. space
	elseif type(padding) == "number" then
		if padding < 1 then return str end -- no padding
		local space = highlight.add_hl_name(rep(" ", floor(padding)), padding_hl_name)
		return space .. str .. space
	elseif type(padding) == "table" then
		local left = type(padding.left) == "number" and padding.left or 1
		local right = type(padding.right) == "number" and padding.right or 1
		local left_padding = left < 1 and "" or highlight.add_hl_name(rep(" ", floor(left)), padding_hl_name)

		local right_padding = right < 1 and ""
			or highlight.add_hl_name(rep(" ", floor(right)), padding_hl_name)

		return left_padding .. str .. right_padding
	end
	return str
end

local function handle_str_returned(update_value, comp)
	update_value = highlight.add_hl_name(add_padding(update_value, comp.padding), comp.__hl_name)

	if type(comp.separator) == "table" then
		return add_sep_with_hl_name(update_value, comp.separator, comp.__hl_name .. "_sep")
	end

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
				local colors = merge_tb(child.colors, merge_tb({}, comp.colors))
				if type(colors) == "table" then
					local hl_name_child = comp_hl_name .. "_child_" .. index
					values[#values + 1] = highlight.add_hl_name(child_value, hl_name_child)

					if child.update or not pcall(api.nvim_get_hl_by_name, hl_name_child, true) then
						highlight.hl(hl_name_child, colors)
					end
				else
					values[#values + 1] = highlight.add_hl_name(child_value, comp_hl_name)
				end
			end
		end
	end

	--handle the padding and separator
	local result = add_padding_with_hl_name(concat(values, ""), comp.padding, comp_hl_name)
	if type(comp.separator) == "table" then
		return add_sep_with_hl_name(result, comp.separator, comp_hl_name .. "_sep")
	end
	return result
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
	for index, comp in ipairs(components) do
		M.update_comp_value(comp, index, configs)
	end
end

M.get_global_augroup = function()
	return group_ids[PLUG_NAME]
		or (function()
			group_ids[PLUG_NAME] = augroup(PLUG_NAME, { clear = true })
			return group_ids[PLUG_NAME]
		end)()
end

M.iter = function(configs)
	local cached_len = components.length

	local comp_index = 0
	if cached_len > 0 then
		return function()
			comp_index = comp_index + 1
			if comp_index > cached_len then return end
			return comp_index, components[comp_index], components.__pos
		end
	else
		local config_components = configs.components

		local key, curr_comp = nil, nil

		local pos_in_statusline = 0

		local unique_comps = {}

		return function()
			comp_index = comp_index + 1

			key, curr_comp = next(config_components, key)

			while key do --still has components
				pos_in_statusline = pos_in_statusline + 1
				if type(curr_comp) ~= "table" then -- special component or path to component
					if curr_comp == "%=" then -- special component
						statusline[pos_in_statusline] = "%="
						goto continue
					elseif type(curr_comp) == "number" then -- special component
						statusline[pos_in_statusline] = rep(" ", floor(curr_comp))
						goto continue
					end

					local has_comp, default_comp = pcall(require, COMP_DIR .. tostring(curr_comp))
					curr_comp = has_comp and default_comp or nil
				elseif curr_comp[2] ~= nil then -- has custom config
					local has_comp, default_comp = pcall(require, COMP_DIR .. tostring(curr_comp[1]))
					curr_comp = has_comp and require("sttusline.config").merge_config(default_comp, curr_comp[2])
						or nil
				end

				if curr_comp then
					statusline[pos_in_statusline] = ""
					if not unique_comps[curr_comp] then
						unique_comps[curr_comp] = true
						curr_comp.__pos = { pos_in_statusline }

						components[comp_index] = curr_comp
						components.length = comp_index
						return comp_index, curr_comp, pos_in_statusline
					else
						curr_comp.__pos[#curr_comp.__pos + 1] = pos_in_statusline
					end
				end

				::continue::
				key, curr_comp = next(config_components, key)
			end
		end
	end
end

M.update_comp_value = function(comp, index, configs)
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

M.run = function(configs, event_name, is_user_event)
	if is_hidden then return end
	schedule(function()
		local event_dict = is_user_event and cached.event_index_maps.user or cached.event_index_maps.nvim
		local indexes = event_name and event_dict[event_name] or cached.timer

		---@diagnostic disable-next-line: param-type-mismatch
		for _, index in ipairs(indexes) do
			M.update_comp_value(components[index], index, configs)
		end

		M.render()
	end, 0)
end

M.hl_sep = function(comp)
	local separator = comp.separator
	if type(separator) == "table" then
		local sep_styles = {
			fg = highlight.get_hl(comp.__hl_name).background,
		}

		local sep_hl_name = comp.__hl_name .. "_sep"
		highlight.hl(sep_hl_name, sep_styles)

		if is_table_child_sep(separator.left) and type(separator.left.colors) == "table" then
			highlight.hl(
				sep_hl_name .. "_left",
				next(separator.left.colors) and separator.left.colors or sep_styles
			)
		end
		if is_table_child_sep(separator.left) and type(separator.right.colors) == "table" then
			highlight.hl(
				sep_hl_name .. "_right",
				next(separator.right.colors) and separator.right.colors or sep_styles
			)
		end
	end
end

M.highlight = function(comp, configs)
	highlight.hl(comp.__hl_name, comp.colors)

	if type(comp.separator) == "table" then M.hl_sep(comp) end

	call_comp_func(comp.on_highlight, comp)
end

M.setup = function(configs)
	local name_index_maps = cached.name_index_maps

	for index, comp, pos_in_statusline in M.iter(configs) do
		comp.__hl_name = highlight.is_hl_name(comp.colors) and comp.colors or PLUG_NAME .. "_" .. index

		if comp.name then name_index_maps[comp.name] = index end

		comp.__state = call(comp.init, comp.configs, comp, pos_in_statusline)

		if comp.lazy == false then M.update_comp_value(comp, index, configs) end

		handle_comp_events(comp, index, configs)
		handle_comp_user_events(comp, index, configs)
		handle_comp_timing(comp, index, configs)

		M.highlight(comp, configs)
	end

	init_cached_autocmds(configs)
	init_cached_timers(configs)

	auto_hidden(configs)
end

return M
