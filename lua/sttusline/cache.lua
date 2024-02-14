local fn = vim.fn
local M = {}

local CACHED_DIR = fn.stdpath("cache") .. "/sttusline"
local CACHED_FILE = CACHED_DIR .. "/cache.lua"

local cached = fn.filereadable(CACHED_FILE) == 1

M.cache = function(cache, force)
	if cached and not force then return end

	fn.mkdir(CACHED_DIR, "p")

	local file = io.open(CACHED_FILE, "w")

	if file then
		file:write("return " .. vim.inspect(cache))
		file:close()
	end
end

M.cached = function() return cached end

M.clear = function()
	if cached then
		fn.delete(CACHED_FILE)
		cached = false
		return true
	end
	return false
end

M.read = function()
	if cached then return true, dofile(CACHED_FILE) end

	-- return false and the format of the cache
	return false,
		{
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

			timers = {},
			min_widths = {},
		}
end

return M
