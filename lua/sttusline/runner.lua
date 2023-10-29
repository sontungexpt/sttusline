local M = {}

local api = vim.api
local autocmd = api.nvim_create_autocmd
local augroup = api.nvim_create_augroup
local COMPONENT_PARENT_MODULE = "sttusline.components"

local component_cache = {}
local event_component_cache = {}
local timming_component_cache = {}

local statusline = {}

local foreach_component = function(opts, comp_cb, empty_comp_cb)
	if #component_cache > 0 then
		for _, component in ipairs(component_cache) do
			comp_cb(component)
		end
	else
		for _, component in ipairs(opts.components) do
			if type(component) == "string" and #component > 0 then
				if component == "%=" then
					empty_comp_cb(component)
					component_cache[#component_cache + 1] = component
				else
					local status_ok, real_comp = pcall(require, COMPONENT_PARENT_MODULE .. "." .. component)
					if status_ok then
						comp_cb(real_comp)
						component_cache[#component_cache + 1] = real_comp
					else
					end
				end
			end
		end
	end
end

return M
