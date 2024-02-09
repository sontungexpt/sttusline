local api = vim.api
local uv = vim.uv or vim.loop

return {
	name = "copilot-loading",
	user_event = "SttuslineCopilotLoad",
	configs = {
		icons = {
			normal = "",
			error = "",
			warning = "",
			inprogress = { "", "󰪞", "󰪟", "󰪠", "󰪢", "󰪣", "󰪤", "󰪥" },
		},
		fps = 3, -- should be 3 - 5
	},
	init = function(configs)
		local nvim_exec_autocmds = api.nvim_exec_autocmds
		local schedule = vim.schedule
		local buf_get_option = api.nvim_buf_get_option
		local timer = uv.new_timer()
		local curr_inprogress_index = 0
		local icons = configs.icons
		local status = ""

		api.nvim_create_autocmd("InsertEnter", {
			once = true,
			desc = "Init copilot status",
			callback = function()
				local cp_api_ok, cp_api = pcall(require, "copilot.api")
				if cp_api_ok then
					cp_api.register_status_notification_handler(function(data)
						schedule(function()
							-- don't need to get status when in TelescopePrompt
							if buf_get_option(0, "buftype") == "prompt" then return end
							status = string.lower(data.status or "")

							if status == "inprogress" then
								timer:start(
									0,
									math.floor(1000 / configs.fps),
									vim.schedule_wrap(
										function()
											nvim_exec_autocmds("User", { pattern = "SttuslineCopilotLoad", modeline = false })
										end
									)
								)
								return
							end
							timer:stop()
							nvim_exec_autocmds("User", { pattern = "SttuslineCopilotLoad", modeline = false })
						end)
					end)
				end
			end,
		})

		return {
			get_icon = function()
				if status == "inprogress" then
					curr_inprogress_index = curr_inprogress_index < #icons.inprogress and curr_inprogress_index + 1
						or 1
					return icons.inprogress[curr_inprogress_index]
				else
					curr_inprogress_index = 0
					return icons[status] or status or ""
				end
			end,
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
		}
	end,
	update = function(_, state)
		if package.loaded["copilot"] then state.check_status() end
		return state.get_icon()
	end,
}
