return {
	name = "nvim-dap",
	event = { "CursorHold", "CursorMoved", "BufEnter" }, -- The component will be update when the event is triggered
	update = function() return require("dap").status() end,
	condition = function()
		local session = require("dap").session()
		return session ~= nil
	end,
}
