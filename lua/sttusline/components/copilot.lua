return {
	name = "copilot",
	user_event = {
		"CopilotStatusNormal",
		"CopilotStatusError",
		"CopilotStatusInProgress",
		"CopilotStatusWarning",
		"CopilotStatusUnknow",
	},
	configs = {
		icons = {
			normal = "",
			error = "",
			warning = "",
			inprogress = "",
		},
	},
	init = function()
		local nvim_exec_autocmds = vim.api.nvim_exec_autocmds
		local schedule = vim.schedule
		local g = vim.g
		vim.api.nvim_create_autocmd("InsertEnter", {
			once = true,
			desc = "Init copilot status",
			callback = function()
				local cp_api_ok, cp_api = pcall(require, "copilot.api")
				if cp_api_ok then
					cp_api.register_status_notification_handler(function(data)
						schedule(function()
							g.copilot_status = string.lower(data.status or "")
							if g.copilot_status == "normal" then
								nvim_exec_autocmds("User", { pattern = "CopilotStatusNormal", modeline = false })
							elseif g.copilot_status == "error" then
								nvim_exec_autocmds("User", { pattern = "CopilotStatusError", modeline = false })
							elseif g.copilot_status == "inprogress" then
								nvim_exec_autocmds("User", { pattern = "CopilotStatusInProgress", modeline = false })
							elseif g.copilot_status == "warning" then
								nvim_exec_autocmds("User", { pattern = "CopilotStatusWarning", modeline = false })
							else
								nvim_exec_autocmds("User", { pattern = "CopilotStatusUnknow", modeline = false })
							end
						end)
					end)
				end
			end,
		})
	end,
	update = function(configs)
		local g = vim.g
		if package.loaded["copilot"] then
			local cp_client_ok, cp_client = pcall(require, "copilot.client")
			if not cp_client_ok then
				g.copilot_status = "error"
				require("sttusline.utils.notify").error("Cannot load copilot.client")
				return
			end

			local copilot_client = cp_client.get()

			if not copilot_client then
				g.copilot_status = "error"
				return
			end

			local cp_api_ok, cp_api = pcall(require, "copilot.api")
			if not cp_api_ok then
				g.copilot_status = "error"
				require("sttusline.utils.notify").error("Cannot load copilot.api")
				return
			end
			cp_api.check_status(copilot_client, {}, function(cserr, status)
				if
					cserr
					or not status.user
					or status.status == "NoTelemetryConsent"
					or status.status == "NotAuthorized"
				then
					g.copilot_status = "error"
					return
				end

				g.copilot_status = cp_client.buf_is_attached(0) and "normal" or "error"
			end)
		end
		return configs.icons[g.copilot_status] or g.copilot_status or ""
	end,
}
