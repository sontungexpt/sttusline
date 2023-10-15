local colors = require("sttusline.utils.color")

local GitBranch = require("sttusline.component").new()

GitBranch.set_colors { fg = colors.pink, bg = colors.bg }
GitBranch.set_config { icon = "" }
GitBranch.set_event { "BufEnter" }
-- GitBranch.set_lazy(false)
-- GitBranch.set_timing(true)

GitBranch.set_update(function()
	-- if not vim.b.gitsigns_head or vim.b.gitsigns_git_status then return "" end

	-- return GitBranch.get_config().icon .. " " .. vim.b.gitsigns_status_dict.head .. ""
end)

return GitBranch
