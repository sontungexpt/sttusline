local M = {}

local api = vim.api
local opt = vim.opt
local autocmd = api.nvim_create_autocmd
local augroup = api.nvim_create_augroup

local HIGHLIGHT_COMPONENT_PREFIX = "STTUSLINE_COMPONENT_"
local AUTOCMD_GROUP_COMPONENT = "STTUSLINE_COMPONENT_EVENTS"
local AUTOCMD_GROUP_CORE = "STTUSLINE_DISABLE"
local COMPONENT_PARENT_MODULE = "sttusline.components"

-- module
local utils = require("sttusline.utils")
local is_highlight_option = utils.is_highlight_option
local is_highlight_name = utils.is_highlight_name
local set_hl = utils.set_hl

local component_autocmd_group = nil
local core_autocmd_group = nil

-- local variables
local statusline_hidden = false
local timer = nil
local statusline = {}
local event_components = {
	-- the default event in neovim (https://neovim.io/doc/user/autocmd.html)
	default = {
		-- [event_name] = { { component, index }, ... }
		-- ...
	},

	-- the user event in neovim
	user = {

		-- [event_name] = { { component, index }, ... }
		-- ...
	},
}
local timer_components = {
	-- { component, index )
	-- ...
}

M.setup = function(opts)
	M.init(opts)
	M.update_statusline()
	M.refresh_highlight_on_colorscheme(opts)
	M.disable_for_filetype(opts)
end

M.update_statusline = function()
	local str_statusline = table.concat(statusline, "")
	if str_statusline == "" then str_statusline = " " end
	opt.statusline = str_statusline
end

M.foreach_component = function(opts, callback, empty_comp_callback)
	for index, component in ipairs(opts.components) do
		if type(component) == "string" then
			if component == "%=" then
				if type(empty_comp_callback) == "function" then empty_comp_callback(component, index) end
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

M.get_component_autocmd_group = function()
	if component_autocmd_group == nil then
		component_autocmd_group = augroup(AUTOCMD_GROUP_COMPONENT, { clear = true })
	end
	return component_autocmd_group
end

M.get_core_autocmd_group = function()
	if core_autocmd_group == nil then
		core_autocmd_group = augroup(AUTOCMD_GROUP_CORE, { clear = true })
	end
	return core_autocmd_group
end

M.refresh_highlight_on_colorscheme = function(opts)
	autocmd("ColorScheme", {
		pattern = "*",
		group = M.get_core_autocmd_group(),
		callback = function() M.set_all_component_highlight(opts) end,
	})
end

M.disable_for_filetype = function(opts)
	local event_trigger = false
	autocmd({ "BufEnter", "WinEnter" }, {
		pattern = "*",
		group = M.get_core_autocmd_group(),
		callback = function()
			if event_trigger then return end
			event_trigger = true
			vim.schedule(function()
				if utils.is_disabled(opts) then
					M.hide_statusline()
				else
					M.restore_statusline(opts)
				end
			end, 5)
		end,
	})
	autocmd({ "BufLeave", "WinLeave" }, {
		pattern = "*",
		group = M.get_core_autocmd_group(),
		callback = function() event_trigger = false end,
	})
end

M.hide_statusline = function()
	if not statusline_hidden then
		statusline_hidden = true
		M.remove_event()
		M.stop_timer()
		vim.schedule(function() opt.statusline = " " end, 3)
	end
end

M.restore_statusline = function(opts)
	if statusline_hidden then
		statusline_hidden = false
		M.reinit_event(opts)
		M.start_timer(opts)
		M.update_all_components(opts)
		M.update_statusline()
	end
end

M.remove_event = function()
	api.nvim_del_augroup_by_name(AUTOCMD_GROUP_COMPONENT)
	component_autocmd_group = nil
end

M.reinit_event = function(opts)
	M.create_default_autocmd(opts, vim.tbl_keys(event_components.default))
	M.create_user_autocmd(opts, vim.tbl_keys(event_components.user))
end
--- Init timer, autocmds, and highlight for statusline
M.init = function(opts)
	M.foreach_component(opts, function(component, index)
		if component.get_lazy() == false then
			M.update_component_value(opts, component, index)
		else
			statusline[index] = ""
		end
		component.load()
		M.init_component_autocmds(opts, component, index)
		M.cache_timming_component(component, index)
		M.set_component_highlight(opts, component, index)
	end, function(empty_zone_comp, index) statusline[index] = empty_zone_comp end)
	M.init_component_timer(opts)
end

M.init_component_autocmds = function(opts, component, index)
	M.create_autocmd(opts, component.get_event(), component, index)
	M.create_autocmd(opts, component.get_user_event(), component, index, true)
end

M.create_default_autocmd = function(opts, event)
	autocmd(event, {
		pattern = "*",
		group = M.get_component_autocmd_group(),
		callback = function(e) M.run(opts, e.event) end,
	})
end

M.create_user_autocmd = function(opts, event)
	autocmd("User", {
		pattern = event,
		group = M.get_component_autocmd_group(),
		callback = function(e) M.run(opts, e.match, true) end,
	})
end

M.create_autocmd = function(opts, events, component, index, is_user_event)
	local key = is_user_event and "user" or "default"

	for _, event in ipairs(events) do
		if event_components[key][event] == nil then
			event_components[key][event] = { { component, index } }
			if is_user_event then
				M.create_user_autocmd(opts, event)
			else
				M.create_default_autocmd(opts, event)
			end
		else
			local next_index = #event_components[key][event] + 1
			event_components[key][event][next_index] = { component, index }
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

M.cache_timming_component = function(component, index)
	if component.get_timing() then table.insert(timer_components, { component, index }) end
end

M.init_component_timer = function(opts)
	if #timer_components > 0 then M.start_timer(opts) end
end

M.stop_timer = function()
	if timer then timer:stop() end
end

M.set_component_highlight = function(opts, component, index)
	local colors = component.get_colors()
	if type(colors) == "table" then
		local is_list = false
		for k, color in ipairs(colors) do
			is_list = true
			set_hl(HIGHLIGHT_COMPONENT_PREFIX .. index .. "_" .. k, color, opts.statusline_color)
		end
		if not is_list then set_hl(HIGHLIGHT_COMPONENT_PREFIX .. index, colors, opts.statusline_color) end
	end
	component.get_onhighlight()()
end

M.set_all_component_highlight = function(opts)
	M.foreach_component(
		opts,
		function(component, index) M.set_component_highlight(opts, component, index) end
	)
end

M.update_component_value = function(opts, component, index)
	local should_display = component.get_condition()()
	if type(should_display) == "boolean" and not should_display then
		statusline[index] = ""
		return
	end

	local updating_value = component.get_update()()
	-- updating_value must be string or table
	-- if updating_value is table, then it must be a list of string or list of
	-- two elements table, the first element is string, the second element is the
	-- colors option of component
	-- example:
	-- { "filetype_icon", "filename" }
	-- { {"filetype_icon", { fg="", bg="" }}, "filename" }
	-- { {"filetype_icon"}  }

	local colors = component.get_colors()
	if type(updating_value) == "string" then
		updating_value = utils.add_padding(updating_value, component.get_padding())
		if is_highlight_option(colors) then
			-- if assign colors to component, then add highlight name to component
			statusline[index] = utils.add_highlight_name(updating_value, HIGHLIGHT_COMPONENT_PREFIX .. index)
		elseif is_highlight_name(colors) then
			-- if assign the highlight name to component, then add that highlight name to component
			statusline[index] = utils.add_highlight_name(updating_value, colors)
		else
			-- if not assign colors to component, then not need to add highlight name
			statusline[index] = updating_value
		end
	elseif type(updating_value) == "table" then
		updating_value = utils.add_padding(updating_value, component.get_padding())
		for k, v in ipairs(updating_value) do
			if type(v) == "string" then
				-- "filename"
				if type(colors) == "table" then
					if is_highlight_option(colors[k]) then
						updating_value[k] =
							utils.add_highlight_name(v, HIGHLIGHT_COMPONENT_PREFIX .. index .. "_" .. k)
					elseif is_highlight_name(colors[k]) then
						updating_value[k] = utils.add_highlight_name(v, colors[k])
					end
				else
					updating_value[k] = v
				end
			elseif type(v) == "table" and type(v[1]) == "string" then
				if is_highlight_option(v[2]) then
					-- { "filename", { fg="", bg="" }}
					colors[k] = v[2]
					component.set_colors(colors)
					updating_value[k] =
						utils.add_highlight_name(v[1], HIGHLIGHT_COMPONENT_PREFIX .. index .. "_" .. k)
					set_hl(HIGHLIGHT_COMPONENT_PREFIX .. index .. "_" .. k, v[2], opts.statusline_color)
					component.get_onhighlight()()
				elseif is_highlight_name(v[2]) then
					-- { "filename", "HIGHLIGHT_NAME" }
					updating_value[k] = utils.add_highlight_name(v[1], v[2])
				else
					-- {"filename"}
					updating_value[k] = v[1]
				end
			else
				statusline[index] = ""
				require("sttusline.utils.notify").error(
					"opts.component["
						.. index
						.. "].update() must return string or table of string or table of {string, table}"
				)
				return
			end
		end
		statusline[index] = table.concat(updating_value, "")
	else
		statusline[index] = ""
		require("sttusline.utils.notify").error(
			"opts.component["
				.. index
				.. "].update() must return string or table of string or table of {string, table}"
		)
	end
end

M.update_all_components = function(opts)
	M.foreach_component(
		opts,
		function(component, index) M.update_component_value(opts, component, index) end
	)
end

M.update_on_trigger = function(opts, table)
	for _, values in ipairs(table) do
		M.update_component_value(opts, values[1], values[2])
	end
end

M.run = function(opts, event_name, is_user_event)
	local event_table = is_user_event and event_components.user or event_components.default
	vim.schedule(function()
		M.update_on_trigger(opts, event_name and event_table[event_name] or timer_components)
		if not statusline_hidden then M.update_statusline() end
	end, 0)
end

return M
