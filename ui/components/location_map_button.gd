extends Button
class_name LocationMapButton


var location_id: String = ""
var location_name: String = ""
var accent: String = ""

var outer_halo_panel: Panel
var middle_halo_panel: Panel
var inner_halo_panel: Panel
var shadow_rect: TextureRect
var glow_rect: TextureRect
var icon_rect: TextureRect

func setup(id: String, display_name: String, accent_text: String = "") -> void:
	location_id = id
	location_name = display_name
	accent = accent_text

	text = ""
	tooltip_text = display_name
	focus_mode = Control.FOCUS_ALL
	clip_contents = false
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	LuminariaTheme.apply_transparent_button(self)
	build_visuals()
	refresh_visual_state(false)


func build_visuals() -> void:
	var location_ui: Dictionary = DataManager.get_location_ui(location_id)
	var icon_path: String = str(location_ui.get("map_icon", ""))
	var icon_texture: Texture2D = load_location_icon(icon_path)

	outer_halo_panel = make_halo_panel(
		Rect2(Vector2(0.04, 0.14), Vector2(0.92, 0.82)),
		make_map_icon_halo_style("outer", false)
	)
	add_child(outer_halo_panel)

	middle_halo_panel = make_halo_panel(
		Rect2(Vector2(0.09, 0.20), Vector2(0.82, 0.70)),
		make_map_icon_halo_style("middle", false)
	)
	add_child(middle_halo_panel)

	inner_halo_panel = make_halo_panel(
		Rect2(Vector2(0.16, 0.28), Vector2(0.68, 0.54)),
		make_map_icon_halo_style("inner", false)
	)
	add_child(inner_halo_panel)

	shadow_rect = make_icon_layer(icon_texture)
	shadow_rect.offset_left = 13
	shadow_rect.offset_top = 13
	shadow_rect.offset_right = -7
	shadow_rect.offset_bottom = -7
	shadow_rect.modulate = Color(0, 0, 0, 0.52)
	add_child(shadow_rect)

	glow_rect = make_icon_layer(icon_texture)
	glow_rect.offset_left = 6
	glow_rect.offset_top = 6
	glow_rect.offset_right = -6
	glow_rect.offset_bottom = -6
	glow_rect.modulate = Color(0.95, 0.70, 0.28, 0.0)
	add_child(glow_rect)

	icon_rect = make_icon_layer(icon_texture)
	icon_rect.offset_left = 11
	icon_rect.offset_top = 8
	icon_rect.offset_right = -11
	icon_rect.offset_bottom = -12
	icon_rect.modulate = Color(1.0, 1.0, 1.0, 0.98)
	add_child(icon_rect)


func make_icon_layer(icon_texture: Texture2D) -> TextureRect:
	var rect: TextureRect = TextureRect.new()
	rect.texture = icon_texture
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rect


func load_location_icon(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path)

	return null


func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_ENTER:
		refresh_visual_state(true)
	elif what == NOTIFICATION_MOUSE_EXIT:
		refresh_visual_state(false)
	elif what == NOTIFICATION_FOCUS_ENTER:
		refresh_visual_state(true)
	elif what == NOTIFICATION_FOCUS_EXIT:
		refresh_visual_state(false)


func refresh_visual_state(is_hovered: bool) -> void:
	update_layer_pivots()

	if outer_halo_panel != null:
		outer_halo_panel.add_theme_stylebox_override("panel", make_map_icon_halo_style("outer", is_hovered))

	if middle_halo_panel != null:
		middle_halo_panel.add_theme_stylebox_override("panel", make_map_icon_halo_style("middle", is_hovered))

	if inner_halo_panel != null:
		inner_halo_panel.add_theme_stylebox_override("panel", make_map_icon_halo_style("inner", is_hovered))

	if is_hovered:
		if shadow_rect != null:
			shadow_rect.modulate = Color(0, 0, 0, 0.62)
			shadow_rect.scale = Vector2(1.05, 1.05)

		if glow_rect != null:
			glow_rect.modulate = Color(0.86, 0.72, 1.0, 0.78)
			glow_rect.scale = Vector2(1.15, 1.15)

		if icon_rect != null:
			icon_rect.modulate = Color(1.0, 0.98, 0.86, 1.0)
			icon_rect.scale = Vector2(1.06, 1.06)
	else:
		if shadow_rect != null:
			shadow_rect.modulate = Color(0, 0, 0, 0.52)
			shadow_rect.scale = Vector2.ONE

		if glow_rect != null:
			glow_rect.modulate = Color(0.95, 0.70, 0.28, 0.0)
			glow_rect.scale = Vector2.ONE

		if icon_rect != null:
			icon_rect.modulate = Color(1.0, 1.0, 1.0, 0.98)
			icon_rect.scale = Vector2.ONE


func update_layer_pivots() -> void:
	var center: Vector2 = size * 0.5

	if shadow_rect != null:
		shadow_rect.pivot_offset = center

	if glow_rect != null:
		glow_rect.pivot_offset = center

	if icon_rect != null:
		icon_rect.pivot_offset = center

func make_map_icon_halo_style(layer: String, is_hovered: bool) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()

	match layer:
		"outer":
			if is_hovered:
				style.bg_color = Color(0.00, 0.00, 0.00, 0.46)
				style.border_color = Color(0.02, 0.01, 0.03, 0.78)
				style.shadow_color = Color(0, 0, 0, 0.50)
				style.shadow_size = 14
			else:
				style.bg_color = Color(0.00, 0.00, 0.00, 0.34)
				style.border_color = Color(0.02, 0.01, 0.03, 0.48)
				style.shadow_color = Color(0, 0, 0, 0.42)
				style.shadow_size = 10

		"middle":
			if is_hovered:
				style.bg_color = Color(0.19, 0.08, 0.28, 0.40)
				style.border_color = Color(0.72, 0.50, 1.00, 0.54)
				style.shadow_color = Color(0.48, 0.22, 0.90, 0.28)
				style.shadow_size = 10
			else:
				style.bg_color = Color(0.16, 0.070, 0.26, 0.42)
				style.border_color = Color(0.62, 0.44, 0.95, 0.58)
				style.shadow_color = Color(0.40, 0.18, 0.76, 0.30)
				style.shadow_size = 10

		"inner":
			if is_hovered:
				style.bg_color = Color(0.82, 0.90, 1.00, 0.20)
				style.border_color = Color(1.00, 0.96, 0.84, 0.72)
				style.shadow_color = Color(1.0, 0.76, 0.28, 0.28)
				style.shadow_size = 8
			else:
				style.bg_color = Color(0.78, 0.86, 1.00, 0.18)
				style.border_color = Color(0.86, 0.92, 1.00, 0.52)
				style.shadow_color = Color(0.42, 0.52, 0.90, 0.24)
				style.shadow_size = 7

		_:
			style.bg_color = Color(0, 0, 0, 0.0)
			style.border_color = Color(0, 0, 0, 0.0)
			style.shadow_color = Color(0, 0, 0, 0.0)
			style.shadow_size = 0

	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1

	style.corner_radius_top_left = 999
	style.corner_radius_top_right = 999
	style.corner_radius_bottom_left = 999
	style.corner_radius_bottom_right = 999

	style.shadow_offset = Vector2(0, 3)

	return style
	
func make_halo_panel(anchor_rect: Rect2, style: StyleBoxFlat) -> Panel:
	var panel: Panel = Panel.new()
	panel.anchor_left = anchor_rect.position.x
	panel.anchor_top = anchor_rect.position.y
	panel.anchor_right = anchor_rect.position.x + anchor_rect.size.x
	panel.anchor_bottom = anchor_rect.position.y + anchor_rect.size.y
	panel.offset_left = 0
	panel.offset_top = 0
	panel.offset_right = 0
	panel.offset_bottom = 0
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", style)
	return panel
