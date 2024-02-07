local CACHED_FILE = vim.fn.stdpath("cache") .. "/sttusline/cached.lua"

local autocmd_cached = {
	[[
    local M = {}
    local vim = vim
    local api = vim.api
    local autocmd = api.nvim_create_autocmd
    local core = require("sttusline.core")
  ]],
}

local cache_autocmd = function(event, pattern, work)
	autocmd_cached[#autocmd_cached + 1] = string.format(
		[[
	    autocmd(%s, {
	      pattern = %s,
		    group = core.get_global_augroup(),
		    callback = function()
		      %s
		    end,
	    })
    ]],
		event,
		pattern,
		work
	)
end
