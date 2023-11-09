return {
	name = "copilot",
	timming = 500,
	space = function(configs, component)
		local require = require
		local pcall = pcall
		local copilot_status = ""
		local copilot_client = nil
		local copilot_handler_registered = false
		local S = {}

		S.check_status = function()
			local cp_client_ok, cp_client = pcall(require, "copilot.client")
			if not cp_client_ok then
				require("sttusline.utils.notify").error("Cannot load copilot.client")
				copilot_status = "error"
				return
			end

			copilot_client = cp_client.get()

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
				if
					cserr
					or not status.user
					or status.status == "NoTelemetryConsent"
					or status.status == "NotAuthorized"
				then
					copilot_status = "error"
					return
				end

				copilot_status = cp_client.buf_is_attached(0) and "normal" or "error"
			end)
		end

		S.register_status_notification_handler = function()
			if not copilot_handler_registered then
				local cp_api_ok, cp_api = pcall(require, "copilot.api")
				if cp_api_ok then
					cp_api.register_status_notification_handler(
						function(data) copilot_status = string.lower(data.status) end
					)
					copilot_handler_registered = true
				end
			end
		end
		S.get_status = function()
			local icon = configs.icons[copilot_status]
			if copilot_status == "inprogress" then
				return icon[math.floor(vim.loop.hrtime() / 1000000 / component.timming) % #icon + 1]
			else
				return icon or copilot_status or ""
			end
		end
		return S
	end,
	configs = {
		icons = {
			normal = "",
			error = "",
			warning = "",
			inprogress = { "", "󰪞", "󰪟", "󰪠", "󰪢", "󰪣", "󰪤", "󰪥" },
		},
	},
	update = function(_, space)
		if package.loaded["copilot"] then
			space.register_status_notification_handler()
			space.check_status()
		end
		return space.get_status()
	end,
}
