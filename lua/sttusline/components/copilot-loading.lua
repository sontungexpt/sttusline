local copilot_status = ""
return {
	name = "copilot-loading",
	user_event = {
		"CopilotStatusNormal",
		"CopilotStatusError",
		"CopilotStatusInProgress",
		"CopilotStatusWarning",
		"CopilotStatusUnknow",
	},
	init = function(configs)
		local nvim_exec_autocmds = vim.api.nvim_exec_autocmds
		local schedule = vim.schedule
		local sttusline_copilot_timer = vim.loop.new_timer()
		vim.api.nvim_create_autocmd("InsertEnter", {
			once = true,
			desc = "Init copilot status",
			callback = function()
				local cp_api_ok, cp_api = pcall(require, "copilot.api")
				if cp_api_ok then
					cp_api.register_status_notification_handler(function(data)
						schedule(function()
							copilot_status = string.lower(data.status or "")
							if copilot_status == "normal" then
								nvim_exec_autocmds("User", { pattern = "CopilotStatusNormal", modeline = false })
							elseif copilot_status == "error" then
								nvim_exec_autocmds("User", { pattern = "CopilotStatusError", modeline = false })
							elseif copilot_status == "inprogress" then
								sttusline_copilot_timer:start(
									0,
									configs.loading_speed,
									vim.schedule_wrap(
										function()
											nvim_exec_autocmds(
												"User",
												{ pattern = "CopilotStatusInProgress", modeline = false }
											)
										end
									)
								)
								return
							elseif copilot_status == "warning" then
								nvim_exec_autocmds("User", { pattern = "CopilotStatusWarning", modeline = false })
							else
								nvim_exec_autocmds("User", { pattern = "CopilotStatusUnknow", modeline = false })
							end
							sttusline_copilot_timer:stop()
						end)
					end)
				end
			end,
		})
	end,
	configs = {
		icons = {
			normal = "",
			error = "",
			warning = "",
			inprogress = { "", "󰪞", "󰪟", "󰪠", "󰪢", "󰪣", "󰪤", "󰪥" },
		},
		loading_speed = 200, -- ms
	},
	space = {
		check_status = function()
			local cp_client_ok, cp_client = pcall(require, "copilot.client")

			if not cp_client_ok then
				copilot_status = "error"
				require("sttusline.utils.notify").error("Cannot load copilot.client")
				return
			end

			local copilot_client = cp_client.get()

			if not copilot_client then
				copilot_status = "error"
				return
			end

			local cp_api_ok, cp_api = pcall(require, "copilot.api")

			if not cp_api_ok then
				copilot_status = "error"
				require("sttusline.utils.notify").error("Cannot load copilot.api")
				return
			end

			cp_api.check_status(copilot_client, {}, function(cserr, status)
				if cserr or not status.user or status.status ~= "OK" then
					copilot_status = "error"
					return
				end
			end)
		end,
	},
	update = function(configs, space)
		if package.loaded["copilot"] then space.check_status() end
		local icon = configs.icons[copilot_status]
		if copilot_status == "inprogress" then
			return icon[math.floor(vim.loop.hrtime() / 1000000 / configs.loading_speed) % #icon + 1] or ""
		else
			return icon or copilot_status or ""
		end
	end,
}
