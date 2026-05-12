extends RefCounted
class_name VisualAsset


static func texture_exists(path: String) -> bool:
	if path == "":
		return false

	return ResourceLoader.exists(path)


static func load_texture(path: String) -> Texture2D:
	if not texture_exists(path):
		return null

	var resource: Resource = load(path)

	if resource is Texture2D:
		return resource

	return null


static func make_placeholder_panel(title: String, subtitle: String = "") -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 8)
	panel.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 4)
	margin.add_child(box)

	var title_label: Label = Label.new()
	title_label.text = title
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(title_label)

	if subtitle != "":
		var subtitle_label: Label = Label.new()
		subtitle_label.text = subtitle
		subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		subtitle_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		box.add_child(subtitle_label)

	return panel


static func make_texture_or_placeholder(path: String, title: String, subtitle: String = "") -> Control:
	var texture: Texture2D = load_texture(path)

	if texture != null:
		var rect: TextureRect = TextureRect.new()
		rect.texture = texture
		rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
		return rect

	return make_placeholder_panel(title, subtitle)
