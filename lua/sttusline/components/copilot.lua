local notify = require("sttusline.utils.notify")
local Copilot = require("sttusline.component").new()

local copilot_status = ""
local copilot_client = nil
local copilot_handler_registered = false

Copilot.set_config {
	icons = {
		normal = "",
		error = "",
		warning = "",
		inprogress = "",
	},
}

Copilot.set_event {
	"BufEnter",
	"InsertEnter",
	"InsertLeave",
	"CursorHoldI",
}
Copilot.set_user_event {}

local check_status = function()
	local cp_client_ok, cp_client = pcall(require, "copilot.client")
	if not cp_client_ok then
		notify.error("Cannot load copilot.client")
		return
	end

	copilot_client = cp_client.get()

	if not copilot_client then
		copilot_status = "error"
		return
	end

	local cp_api_ok, cp_api = pcall(require, "copilot.api")
	if not cp_api_ok then
		notify.error("Cannot load copilot.api")
		return
	end

	cp_api.check_status(copilot_client, {}, function(cserr, status)
		if cserr then
			copilot_status = "error"
			notify.warn(cserr)
			return
		elseif not status.user then
			copilot_status = "error"
			notify.warn("Copilot: No user found")
			return
		elseif status.status == "NoTelemetryConsent" then
			copilot_status = "error"
			notify.warn("Copilot: No telemetry consent")
			return
		elseif status.status == "NotAuthorized" then
			copilot_status = "error"
			notify.warn("Copilot: Not authorized")
			return
		end

		local attached = cp_client.buf_is_attached(0)
		if not attached then
			copilot_status = "error"
			notify.warn("Copilot: Not attached")
		else
			copilot_status = "normal"
		end
	end)
end

local handle_status_data = function(data) copilot_status = string.lower(data.status) end

local register_status_notification_handler = function()
	local cp_api_ok, cp_api = pcall(require, "copilot.api")
	if cp_api_ok then
		cp_api.register_status_notification_handler(handle_status_data)
		copilot_handler_registered = true
	end
end

Copilot.set_update(function()
	if package.loaded["copilot"] then
		if not copilot_handler_registered then register_status_notification_handler() end
		check_status()
	end

	return Copilot.get_config().icons[copilot_status] or ""
end)

return Copilot
