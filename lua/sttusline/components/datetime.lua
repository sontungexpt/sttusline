local Datetime = require("sttusline.component").new()

Datetime.set_config {
	style = "default",
}

Datetime.set_timing(true)

Datetime.set_update(function()
	local style = Datetime.get_config().style
	local fmt = style
	if style == "default" then
		fmt = "%A, %B %d | %H.%M"
	elseif style == "us" then
		fmt = "%m/%d/%Y"
	elseif style == "uk" then
		fmt = "%d/%m/%Y"
	elseif style == "iso" then
		fmt = "%Y-%m-%d"
	end
	return os.date(fmt)
end)

return Datetime
