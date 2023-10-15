local M = {}

local api = vim.api
local opt = vim.opt
local autocmd = api.nvim_create_autocmd
local augroup = api.nvim_create_augroup
local tbl_insert = table.insert

local AUTOCMD_GROUP_PREFIX = "STTUSLINE_AUGROUP_"
local HIGHLIGHT_COMPONENT_PREFIX = "STTUSLINE_COMPONENT_"

-- module
local utils = require("sttusline.utils")
local notify = require("sttusline.utils.notify")

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
	M.disable_for_filetype(opts)
end

M.update_statusline = function() opt.statusline = table.concat(statusline, "") end

M.disable_for_filetype = function(opts)
	autocmd({ "BufEnter", "WinEnter" }, {
		pattern = "*",
		group = augroup(AUTOCMD_GROUP_PREFIX .. "DISABLED", { clear = true }),
		callback = function()
			vim.defer_fn(function()
				if not statusline_hidden and utils.is_disabled(opts) then
					M.hide_statusline()
				else
					M.restore_statusline()
				end
			end, 5)
		end,
	})
end

M.hide_statusline = function()
	if not statusline_hidden then
		statusline_hidden = true
		M.remove_event()
		M.stop_timer()
		vim.defer_fn(function() opt.statusline = " " end, 3)
	end
end

M.restore_statusline = function()
	if statusline_hidden then
		statusline_hidden = false
		M.reinit_event()
		M.start_timer()
		M.update_statusline()
	end
end

M.remove_event = function()
	for _, events in pairs(event_components) do
		for event, _ in pairs(events) do
			api.nvim_del_augroup_by_name(AUTOCMD_GROUP_PREFIX .. event)
		end
	end
end

M.reinit_event = function()
	for event, _ in pairs(event_components.default) do
		M.create_default_autocmd(event)
	end
	for event, _ in pairs(event_components.user) do
		M.create_user_autocmd(event)
	end
end

--- Init timer, autocmds, and highlight for statusline
M.init = function(opts)
	utils.foreach_component(opts, function(component, index)
		statusline[index] = ""
		component.load()
		M.init_component_autocmds(component, index)
		M.init_timer(component, index)
		M.set_component_highlight(component, index)
		if not component.get_lazy() then M.update_component_value(component, index) end
	end, function(empty_zone_comp, index) statusline[index] = empty_zone_comp end)
end

M.init_component_autocmds = function(component, index)
	M.create_autocmd(component.get_event(), component, index)
	M.create_autocmd(component.get_user_event(), component, index, true)
end

M.create_default_autocmd = function(event)
	autocmd(event, {
		pattern = "*",
		group = augroup(AUTOCMD_GROUP_PREFIX .. event, { clear = true }),
		callback = function(e) M.run(e.event) end,
	})
end

M.create_user_autocmd = function(event)
	autocmd("User", {
		pattern = event,
		group = augroup(AUTOCMD_GROUP_PREFIX .. event, { clear = true }),
		callback = function(e) M.run(e.match, true) end,
	})
end

M.create_autocmd = function(events, component, index, is_user_event)
	local key = is_user_event and "user" or "default"

	for _, event in ipairs(events) do
		if event_components[key][event] == nil then
			event_components[key][event] = { { component, index } }
			if is_user_event then
				M.create_user_autocmd(event)
			else
				M.create_default_autocmd(event)
			end
		else
			tbl_insert(event_components[key][event], { component, index })
		end
	end
end

M.stop_timer = function()
	if timer then timer:stop() end
end

M.start_timer = function()
	if timer == nil then timer = vim.loop.new_timer() end
	timer:start(1000, 1000, vim.schedule_wrap(M.run))
end

M.init_timer = function(component, index)
	if component.get_timing() then
		tbl_insert(timer_components, { component, index })
		if timer == nil then M.start_timer() end
	end
end

M.set_component_highlight = function(component, index)
	if next(component.get_colors()) then
		api.nvim_set_hl(0, HIGHLIGHT_COMPONENT_PREFIX .. index, component.get_colors())
	end
end

M.set_highlight = function(opts)
	utils.foreach_component(
		opts,
		function(component, index) M.set_component_highlight(component, index) end
	)
end

M.update_component_value = function(component, index)
	local should_display = component.get_condition()()
	if type(should_display) == "boolean" and not should_display then
		statusline[index] = ""
		return
	end

	local value = component.get_update()()
	if type(value) == "string" then
		value = utils.add_padding(value, component.get_padding())
		if next(component.get_colors()) then
			statusline[index] = utils.add_highlight_name(value, HIGHLIGHT_COMPONENT_PREFIX .. index)
		else
			statusline[index] = value
		end
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

M.run = function(event_name, is_user_event)
	vim.defer_fn(function()
		if event_name ~= nil then
			if is_user_event then
				M.update_on_trigger(event_components.user[event_name])
			else
				M.update_on_trigger(event_components.default[event_name])
			end
		else
			M.update_on_trigger(timer_components)
		end
		M.update_statusline()
	end, 0)
end

return M
