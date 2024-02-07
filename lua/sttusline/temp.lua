-- local len = #update_value
-- local values = {}
-- if comp.color_expanded == false then
-- 	for i, v in ipairs(update_value) do
-- 		v.__hl_name = comp.__hl_name .. "_" .. i
-- 		if type(v) == "string" then
-- 			if i == 1 then
-- 				if type(comp.padding) == "table" then
-- 					update_value[i] = add_left_padding(v, comp.padding.left)
-- 				end

-- 				update_value[i] = util.add_hl_group_name(update_value[i], v.__hl_name)

-- 				if type(comp.separator) == "table" then
-- 					update_value[i] = add_left_separator(update_value[i], comp.separator.left, hl_name_i_sep)
-- 				end
-- 			end
-- 		elseif type(v) == "table" and type(v.value) == "string" then
-- 		end

-- 		if i == 1 then
-- 			if type(v) == "string" then
-- 				if type(comp.padding) == "table" then
-- 					update_value[i] = add_left_padding(v, comp.padding.left)
-- 				end

-- 				update_value[i] = util.add_hl_group_name(update_value[i], hl_name_i)

-- 				if type(comp.separator) == "table" then
-- 					update_value[i] = add_left_separator(update_value[i], comp.separator.left, hl_name_i_sep)
-- 				end
-- 			elseif type(v) == "table" then
-- 				v.value = handle_str_returned(v.value, v)
-- 			end
-- 		elseif i == #len then
-- 			if type(v) == "string" then
-- 				if type(comp.padding) == "table" then
-- 					update_value[i] = add_right_padding(v, comp.padding.left)
-- 				end

-- 				update_value[i] = util.add_hl_group_name(update_value[i], hl_name_i)

-- 				if type(comp.separator) == "table" then
-- 					update_value[i] = add_right_separator(update_value[i], comp.separator.left, hl_name_i_sep)
-- 				end
-- 			elseif type(v) == "table" then
-- 			end
-- 		else
-- 		end
-- 	end
-- else
-- end
--
local add_left_padding = function(str, num)
	if type(num) == "number" then return (" "):rep(num) .. str end
	return " " .. str
end

local add_right_padding = function(str, num)
	if type(num) == "number" then return str .. (" "):rep(num) end
	return str .. " "
end

local add_padding = function(str, nums)
	if str == "" then
		return ""
	elseif nums == nil then
		return " " .. str .. " "
	elseif type(nums) == "number" then
		if nums < 1 then return str end -- no padding
		local padding = (" "):rep(math.floor(nums))
		return padding .. str .. padding
	elseif type(nums) == "table" then
		return add_right_padding(add_left_padding(str, nums.left), nums.right)
	end

	return str
end

local add_left_separator = function(str, sep, sep_hl_name)
	if type(sep) == "string" then
		return util.add_hl_group_name(sep, sep_hl_name .. "_left") .. str
	elseif type(sep) == "table" and type(sep.value) == "string" then
		return util.add_hl_group_name(sep.value, sep_hl_name .. "_left") .. str
	end
	return str
end

local add_right_separator = function(str, sep, sep_hl_name)
	if type(sep) == "string" then
		return str .. util.add_hl_group_name(sep, sep_hl_name .. "_right")
	elseif type(sep) == "table" and type(sep.value) then
		return str .. util.add_hl_group_name(sep.value, sep_hl_name .. "_right")
	end
	return str
end

local add_separator = function(str, seps, hl_name)
	if type(seps) ~= "table" or str == "" then return str end
	if seps.left ~= nil then str = add_left_separator(str, seps.left, hl_name .. "_sep") end
	if seps.right ~= nil then str = add_right_separator(str, seps.right, hl_name .. "_sep") end
	return str
end

local add_padding = function(str, hl_name, padding)
	if str == "" then
		return str
	elseif padding == nil then
		return util.add_hl_group_name(str)
	elseif type(padding) == "number" then
		if padding < 1 then return util.add_hl_group_name(str) end -- no padding
		local space = (" "):rep(math.floor(padding))
		return space .. util.add_hl_group_name(str) .. space
	elseif type(padding) == "table" then
		local left = type(padding.left) == "number" and padding.left or 1
		local right = type(padding.right) == "number" and padding.right or 1
		local left_padding = left < 1 and "" or (" "):rep(math.floor(left))
		local right_padding = right < 1 and "" or (" "):rep(math.floor(right))
		if padding.spread_out == false then
			-- color not include padding
			return arrange3(left_padding, util.add_hl_group_name(str, hl_name), right_padding)
		else
			return util.add_hl_group_name(arrange5(left_padding, str, right_padding), hl_name)
		end
	end
end

local handle_str_returned = function(str, hl_name, sep, padding)
	if str == "" then
		return str
	elseif padding == nil then
		return add_separator(highlight.add_hl_group_name(" " .. str .. " ", hl_name), hl_name, sep)
	elseif type(padding) == "number" then
		if padding < 1 then return add_separator(highlight.add_hl_group_name(str, hl_name), hl_name, sep) end -- no padding
		local space = (" "):rep(math.floor(padding))
		return add_separator(highlight.add_hl_group_name(space .. str .. space, hl_name), hl_name, sep) -- add color to padding
	elseif type(padding) == "table" then
		local left = type(padding.left) == "number" and padding.left or 1
		local right = type(padding.right) == "number" and padding.right or 1
		local left_padding = left < 1 and "" or (" "):rep(math.floor(left))
		local right_padding = right < 1 and "" or (" "):rep(math.floor(right))

		if padding.spread_out == false then
			return left_padding
				.. add_separator(highlight.add_hl_group_name(str, hl_name), hl_name, sep)
				.. right_padding
		else
			return add_separator(
				highlight.add_hl_group_name(left_padding .. str .. right_padding, hl_name),
				hl_name,
				sep
			) -- add color to padding
		end
	end
end

local arrange5 = function(a, b, c, d, e) return format("%s%s%s%s%s", a, b, c, d, e) end
local arrange3 = function(a, b, c) return format("%s%s%s", a, b, c) end
