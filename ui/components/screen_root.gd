extends Control
class_name ScreenRoot

static func create(parent: Node) -> VBoxContainer:
	var background: ColorRect = ColorRect.new()
	background.color = Color(0.055, 0.045, 0.065, 1.0)
	background.anchor_right = 1.0
	background.anchor_bottom = 1.0
	parent.add_child(background)

	var margin: MarginContainer = MarginContainer.new()
	margin.anchor_right = 1.0
	margin.anchor_bottom = 1.0
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	parent.add_child(margin)

	var panel: PanelContainer = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(panel)

	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.11, 0.085, 0.13, 0.96)
	style.border_color = Color(0.75, 0.55, 0.72, 0.8)
	style.set_border_width_all(2)
	style.set_corner_radius_all(18)
	style.content_margin_left = 28
	style.content_margin_right = 28
	style.content_margin_top = 24
	style.content_margin_bottom = 24
	panel.add_theme_stylebox_override("panel", style)

	var layout: VBoxContainer = VBoxContainer.new()
	layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.alignment = BoxContainer.ALIGNMENT_BEGIN
	layout.add_theme_constant_override("separation", 12)
	panel.add_child(layout)

	return layout
