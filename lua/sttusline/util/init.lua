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

return M
