local Text = require("sttusline.component").new()

Text.set_config {
	text = "Text",
}

Text.set_update(function() return Text.get_config().text end)

return Text
