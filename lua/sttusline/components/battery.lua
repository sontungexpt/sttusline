local fn = vim.fn
local colors = require("sttusline.utils.color")

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
		local bat = fn.system("ls /sys/class/power_supply/ | grep BAT"):match("(.-)%s*$") or ""
		local bat_dir = "/sys/class/power_supply/" .. bat .. "/"

		local read_battery_file = function(filename)
			local f = io.open(bat_dir .. filename, "r")
			if not f then return "" end
			local content = f:read("*all")
			f:close()
			return content:match("(.-)%s*$")
		end
		return {
			get_status = function() return read_battery_file("status") end,
			get_capacity = function() return read_battery_file("capacity") end,
			curr_charging_index = 0,
		}
	end,
	update = function(configs, space)
		local status = space.get_status()
		local capacity = space.get_capacity()
		local icon_index = math.floor(capacity / 10) + 1
		local battery_color = icon_index > 8 and colors.green
			or icon_index > 4 and colors.yellow
			or colors.red

		if status == "Charging" then
			space.curr_charging_index = space.curr_charging_index == 0 and icon_index
				or space.curr_charging_index < #configs.icons.charging and space.curr_charging_index + 1
				or icon_index

			return {
				{
					configs.icons.charging[space.curr_charging_index] .. " " .. capacity .. "%%",
					{ fg = battery_color },
				},
			}
		elseif status == "Discharging" then
			space.curr_charging_index = 0
			return {
				{
					configs.icons.discharging[icon_index] .. " " .. capacity .. "%%",
					{ fg = battery_color },
				},
			}
		elseif status == "Full" then
			space.curr_charging_index = 0
			return "󰂄 " .. capacity .. "%%"
		elseif status == "Not charging" then
			space.curr_charging_index = 0
			return "󰁹 " .. capacity .. "%%"
		else
			space.curr_charging_index = 0
			return "Battery: " .. capacity .. "%%"
		end
	end,
	condition = function() return vim.loop.os_uname().sysname == "Linux" end,
}
