local colors = require("sttusline.utils.color")

return {
	name = "git-branch",
	event = { "BufEnter" },
	user_event = { "VeryLazy", "GitSignsUpdate" },
	configs = {
		icon = "",
	},
	colors = { fg = colors.pink },
	space = {
		get_branch = function()
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
		end,
	},
	update = function(configs, _, space)
		local branch = space.get_branch()
		return branch ~= "" and configs.icon .. " " .. branch or ""
	end,
	condition = function() return vim.api.nvim_buf_get_option(0, "buflisted") end,
}
