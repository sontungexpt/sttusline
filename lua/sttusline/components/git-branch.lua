local colors = require("sttusline.utils.color")

local get_branch = function()
	local git_dir = vim.fn.finddir(".git", ".;")
	if git_dir ~= "" then
		local head_file = io.open(git_dir .. "/HEAD", "r")
		if head_file then
			local content = head_file:read("*all")
			head_file:close()
			return content:match("ref: refs/heads/(.-)%s*$")
		end
		return ""
	end
	return ""
end
return {
	name = "git-branch",
	event = { "BufEnter" }, -- The component will be update when the event is triggered
	user_event = { "VeryLazy" },
	configs = {
		icon = "",
	},
	colors = { fg = colors.pink, bg = colors.bg }, -- { fg = colors.black, bg = colors.white }
	update = function(configs)
		local branch = get_branch()
		return branch ~= "" and configs.icon .. " " .. branch or ""
	end,
	condition = function() return vim.api.nvim_buf_get_option(0, "buflisted") end,
}
