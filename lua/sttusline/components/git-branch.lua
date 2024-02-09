local fn = vim.fn
local api = vim.api
local colors = require("sttusline.util.color")

return {
	name = "git-branch",
	event = "BufEnter",
	user_event = { "VeryLazy", "GitSignsUpdate" },
	configs = {
		icon = "",
	},
	colors = { fg = colors.pink },
	update = function(configs, state)
		local branch = ""
		local git_dir = fn.finddir(".git", ".;")
		if git_dir ~= "" then
			local head_file = io.open(git_dir .. "/HEAD", "r")
			if head_file then
				local content = head_file:read("*all")
				head_file:close()
				-- branch name  or commit hash
				branch = content:match("ref: refs/heads/(.-)%s*$") or content:sub(1, 7) or ""
			end
		end
		return branch ~= "" and configs.icon .. " " .. branch or ""
	end,
	condition = function() return api.nvim_buf_get_option(0, "buflisted") end,
}
