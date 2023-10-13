local M = {}

local api = vim.api
local tbl_concat = table.concat
local tbl_insert = table.insert

-- module
local utils = require("sttusline.utils")
local constants = require("sttusline.constant")

local timer = nil
local event_components = {}
local timer_components = {}
local statusline = {
	left = {},
	center = {},
	right = {},
}

M.update_statusline = function()
	vim.opt.statusline = tbl_concat(statusline.left, "")
		.. "%="
		.. tbl_concat(statusline.center, "")
		.. "%="
		.. tbl_concat(statusline.right, "")
end

M.setup = function(opts)
	M.init(opts)
	M.update_all(opts)
	M.update_statusline()
end

M.create_autocmds = function(component, zone, index_in_zone)
	if component.event then
		for _, event in ipairs(component.event) do
			if event_components[event] == nil then
				event_components[event] = { { component, zone, index_in_zone } }
				api.nvim_create_autocmd(event, {
					group = api.nvim_create_augroup(constants.AUTOCMD_GROUP_NAME_PREFIX .. event, {}),
					callback = function(e) M.run(e.event) end,
				})
			end
			tbl_insert(event_components[event], { component, zone, index_in_zone })
		end
	end

	if component.user_event then
		for _, event in ipairs(component.user_event) do
			if event_components[event] == nil then
				event_components[event] = { { component, zone, index_in_zone } }
				api.nvim_create_autocmd("User", {
					pattern = event,
					group = api.nvim_create_augroup(constants.AUTOCMD_GROUP_NAME_PREFIX .. event, {}),
					callback = function(e) M.run(e.match) end,
				})
			end
			tbl_insert(event_components[event], { component, zone, index_in_zone })
		end
	end
end

M.init_timer = function(component, zone, index_in_zone)
	if component.timing then
		tbl_insert(timer_components, { component, zone, index_in_zone })
		if timer == nil then
			timer = vim.loop.new_timer()
			timer:start(1000, 1000, vim.schedule_wrap(function() M.run() end))
		end
	end
end

M.set_component_highlight = function(component, zone, index_in_zone)
	if component.colors ~= nil then
		api.nvim_set_hl(0, constants.HIGHLIGHT_COMPONENT_PREFIX .. zone .. index_in_zone, component.colors)
	end
end

--- Init timer, autocmds, and highlight for statusline
M.init = function(opts)
	utils.foreach_component(opts, function(component, zone, index_in_zone)
		component:load()
		M.create_autocmds(component, zone, index_in_zone)
		M.init_timer(component, zone, index_in_zone)
		M.set_component_highlight(component, zone, index_in_zone)
	end)
end

M.set_highlight = function(opts)
	utils.foreach_component(
		opts,
		function(component, zone, index_in_zone) M.set_component_highlight(component, zone, index_in_zone) end
	)
end

M.update_component_value = function(component, zone, index_in_zone)
	local value = component.update()
	if type(value) == "string" then
		value = utils.add_padding(value, component.padding)
		value =
			utils.add_highlight_name(value, constants.HIGHLIGHT_COMPONENT_PREFIX .. zone .. index_in_zone)
		statusline[zone][index_in_zone] = value
	else
		require("sttusline.notify").error(
			"Value return in update function of opts.component["
				.. zone
				.. "]["
				.. index_in_zone
				.. "]"
				.. " must be string"
		)
	end
end

M.update_all = function(opts)
	utils.foreach_component(
		opts,
		function(component, zone, index_in_zone) M.update_component_value(component, zone, index_in_zone) end
	)
end

M.update_on_trigger = function(table)
	for _, values in ipairs(table) do
		M.update_component_value(values[1], values[2], values[3])
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
