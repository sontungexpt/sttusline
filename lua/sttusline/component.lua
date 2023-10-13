local Component = {
	event = {},
	user_event = {},
	timing = false,
	config = {},
	padding = 1, -- { left = 1, right = 1 }
	colors = {}, -- { fg = colors.black, bg = colors.white }
	update = function() return "" end,
	condition = function() return true end,
	is_loaded = false,
	on_load = function() end, -- the function will call on the first time component load
}
function Component:new()
	local instance = setmetatable({}, self)
	self.__index = self

	self.__newindex = function(owner, k, v)
		if k == "event" or k == "user_event" then
			if type(v) == "table" then
				rawset(owner, k, vim.tbl_filter(function(e) return type(e) == "string" and #e > 0 end, v))
			elseif type(v) == "string" and #v > 0 then
				rawset(owner, k, { v })
			end
		elseif k == "timing" and type(v) == "boolean" then
			rawset(owner, k, v)
		elseif k == "config" and type(v) == "table" then
			rawset(owner, k, vim.tbl_deep_extend("force", owner[k], v))
		elseif k == "colors" and type(v) == "table" then
			rawset(owner, k, {
				fg = type(v.fg) == "string" and v.fg or nil,
				bg = type(v.bg) == "string" and v.bg or nil,
			})
		elseif k == "update" or k == "condition" or k == "on_load" then
			if type(v) == "function" then rawset(owner, k, v) end
		elseif k == "padding" then
			if type(v) == "number" then
				rawset(owner, k, math.floor(v < 0 and 0 or v))
			elseif type(v) == "table" then
				rawset(owner, k, {
					left = math.floor(type(v.left) == "number" and (v.left < 0 and 0 or v.left) or 1),
					right = math.floor(type(v.right) == "number" and (v.right < 0 and 0 or v.right) or 1),
				})
			end
		end
	end

	return instance
end

function Component:load()
	if self.is_loaded then return end
	self.on_load()
	self.is_loaded = true
end

return Component
