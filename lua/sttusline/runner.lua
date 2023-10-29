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

local statusline = {}
local component_cache = {}
local event_component_id_cache = {
	default = {
		-- ...
		-- [event_name] = { component_index, ... }
	},
	user = {
		-- ...
		-- [event_name] = { component_index, ... }
	},
}
local timming_component_id_cache = {
	-- ...
	-- component_index
}

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
		for _, component in ipairs(opts.components) do
			if type(component) == "string" and #component > 0 then
				if component == "%=" then
					local index = #component_cache + 1
					component_cache[index] = component
					utils.eval_func(empty_comp_cb, component, index)
				else
					local status_ok, real_comp = pcall(require, COMPONENT_PARENT_MODULE .. "." .. component)
					if status_ok then
						local index = #component_cache + 1
						component_cache[index] = real_comp
						comp_cb(real_comp, index)
					else
						require("sttusline.utils.notify").error("Failed to load component: " .. component)
					end
				end
			elseif type(component) == "table" and #component > 0 then
				if type(component[1] == "string") then
					local status_ok, real_comp = pcall(require, COMPONENT_PARENT_MODULE .. "." .. component[1])
					if status_ok then
						if type(component[2]) == "table" then
							real_comp = vim.tbl_deep_extend("force", real_comp, component[2])
						end
						local index = #component_cache + 1
						component_cache[index] = real_comp
						comp_cb(real_comp, index)
					else
						require("sttusline.utils.notify").error("Failed to load component: " .. component[1])
					end
				else
					local index = #component_cache + 1
					component_cache[index] = component
					comp_cb(component, index)
				end
			end
		end
	end
end

M.update_statusline = function() opt.statusline = table.concat(statusline, "") end

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

M.init = function(opts)
	M.foreach_component(opts, function(component, index)
		statusline[index] = component.lazy == false and M.update_component_value(index) or ""
		eval_component_func(component, "init")

		-- M.init_component_autocmds(component, index)
		-- M.init_timer(component, index)
		-- M.set_component_highlight(component, index)
	end, function(empty_comp, index) statusline[index] = empty_comp end)
end

M.update_component_value = function(index)
	local should_display = eval_component_func(component_cache[index], "condition")
	if type(should_display) == "boolean" and not should_display then
		statusline[index] = ""
		return
	end

	local value = eval_component_func(component_cache[index], "update")
	if type(value) == "string" then
		value = utils.add_padding(value, component_cache[index].padding)
		if next(component_cache[index].colors) then
			statusline[index] = utils.add_highlight_name(value, HIGHLIGHT_COMPONENT_PREFIX .. index)
		else
			statusline[index] = value
		end
	else
		statusline[index] = ""
		require("sttusline.utils.notify").error(
			"component " .. component_cache[index].name and component_cache[index].name .. " "
				or "" .. "update() must return string"
		)
	end
end

M.update_all_components = function(opts)
	M.foreach_component(opts, function(_, index) M.update_component_value(index) end)
end

M.update_on_trigger = function(ids)
	for _, id in ipairs(ids) do
		M.update_component_value(id)
	end
end

M.run = function(event_name, is_user_event)
	local event_table = is_user_event and event_component_id_cache.user or event_component_id_cache.default
	vim.schedule(function()
		M.update_on_trigger(event_name and event_table[event_name] or timming_component_id_cache)
		M.update_statusline()
	end, 0)
end

return M
