local Component = {}
Component.__index = Component

local format_event = function(event)
	if type(event) == "table" then
		return vim.tbl_filter(function(e_name) return type(e_name) == "string" and #e_name > 0 end, event)
	elseif type(event) == "string" and #event > 0 then
		return { event }
	end
end

function Component.new()
	local component_data = {
		event = {}, -- The component will be update when the event is triggered
		user_event = { "VeryLazy" },

		timing = false, -- The component will be update every time interval
		lazy = true,

		config = {},

		-- number or table
		padding = 1, -- { left = 1, right = 1 }
		colors = {}, -- { fg = colors.black, bg = colors.white }

		-- The returning string function to display on the statusline
		update = function() return "" end,
		-- The returning boolean function to check if the component should be display
		condition = function() return true end,

		-- Show the load status of the component
		is_loaded = false,

		-- The function will call on the first time component load
		onload = function() end,

		-- The function will call when the component is highlight
		onhighlight = function() end,
	}

	local instance = {
		get_event = function() return component_data.event end,
		set_event = function(event) component_data.event = format_event(event) end,

		get_user_event = function() return component_data.user_event end,
		set_user_event = function(event) component_data.user_event = format_event(event) end,

		get_timing = function() return component_data.timing end,
		set_timing = function(timing)
			if type(timing) == "boolean" then component_data.timing = timing end
		end,

		get_lazy = function() return component_data.lazy end,
		set_lazy = function(lazy)
			if type(lazy) == "boolean" then component_data.lazy = lazy end
		end,

		get_config = function() return component_data.config end,
		set_config = function(opts)
			component_data.config = vim.tbl_deep_extend("force", component_data.config, opts)
		end,

		get_padding = function() return component_data.padding end,
		set_padding = function(padding)
			if type(padding) == "number" then
				component_data.padding = math.floor(padding < 0 and 0 or padding)
			elseif type(padding) == "table" then
				component_data.padding = {
					left = math.floor(
						type(padding.left) == "number" and (padding.left < 0 and 0 or padding.left) or 1
					),
					right = math.floor(
						type(padding.right) == "number" and (padding.right < 0 and 0 or padding.right) or 1
					),
				}
			end
		end,

		get_colors = function() return component_data.colors end,
		set_colors = function(colors)
			if type(colors) == "table" then
				component_data.colors = {
					fg = type(colors.fg) == "string" and colors.fg or nil,
					bg = type(colors.bg) == "string" and colors.bg or nil,
				}
			end
		end,

		get_update = function() return component_data.update end,
		set_update = function(update)
			if type(update) == "function" then component_data.update = update end
		end,

		get_condition = function() return component_data.condition end,
		set_condition = function(condition)
			if type(condition) == "function" then component_data.condition = condition end
		end,

		get_onload = function() return component_data.onload end,
		set_onload = function(onload)
			if type(onload) == "function" then component_data.onload = onload end
		end,

		get_onhighlight = function() return component_data.onhighlight end,
		set_onhighlight = function(onhighlight)
			if type(onhighlight) == "function" then component_data.onhighlight = onhighlight end
		end,

		load = function()
			if component_data.is_loaded then return end
			component_data.onload()
			component_data.is_loaded = true
		end,

		is_loaded = function() return component_data.is_loaded end,
	}

	return setmetatable(instance, Component)
end

return Component
