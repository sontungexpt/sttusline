return {
	name = "datetime",
	timming = true,
	configs = {
		style = "default",
	},

	update = function(configs)
		local style = configs.style
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
		return os.date(fmt) .. ""
	end,
}
