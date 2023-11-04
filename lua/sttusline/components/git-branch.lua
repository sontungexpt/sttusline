local colors = require("sttusline.utils.color")

local GitBranch = require("sttusline.component").new()

GitBranch.set_colors { fg = colors.pink }
GitBranch.set_config {
	icon = "",
}
GitBranch.set_event { "BufEnter" }
GitBranch.set_user_event { "VeryLazy", "GitSignsUpdate" }

local get_branch = function()
	local git_dir = vim.fn.finddir(".git", ".;")
	if git_dir ~= "" then
		local head_file = io.open(git_dir .. "/HEAD", "r")
		if head_file then
			local content = head_file:read("*all")
			head_file:close()
			-- branch name  or commit hash
			return content:match("ref: refs/heads/(.-)%s*$") or content:sub(1, 7) or ""
		end
		return ""
	end
	return ""
end

GitBranch.set_condition(function() return vim.api.nvim_buf_get_option(0, "buflisted") end)

GitBranch.set_update(function()
	local branch = get_branch()
	return branch ~= "" and GitBranch.get_config().icon .. " " .. branch or ""
end)

return GitBranch
