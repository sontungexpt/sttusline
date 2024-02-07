local M = {}

-- constants
local COMPONENT_PARENT_MODULE = "sttusline.components"
local AUTOCMD_CORE_GROUP = "STTUSLINE_CORE_EVENTS"
local AUTOCMD_COMPONENT_GROUP = "STTUSLINE_COMPONENT_EVENTS"

local vim = vim
local api = vim.api
local opt = vim.opt
local uv = vim.uv or vim.loop
local schedule = vim.schedule
local autocmd = api.nvim_create_autocmd
local augroup = api.nvim_create_augroup
local concat = table.concat
local pairs = pairs
local ipairs = ipairs
local next = next
local type = type
local require = require

-- module
local highlight = require("sttusline.highlight")
local set_hl = highlight.set_hl
local set_hl_separator = highlight.set_hl_separator
local gen_component_hl_name = highlight.gen_component_hl_name
local gen_component_separator_hl_name = highlight.gen_component_separator_hl_name
local add_highlight_name = highlight.add_highlight_name
local is_highlight_option = highlight.is_highlight_option
local is_highlight_name = highlight.is_highlight_name

-- local vars
local core_autocmd_group = nil
local component_autocmd_group = nil
local glob_timer = nil
local statusline_hidden = false

-- save the timer of the each component so that it can be reused
local comp_timers = {}
-- save the space of the each component so that it can be reused
local comp_spaces = {}

-- save the updating value of the component
local statusline = {}

-- save the valid component after the first time call M.foreach_component
local components = {}

local catalog = {
	event = {
		-- save the index of the component that update when the event trigger
		-- the value is the table of the indexs of the component that update when the event trigger
		-- example: { BufEnter = { 1, 2, 3 }, BufWritePre = { 1, 2, 3 } }

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

	-- save the index of the component that update when the timer trigger
	timer = {},
}

local update_groups = {
	CURSOR_MOVING = {
		members = {},
		opts = {
			event = { "CursorMoved", "CursorMovedI" },
			user_event = "VeryLazy",
		},
	},
	BUF_WIN_ENTER = {
		members = {},
		opts = {
			event = { "BufEnter", "WinEnter" },
			user_event = "VeryLazy",
		},
	},
}

M.create_update_group = function(group_name, opts)
	vim.validate { group_name = { group_name, "string" }, opts = { opts, "table" } }
	update_groups[group_name] = update_groups[group_name] or { members = {} }
	update_groups[group_name].opts = opts
	return group_name
end

M.get_component_autocmd_group = function()
	if component_autocmd_group == nil then
		component_autocmd_group = augroup(AUTOCMD_COMPONENT_GROUP, { clear = true })
	end
	return component_autocmd_group
end

M.get_core_autocmd_group = function()
	if core_autocmd_group == nil then
		core_autocmd_group = augroup(AUTOCMD_CORE_GROUP, { clear = true })
	end
	return core_autocmd_group
end

M.init_component_autocmds = function(opts)
	local nvim_keys = catalog.event.nvim.keys
	local user_keys = catalog.event.user.keys
	if next(nvim_keys) then
		autocmd(nvim_keys, {
			group = M.get_component_autocmd_group(),
			callback = function(e) M.run(opts, e.event) end,
		})
	end
	if next(user_keys) then
		autocmd("User", {
			pattern = user_keys,
			group = M.get_component_autocmd_group(),
			callback = function(e) M.run(opts, e.match, true) end,
		})
	end
end

M.update_statusline = function()
	local str_statusline = concat(statusline, "")
	opt.statusline = #str_statusline > 0 and str_statusline or " "
end

local eval_func = function(func, ...)
	if type(func) == "function" then return func(...) end
end

local eval_component_func = function(component, func_name, ...)
	local index = component.index
	if not comp_spaces[index] then
		if type(component.space) == "function" then
			comp_spaces[index] = component.space(component.configs, component, ...)
		elseif type(component.space) == "table" then
			comp_spaces[index] = component.space
		end
	end
	return eval_func(component[func_name], component.configs, comp_spaces[index], component, ...)
end

local is_sub_table_child = function(child) return type(child) == "table" and type(child[1]) == "string" end

local add_to_left_and_right = function(component, left, right)
	if type(component) == "string" then
		return left .. component .. right
	else -- component is a table
		local first_element = component[1]
		local last_element = component[#component]

		if type(first_element) == "string" then
			component[1] = left .. first_element
		elseif is_sub_table_child(first_element) then
			first_element[1] = left .. first_element[1]
		end

		if type(last_element) == "string" then
			component[#component] = last_element .. right
		elseif is_sub_table_child(last_element) then
			last_element[1] = last_element[1] .. right
		end
		return component
	end
end

M.add_component_separator = function(component, seps, index)
	if type(seps) ~= "table" or #component == 0 then return component end

	return add_to_left_and_right(
		component,
		type(seps.left) == "string" and add_highlight_name(seps.left, gen_component_separator_hl_name(index))
			or "",
		type(seps.right) == "string"
				and add_highlight_name(seps.right, gen_component_separator_hl_name(index))
			or ""
	)
end

-- this function will add padding to the updating value of the component
M.add_component_padding = function(component, nums)
	if #component == 0 then return component end

	local left_padding = " " -- default left padding is 1 space
	local right_padding = " " -- default right padding is 1 space

	if type(nums) == "number" then
		if nums < 1 then return component end -- no padding
		left_padding = (" "):rep(math.floor(nums))
		right_padding = left_padding
	elseif type(nums) == "table" then
		local left = type(nums.left) == "number" and nums.left or 1
		local right = type(nums.right) == "number" and nums.right or 1
		left_padding = left < 1 and "" or (" "):rep(math.floor(left))
		right_padding = right < 1 and "" or (" "):rep(math.floor(right))
	end

	return add_to_left_and_right(component, left_padding, right_padding)
end

local tbl_contains = function(tbl, item)
	if type(tbl) ~= "table" then return false end
	for _, value in ipairs(tbl) do
		if value == item then return true end
	end
	return false
end

M.should_statusline_hidden = function(disabled_list)
	return tbl_contains(disabled_list.filetypes, api.nvim_buf_get_option(0, "filetype"))
		or tbl_contains(disabled_list.buftypes, api.nvim_buf_get_option(0, "buftype"))
end

M.disable_for_filetype = function(opts)
	local event_trigger = false
	autocmd({ "BufEnter", "WinEnter" }, {
		group = M.get_core_autocmd_group(),
		callback = function()
			if not event_trigger then
				event_trigger = true
				schedule(function()
					if M.should_statusline_hidden(opts.disabled) then
						M.hide_statusline()
					else
						M.restore_statusline(opts)
					end
				end, 0)
			end
		end,
	})
	autocmd({ "BufLeave", "WinLeave" }, {
		group = M.get_core_autocmd_group(),
		callback = function() event_trigger = false end,
	})
end

M.hide_statusline = function()
	if not statusline_hidden then
		statusline_hidden = true
		schedule(function() opt.statusline = " " end, 0)
	end
end

M.restore_statusline = function(opts)
	if statusline_hidden then
		statusline_hidden = false
		M.update_all_components(opts)
		M.update_statusline()
	end
end

M.foreach_component = function(opts, comp_cb, empty_comp_cb)
	local component_count = #components
	if component_count > 0 then
		for index = 1, component_count do
			local component = components[index]
			if type(component) == "string" then
				eval_func(empty_comp_cb, component, index)
			else
				comp_cb(component, index)
			end
		end
	else
		local track_real_component = function(component)
			component_count = component_count + 1
			component.index = component_count
			components[component_count] = component
			comp_cb(component, component_count)
		end

		local load_and_track_default_component = function(component, overrides)
			if type(component) ~= "string" then return false end

			if component == "%=" then
				component_count = component_count + 1
				components[component_count] = component
				eval_func(empty_comp_cb, component, component_count)
			else
				local status_ok, real_comp = pcall(require, COMPONENT_PARENT_MODULE .. "." .. component)
				if status_ok then
					if type(overrides) == "table" then
						real_comp = vim.tbl_deep_extend("force", real_comp, overrides)
					end
					track_real_component(real_comp)
				else
					require("sttusline.utils.notify").error("Failed to load component: " .. component)
					return false
				end
			end
			return true
		end

		for _, component in ipairs(opts.components) do
			if type(component) == "table" then
				if not load_and_track_default_component(component[1], component[2]) then
					track_real_component(component)
				end
			else
				load_and_track_default_component(component)
			end
		end
	end
end

M.start_timer = function(opts)
	if glob_timer == nil then glob_timer = uv.new_timer() end
	glob_timer:start(0, 1000, vim.schedule_wrap(function() M.run(opts) end))
end

M.start_sub_timer = function(opts, component, index, timing)
	if comp_timers[index] == nil then comp_timers[index] = uv.new_timer() end
	comp_timers[index]:start(
		0,
		timing,
		vim.schedule_wrap(function()
			if statusline_hidden then return end
			if type(index) == "table" then
				for _, i in ipairs(index) do
					M.update_component_value(opts, components[i], i)
				end
			else
				M.update_component_value(opts, component, index)
			end
			M.update_statusline()
		end)
	)
end

M.index_timer_catalog_or_start_sub_timer = function(opts, component, index)
	if component.timing == true then
		catalog.timer[#catalog.timer + 1] = index
	elseif type(component.timing) == "number" then
		M.start_sub_timer(opts, component, index, component.timing)
	end
end

M.init_global_timer = function(opts)
	if next(catalog.timer) then M.start_timer(opts) end
end

M.highlight_component = function(opts, component, index)
	local colors = component.colors
	local statusline_color = opts.statusline_color

	-- had colors
	if type(colors) == "table" then
		if colors[1] == nil then
			set_hl(gen_component_hl_name(index), colors, statusline_color)
		else
			for k, color in ipairs(colors) do
				set_hl(gen_component_hl_name(index, k), color, statusline_color)
			end
		end
	end

	-- had separator
	if type(component.separator) == "table" then set_hl_separator(index, statusline_color) end

	eval_component_func(component, "on_highlight")
end

M.highlight_all_components = function(opts)
	M.foreach_component(opts, function(component, index) M.highlight_component(opts, component, index) end)
end

M.refresh_highlight_on_colorscheme = function(opts)
	autocmd("ColorScheme", {
		group = M.get_core_autocmd_group(),
		callback = function() M.highlight_all_components(opts) end,
	})
end

M.update_component_value = function(opts, component, index)
	local should_display = eval_component_func(component, "condition")
	if should_display == false then
		statusline[index] = ""
		return
	end

	local updating_value = eval_component_func(component, "update")
	-- updating_value is string or table
	-- If updating_value is table, then it must be a table of string or table of {string, table (highlight_option)}
	-- Example:
	-- table of string: { "filename", "filetype_icon" }
	-- table of {string, table}: { { "filename", { fg="", bg="" } }, { "filetype_icon", { fg="", bg="" }} }
	-- table of {string, nil}: { { "filename" }, { "filetype_icon" } }

	local colors = component.colors
	if type(updating_value) == "string" then
		updating_value = M.add_component_padding(updating_value, component.padding)
		if is_highlight_option(colors) then
			-- if assign colors to component, then add highlight name to component
			statusline[index] = add_highlight_name(updating_value, gen_component_hl_name(index))
		elseif is_highlight_name(colors) then
			-- if assign the highlight name to component, then add that highlight name to component
			statusline[index] = add_highlight_name(updating_value, colors)
		else
			-- if not assign colors to component, then not need to add highlight name
			statusline[index] = updating_value
		end

		statusline[index] = M.add_component_separator(statusline[index], component.separator, index)
	elseif type(updating_value) == "table" then
		updating_value = M.add_component_padding(updating_value, component.padding)
		for k, child in ipairs(updating_value) do
			if type(child) == "string" then
				-- "filename"
				if type(colors) == "table" then -- is assigned colors to component
					if is_highlight_option(colors[k]) then
						updating_value[k] = add_highlight_name(child, gen_component_hl_name(index, k))
					elseif is_highlight_name(colors[k]) then
						updating_value[k] = add_highlight_name(child, colors[k])
					end
				else
					updating_value[k] = child
				end
			elseif is_sub_table_child(child) then
				if is_highlight_option(child[2]) then
					-- { "filename", { fg="", bg="" }}
					component.colors = colors or {}
					component.colors[k] = child[2]

					local component_hl_name = gen_component_hl_name(index, k)
					updating_value[k] = add_highlight_name(child[1], component_hl_name)
					set_hl(component_hl_name, child[2], opts.statusline_color)

					eval_component_func(component, "on_highlight")
				elseif is_highlight_name(child[2]) then
					-- { "filename", "HIGHLIGHT_NAME" }
					updating_value[k] = add_highlight_name(child[1], child[2])
				else
					-- {"filename"}
					updating_value[k] = child[1]
				end
			else
				statusline[index] = ""
				require("sttusline.utils.notify").error(
					string.format(
						"component %s update() must return string or table of string or table of {string, table}",
						type(component) == "string" and component or component.name or ""
					)
				)
				return
			end
		end
		statusline[index] = M.add_component_separator(concat(updating_value, ""), component.separator, index)
	else
		statusline[index] = ""
		require("sttusline.utils.notify").error(
			string.format(
				"component %s update() must return string or table of string or table of {string, table}",
				type(component) == "string" and component or component.name or ""
			)
		)
	end
end

M.update_all_components = function(opts)
	M.foreach_component(
		opts,
		function(component, index) M.update_component_value(opts, component, index) end
	)
end

M.update_on_trigger = function(opts, update_indexs)
	for _, index in ipairs(update_indexs) do
		if type(index) == "table" then
			for _, i in ipairs(index) do
				M.update_component_value(opts, components[i], i)
			end
		else
			M.update_component_value(opts, components[index], index)
		end
	end
end

M.run = function(opts, event_name, is_user_event)
	if statusline_hidden then return end
	schedule(function()
		local event_table = is_user_event and catalog.event.user or catalog.event.nvim
		M.update_on_trigger(opts, event_name and event_table[event_name] or catalog.timer)
		M.update_statusline()
	end, 0)
end

local add_event_index_entry = function(event, index, cache_key)
	local event_table = catalog.event[cache_key]
	local catalog_event = event_table[event]
	if catalog_event == nil then
		event_table[event] = { index }
		event_table.length = (event_table.length or 0) + 1
		event_table.keys[event_table.length] = event
	else
		catalog_event[#catalog_event + 1] = index
	end
end

M.index_event_catalog = function(event, index, cache_key)
	if type(event) == "string" then
		add_event_index_entry(event, index, cache_key)
	elseif type(event) == "table" then
		for _, e in ipairs(event) do
			add_event_index_entry(e, index, cache_key)
		end
	end
end

M.init = function(opts)
	M.foreach_component(opts, function(component, index)
		eval_component_func(component, "init")
		if component.lazy == false then
			M.update_component_value(opts, component, index)
		else
			statusline[index] = ""
		end

		local update_group = update_groups[component.update_group]
		if type(update_group) == "table" then
			update_group.members[#update_group.members + 1] = index
		else
			M.index_event_catalog(component.event, index, "nvim")
			M.index_event_catalog(component.user_event, index, "user")
			M.index_timer_catalog_or_start_sub_timer(opts, component, index)
		end
		M.highlight_component(opts, component, index)
	end, function(empty_comp, index) statusline[index] = empty_comp end)

	for _, group in pairs(update_groups) do
		local members = group.members
		if #members > 0 then
			local group_opts = group.opts
			M.index_event_catalog(group_opts.event, members, "nvim")
			M.index_event_catalog(group_opts.user_event, members, "user")
			M.index_timer_catalog_or_start_sub_timer(opts, group_opts, members)
		end
	end

	M.init_component_autocmds(opts)
	M.init_global_timer(opts)
end

M.setup = function(opts)
	M.init(opts)
	M.update_statusline()
	M.refresh_highlight_on_colorscheme(opts)
	M.disable_for_filetype(opts)
end

return M
