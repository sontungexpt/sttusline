local fn = vim.fn
local colors = require("sttusline.utils.color")
local current_charging_index = 0

return {
	name = "battery",
	timing = true,
	configs = {
		icons = {
			charging = {
				"󰢟",
				"󰢜",
				"󰂆",
				"󰂇",
				"󰂈",
				"󰢝",
				"󰂉",
				"󰢞",
				"󰂊",
				"󰂋",
				"󰂅",
			},
			discharging = {
				"󰂎",
				"󰁺",
				"󰁻",
				"󰁼",
				"󰁽",
				"󰁾",
				"󰁿",
				"󰂀",
				"󰂁",
				"󰂂",
				"󰁹",
			},
		},
	},
	colors = {
		fg = colors.green,
	},
	space = function()
		local bat_dir = fn.glob("/sys/class/power_supply/BAT*", true, true)[1]
		if not bat_dir then return "" end
		bat_dir = bat_dir:match("(.-)%s*$")

		local read_battery_file = function(filename)
			local f = io.open(bat_dir .. "/" .. filename, "r")
			if not f then return "" end
			local content = f:read("*all")
			f:close()
			return content:match("(.-)%s*$")
		end
		return {
			get_status = function() return read_battery_file("status") end,
			get_capacity = function() return read_battery_file("capacity") end,
		}
	end,
	update = function(configs, space)
		local status = space.get_status()
		local capacity = space.get_capacity()
		local icon_index = math.floor(capacity / 10) + 1
		local battery_color = icon_index > 8 and colors.green
			or icon_index > 3 and colors.yellow
			or colors.red

		if status == "Charging" then
			current_charging_index = current_charging_index == 0 and icon_index
				or current_charging_index < #configs.icons.charging and current_charging_index + 1
				or icon_index

			return {
				{
					configs.icons.charging[current_charging_index] .. " " .. capacity .. "%%",
					{ fg = battery_color },
				},
			}
		elseif status == "Discharging" or status == "Not charging" then
			current_charging_index = 0
			return {
				{
					configs.icons.discharging[icon_index] .. " " .. capacity .. "%%",
					{ fg = battery_color },
				},
			}
		elseif status == "Full" then
			current_charging_index = 0
			return {
				{
					"󰂄 " .. capacity .. "%%",
					{ fg = battery_color },
				},
			}
		else
			current_charging_index = 0
			return "Battery: " .. capacity .. "%%"
		end
	end,
	condition = function() return vim.loop.os_uname().sysname == "Linux" end,
}
