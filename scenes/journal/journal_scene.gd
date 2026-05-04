extends Control

var title_label: Label
var list_container: VBoxContainer
var detail_label: Label

func _ready() -> void:
	setup_fullscreen_root()
	build_ui()
	show_npc_list()

func build_ui() -> void:
	var root: VBoxContainer = ScreenRoot.create(self)

	var top_bar: HBoxContainer = HBoxContainer.new()
	top_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_theme_constant_override("separation", 12)
	root.add_child(top_bar)

	var back_button: Button = UIFactory.button("← Volver al mapa")
	back_button.pressed.connect(func(): SceneRouter.go_to_world_map())
	top_bar.add_child(back_button)

	title_label = UIFactory.title("Bitácora")
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(title_label)

	var main_split: HBoxContainer = HBoxContainer.new()
	main_split.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_split.add_theme_constant_override("separation", 16)
	root.add_child(main_split)

	var list_scroll: ScrollContainer = ScrollContainer.new()
	list_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	list_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	list_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	list_scroll.custom_minimum_size = Vector2(320, 1)
	main_split.add_child(list_scroll)

	list_container = VBoxContainer.new()
	list_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_container.add_theme_constant_override("separation", 8)
	list_scroll.add_child(list_container)

	var detail_scroll: ScrollContainer = ScrollContainer.new()
	detail_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	detail_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	main_split.add_child(detail_scroll)

	detail_label = UIFactory.body("Selecciona un personaje para ver detalles.")
	detail_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	detail_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_scroll.add_child(detail_label)

func show_npc_list() -> void:
	clear_container(list_container)

	for npc_id in DataManager.npcs.keys():
		var npc: Dictionary = DataManager.get_npc(npc_id)
		var is_known: bool = is_npc_known(npc_id)

		if is_known:
			var relation: Dictionary = GameManager.player["relationships"].get(npc_id, {})
			var state: String = relation.get("relationship_state", "none")
			var total: int = GameManager.get_total_affinity(npc_id)

			var button_text: String = "%s · %s · Vínculo %s" % [
				npc.get("name", npc_id),
				GameManager.get_relationship_state_label(state),
				total
			]

			var button: Button = UIFactory.button(button_text)
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			button.pressed.connect(func(): show_npc_detail(npc_id))
			list_container.add_child(button)
		else:
			var unknown_button: Button = UIFactory.button("??? · Personaje no conocido")
			unknown_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			unknown_button.pressed.connect(func(): show_unknown_npc_detail())
			list_container.add_child(unknown_button)

func is_npc_known(npc_id: String) -> bool:
	if not GameManager.player.has("known_npc_info"):
		return false

	if not GameManager.player["known_npc_info"].has(npc_id):
		return false

	var knowledge: Dictionary = GameManager.player["known_npc_info"].get(npc_id, {})
	var known_info: Array = knowledge.get("info", [])
	var known_gifts: Array = knowledge.get("gifts", [])
	var notes: Array = knowledge.get("notes", [])

	if not known_info.is_empty():
		return true

	if not known_gifts.is_empty():
		return true

	if not notes.is_empty():
		return true

	if GameManager.player["relationships"].has(npc_id):
		var relation: Dictionary = GameManager.player["relationships"][npc_id]
		var total: int = GameManager.get_total_affinity(npc_id)

		if total > 0:
			return true

		if relation.get("relationship_state", "none") != "none":
			return true

	var collectibles: Dictionary = GameManager.get_npc_collectibles(npc_id)

	if not collectibles.get("date_memories", []).is_empty():
		return true

	if not collectibles.get("portrait_pieces", []).is_empty():
		return true

	if not collectibles.get("trophies", []).is_empty():
		return true

	return false

func show_unknown_npc_detail() -> void:
	var text: String = ""
	text += "???\n\n"
	text += "Personaje no conocido.\n\n"
	text += "Todavía no tienes información suficiente para registrar detalles en la bitácora.\n\n"
	text += "Interactúa con personajes en las distintas ubicaciones para descubrir quiénes son, qué desean y qué papel pueden tener en tu historia."

	detail_label.text = text

func show_npc_detail(npc_id: String) -> void:
	GameManager.ensure_relationship(npc_id)
	GameManager.ensure_npc_knowledge(npc_id)

	var npc: Dictionary = DataManager.get_npc(npc_id)
	var relation: Dictionary = GameManager.player["relationships"][npc_id]
	var knowledge: Dictionary = GameManager.player["known_npc_info"][npc_id]

	var state: String = relation.get("relationship_state", "none")
	var collectibles: Dictionary = GameManager.get_npc_collectibles(npc_id)

	var text: String = ""
	text += "%s\n\n" % npc.get("name", npc_id)

	text += "Estado de relación:\n"
	text += "%s\n" % GameManager.get_relationship_state_label(state)
	text += "%s\n\n" % GameManager.get_relationship_state_description(state)

	text += "Vínculo:\n"
	text += "- Amistad: %s\n" % int(relation.get("friendship", 0))
	text += "- Tensión: %s\n" % int(relation.get("tension", 0))
	text += "- Lealtad: %s\n" % int(relation.get("loyalty", 0))
	text += "- Celos: %s\n" % int(relation.get("jealousy", 0))
	text += "- Total: %s\n\n" % GameManager.get_total_affinity(npc_id)

	text += build_progression_text(npc_id)
	text += "\n"

	text += "Información descubierta:\n"
	var known_info: Array = knowledge.get("info", [])

	if known_info.is_empty():
		text += "- No has descubierto información personal todavía.\n"
	else:
		for info_key in known_info:
			var key: String = str(info_key)
			var label: String = GameManager.get_info_label(key)
			var value: String = str(npc.get("info", {}).get(key, ""))
			var tier: int = GameManager.get_info_tier(key)
			text += "- [%s] %s: %s\n" % [tier, label, value]

	text += "\nGustos de regalos descubiertos:\n"
	var known_gifts: Array = knowledge.get("gifts", [])

	if known_gifts.is_empty():
		text += "- No has descubierto gustos de regalo todavía.\n"
	else:
		for item_id in known_gifts:
			var item: Dictionary = DataManager.get_item(str(item_id))
			text += "- %s\n" % item.get("name", item_id)

	text += "\nColeccionables:\n"

	var date_memories: Array = collectibles.get("date_memories", [])
	text += "Recuerdos de cita:\n"

	if date_memories.is_empty():
		text += "- Ninguno todavía.\n"
	else:
		for collectible_id in date_memories:
			text += "- %s\n" % GameManager.get_collectible_label(str(collectible_id))

	var portrait_pieces: Array = collectibles.get("portrait_pieces", [])
	text += "\nPiezas de retrato:\n"

	if portrait_pieces.is_empty():
		text += "- Ninguna todavía.\n"
	else:
		for collectible_id in portrait_pieces:
			text += "- %s\n" % GameManager.get_collectible_label(str(collectible_id))

	var trophies: Array = collectibles.get("trophies", [])
	text += "\nTrofeo de vínculo:\n"

	if trophies.is_empty():
		text += "- No obtenido.\n"
	else:
		for collectible_id in trophies:
			text += "- %s\n" % GameManager.get_collectible_label(str(collectible_id))

	text += "\nNotas:\n"
	var notes: Array = knowledge.get("notes", [])

	if notes.is_empty():
		text += "- Sin notas registradas.\n"
	else:
		for note in notes:
			text += "- %s\n" % str(note)

	detail_label.text = text

func build_progression_text(npc_id: String) -> String:
	var text: String = "Próximo avance:\n"
	var step_id: String = RelationshipSystem.get_next_step_id(npc_id)

	if step_id == "":
		text += "- Esta ruta personal ya llegó a su estado máximo disponible.\n"
		return text

	var step: Dictionary = DataManager.get_relationship_step(step_id)
	text += "- %s\n" % step.get("name", step_id)

	if RelationshipSystem.can_start_step(npc_id, step_id):
		text += "- Disponible: sí\n"
	else:
		text += "- Disponible: no\n"
		text += "- Motivo: %s\n" % RelationshipSystem.get_blocked_reason(npc_id, step_id)

	var required_tier: int = int(step.get("required_info_tier", 0))
	var required_count: int = int(step.get("required_known_info_count", 0))
	var known_count: int = RelationshipSystem.get_known_info_count_for_tier(npc_id, required_tier)

	text += "- Información tier %s: %s/%s\n" % [
		required_tier,
		known_count,
		required_count
	]

	if step.get("required_successful_date", false):
		var has_date: bool = GameManager.has_world_flag("successful_date:%s" % npc_id)
		text += "- Cita normal exitosa: %s\n" % ("sí" if has_date else "no")

	text += "- Vínculo requerido: %s\n" % int(step.get("required_total_affinity", 0))

	return text

func clear_container(container: VBoxContainer) -> void:
	for child in container.get_children():
		child.queue_free()

func setup_fullscreen_root() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0
