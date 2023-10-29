local M = {}

M.eval_func = function(func, ...)
	if type(func) == "function" then return func(...) end
end

M.eval_component_func = function(component, func, ...)
	return M.eval_func(
		component[func],
		type(component.configs) == "table" and component.configs or {},
		type(component.utils) == "table" and component.utils or {},
		...
	)
end

return M
