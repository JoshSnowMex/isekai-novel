extends Node
class_name UIFactory

static func title(text: String) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 30)
	label.add_theme_color_override("font_color", Color(0.95, 0.82, 0.92))
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label

static func body(text: String = "") -> Label:
	var label: Label = Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 17)
	label.add_theme_color_override("font_color", Color(0.88, 0.82, 0.88))
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label

static func button(text: String) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(260, 40)
	button.add_theme_font_size_override("font_size", 16)

	var normal: StyleBoxFlat = StyleBoxFlat.new()
	normal.bg_color = Color(0.28, 0.13, 0.23)
	normal.set_corner_radius_all(10)
	normal.content_margin_top = 8
	normal.content_margin_bottom = 8
	normal.content_margin_left = 12
	normal.content_margin_right = 12

	var hover: StyleBoxFlat = StyleBoxFlat.new()
	hover.bg_color = Color(0.42, 0.18, 0.34)
	hover.set_corner_radius_all(10)

	var pressed: StyleBoxFlat = StyleBoxFlat.new()
	pressed.bg_color = Color(0.62, 0.26, 0.48)
	pressed.set_corner_radius_all(10)

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_color_override("font_color", Color(0.98, 0.9, 0.96))

	return button
