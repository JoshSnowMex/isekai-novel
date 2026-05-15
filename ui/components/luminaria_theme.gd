extends RefCounted
class_name LuminariaTheme


const DEFAULT_FONT_PATH: String = "res://assets/fonts/luminaria_fantasy_regular.ttf"
const SELECTION_FRAME_PATH: String = "res://assets/ui/selection_frame_velo.png"


static func load_font() -> FontFile:
	if ResourceLoader.exists(DEFAULT_FONT_PATH):
		var resource: Resource = load(DEFAULT_FONT_PATH)

		if resource is FontFile:
			return resource

	return null


static func apply_label(
	label: Label,
	font_size: int = 18,
	font_color: Color = Color(0.96, 0.91, 0.82, 1.0),
	outline_size: int = 2
) -> void:
	var font: FontFile = load_font()

	if font != null:
		label.add_theme_font_override("font", font)

	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", font_color)
	label.add_theme_color_override("font_outline_color", Color(0.03, 0.02, 0.04, 0.92))
	label.add_theme_constant_override("outline_size", outline_size)


static func apply_button_text(
	button: Button,
	font_size: int = 18,
	font_color: Color = Color(0.96, 0.91, 0.82, 1.0)
) -> void:
	var font: FontFile = load_font()

	if font != null:
		button.add_theme_font_override("font", font)

	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", font_color)
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.94, 0.72, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.86, 0.70, 0.46, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.60, 0.58, 0.66, 0.70))
	button.add_theme_color_override("font_outline_color", Color(0.03, 0.02, 0.04, 0.92))
	button.add_theme_constant_override("outline_size", 2)


static func make_transparent_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0)
	style.border_width_left = 0
	style.border_width_top = 0
	style.border_width_right = 0
	style.border_width_bottom = 0
	style.content_margin_left = 0
	style.content_margin_top = 0
	style.content_margin_right = 0
	style.content_margin_bottom = 0
	return style


static func apply_transparent_button(button: Button) -> void:
	var style: StyleBoxFlat = make_transparent_style()

	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style)
	button.add_theme_stylebox_override("pressed", style)
	button.add_theme_stylebox_override("focus", style)
	button.add_theme_stylebox_override("disabled", style)

static func make_hud_panel_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.025, 0.022, 0.035, 0.86)
	style.border_color = Color(0.74, 0.58, 0.34, 0.36)
	style.border_width_left = 0
	style.border_width_top = 0
	style.border_width_right = 0
	style.border_width_bottom = 1
	style.content_margin_left = 8
	style.content_margin_top = 6
	style.content_margin_right = 8
	style.content_margin_bottom = 6
	style.shadow_color = Color(0, 0, 0, 0.34)
	style.shadow_size = 8
	style.shadow_offset = Vector2(0, 2)
	return style

static func make_top_nav_panel_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.018, 0.012, 0.030, 0.58)
	style.border_color = Color(0.44, 0.30, 0.72, 0.30)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1

	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12

	style.content_margin_left = 10
	style.content_margin_top = 8
	style.content_margin_right = 10
	style.content_margin_bottom = 8

	style.shadow_color = Color(0, 0, 0, 0.48)
	style.shadow_size = 14
	style.shadow_offset = Vector2(0, 4)

	return style
	
static func make_top_nav_button_style(state: String = "normal") -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()

	match state:
		"hover":
			style.bg_color = Color(0.18, 0.08, 0.28, 0.74)
			style.border_color = Color(0.78, 0.58, 1.0, 0.78)
			style.shadow_color = Color(0.48, 0.22, 0.90, 0.34)
			style.shadow_size = 10
		"pressed":
			style.bg_color = Color(0.08, 0.04, 0.14, 0.86)
			style.border_color = Color(0.64, 0.46, 0.90, 0.82)
			style.shadow_color = Color(0, 0, 0, 0.50)
			style.shadow_size = 3
		"disabled":
			style.bg_color = Color(0.012, 0.010, 0.018, 0.22)
			style.border_color = Color(0.26, 0.22, 0.34, 0.18)
			style.shadow_color = Color(0, 0, 0, 0.10)
			style.shadow_size = 1
		_:
			style.bg_color = Color(0.036, 0.026, 0.060, 0.58)
			style.border_color = Color(0.46, 0.34, 0.72, 0.38)
			style.shadow_color = Color(0, 0, 0, 0.24)
			style.shadow_size = 4

	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1

	style.corner_radius_top_left = 7
	style.corner_radius_top_right = 7
	style.corner_radius_bottom_left = 7
	style.corner_radius_bottom_right = 7

	style.content_margin_left = 14
	style.content_margin_top = 5
	style.content_margin_right = 14
	style.content_margin_bottom = 6

	style.shadow_offset = Vector2(0, 2)

	return style
	
static func apply_top_nav_button(button: Button) -> void:
	button.focus_mode = Control.FOCUS_ALL
	button.custom_minimum_size = Vector2(92, 34)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.clip_text = true

	apply_button_text(button, 17, Color(0.96, 0.91, 0.82, 1.0))

	button.add_theme_stylebox_override("normal", make_top_nav_button_style("normal"))
	button.add_theme_stylebox_override("hover", make_top_nav_button_style("hover"))
	button.add_theme_stylebox_override("pressed", make_top_nav_button_style("pressed"))
	button.add_theme_stylebox_override("focus", make_top_nav_button_style("hover"))
	button.add_theme_stylebox_override("disabled", make_top_nav_button_style("disabled"))


static func apply_hud_label(label: Label, alignment: HorizontalAlignment) -> void:
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.horizontal_alignment = alignment
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.clip_text = true
	apply_label(label, 20, Color(0.98, 0.93, 0.82, 1.0), 2)

static func apply_flat_nav_text_button(button: Button) -> void:
	var transparent_style: StyleBoxFlat = make_transparent_style()

	button.add_theme_stylebox_override("normal", transparent_style)
	button.add_theme_stylebox_override("hover", transparent_style)
	button.add_theme_stylebox_override("pressed", transparent_style)
	button.add_theme_stylebox_override("focus", transparent_style)
	button.add_theme_stylebox_override("disabled", transparent_style)

	apply_button_text(button, 18, Color(0.96, 0.91, 0.82, 1.0))

	button.add_theme_color_override("font_hover_color", Color(0.88, 0.78, 1.0, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.72, 0.58, 0.92, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.52, 0.50, 0.62, 0.70))
	button.add_theme_constant_override("outline_size", 2)

static func get_world_info_panel_texture() -> Texture2D:
	var world_map_ui: Dictionary = DataManager.get_world_map_ui()
	var path: String = str(world_map_ui.get("hover_info_panel", "res://assets/ui/world_hover_info_panel.png"))

	if ResourceLoader.exists(path):
		return load(path)

	return null


static func apply_content_title(label: Label) -> void:
	apply_label(label, 20, Color(0.95, 0.88, 1.0, 1.0), 2)


static func apply_content_body(label: Label) -> void:
	apply_label(label, 17, Color(0.92, 0.90, 0.96, 1.0), 2)


static func apply_content_action_button(button: Button) -> void:
	var normal: StyleBoxFlat = make_content_action_button_style("normal")
	var hover: StyleBoxFlat = make_content_action_button_style("hover")
	var pressed: StyleBoxFlat = make_content_action_button_style("pressed")
	var disabled: StyleBoxFlat = make_content_action_button_style("disabled")

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", hover)
	button.add_theme_stylebox_override("disabled", disabled)

	button.focus_mode = Control.FOCUS_ALL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.custom_minimum_size = Vector2(180, 38)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	apply_button_text(button, 17, Color(0.94, 0.88, 1.0, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.96, 1.0, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.78, 0.66, 1.0, 1.0))


static func make_content_action_button_style(state: String) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()

	match state:
		"hover":
			style.bg_color = Color(0.16, 0.07, 0.26, 0.68)
			style.border_color = Color(0.78, 0.58, 1.0, 0.72)
			style.shadow_color = Color(0.48, 0.22, 0.90, 0.26)
			style.shadow_size = 8
		"pressed":
			style.bg_color = Color(0.08, 0.035, 0.14, 0.84)
			style.border_color = Color(0.62, 0.42, 0.90, 0.80)
			style.shadow_color = Color(0, 0, 0, 0.46)
			style.shadow_size = 3
		"disabled":
			style.bg_color = Color(0.02, 0.018, 0.028, 0.30)
			style.border_color = Color(0.30, 0.26, 0.38, 0.22)
			style.shadow_color = Color(0, 0, 0, 0.10)
			style.shadow_size = 1
		_:
			style.bg_color = Color(0.05, 0.035, 0.08, 0.48)
			style.border_color = Color(0.46, 0.34, 0.72, 0.38)
			style.shadow_color = Color(0, 0, 0, 0.20)
			style.shadow_size = 4

	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1

	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8

	style.content_margin_left = 10
	style.content_margin_top = 5
	style.content_margin_right = 10
	style.content_margin_bottom = 6
	style.shadow_offset = Vector2(0, 2)

	return style
