local MAX_DEPTH = 10
local NestedTable = {}
NestedTable.__index = NestedTable

function NestedTable:new(table)
	table = table or {}
	if type(table) ~= "table" then error("NestedTable:new() expects a table, got " .. type(table)) end
	return setmetatable(table, self)
end

function NestedTable:mapi(func, depth)
	depth = depth or 1
	if depth > MAX_DEPTH then error("NestedTable:mapi() reached max depth") end
	local new_table = {}
	for k, v in pairs(self) do
		if type(v) == "table" then
			if getmetatable(v) == NestedTable then
				new_table[k] = v:mapi(func, depth + 1)
			else
				new_table[k] = NestedTable:new(v):mapi(func, depth + 1)
			end
		else
			new_table[k] = func(v, k)
		end
	end
	return NestedTable:new(new_table)
end

function NestedTable:foreachi(func, depth)
	depth = depth or 1
	if depth > MAX_DEPTH then error("NestedTable:foreachi() reached max depth") end
	for k, v in ipairs(self) do
		if type(v) == "table" then
			if getmetatable(v) == NestedTable then
				v:foreachi(func, depth + 1)
			else
				NestedTable:new(v):foreachi(func, depth + 1)
			end
		else
			func(v, k)
		end
	end
end

function NestedTable:insert(value, pos)
	pos = pos or #self + 1
	if type(value) == "table" then
		if getmetatable(value) == NestedTable then
			table.insert(self, pos, value)
		else
			table.insert(self, pos, NestedTable:new(value))
		end
	else
		table.insert(self, pos, value)
	end
end

function NestedTable:remove(pos) table.remove(self, pos) end

function NestedTable:concat(sep, i, j)
	local t = {}
	for k, v in ipairs(self) do
		if type(v) == "table" then
			if getmetatable(v) == NestedTable then
				t[k] = v:concat(sep, i, j)
			else
				t[k] = NestedTable:new(v):concat(sep, i, j)
			end
		else
			t[k] = v
		end
	end
	return table.concat(t, sep, i, j)
end

return NestedTable
