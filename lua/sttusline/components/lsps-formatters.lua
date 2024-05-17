local colors = require("sttusline.utils.color")

return {
	name = "lsps-formatters",
	event = { "LspAttach", "LspDetach", "BufWritePost", "BufEnter", "VimResized" }, -- The component will be update when the event is triggered
	colors = { fg = colors.magenta }, -- { fg = colors.black, bg = colors.white }
	update = function()
		local buf_clients = vim.lsp.get_clients()
		local server_names = {}
		local has_null_ls = false
		local ignore_lsp_servers = {
			["null-ls"] = true,
			["copilot"] = true,
		}

		for _, client in pairs(buf_clients) do
			local client_name = client.name
			if not ignore_lsp_servers[client_name] then table.insert(server_names, client_name) end
		end

		if package.loaded["null-ls"] then
			local null_ls = nil
			has_null_ls, null_ls = pcall(require, "null-ls")

			if has_null_ls then
				local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
				local null_ls_methods = {
					null_ls.methods.DIAGNOSTICS,
					null_ls.methods.DIAGNOSTICS_ON_OPEN,
					null_ls.methods.DIAGNOSTICS_ON_SAVE,
					null_ls.methods.FORMATTING,
				}

				local get_null_ls_sources = function(methods, name_only)
					local sources = require("null-ls.sources")
					local available_sources = sources.get_available(buf_ft)

					methods = type(methods) == "table" and methods or { methods }

					-- methods = nil or {}
					if #methods == 0 then
						if name_only then
							return vim.tbl_map(function(source) return source.name end, available_sources)
						end
						return available_sources
					end

					local source_results = {}

					for _, source in ipairs(available_sources) do
						for _, method in ipairs(methods) do
							if source.methods[method] then
								if name_only then
									table.insert(source_results, source.name)
								else
									table.insert(source_results, source)
								end
								break
							end
						end
					end

					return source_results
				end

				local null_ls_builtins = get_null_ls_sources(null_ls_methods, true)
				vim.list_extend(server_names, null_ls_builtins)
			end
		end

		if package.loaded["conform"] then
			local has_conform, conform = pcall(require, "conform")
			if has_conform then
				vim.list_extend(
					server_names,
					vim.tbl_map(function(formatter) return formatter.name end, conform.list_formatters(0))
				)
				if has_null_ls then server_names = vim.fn.uniq(server_names) end
			end
		end

		return #server_names > 0 and table.concat(server_names, ", ") or "NO LSP, FORMATTER  "
	end,
	condition = function() return vim.o.columns > 70 end,
}
