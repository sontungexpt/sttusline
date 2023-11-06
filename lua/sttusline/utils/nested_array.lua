local M = {}
local MAX_DEPTH = 10 -- Maximum depth of nested table

M.foreach = function(array, func, depth)
	depth = depth or 0
	for index, value in ipairs(array) do
		if type(value) == "table" then
			if depth < MAX_DEPTH then
				M.foreach(value, func, depth + 1)
			else
				require("sttusline.utils.notify").error("Maximum depth of nested table exceeded")
			end
		else
			func(index, value)
		end
	end
end

M.map = function(array, func, depth)
	depth = depth or 0
	local result = {}
	for index, value in ipairs(array) do
		if type(value) == "table" then
			if depth < MAX_DEPTH then result[index] = M.map(value, func, depth + 1) end
		else
			require("sttusline.utils.notify").error("Maximum depth of nested table exceeded")
		end
	end
	return result
end

M.extend = function(array, another_array) table.insert(array, another_array) end

M.concat = function(array, separator, depth)
	depth = depth or 0
	local result = {}
	for _, value in ipairs(array) do
		if type(value) == "table" then
			if depth < MAX_DEPTH then
				table.insert(result, M.concat(value, separator, depth + 1))
			else
				require("sttusline.utils.notify").error("Maximum depth of nested table exceeded")
			end
		else
			table.insert(result, value)
		end
	end
	return table.concat(result, separator)
end

return M
