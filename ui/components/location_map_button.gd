extends Button
class_name LocationMapButton


var location_id: String = ""
var location_name: String = ""
var accent: String = ""

var icon_rect: TextureRect
var border_panel: Panel


func setup(id: String, display_name: String, accent_text: String = "") -> void:
	location_id = id
	location_name = display_name
	accent = accent_text

	text = ""
	tooltip_text = display_name
	focus_mode = Control.FOCUS_ALL
	clip_contents = true
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	LuminariaTheme.apply_transparent_button(self)
	build_visuals()
	refresh_visual_state(false)


func build_visuals() -> void:
	var location_ui: Dictionary = DataManager.get_location_ui(location_id)
	var icon_path: String = str(location_ui.get("map_icon", ""))

	border_panel = Panel.new()
	border_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	border_panel.offset_left = 2
	border_panel.offset_top = 2
	border_panel.offset_right = -2
	border_panel.offset_bottom = -2
	border_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	border_panel.add_theme_stylebox_override("panel", make_map_icon_border_style(false))
	add_child(border_panel)

	icon_rect = TextureRect.new()
	icon_rect.texture = load_location_icon(icon_path)
	icon_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	icon_rect.offset_left = 14
	icon_rect.offset_top = 10
	icon_rect.offset_right = -14
	icon_rect.offset_bottom = -14-5
	icon_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_rect.modulate = Color(0.92, 0.94, 1.0, 0.95)
	add_child(icon_rect)


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
	if border_panel != null:
		border_panel.add_theme_stylebox_override("panel", make_map_icon_border_style(is_hovered))

	if icon_rect != null:
		icon_rect.pivot_offset = size * 0.5

		if is_hovered:
			icon_rect.modulate = Color(1.0, 0.96, 0.74, 1.0)
			icon_rect.scale = Vector2(1.03, 1.03)
		else:
			icon_rect.modulate = Color(0.92, 0.94, 1.0, 0.95)
			icon_rect.scale = Vector2.ONE

func make_map_icon_border_style(is_hovered: bool) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()

	if is_hovered:
		style.bg_color = Color(0.08, 0.050, 0.10, 0.30)
		style.border_color = Color(1.0, 0.78, 0.36, 0.86)
		style.shadow_color = Color(1.0, 0.70, 0.26, 0.30)
		style.shadow_size = 10
	else:
		style.bg_color = Color(0.01, 0.010, 0.018, 0.10)
		style.border_color = Color(0.55, 0.52, 0.66, 0.16)
		style.shadow_color = Color(0, 0, 0, 0.18)
		style.shadow_size = 4

	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1

	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10

	style.shadow_offset = Vector2(0, 2)

	return style
