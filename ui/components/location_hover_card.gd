extends Control
class_name LocationHoverCard


var title_label: Label
var description_label: Label
var npc_label: Label
var hint_label: Label

var panel_texture: TextureRect


func _init() -> void:
	custom_minimum_size = Vector2(500, 320)
	size = custom_minimum_size
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func build() -> void:
	panel_texture = TextureRect.new()
	panel_texture.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel_texture.offset_left = 0
	panel_texture.offset_top = 0
	panel_texture.offset_right = 0
	panel_texture.offset_bottom = 0
	panel_texture.texture = get_hover_panel_texture()
	panel_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	panel_texture.stretch_mode = TextureRect.STRETCH_SCALE
	panel_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel_texture)

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 24)
	add_child(margin)

	var root: VBoxContainer = VBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 8)
	margin.add_child(root)

	title_label = Label.new()
	title_label.custom_minimum_size = Vector2(1, 30)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	LuminariaTheme.apply_label(title_label, 20, Color(0.95, 0.88, 1.0, 1.0), 2)
	root.add_child(title_label)

	description_label = Label.new()
	description_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	description_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	description_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	description_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	LuminariaTheme.apply_label(description_label, 17, Color(0.92, 0.90, 0.96, 1.0), 2)
	root.add_child(description_label)

	npc_label = Label.new()
	npc_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	npc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	npc_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	npc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	LuminariaTheme.apply_label(npc_label, 16, Color(0.82, 0.80, 0.92, 1.0), 2)
	root.add_child(npc_label)

	var spacer: Control = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(spacer)

	hint_label = Label.new()
	hint_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	LuminariaTheme.apply_label(hint_label, 17, Color(0.82, 0.72, 1.0, 1.0), 2)
	root.add_child(hint_label)

	set_intro()


func get_hover_panel_texture() -> Texture2D:
	var world_map_ui: Dictionary = DataManager.get_world_map_ui()
	var path: String = str(world_map_ui.get("hover_info_panel", "res://assets/ui/world_hover_info_panel.png"))

	if ResourceLoader.exists(path):
		return load(path)

	return null


func set_intro() -> void:
	title_label.text = "Mapa de Luminaria"
	description_label.text = "Elige una ubicación para moverte por la ciudad."
	npc_label.text = ""
	hint_label.text = "Click para viajar"


func set_location(location_id: String) -> void:
	var location_data: Dictionary = DataManager.get_location(location_id)

	title_label.text = str(location_data.get("name", location_id))
	description_label.text = get_short_description(str(location_data.get("description", "")))

	var present_npcs: Array = get_present_npcs_for_location(location_id)

	if present_npcs.is_empty():
		npc_label.text = "Presentes: nadie visible"
	else:
		var names: Array = []

		for npc_id in present_npcs:
			names.append(get_visible_npc_name(str(npc_id)))

		npc_label.text = "Presentes: %s" % ", ".join(names)

	if location_id == "home":
		hint_label.text = "Entrar a casa"
	elif location_id == "shop":
		description_label.text = "Compra regalos y objetos útiles para tus relaciones."
		npc_label.text = ""
		hint_label.text = "Abrir tienda"
	else:
		hint_label.text = "Viajar"


func get_short_description(text: String) -> String:
	var clean_text: String = text.strip_edges()

	if clean_text.length() <= 150:
		return clean_text

	return clean_text.substr(0, 147).strip_edges() + "..."


func get_present_npcs_for_location(location_id: String) -> Array:
	var result: Array = []

	for npc_id in DataManager.npcs.keys():
		var id: String = str(npc_id)
		var current_location: String = ScheduleSystem.get_npc_location(id)

		if current_location == location_id:
			result.append(id)

	return result


func get_visible_npc_name(npc_id: String) -> String:
	GameManager.ensure_npc_knowledge(npc_id)

	var knowledge: Dictionary = GameManager.player["known_npc_info"].get(npc_id, {})
	var profile_seen: bool = bool(knowledge.get("profile_seen", false))

	if not profile_seen:
		return "???"

	var npc: Dictionary = DataManager.get_npc(npc_id)
	return str(npc.get("name", npc_id))
