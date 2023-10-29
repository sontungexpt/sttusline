return {
	name = "copilot",
	event = { "InsertEnter", "InsertLeave", "CursorHoldI" }, -- The component will be update when the event is triggered

	space = function(configs)
		local copilot_status = ""
		local copilot_client = nil
		local copilot_handler_registered = false
		local M = {}

		local handle_status_data = function(data) copilot_status = string.lower(data.status) end

		M.check_status = function()
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
					require("sttusline.utils.notify").warn(cserr)
					return
				elseif not status.user then
					copilot_status = "error"
					require("sttusline.utils.notify").warn("Copilot: No user found")
					return
				elseif status.status == "NoTelemetryConsent" then
					copilot_status = "error"
					require("sttusline.utils.notify").warn("Copilot: No telemetry consent")
					return
				elseif status.status == "NotAuthorized" then
					copilot_status = "error"
					require("sttusline.utils.notify").warn("Copilot: Not authorized")
					return
				end

				local attached = cp_client.buf_is_attached(0)
				if not attached then
					copilot_status = "error"
					require("sttusline.utils.notify").warn("Copilot: Not attached")
				else
					copilot_status = "normal"
				end
			end)
		end

		M.register_status_notification_handler = function()
			if not copilot_handler_registered then
				local cp_api_ok, cp_api = pcall(require, "copilot.api")
				if cp_api_ok then
					cp_api.register_status_notification_handler(handle_status_data)
					copilot_handler_registered = true
				end
			end
		end
		M.get_status = function() return configs.icons[copilot_status] or "" end
		return M
	end,

	configs = {
		icons = {
			normal = "",
			error = "",
			warning = "",
			inprogress = "",
		},
	},

	update = function(_, _, space)
		if package.loaded["copilot"] then
			space.register_status_notification_handler()
			space.check_status()
		end
		return space.get_status()
	end,
}