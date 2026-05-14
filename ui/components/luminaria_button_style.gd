extends RefCounted
class_name LuminariaButtonStyle


static func apply_menu_plate(button: Button) -> void:
	button.focus_mode = Control.FOCUS_ALL
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(1, 54)
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER

	button.add_theme_font_size_override("font_size", 19)

	var button_assets: Dictionary = DataManager.get_button_theme_assets()

	var normal_path: String = str(button_assets.get("menu_normal", "res://assets/ui/button_velo_normal.png"))
	var hover_path: String = str(button_assets.get("menu_hover", normal_path))
	var pressed_path: String = str(button_assets.get("menu_pressed", normal_path))
	var disabled_path: String = str(button_assets.get("menu_disabled", normal_path))

	button.add_theme_stylebox_override("normal", make_texture_style(normal_path, make_fallback_style(false)))
	button.add_theme_stylebox_override("hover", make_texture_style(hover_path, make_fallback_style(true)))
	button.add_theme_stylebox_override("pressed", make_texture_style(pressed_path, make_fallback_style(true)))
	button.add_theme_stylebox_override("focus", make_texture_style(hover_path, make_fallback_style(true)))
	button.add_theme_stylebox_override("disabled", make_texture_style(disabled_path, make_disabled_fallback_style()))

	button.add_theme_color_override("font_color", Color(0.96, 0.90, 0.78, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.94, 0.72, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.88, 0.72, 0.50, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.58, 0.56, 0.62, 0.70))


static func make_texture_style(path: String, fallback_style: StyleBox) -> StyleBox:
	var texture: Texture2D = VisualAsset.load_texture(path)

	if texture == null:
		return fallback_style

	var style: StyleBoxTexture = StyleBoxTexture.new()
	style.texture = texture

	style.texture_margin_left = 48
	style.texture_margin_top = 24
	style.texture_margin_right = 48
	style.texture_margin_bottom = 24

	style.content_margin_left = 28
	style.content_margin_right = 28
	style.content_margin_top = 8
	style.content_margin_bottom = 8

	return style


static func make_fallback_style(is_hover: bool) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()

	if is_hover:
		style.bg_color = Color(0.090, 0.062, 0.120, 0.82)
		style.border_color = Color(1.00, 0.78, 0.40, 0.86)
		style.border_width_left = 5
	else:
		style.bg_color = Color(0.030, 0.026, 0.045, 0.66)
		style.border_color = Color(0.86, 0.67, 0.36, 0.42)
		style.border_width_left = 3

	style.border_width_top = 0
	style.border_width_right = 0
	style.border_width_bottom = 1

	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 2
	style.corner_radius_bottom_right = 10

	style.content_margin_left = 24
	style.content_margin_right = 18
	style.content_margin_top = 8
	style.content_margin_bottom = 8

	style.shadow_color = Color(0, 0, 0, 0.34)
	style.shadow_size = 8
	style.shadow_offset = Vector2(0, 4)

	return style


static func make_disabled_fallback_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = make_fallback_style(false)
	style.bg_color = Color(0.030, 0.030, 0.040, 0.36)
	style.border_color = Color(0.46, 0.43, 0.48, 0.20)
	style.shadow_size = 0
	return style
