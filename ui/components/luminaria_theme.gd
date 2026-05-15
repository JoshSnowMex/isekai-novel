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
	style.bg_color = Color(0.012, 0.010, 0.018, 0.62)
	style.border_color = Color(0.86, 0.70, 0.42, 0.18)
	style.border_width_left = 0
	style.border_width_top = 0
	style.border_width_right = 0
	style.border_width_bottom = 1
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 12
	style.content_margin_top = 8
	style.content_margin_right = 12
	style.content_margin_bottom = 8
	style.shadow_color = Color(0, 0, 0, 0.42)
	style.shadow_size = 12
	style.shadow_offset = Vector2(0, 4)
	return style
	
static func make_top_nav_button_style(state: String = "normal") -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()

	match state:
		"hover":
			style.bg_color = Color(0.070, 0.045, 0.085, 0.68)
			style.border_color = Color(1.0, 0.76, 0.34, 0.82)
			style.shadow_color = Color(1.0, 0.70, 0.28, 0.18)
			style.shadow_size = 8
		"pressed":
			style.bg_color = Color(0.030, 0.024, 0.040, 0.82)
			style.border_color = Color(0.84, 0.60, 0.26, 0.90)
			style.shadow_color = Color(0, 0, 0, 0.46)
			style.shadow_size = 3
		"disabled":
			style.bg_color = Color(0.010, 0.010, 0.014, 0.18)
			style.border_color = Color(0.34, 0.32, 0.38, 0.18)
			style.shadow_color = Color(0, 0, 0, 0.08)
			style.shadow_size = 1
		_:
			style.bg_color = Color(0.020, 0.018, 0.030, 0.34)
			style.border_color = Color(0.72, 0.58, 0.34, 0.44)
			style.shadow_color = Color(0, 0, 0, 0.20)
			style.shadow_size = 3

	style.border_width_left = 0
	style.border_width_top = 0
	style.border_width_right = 0
	style.border_width_bottom = 2

	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 2
	style.corner_radius_bottom_right = 2

	style.content_margin_left = 14
	style.content_margin_top = 4
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
