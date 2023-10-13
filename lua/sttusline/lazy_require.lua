local loaded_modules = {}

local function lazy_require(module_name)
	if not loaded_modules[module_name] then loaded_modules[module_name] = require(module_name) end
	return loaded_modules[module_name]
end

return lazy_require
