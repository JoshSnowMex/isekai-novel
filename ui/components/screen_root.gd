extends Control
class_name ScreenRoot

static func create(parent: Node) -> VBoxContainer:
	var background := ColorRect.new()
	background.color = Color(0.055, 0.045, 0.065, 1.0)
	background.anchor_right = 1.0
	background.anchor_bottom = 1.0
	parent.add_child(background)

	var center := CenterContainer.new()
	center.anchor_right = 1.0
	center.anchor_bottom = 1.0
	parent.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(720, 520)
	center.add_child(panel)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.11, 0.085, 0.13, 0.96)
	style.border_color = Color(0.75, 0.55, 0.72, 0.8)
	style.set_border_width_all(2)
	style.set_corner_radius_all(18)
	style.content_margin_left = 36
	style.content_margin_right = 36
	style.content_margin_top = 32
	style.content_margin_bottom = 32
	panel.add_theme_stylebox_override("panel", style)

	var layout := VBoxContainer.new()
	layout.alignment = BoxContainer.ALIGNMENT_CENTER
	layout.add_theme_constant_override("separation", 18)
	panel.add_child(layout)

	return layout
