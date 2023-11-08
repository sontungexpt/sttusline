return {
	name = "copilot",
	event = { "InsertEnter", "InsertLeave", "CursorHoldI" },
	space = function(configs)
		local copilot_status = ""
		local copilot_client = nil
		local copilot_handler_registered = false
		local S = {}
		local handle_status_data = function(data) copilot_status = string.lower(data.status) end

		S.check_status = function()
			local cp_client_ok, cp_client = pcall(require, "copilot.client")
			if not cp_client_ok then
				require("sttusline.utils.notify").error("Cannot load copilot.client")
				return
			end

			copilot_client = cp_client.get()

			if not copilot_client then
				copilot_status = "error"
				return
			end

			local cp_api_ok, cp_api = pcall(require, "copilot.api")
			if not cp_api_ok then
				require("sttusline.utils.notify").error("Cannot load copilot.api")
				return
			end

			cp_api.check_status(copilot_client, {}, function(cserr, status)
				if cserr then
					copilot_status = "error"
					return
				elseif not status.user then
					copilot_status = "error"
					return
				elseif status.status == "NoTelemetryConsent" then
					copilot_status = "error"
					return
				elseif status.status == "NotAuthorized" then
					copilot_status = "error"
					return
				end

				local attached = cp_client.buf_is_attached(0)
				if not attached then
					copilot_status = "error"
				else
					copilot_status = "normal"
				end
			end)
		end

		S.register_status_notification_handler = function()
			if not copilot_handler_registered then
				local cp_api_ok, cp_api = pcall(require, "copilot.api")
				if cp_api_ok then
					cp_api.register_status_notification_handler(handle_status_data)
					copilot_handler_registered = true
				end
			end
		end
		S.get_status = function() return configs.icons[copilot_status] or copilot_status or "" end
		return S
	end,

	configs = {
		icons = {
			normal = "",
			error = "",
			warning = "",
			inprogress = "",
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
