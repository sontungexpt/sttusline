local fn = vim.fn
local M = {}

-- print path of this module

-- local CACHED_DIR = fn.stdpath("data") .. "/sttusline/cache"
local CACHED_DIR = fn.stdpath("cache") .. "/sttusline"
local CACHED_FILE = CACHED_DIR .. "/cached.lua"

local has_cached = fn.filereadable(CACHED_FILE) == 1

local header = [[
    local vim = vim
    local api = vim.api
    local uv = vim.uv or vim.loop
    local autocmd = api.nvim_create_autocmd
    local core = require("sttusline.core")
  ]]

local cached
local autocmd_cached = {}
local footer = [[
    return cached
]]

M.cache_autocmd = function(event, pattern, index)
	autocmd_cached[#autocmd_cached + 1] = string.format(
		[[
      autocmd(%s, {
      pattern = %s,
      group = core.get_global_augroup(),
      callback = function()
        core.update_comp_value(%s)
        core.render()
      end,
    }]],
		event,
		pattern,
		index
	)
end

M.cache_autocmds = function()
	autocmd_cached[#autocmd_cached + 1] = [[
    local nvim_keys = cached.event_index_maps.nvim.keys
    local user_keys = cached.event_index_maps.user.keys
    if next(nvim_keys) then
      autocmd(nvim_keys, {
        group = core.get_global_augroup(),
        callback = function(e) core.run(e.event) end,
      })
    end
    if next(user_keys) then
      autocmd("User", {
        pattern = user_keys,
        group = core.get_global_augroup(),
        callback = function(e) core.run(e.match, true) end,
      })
    end
	]]
end

M.cache_cached = function(value) cached = "local cached = " .. vim.inspect(value) end

M.cache = function()
	if has_cached then return end

	if fn.isdirectory(CACHED_DIR) ~= 1 then fn.mkdir(CACHED_DIR, "p") end
	local file = io.open(CACHED_FILE, "w")

	if file then
		file:write(header .. cached .. table.concat(autocmd_cached, "\n") .. footer)
		file:close()
	end
end

M.has_cached = function() return has_cached end

M.read_cache = function(store)
	if not has_cached then return false, store end
	return true, dofile(CACHED_FILE)
end

return M
