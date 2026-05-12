extends Button
class_name LocationMapButton


var location_id: String = ""
var location_name: String = ""
var accent: String = ""


func setup(id: String, display_name: String, accent_text: String = "") -> void:
	location_id = id
	location_name = display_name
	accent = accent_text

	text = build_button_text()
	tooltip_text = display_name
	focus_mode = Control.FOCUS_ALL
	clip_text = true


func build_button_text() -> String:
	if accent == "":
		return location_name

	return "%s\n%s" % [
		location_name,
		accent
	]
