local utils = require("sttusline.utils")
local colors = require("sttusline.utils.color")

local Mode = require("sttusline.component").new()

Mode.set_config {
	modes = {
		["n"] = { "NORMAL", "STTUSLINE_NORMAL_MODE" },
		["no"] = { "NORMAL (no)", "STTUSLINE_NORMAL_MODE" },
		["nov"] = { "NORMAL (nov)", "STTUSLINE_NORMAL_MODE" },
		["noV"] = { "NORMAL (noV)", "STTUSLINE_NORMAL_MODE" },
		["noCTRL-V"] = { "NORMAL", "STTUSLINE_NORMAL_MODE" },
		["niI"] = { "NORMAL i", "STTUSLINE_NORMAL_MODE" },
		["niR"] = { "NORMAL r", "STTUSLINE_NORMAL_MODE" },
		["niV"] = { "NORMAL v", "STTUSLINE_NORMAL_MODE" },

		["nt"] = { "TERMINAL", "STTUSLINE_NTERMINAL_MODE" },
		["ntT"] = { "TERMINAL (ntT)", "STTUSLINE_NTERMINAL_MODE" },

		["v"] = { "VISUAL", "STTUSLINE_VISUAL_MODE" },
		["vs"] = { "V-CHAR (Ctrl O)", "STTUSLINE_VISUAL_MODE" },
		["V"] = { "V-LINE", "STTUSLINE_VISUAL_MODE" },
		["Vs"] = { "V-LINE", "STTUSLINE_VISUAL_MODE" },
		[""] = { "V-BLOCK", "STTUSLINE_VISUAL_MODE" },

		["i"] = { "INSERT", "STTUSLINE_INSERT_MODE" },
		["ic"] = { "INSERT (completion)", "STTUSLINE_INSERT_MODE" },
		["ix"] = { "INSERT completion", "STTUSLINE_INSERT_MODE" },

		["t"] = { "TERMINAL", "STTUSLINE_TERMINAL_MODE" },
		["!"] = { "SHELL", "STTUSLINE_TERMINAL_MODE" },

		["R"] = { "REPLACE", "STTUSLINE_REPLACE_MODE" },
		["Rc"] = { "REPLACE (Rc)", "STTUSLINE_REPLACE_MODE" },
		["Rx"] = { "REPLACEa (Rx)", "STTUSLINE_REPLACE_MODE" },
		["Rv"] = { "V-REPLACE", "STTUSLINE_REPLACE_MODE" },
		["Rvc"] = { "V-REPLACE (Rvc)", "STTUSLINE_REPLACE_MODE" },
		["Rvx"] = { "V-REPLACE (Rvx)", "STTUSLINE_REPLACE_MODE" },

		["s"] = { "SELECT", "STTUSLINE_SELECT_MODE" },
		["S"] = { "S-LINE", "STTUSLINE_SELECT_MODE" },
		[""] = { "S-BLOCK", "STTUSLINE_SELECT_MODE" },

		["c"] = { "COMMAND", "STTUSLINE_COMMAND_MODE" },
		["cv"] = { "COMMAND", "STTUSLINE_COMMAND_MODE" },
		["ce"] = { "COMMAND", "STTUSLINE_COMMAND_MODE" },

		["r"] = { "PROMPT", "STTUSLINE_CONFIRM_MODE" },
		["rm"] = { "MORE", "STTUSLINE_CONFIRM_MODE" },
		["r?"] = { "CONFIRM", "STTUSLINE_CONFIRM_MODE" },
		["x"] = { "CONFIRM", "STTUSLINE_CONFIRM_MODE" },
	},
	mode_colors = {
		["STTUSLINE_NORMAL_MODE"] = { fg = colors.blue, bg = colors.bg },
		["STTUSLINE_INSERT_MODE"] = { fg = colors.green, bg = colors.bg },
		["STTUSLINE_VISUAL_MODE"] = { fg = colors.purple, bg = colors.bg },
		["STTUSLINE_NTERMINAL_MODE"] = { fg = colors.gray, bg = colors.bg },
		["STTUSLINE_TERMINAL_MODE"] = { fg = colors.cyan, bg = colors.bg },
		["STTUSLINE_REPLACE_MODE"] = { fg = colors.red, bg = colors.bg },
		["STTUSLINE_SELECT_MODE"] = { fg = colors.magenta, bg = colors.bg },
		["STTUSLINE_COMMAND_MODE"] = { fg = colors.yellow, bg = colors.bg },
		["STTUSLINE_CONFIRM_MODE"] = { fg = colors.yellow, bg = colors.bg },
	},
	auto_hide_on_vim_resized = true,
}

Mode.set_event { "ModeChanged", "VimResized" }
Mode.set_padding(0)
Mode.set_condition(function()
	if Mode.get_config().auto_hide_on_vim_resized then
		if vim.o.columns > 70 then
			vim.opt.showmode = false
			return true
		else
			vim.opt.showmode = true
			return false
		end
	end
end)

Mode.set_update(function()
	local mode_code = vim.api.nvim_get_mode().mode
	local mode = Mode.get_config().modes[mode_code]
	if mode then
		local hl_name = mode[2]
		vim.api.nvim_set_hl(0, hl_name, Mode.get_config().mode_colors[hl_name])
		return utils.add_highlight_name(" " .. mode[1] .. " ", hl_name)
	end
	return " " .. mode_code .. " "
end)

return Mode
