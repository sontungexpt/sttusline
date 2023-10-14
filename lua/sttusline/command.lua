local M = {}

M.setup = function(opts)
	vim.api.nvim_create_user_command(
		"SttuslineNewComponent",
		function() require("sttusline.utils.new-component").create_component_template() end,
		{ nargs = 0 }
	)
end

return M
