local vim = vim
local api = vim.api
local opt = vim.opt
local uv = vim.uv or vim.loop
local schedule = vim.schedule
local autocmd = api.nvim_create_autocmd
local augroup = api.nvim_create_augroup

local type = type
local ipairs = ipairs
local concat = table.concat

local Statusline = {}

local PLUG_NAME = "sttusline"
local COMP_DIR = "sttusline.components."

local cache_module = require("sttusline.cache")

local values_len = 0
local values = {}

local comps_len = 0
local comps = {}

local is_hidden = false
local augr_id = augroup(PLUG_NAME, { clear = true })
local timer_ids = {}
local cached, cache = cache_module.read()

local inherit_attrs = {
	styles = true,
	configs = true,
	static = true,
	padding = true,
}

local function get_global_augroup()
	return augr_id or (function()
		augr_id = augroup(PLUG_NAME, { clear = true })
		return augr_id
	end)()
end

--- Search up the component tree for a key
--- If the nearest parent has the key, return the value and the parent
--- @param comp table : component to search from
function Statusline.search_up(comp, key)
	while comp do
		if comp[key] then return comp[key], comp end
		comp = comp.__parent
	end
end

---
-- Searches for a specified set of keys deeply within a component and its parent components.
-- @param comp The starting component to search from.
-- @param ... A list of keys to search deeply for.
-- @return The component containing the keys if found, along with its parent component.
function Statusline.deep_search_up(comp, ...)
	local keys = { ... }
	local left = #keys
	while comp do
		local found = comp
		for _, key in ipairs(keys) do
			if not type(found[key]) == "table" then break end
			found = found[key]
		end
		if found and left == 0 then return found, comp end
		comp = comp.__parent
	end
end

local function call(func, ...) return type(func) == "function" and func(...) end

local function call_comp_func(func, comp, ...)
	local get_shared = function(key)
		while comp do
			local shared = comp.shared
			if shared == "table" and shared[key] then return shared[key] end
			comp = comp.__parent
		end
	end

	if type(func) == "function" then return func(comp.configs, comp.__state, get_shared, comp, ...) end
end

local function tbl_contains(tbl, value)
	return tbl[value] or require("sttusline.util").arr_contains(tbl, value)
end

local function should_hidden(excluded, bufnr)
	return tbl_contains(excluded.filetypes, api.nvim_buf_get_option(bufnr or 0, "filetype"))
		or tbl_contains(excluded.buftypes, api.nvim_buf_get_option(bufnr or 0, "buftype"))
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

local function handle_comp_timing(comp, index)
	if comp.timing == true then
		cache.timers[#cache.timers + 1] = index
	elseif type(comp.timing) == "number" then
		if timer_ids[index] == nil then timer_ids[index] = uv.new_timer() end
		timer_ids[index]:start(
			0,
			comp.timing,
			vim.schedule_wrap(function()
				Statusline.update_comp(comp)
				Statusline.render()
			end)
		)
	end
end

local function init_cached_autocmds()
	local nvim = cache.events.nvim
	local user = cache.events.user

	local group = get_global_augroup()

	if nvim.keys_len > 0 then -- has nvim events
		autocmd(nvim.keys, {
			group = group,
			callback = function(e) Statusline.run(e.event) end,
		})
	end
	if user.keys_len > 0 then -- has user events
		autocmd("User", {
			pattern = user.keys,
			group = group,
			callback = function(e) Statusline.run(e.match, true) end,
		})
	end
end

local function init_cached_timers()
	if cache.timers[1] ~= nil then -- has timing components
		if timer_ids[PLUG_NAME] == nil then timer_ids[PLUG_NAME] = uv.new_timer() end
		timer_ids[PLUG_NAME]:start(0, 1000, vim.schedule_wrap(Statusline.run))
	end
end
--- Add a component to the statusline
--- @param comp table|string|number : component to add
--- @param seen table : table to keep track of seen components
--- @param parent table|nil : parent component
local function init_tree(comp, seen, parent)
	-- handle special components or get the component from the component directory
	if type(comp) ~= "table" then
		if type(comp) == "string" then
			if comp == "%=" then -- special component
				values_len = values_len + 1
				values[values_len] = "%="
				return
			end
			local ok = false
			ok, comp = pcall(require, COMP_DIR .. comp)
			if not ok then
				return -- invalid component
			end
		elseif type(comp) == "number" then -- special component
			values_len = values_len + 1
			values[values_len] = string.rep(" ", math.floor(comp))
			return
		end
		-- elseif comp.from ~= nil then
		-- 	local ok, default = pcall(require, COMP_DIR .. tostring(comp.from))
		-- 	if not ok then
		-- 		return -- invalid component
		-- 	end
		-- 	comp = require("sttusline.config").merge_config(default, comp.ovveride, true)
	end

	-- make a copy of the component if it has been seen before
	if seen[comp] then
		comp = require("sttusline.config").merge_config({}, comp, true)
	else
		seen[comp] = true
	end

	if parent then
		comp.__parent = parent

		-- inherit attributes from the parent
		setmetatable(comp, {
			__index = function(_, key)
				if inherit_attrs[key] then return parent[key] end
			end,
		})
	end

	comp.__state = call(comp.init, comp.configs, comp)

	comps_len = comps_len + 1
	comps[comps_len] = comp

	if not cached then
		if comp.min_width then cache.min_widths[#cache.min_windth + 1] = comps_len end

		handle_comp_events(comp, comps_len)
		-- NOTE: this only add the id to cache.timers,
		-- but it don't handle case when both the child component
		-- and parent component have timing set to true.
		-- If it happens, the child component will be updated twice.
		handle_comp_timing(comp, comps_len)
	end

	if comp[1] ~= nil then
		for _, child in ipairs(comp) do
			init_tree(child, seen, comp)
		end
	else -- a leaf component
		values_len = values_len + 1
		values[values_len] = comp.lazy == false and "" or ""
		comp.__pos = values_len
	end
end

-- function Statusline.run(event_name, is_user_event)
-- 	if is_hidden then return end

-- 	schedule(function()
-- 		local event_dict = is_user_event and cache.events.user or cache.events.nvim
-- 		local indexes = event_name and event_dict[event_name] or cache.timers

-- 		---@diagnostic disable-next-line: param-type-mismatch
-- 		for _, index in ipairs(indexes) do
-- 			Statusline.update_comp(comps[index])
-- 		end

-- 		Statusline.render()
-- 	end, 0)
-- end

function Statusline.render()
	if is_hidden then
		opt.statusline = " "
	else
		local str = concat(values)
		opt.statusline = str ~= "" and str or " "
	end
end

function Statusline.setup(configs)
	local seen = {}

	init_tree(configs.components, seen)

	-- init_cached_autocmds()
	-- init_cached_timers()

	-- autocmd("VimLeavePre", {
	-- 	group = get_global_augroup(),
	-- 	callback = function() cache_module.cache(cache) end,
	-- })

	autocmd("Colorscheme", {
		group = get_global_augroup(),
		callback = function() require("sttusline.highlight").colorscheme() end,
	})
end

return Statusline
