extends Control
class_name ScreenRoot

static func create(parent: Node) -> VBoxContainer:
	var background: ColorRect = ColorRect.new()
	background.color = Color(0.055, 0.045, 0.065, 1.0)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	parent.add_child(background)

	var root_scroll: ScrollContainer = ScrollContainer.new()
	root_scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	parent.add_child(root_scroll)

	var outer_margin: MarginContainer = MarginContainer.new()
	outer_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	outer_margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	outer_margin.add_theme_constant_override("margin_left", 32)
	outer_margin.add_theme_constant_override("margin_right", 32)
	outer_margin.add_theme_constant_override("margin_top", 24)
	outer_margin.add_theme_constant_override("margin_bottom", 24)
	root_scroll.add_child(outer_margin)

	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(980, 0)
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	outer_margin.add_child(panel)

	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.11, 0.085, 0.13, 0.96)
	style.border_color = Color(0.75, 0.55, 0.72, 0.8)
	style.set_border_width_all(2)
	style.set_corner_radius_all(18)
	style.content_margin_left = 32
	style.content_margin_right = 32
	style.content_margin_top = 24
	style.content_margin_bottom = 24
	panel.add_theme_stylebox_override("panel", style)

	var layout: VBoxContainer = VBoxContainer.new()
	layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	layout.alignment = BoxContainer.ALIGNMENT_BEGIN
	layout.add_theme_constant_override("separation", 14)
	panel.add_child(layout)

	return layout
