local fn = vim.fn
local M = {}

local CACHED_DIR = fn.stdpath("cache") .. "/sttusline"
local CACHED_FILE = CACHED_DIR .. "/cache.lua"

local has_cached = fn.filereadable(CACHED_FILE) == 1

M.cache = function(cache, force)
	if has_cached and not force then return end

	if fn.isdirectory(CACHED_DIR) ~= 1 then fn.mkdir(CACHED_DIR, "p") end
	local file = io.open(CACHED_FILE, "w")

	if file then
		file:write("return " .. vim.inspect(cache))
		file:close()
	end
end

M.has_cached = function() return has_cached end

M.clear = function()
	if has_cached then
		fn.delete(CACHED_FILE)
		has_cached = false
		return true
	end
	return false
end

M.read = function()
	if has_cached then return true, dofile(CACHED_FILE) end

	-- return false and the format of the cache
	return false,
		{
			name_index_maps = {},

			events = {
				-- the key is the name of the default event
				nvim = {
					keys_len = 0,
					keys = {},
				},
				-- the key is the name of user defined event
				user = {
					keys_len = 0,
					keys = {},
				},
			},

			timer = {},
		}
end

return M
