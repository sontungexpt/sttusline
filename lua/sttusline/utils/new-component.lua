local notify = require("sttusline.utils.notify")
local fn = vim.fn

local NEW_COMPONENT_TEMPLATE = [[
-- Change NewComponent to your component name
local NewComponent = require("sttusline.component"):new()

-- The component will be update when the event is triggered
-- To disable default event, set NewComponent.event = {}
NewComponent.event = {}

-- The component will be update when the user event is triggered
-- To disable default user_event, set NewComponent.user_event = {}
NewComponent.user_event = { "VeryLazy" }

-- The component will be update every time interval
NewComponent.timing = false

-- The component will be update when the require("sttusline").setup() is called
NewComponent.lazy = true

-- The config of the component
NewComponent.config = {}

-- The number of spaces to add before and after the component
NewComponent.padding = 1 -- { left = 1, right = 1 }

-- The colors of the component
NewComponent.colors = {} -- { fg = colors.black, bg = colors.white }

-- The function will return the value of the component to display on the statusline
-- Must return a string
NewComponent.update = function() return "" end

-- The function will return the condition to display the component when the component is update
-- Must return a boolean
NewComponent.condition = function() return true end

-- The function will call on the first time component load
NewComponent.on_load = function() end

return NewComponent
]]

local M = {}

M.create_component_template = function()
	local new_file_path = fn.input("Enter the filename: ", fn.stdpath("config") .. "/", "file")

	if new_file_path == "" then
		notify.warn("No new_file_path given")
		return
	end

	if not new_file_path:match("%.lua$") then
		new_file_path = fn.fnamemodify(new_file_path, ":r") .. ".lua"
	end

	if fn.filereadable(new_file_path) == 1 then
		notify.warn("File already exists: " .. new_file_path)
		return
	end

	local file = io.open(new_file_path, "w")
	if file then
		file:write(NEW_COMPONENT_TEMPLATE)
		file:close()
		notify.info("Created new component: " .. new_file_path)
	else
		notify.warn("Failed to create new component: " .. new_file_path)
	end
end

return M
