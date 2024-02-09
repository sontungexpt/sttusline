local M = {}

M.merge_tb = function(to, from)
	if type(to) == "table" and type(from) == "table" then
		for k, v in pairs(from) do
			if to[1] == nil then -- to is a dict
				to[k] = M.merge_tb(to[k], v)
			else -- to is a list
				to[#to + 1] = v
			end
		end
	else
		to = from
	end
	return to
end

M.arr_contains = function(tbl, value)
	for _, v in ipairs(tbl) do
		if v == value then return true end
	end
	return false
end

M.read_only = function(tbl, err_msg)
	local cache = {}

	function M.read_only(table, error_msg)
		if not cache[table] then
			cache[table] = setmetatable({}, {
				__index = table,
				__newindex = function(metatable, key, value)
					error(
						type(error_msg) == "function" and error_msg(metatable, key, value)
							or error_msg
							or "Attempt to modify read-only table"
					)
				end,
			})
		end

		return cache[table]
	end
	return M.read_only(tbl, err_msg)
end
return M
