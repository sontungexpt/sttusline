local api = vim.api

return {
	name = "diagnostics",
	event = "DiagnosticChanged",
	configs = {
		ERROR = {
			value = "",
			colors = { fg = "DiagnosticError" },
		},
		WARN = {
			value = "",
			colors = { fg = "DiagnosticWarn" },
		},
		INFO = {
			value = "",
			colors = { fg = "DiagnosticInfo" },
		},
		HINT = {
			value = "",
			colors = { fg = "DiagnosticHint" },
		},
		order = { "ERROR", "WARN", "INFO", "HINT" },
	},
	update = function(configs)
		local result = {}

		local should_add_spacing = false
		for _, key in ipairs(configs.order) do
			local count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity[key] })

			if count > 0 then
				result[#result + 1] = {
					value = configs[key].value .. " " .. count,
					colors = configs[key].colors,
					hl_update = true,
					padding = should_add_spacing and { left = 1 } or nil,
				}
				should_add_spacing = true
			end
		end

		return result
	end,
	condition = function()
		return api.nvim_buf_get_option(0, "filetype") ~= "lazy"
			and not api.nvim_buf_get_name(0):match("%.env$")
	end,
}
