local colors = require("sttusline.utils.color")

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
		for _, key in ipairs(order) do
			local count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity[key] })

			if count > 0 then
				if should_add_spacing then
					table.insert(result, " " .. icons[key] .. " " .. count)
				else
					should_add_spacing = true
					table.insert(result, icons[key] .. " " .. count)
				end
			else
				table.insert(result, "")
			end
		end
		return result
	end,
	condition = function()
		local filetype = vim.api.nvim_buf_get_option(0, "filetype")
		return filetype ~= "lazy"
	end,
}
