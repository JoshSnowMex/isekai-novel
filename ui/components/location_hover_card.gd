extends PanelContainer
class_name LocationHoverCard


var title_label: Label
var description_label: Label
var npc_label: Label
var hint_label: Label


func _init() -> void:
	custom_minimum_size = Vector2(420, 132)
	size = custom_minimum_size
	visible = false


func build() -> void:
	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 8)
	add_child(margin)

	var root: VBoxContainer = VBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 3)
	margin.add_child(root)

	title_label = UIFactory.body("Mapa de Luminaria")
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(title_label)

	description_label = UIFactory.body("Pasa el cursor por una ubicación para ver detalles.")
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(description_label)

	npc_label = UIFactory.body("")
	npc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(npc_label)

	hint_label = UIFactory.body("Click para viajar.")
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(hint_label)


func set_intro() -> void:
	title_label.text = "Mapa de Luminaria"
	description_label.text = "Pasa el cursor por una ubicación para ver detalles. Haz click para viajar directamente."
	npc_label.text = ""
	hint_label.text = "Los marcadores actuales son placeholders con nombres definitivos para reemplazo por assets finales."


func set_location(location_id: String) -> void:
	var location_data: Dictionary = DataManager.get_location(location_id)

	title_label.text = str(location_data.get("name", location_id))
	description_label.text = str(location_data.get("description", ""))

	var present_npcs: Array = get_present_npcs_for_location(location_id)

	if present_npcs.is_empty():
		npc_label.text = "Personajes presentes: nadie visible."
	else:
		var names: Array = []

		for npc_id in present_npcs:
			names.append(get_visible_npc_name(str(npc_id)))

		npc_label.text = "Personajes presentes: %s" % ", ".join(names)

	if location_id == "home":
		hint_label.text = "Click para entrar a la Casa del Forastero."
	elif location_id == "shop":
		hint_label.text = "Click para entrar a la Tienda del Umbral."
	else:
		hint_label.text = "Click para viajar a esta ubicación."


func get_present_npcs_for_location(location_id: String) -> Array:
	var result: Array = []

	for npc_id in DataManager.npcs.keys():
		var npc: Dictionary = DataManager.get_npc(str(npc_id))
		var schedule: Dictionary = npc.get("schedule", {})
		var current_location: String = str(schedule.get(GameManager.current_time_block, ""))

		if current_location == location_id:
			result.append(str(npc_id))

	return result


func get_visible_npc_name(npc_id: String) -> String:
	GameManager.ensure_npc_knowledge(npc_id)

	var knowledge: Dictionary = GameManager.player["known_npc_info"].get(npc_id, {})
	var profile_seen: bool = bool(knowledge.get("profile_seen", false))

	if not profile_seen:
		return "???"

	var npc: Dictionary = DataManager.get_npc(npc_id)
	return str(npc.get("name", npc_id))
