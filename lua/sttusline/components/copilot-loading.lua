local copilot_status = ""
return {
	name = "copilot-loading",
	user_event = {
		"SttuslineCopilotStatusUpdate",
	},
	init = function(configs)
		local nvim_exec_autocmds = vim.api.nvim_exec_autocmds
		local schedule = vim.schedule
		local buf_get_option = vim.api.nvim_buf_get_option
		local sttusline_copilot_timer = vim.loop.new_timer()
		vim.api.nvim_create_autocmd("InsertEnter", {
			once = true,
			desc = "Init copilot status",
			callback = function()
				local cp_api_ok, cp_api = pcall(require, "copilot.api")
				if cp_api_ok then
					cp_api.register_status_notification_handler(function(data)
						schedule(function()
							-- don't need to get status when in TelescopePrompt
							if buf_get_option(0, "buftype") == "prompt" then return end
							copilot_status = string.lower(data.status or "")
							if copilot_status == "inprogress" then
								sttusline_copilot_timer:start(
									0,
									math.floor(1000 / configs.fps),
									vim.schedule_wrap(
										function()
											nvim_exec_autocmds(
												"User",
												{ pattern = "SttuslineCopilotStatusUpdate", modeline = false }
											)
										end
									)
								)
								return
							end
							sttusline_copilot_timer:stop()
							nvim_exec_autocmds("User", { pattern = "SttuslineCopilotStatusUpdate", modeline = false })
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
		fps = 3, -- should be 3 - 5
	},
	space = function(configs)
		local current_inprogress_index = 0
		local icons = configs.icons
		return {
			get_icon = function()
				if copilot_status == "inprogress" then
					current_inprogress_index = current_inprogress_index < #icons.inprogress
							and current_inprogress_index + 1
						or 1
					return icons.inprogress[current_inprogress_index]
				else
					current_inprogress_index = 0
					return icons[copilot_status] or copilot_status or ""
				end
			end,
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
		}
	end,
	update = function(_, space)
		if package.loaded["copilot"] then space.check_status() end
		return space.get_icon()
	end,
}
