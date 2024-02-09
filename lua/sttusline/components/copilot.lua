local api = vim.api
local uv = vim.loop

return {
	name = "copilot",
	user_event = "SttuslineCopilotLoad",
	configs = {
		icons = {
			normal = "",
			error = "",
			warning = "",
			inprogress = "",
		},
	},
	init = function(configs)
		local nvim_exec_autocmds = api.nvim_exec_autocmds
		local schedule = vim.schedule
		local buf_get_option = api.nvim_buf_get_option
		local status = ""

		api.nvim_create_autocmd("InsertEnter", {
			once = true,
			desc = "Init copilot status",
			callback = function()
				local cp_api_ok, cp_api = pcall(require, "copilot.api")
				if cp_api_ok then
					cp_api.register_status_notification_handler(function(data)
						schedule(function()
							-- don't need to get status when in prompt
							if buf_get_option(0, "buftype") == "prompt" then return end

							status = string.lower(data.status or "")
							nvim_exec_autocmds("User", { pattern = "SttuslineCopilotLoad", modeline = false })
						end)
					end)
				end
			end,
		})

		return {
			check_status = function()
				local cp_client_ok, cp_client = pcall(require, "copilot.client")
				if not cp_client_ok then
					status = "error"
					require("sttusline.util.notify").error("Cannot load copilot.client")
					return
				end

				local copilot_client = cp_client.get()
				if not copilot_client then
					status = "error"
					return
				end

				local cp_api_ok, cp_api = pcall(require, "copilot.api")
				if not cp_api_ok then
					status = "error"
					require("sttusline.util.notify").error("Cannot load copilot.api")
					return
				end

				cp_api.check_status(copilot_client, {}, function(cserr, status_copilot)
					if cserr or not status_copilot.user or status_copilot.status ~= "OK" then
						status = "error"
						return
					end
				end)
			end,
			get_status = function() return status end,
		}
	end,
	update = function(configs, state)
		if package.loaded["copilot"] then state.check_status() end
		return configs.icons[state.get_status()] or state.get_status() or ""
	end,
}
