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
