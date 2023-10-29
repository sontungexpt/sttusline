local M = {}

local api = vim.api
local opt = vim.opt
local autocmd = api.nvim_create_autocmd
local augroup = api.nvim_create_augroup

local COMPONENT_PARENT_MODULE = "sttusline.components"
local AUTOCMD_CORE_GROUP = "STTUSLINE_CORE_EVENTS"
local AUTOCMD_COMPONENT_GROUP = "STTUSLINE_COMPONENT_EVENTS"
local HIGHLIGHT_COMPONENT_PREFIX = "STTUSLINE_COMPONENT_"

local utils = require("sttusline.utils")
local eval_component_func = utils.eval_component_func

local core_autocmd_group = nil
local component_autocmd_group = nil
local timer = nil
local statusline_hidden = false

local statusline = {}
local component_cache = {}
local event_component_index_cache = {
	default = {
		-- ...
		-- [event_name] = { component_index, ... }
	},
	user = {
		-- ...
		-- [event_name] = { component_index, ... }
	},
}
local timming_component_index_cache = {
	-- ...
	-- component_index
}

M.update_statusline = function() opt.statusline = table.concat(statusline, "") end

M.setup = function(opts)
	M.init(opts)
	M.refresh_highlight_on_colorscheme(opts)
	M.disable_for_filetype(opts)
	M.update_statusline()
end

M.foreach_component = function(opts, comp_cb, empty_comp_cb)
	if #component_cache > 0 then
		for index, component in ipairs(component_cache) do
			if type(component) == "string" then
				utils.eval_func(empty_comp_cb, component, index)
			else
				comp_cb(component, index)
			end
		end
	else
		local index = 0
		for _, component in ipairs(opts.components) do
			if type(component) == "string" and #component > 0 then
				if component == "%=" then
					index = index + 1
					component_cache[index] = component
					utils.eval_func(empty_comp_cb, component, index)
				else
					local status_ok, real_comp = pcall(require, COMPONENT_PARENT_MODULE .. "." .. component)
					if status_ok then
						index = index + 1
						component_cache[index] = real_comp
						comp_cb(real_comp, index)
					else
						require("sttusline.utils.notify").error("Failed to load component: " .. component)
					end
				end
			elseif type(component) == "table" and next(component) then
				if type(component[1]) == "string" then
					local status_ok, real_comp = pcall(require, COMPONENT_PARENT_MODULE .. "." .. component[1])
					if status_ok then
						if type(component[2]) == "table" then
							real_comp = vim.tbl_deep_extend("force", real_comp, component[2])
						end
						index = index + 1
						component_cache[index] = real_comp
						comp_cb(real_comp, index)
					else
						require("sttusline.utils.notify").error("Failed to load component: " .. component[1])
					end
				else
					index = index + 1
					component_cache[index] = component
					comp_cb(component, index)
				end
			end
		end
	end
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
			if not event_trigger then
				event_trigger = true
				vim.schedule(function()
					if utils.is_disabled(opts) then
						M.hide_statusline()
					else
						M.restore_statusline(opts)
					end
				end, 0)
			end
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
		vim.schedule(function() opt.statusline = " " end)
	end
end

M.restore_statusline = function(opts)
	if statusline_hidden then
		statusline_hidden = false
		M.update_all_components(opts)
		M.update_statusline()
	end
end

M.start_timer = function()
	if timer == nil then timer = vim.loop.new_timer() end
	timer:start(
		1000,
		1000,
		vim.schedule_wrap(function()
			if not statusline_hidden then M.run() end
		end)
	)
end

M.init_component_timer = function()
	if #timming_component_index_cache > 0 then M.start_timer() end
end

M.set_component_highlight = function(component, index)
	if type(component.colors) == "table" and next(component.colors) then
		api.nvim_set_hl(0, HIGHLIGHT_COMPONENT_PREFIX .. index, component.colors)
	end

	eval_component_func(component, "on_highlight")
end

M.set_all_component_highlight = function(opts) M.foreach_component(opts, M.set_component_highlight) end

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

M.create_default_autocmd = function(event)
	autocmd(event, {
		pattern = "*",
		group = M.get_component_autocmd_group(),
		callback = function(e)
			if not statusline_hidden then M.run(e.event) end
		end,
	})
end

M.create_user_autocmd = function(event)
	autocmd("User", {
		pattern = event,
		group = M.get_component_autocmd_group(),
		callback = function(e)
			if not statusline_hidden then M.run(e.match, true) end
		end,
	})
end

M.cache_timming_component_index = function(component, index)
	if component.timming == true then table.insert(timming_component_index_cache, index) end
end

M.cache_event_component_index = function(event, index, cache_key)
	if type(event) == "string" then
		event_component_index_cache[cache_key][event] = event_component_index_cache[cache_key][event] or {}
		table.insert(event_component_index_cache[cache_key][event], index)
	elseif type(event) == "table" then
		for _, e in ipairs(event) do
			event_component_index_cache[cache_key][e] = event_component_index_cache[cache_key][e] or {}
			table.insert(event_component_index_cache[cache_key][e], index)
		end
	end
end

M.init_component_autocmds = function()
	if next(event_component_index_cache.default) then
		M.create_default_autocmd(vim.tbl_keys(event_component_index_cache.default))
	end
	if next(event_component_index_cache.user) then
		M.create_user_autocmd(vim.tbl_keys(event_component_index_cache.user))
	end
end

M.init = function(opts)
	M.foreach_component(opts, function(component, index)
		if component.lazy == false then
			M.update_component_value(component, index)
		else
			statusline[index] = ""
		end
		eval_component_func(component, "init")

		M.cache_event_component_index(component.event, index, "default")
		M.cache_event_component_index(component.user_event, index, "user")
		M.cache_timming_component_index(component, index)
		M.set_component_highlight(component, index)
	end, function(empty_comp, index) statusline[index] = empty_comp end)
	M.init_component_autocmds()
	M.init_component_timer()
end

M.update_component_value = function(component, index)
	local should_display = eval_component_func(component, "condition")
	if type(should_display) == "boolean" and not should_display then
		statusline[index] = ""
		return
	end

	local value = eval_component_func(component, "update")
	if type(value) == "string" then
		value = utils.add_padding(value, component.padding)
		if type(component.colors) == "table" and next(component.colors) then
			statusline[index] = utils.add_highlight_name(value, HIGHLIGHT_COMPONENT_PREFIX .. index)
		else
			statusline[index] = value
		end
	else
		statusline[index] = ""
		require("sttusline.utils.notify").error(
			"component " .. component.name and component.name .. " " or "" .. "update() must return string"
		)
	end
end

M.update_all_components = function(opts) M.foreach_component(opts, M.update_component_value) end

M.update_on_trigger = function(indexs)
	for _, index in ipairs(indexs) do
		M.update_component_value(component_cache[index], index)
	end
end

M.run = function(event_name, is_user_event)
	local event_table = is_user_event and event_component_index_cache.user
		or event_component_index_cache.default
	vim.schedule(function()
		M.update_on_trigger(event_name and event_table[event_name] or timming_component_index_cache)
		if not statusline_hidden then M.update_statusline() end
	end, 0)
end

return M
