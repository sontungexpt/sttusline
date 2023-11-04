local colors = require("sttusline.utils.color")
local diag = vim.diagnostic

local Diagnostics = require("sttusline.component").new()
Diagnostics.set_colors {
	{ fg = colors.tokyo_diagnostics_error },
	{ fg = colors.tokyo_diagnostics_warn },
	{ fg = colors.tokyo_diagnostics_hint },
	{ fg = colors.tokyo_diagnostics_info },
}

Diagnostics.set_config {
	icons = {
		ERROR = "",
		INFO = "",
		HINT = "󰌵",
		WARN = "",
	},
	order = { "ERROR", "WARN", "INFO", "HINT" },
}

Diagnostics.set_event {
	"DiagnosticChanged",
}

Diagnostics.set_user_event {}

Diagnostics.set_condition(function()
	local filetype = vim.api.nvim_buf_get_option(0, "filetype")
	return filetype ~= "lazy"
end)

Diagnostics.set_update(function()
	local result = {}

	local config = Diagnostics.get_config()
	local icons = config.icons
	local order = config.order

	local should_add_spacing = false
	for _, key in ipairs(order) do
		local count = #diag.get(0, { severity = diag.severity[key] })

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
end)

return Diagnostics
