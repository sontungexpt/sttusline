local colors = require("sttusline.utils.color")
local diagnostics = vim.diagnostics

return {
	name = "diagnostics",
	event = { "DiagnosticChanged" }, -- The component will be update when the event is triggered
	colors = {
		{ fg = colors.tokyo_diagnostics_error },
		{ fg = colors.tokyo_diagnostics_warn },
		{ fg = colors.tokyo_diagnostics_hint },
		{ fg = colors.tokyo_diagnostics_info },
	},
	configs = {
		icons = {
			ERROR = "",
			INFO = "",
			HINT = "󰌵",
			WARN = "",
		},
		order = { "ERROR", "WARN", "INFO", "HINT" },
	},
	update = function(configs)
		local result = {}

		local icons = configs.icons
		local order = configs.order

		local should_add_spacing = false
		for index, key in ipairs(order) do
			local count = #diagnostics.get(0, { severity = diagnostics.severity[key] })

			if count > 0 then
				if should_add_spacing then
					result[index] = " " .. icons[key] .. " " .. count
				else
					should_add_spacing = true
					result[index] = icons[key] .. " " .. count
				end
			else
				result[index] = ""
			end
		end
		return result
	end,
	condition = function() return vim.api.nvim_buf_get_option(0, "filetype") ~= "lazy" end,
}
