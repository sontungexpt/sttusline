local M = {}

local api = vim.api
local autocmd = api.nvim_create_autocmd
local augroup = api.nvim_create_augroup
local tbl_insert = table.insert
local AUTOCMD_GROUP_PREFIX = "STTUSLINE_AUGROUP_"
local HIGHLIGHT_COMPONENT_PREFIX = "STTUSLINE_COMPONENT_"

-- module
local utils = require("sttusline.utils")
local notify = require("sttusline.utils.notify")

-- local variables
local timer = nil
local statusline = {}
local event_components = {
	-- [event_name] = { { component, index }, ... }
	-- ...
}
local timer_components = {
	-- { component, index )
	-- ...
}

M.update_statusline = function() vim.opt.statusline = table.concat(statusline, "") end

M.hide_statusline = function()
	vim.opt.statusline = ""
	if timer then timer:stop() end
end

M.restore_statusline = function()
	M.update_statusline()
	if timer then timer:start() end
end

M.setup = function(opts)
	M.init(opts)
	M.update_statusline()
end

--- Init timer, autocmds, and highlight for statusline
M.init = function(opts)
	utils.foreach_component(opts, function(component, index)
		statusline[index] = ""
		component:load()
		M.init_component_autocmds(component, index)
		M.init_timer(component, index)
		M.set_component_highlight(component, index)
		if not component.lazy then M.update_component_value(component, index) end
	end, function(empty_zone_comp, index) statusline[index] = empty_zone_comp end)
end

M.init_component_autocmds = function(component, index)
	M.create_autocmd(component.event, component, index, function(e) M.run(e.event) end)
	M.create_autocmd(component.user_event, component, index, function(e) M.run(e.match) end, true)
end

M.create_autocmd = function(events, component, index, callback, is_user_event)
	for _, event in ipairs(events) do
		if event_components[event] == nil then
			event_components[event] = { { component, index } }
			autocmd(is_user_event and "User" or event, {
				pattern = is_user_event and event or "*",
				group = augroup(AUTOCMD_GROUP_PREFIX .. event, {}),
				callback = callback,
			})
		end
		tbl_insert(event_components[event], { component, index })
	end
end

M.init_timer = function(component, index)
	if component.timing then
		tbl_insert(timer_components, { component, index })
		if timer == nil then
			timer = vim.loop.new_timer()
			timer:start(1000, 1000, vim.schedule_wrap(M.run))
		end
	end
end

M.set_component_highlight = function(component, index)
	if next(component.colors) then
		api.nvim_set_hl(0, HIGHLIGHT_COMPONENT_PREFIX .. index, component.colors)
	end
end

M.set_highlight = function(opts)
	utils.foreach_component(
		opts,
		function(component, index) M.set_component_highlight(component, index) end
	)
end

M.update_component_value = function(component, index)
	local should_display = component.condition()
	if type(should_display) == "boolean" and not should_display then
		statusline[index] = ""
		return
	end

	local value = component.update()
	if type(value) == "string" then
		value = utils.add_padding(value, component.padding)
		statusline[index] = utils.add_highlight_name(value, HIGHLIGHT_COMPONENT_PREFIX .. index)
	else
		statusline[index] = ""
		notify.error("opts.component[" .. index .. "].update() must return string")
	end
end

M.update_on_trigger = function(table)
	for _, values in ipairs(table) do
		M.update_component_value(values[1], values[2])
	end
end

M.run = function(event_name)
	if event_name ~= nil then
		M.update_on_trigger(event_components[event_name])
	else
		M.update_on_trigger(timer_components)
	end
	M.update_statusline()
end

return M
