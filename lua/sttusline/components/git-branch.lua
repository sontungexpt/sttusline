local fn = vim.fn
local colors = require("sttusline.utils.color")

local GitBranch = require("sttusline.component").new()

GitBranch.set_colors { fg = colors.pink, bg = colors.bg }
GitBranch.set_config { icon = " " }
GitBranch.set_event { "TermResponse" }

local is_inside_git = function()
	fn.system(
		"git -C " .. '"' .. fn.expand("%:p:h") .. '"' .. " rev-parse --show-toplevel >/dev/null 2>&1"
	)
	return vim.v.shell_error == 0
end

GitBranch.set_update(function()
	if is_inside_git() then
		local handle = io.popen(
			"git -C " .. '"' .. fn.expand("%:p:h") .. '"' .. " rev-parse --abbrev-ref HEAD 2>/dev/null"
		)
		local branch = ""
		if handle then
			branch = handle:read("*a")
			handle:close()
			branch = branch:gsub("\n", "")
			return branch
		end
		return ""
	end
end)

return GitBranch
