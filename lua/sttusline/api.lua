local M = {}

-- constants
local COMPONENT_PARENT_MODULE = "sttusline.components"
local AUTOCMD_CORE_GROUP = "STTUSLINE_CORE_EVENTS"
local AUTOCMD_COMPONENT_GROUP = "STTUSLINE_COMPONENT_EVENTS"

local api = vim.api
local opt = vim.opt
local autocmd = api.nvim_create_autocmd
local augroup = api.nvim_create_augroup

-- module
local highlight = require("sttusline.highlight")
-- local NestedTable = require("sttusline.utils.NestedTable")

-- local vars
local core_autocmd_group = nil
local component_autocmd_group = nil
local timer = nil
local statusline_hidden = false

local statusline = {}
-- save the valid component after the first time call M.foreach_component
local components = {}

local catalog = {
	event = {
		-- save the index of the component that update when the event trigger
		-- the value is the table of the indexs of the component that update when the event trigger
		-- example: { BufEnter = { 1, 2, 3 }, BufWritePre = { 1, 2, 3 } }

		-- the key is the name of the default event
		nvim = {},
		-- the key is the name of user defined event
		user = {},
	},

	-- save the index of the component that update when the timer trigger
	timer = {},
}

local update_groups = {
	CURSOR_MOVING = {
		childs = {
			-- the index of the component belong to the group
		},
		value = {
			event = { "CursorMoved", "CursorMovedI" },
			user_event = { "VeryLazy" },
			timing = false,
		},
	},
}

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

M.update_statusline = function()
	local str_statusline = table.concat(statusline, "")
	opt.statusline = #str_statusline > 0 and str_statusline or " "
end

M.eval_func = function(func, ...)
	if type(func) == "function" then return func(...) end
end

M.eval_component_func = function(component, func_name, ...)
	local configs = type(component.configs) == "table" and component.configs or {}
	local space = nil

	if type(component.space) == "function" then
		space = component.space(configs)
	elseif type(component.space) == "table" then
		space = component.space
	end

	return M.eval_func(component[func_name], configs, space, ...)
end

M.is_sub_table_child = function(child) return type(child) == "table" and type(child[1]) == "string" end

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

	if type(component) == "string" then
		return left_padding .. component .. right_padding
	else -- component is a table
		local first_element = component[1]
		local last_element = component[#component]

		if type(first_element) == "string" then
			component[1] = left_padding .. first_element
		elseif M.is_sub_table_child(first_element) then
			first_element[1] = left_padding .. first_element[1]
		end

		if type(last_element) == "string" then
			component[#component] = last_element .. right_padding
		elseif M.is_sub_table_child(last_element) then
			last_element[1] = last_element[1] .. right_padding
		end
		return component
	end
end

M.tbl_contains = function(tbl, item)
	if type(tbl) ~= "table" then return false end
	for _, value in ipairs(tbl) do
		if value == item then return true end
	end
	return false
end

M.is_in_disabled_opts = function(opts)
	return M.tbl_contains(opts.disabled.filetypes, api.nvim_buf_get_option(0, "filetype"))
		or M.tbl_contains(opts.disabled.buftypes, api.nvim_buf_get_option(0, "buftype"))
end

M.disable_for_filetype = function(opts)
	local event_trigger = false
	autocmd({ "BufEnter", "WinEnter" }, {
		group = M.get_core_autocmd_group(),
		callback = function()
			if not event_trigger then
				event_trigger = true
				vim.schedule(function()
					if M.is_in_disabled_opts(opts) then
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
		vim.schedule(function() opt.statusline = " " end, 0)
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
	if #components > 0 then
		for index, component in ipairs(components) do
			if type(component) == "string" then
				M.eval_func(empty_comp_cb, component, index)
			else
				comp_cb(component, index)
			end
		end
	else
		local index = 0

		local cache_and_eval_comp_cb = function(component, callback)
			index = index + 1
			components[index] = component
			M.eval_func(callback, component, index)
		end

		local load_default_component = function(component_name, overrides)
			local status_ok, real_comp = pcall(require, COMPONENT_PARENT_MODULE .. "." .. component_name)
			if status_ok then
				if type(overrides) == "table" then
					real_comp = vim.tbl_deep_extend("force", real_comp, overrides)
				end
				cache_and_eval_comp_cb(real_comp, comp_cb)
			else
				require("sttusline.utils.notify").error("Failed to load component: " .. component_name)
			end
		end

		for _, component in ipairs(opts.components) do
			if type(component) == "string" then
				if component == "%=" then -- empty component
					cache_and_eval_comp_cb(component, empty_comp_cb)
				else -- default component name
					load_default_component(component)
				end
			elseif type(component) == "table" and next(component) then
				if type(component[1]) == "string" then -- default component name
					load_default_component(component[1], component[2])
				else -- custom component
					cache_and_eval_comp_cb(component, comp_cb)
				end
			end
		end
	end
end

M.start_timer = function(opts)
	if timer == nil then timer = vim.loop.new_timer() end
	timer:start(
		1000,
		1000,
		vim.schedule_wrap(function()
			if not statusline_hidden then M.run(opts) end
		end)
	)
end

M.init_component_timer = function(opts)
	if #catalog.timer > 0 then M.start_timer(opts) end
end

M.set_component_highlight = function(opts, component, index)
	local colors = component.colors
	if type(colors) == "table" then
		if colors[1] == nil then
			highlight.set_hl(highlight.gen_component_hl_name(index), colors, opts.statusline_color)
		else
			for k, color in ipairs(colors) do
				highlight.set_hl(highlight.gen_component_hl_name(index, k), color, opts.statusline_color)
			end
		end
	end
	M.eval_component_func(component, "on_highlight")
end

M.set_all_component_highlight = function(opts)
	M.foreach_component(
		opts,
		function(component, index) M.set_component_highlight(opts, component, index) end
	)
end

M.refresh_highlight_on_colorscheme = function(opts)
	autocmd("ColorScheme", {
		group = M.get_core_autocmd_group(),
		callback = function() M.set_all_component_highlight(opts) end,
	})
end

M.update_component_value = function(opts, component, index)
	local should_display = M.eval_component_func(component, "condition")
	if type(should_display) == "boolean" and not should_display then
		statusline[index] = ""
		return
	end

	local updating_value = M.eval_component_func(component, "update")
	-- updating_value is string or table
	-- If updating_value is table, then it must be a table of string or table of {string, table (highlight_option)}
	-- Example:
	-- table of string: { "filename", "filetype_icon" }
	-- table of {string, table}: { {"filename", { fg="", bg="" }}, {"filetype_icon", { fg="", bg="" }} }
	-- table of {string, nil}: { { "filename" }, { "filetype_icon" } }

	local colors = component.colors
	if type(updating_value) == "string" then
		updating_value = M.add_component_padding(updating_value, component.padding)
		if highlight.is_highlight_option(colors) then
			-- if assign colors to component, then add highlight name to component
			statusline[index] =
				highlight.add_highlight_name(updating_value, highlight.gen_component_hl_name(index))
		elseif highlight.is_highlight_name(colors) then
			-- if assign the highlight name to component, then add that highlight name to component
			statusline[index] = highlight.add_highlight_name(updating_value, colors)
		else
			-- if not assign colors to component, then not need to add highlight name
			statusline[index] = updating_value
		end
	elseif type(updating_value) == "table" then
		updating_value = M.add_component_padding(updating_value, component.padding)
		for k, child in ipairs(updating_value) do
			if type(child) == "string" then
				-- "filename"
				if type(colors) == "table" then -- is assigned colors to component
					if highlight.is_highlight_option(colors[k]) then
						updating_value[k] =
							highlight.add_highlight_name(child, highlight.gen_component_hl_name(index, k))
					elseif highlight.is_highlight_name(colors[k]) then
						updating_value[k] = highlight.add_highlight_name(child, colors[k])
					end
				else
					updating_value[k] = child
				end
			elseif M.is_sub_table_child(child) then
				if highlight.is_highlight_option(child[2]) then
					-- { "filename", { fg="", bg="" }}
					component.colors = colors or {}
					component.colors[k] = child[2]

					local component_hl_name = highlight.gen_component_hl_name(index, k)
					updating_value[k] = highlight.add_highlight_name(child[1], component_hl_name)
					highlight.set_hl(component_hl_name, child[2], opts.statusline_color)

					M.eval_component_func(component, "on_highlight")
				elseif highlight.is_highlight_name(child[2]) then
					-- { "filename", "HIGHLIGHT_NAME" }
					updating_value[k] = highlight.add_highlight_name(child[1], child[2])
				else
					-- {"filename"}
					updating_value[k] = child[1]
				end
			else
				statusline[index] = ""
				require("sttusline.utils.notify").error(
					string.format(
						"component %s update() must return string or table of string or table of {string, table}",
						component.name or ""
					)
				)
				return
			end
		end
		statusline[index] = table.concat(updating_value, "")
	else
		statusline[index] = ""
		require("sttusline.utils.notify").error(
			string.format(
				"component %s update() must return string or table of string or table of {string, table}",
				component.name or ""
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

M.update_on_trigger = function(opts, indexs)
	for _, index in ipairs(indexs) do
		M.update_component_value(opts, components[index], index)
	end
end

M.run = function(opts, event_name, is_user_event)
	local event_table = is_user_event and catalog.event.user or catalog.event.nvim
	vim.schedule(function()
		M.update_on_trigger(opts, event_name and event_table[event_name] or catalog.timer)
		if not statusline_hidden then M.update_statusline() end
	end, 0)
end

return M
