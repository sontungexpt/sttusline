local notify = require("sttusline.utils.notify")
local fn = vim.fn

local NEW_COMPONENT_TEMPLATE = [[
-- Change NewComponent to your component name
local utils = require("sttusline.utils")
local NewComponent = require("sttusline.set_component").new()

-- The component will be update when the event is triggered
-- To disable default event, set NewComponent.set_event = {}
NewComponent.set_event {}

-- The component will be update when the user event is triggered
-- To disable default user_event, set NewComponent.set_user_event = {}
NewComponent.set_user_event { "VeryLazy" }

-- The component will be update every time interval
NewComponent.set_timing(false)

-- The component will be update when the require("sttusline").setup() is called
NewComponent.set_lazy(true)

-- The config of the component
-- After set_config, the config will be available in the component
-- You can access the config by NewComponent.get_config()
NewComponent.set_config {}

-- The number of spaces to add before and after the component
NewComponent.set_padding(1)
-- or NewComponent.set_padding{ left = 1, right = 1 }

-- The colors of the component
NewComponent.set_colors {} -- { fg = colors.set_black, bg = colors.set_white }

-- The function will return the value of the component to display on the statusline
-- Must return a string
NewComponent.set_update(function() return "" end)
-- NOTE:
-- If you don't use NewComponent.set_colors{} and you want to customize the highlight of your component
-- You should use utils.add_highlight_name(value, highlight_name) to add the highlight name to the value
-- After that you can set the highlight of your component by using vim.api.nvim_set_hl(0, highlight_name, opts) (You should add this to NewComponent.set_onhighlight)
-- The function utils.add_highlight_name(value,highlight_name) will return the value
-- So you can use it like this:
-- NewComponent.set_update(function() return utils.add_highlight_name("Hello", "HelloHighlight") end)
-- NewComponent.set_onhighlight(function() vim.api.nvim_set_hl(0, "HelloHighlight", { fg = "#ffffff", bg = "#000000" }) end)


-- The function will call when the component is highlight
-- You should use it to set the highlight of the component
-- Example:
-- NewComponent.set_onhighlight(function() vim.api.nvim_set_hl(0, "ComponentHighlight", { fg = colors.set_black, bg = colors.set_white }) end)
NewComponent.set_onhighlight(function() end)

-- The function will return the condition to display the component when the component is update
-- Must return a boolean
NewComponent.set_condition(function() return true end)

-- The function will call on the first time component load
NewComponent.set_onload(function() end)


return NewComponent
]]

local M = {}

M.create_component_template = function()
	local new_file_path = fn.input("Enter the filename: ", fn.stdpath("config") .. "/", "file")

	if new_file_path == "" then
		notify.warn("No new_file_path given")
		return
	end

	local is_lua = new_file_path:match("%.lua$")
	local is_vim = new_file_path:match("%.vim$")

	if not is_lua and not is_vim then new_file_path = fn.fnamemodify(new_file_path, ":r") .. ".lua" end

	if fn.filereadable(new_file_path) == 1 then
		notify.warn("File already exists: " .. new_file_path)
		return
	end

	-- Create parent directory if not exists
	local parent_dir = fn.fnamemodify(new_file_path, ":h")
	if fn.isdirectory(parent_dir) ~= 1 then fn.mkdir(parent_dir, "p") end

	local file = io.open(new_file_path, "w")
	if file then
		if is_vim then NEW_COMPONENT_TEMPLATE = "lua << EOF\n" .. NEW_COMPONENT_TEMPLATE .. "\nEOF" end

		file:write(NEW_COMPONENT_TEMPLATE)
		file:close()
		notify.info("Created new component: " .. new_file_path)
	else
		notify.warn("Failed to create new component: " .. new_file_path)
	end
end

return M
