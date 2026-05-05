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
	
	var world_button: Button = UIFactory.button("Estado del mundo")
	world_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	world_button.pressed.connect(show_world_state_detail)
	list_container.add_child(world_button)

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

func show_world_state_detail() -> void:
	GameManager.ensure_world_state()

	var global_tension: int = GameManager.get_world_state_value("global_tension")
	var world_instability: int = GameManager.get_world_state_value("world_instability")
	var romantic_pressure: int = GameManager.get_world_state_value("romantic_pressure")

	var text: String = ""
	text += "Estado del mundo\n\n"

	text += "Lectura general:\n"
	text += "- Tensión global: %s · %s\n" % [
		global_tension,
		get_world_state_level_label(global_tension)
	]
	text += "- Inestabilidad del Velo: %s · %s\n" % [
		world_instability,
		get_world_state_level_label(world_instability)
	]
	text += "- Presión romántica: %s · %s\n\n" % [
		romantic_pressure,
		get_world_state_level_label(romantic_pressure)
	]

	text += "Interpretación:\n"
	text += build_world_state_interpretation(global_tension, world_instability, romantic_pressure)
	text += "\n"

	text += "Eje dominante del Velo:\n"
	text += build_veil_axis_text()
	text += "\n"

	text += "Consecuencias activas:\n"
	text += build_active_world_consequences_text()
	text += "\n"

	text += "Memorias del mundo:\n"
	text += build_world_memories_text()

	detail_label.text = text


func get_world_state_level_label(value: int) -> String:
	if value >= 80:
		return "crítico"
	if value >= 60:
		return "alto"
	if value >= 35:
		return "medio"
	if value >= 15:
		return "leve"

	return "estable"


func build_world_state_interpretation(global_tension: int, world_instability: int, romantic_pressure: int) -> String:
	var text: String = ""

	if global_tension <= 10 and world_instability <= 10 and romantic_pressure <= 10:
		text += "- Luminaria todavía parece estable. Las consecuencias existen, pero aún no pesan sobre todos.\n"
	else:
		if global_tension >= world_instability and global_tension >= romantic_pressure:
			text += "- La presión social domina el ambiente. El Consejo, el gremio o los rumores empiezan a importar más que los accidentes aislados.\n"
		elif world_instability >= global_tension and world_instability >= romantic_pressure:
			text += "- El Velo muestra señales de tensión. La realidad conserva coherencia, pero ya no parece completamente obediente.\n"
		else:
			text += "- Los vínculos personales están alterando la superficie pública del mundo. El deseo, los celos y las promesas empiezan a tener consecuencias visibles.\n"

	if global_tension >= 50:
		text += "- La aldea está alerta. Algunas decisiones privadas podrían tener costos públicos.\n"

	if world_instability >= 50:
		text += "- El Velo está inestable. Recuerdos, registros o presencias podrían contradecirse.\n"

	if romantic_pressure >= 50:
		text += "- La vida romántica del Forastero ya no pasa desapercibida.\n"

	return text


func build_veil_axis_text() -> String:
	var axes := {
		"story_axis:veil_interpretation:aeris": "Aeris interpreta el Velo como memoria viva y responsabilidad observada.",
		"story_axis:veil_interpretation:lyria": "Lyria interpreta el Velo como archivo contradictorio y verdad protegida.",
		"story_axis:veil_interpretation:eryon": "Eryon interpreta el Velo como profecía mutable y narración peligrosa.",
		"story_axis:veil_interpretation:nova": "Nova interpreta el Velo como sistema alterable, inestable y emocionalmente reactivo.",
		"story_axis:veil_interpretation:axiom": "Axiom interpreta el Velo como frontera existencial y reconocimiento imposible.",
		"story_axis:veil_interpretation:myr": "Myr interpreta el Velo como identidad mutable y forma sensible al deseo.",
		"story_axis:veil_interpretation:rhein": "Rhein interpreta el Velo como memoria natural anterior a la gente."
	}

	for flag in axes.keys():
		if GameManager.has_world_flag(flag):
			return "- %s\n" % axes[flag]

	return "- Todavía no hay una interpretación dominante. El mundo espera a que tus vínculos le den forma.\n"


func build_active_world_consequences_text() -> String:
	var known_consequences := {
		"council_is_watching": "El Consejo está observando tus movimientos.",
		"social_pressure_rising": "Los rumores sobre el Forastero empiezan a circular.",
		"village_security_weakened": "La seguridad de la aldea quedó debilitada por una decisión emocional.",
		"village_attack_happened": "La aldea sufrió un ataque como consecuencia de una guardia ausente.",
		"guild_order_weakened": "El orden del gremio quedó debilitado.",
		"guild_confusion_seen": "El gremio sufrió confusión por órdenes cruzadas.",
		"faith_pressure_rising": "La tensión espiritual empieza a sentirse alrededor del Santuario.",
		"unstable_prototype_awakened": "Un prototipo inestable despertó por una reacción emocional.",
		"threshold_recognized_player": "El Umbral reconoció al Forastero.",
		"forest_remembers_player": "El bosque recuerda al Forastero de una forma imposible."
	}

	var text: String = ""
	var found: bool = false

	for flag in known_consequences.keys():
		if GameManager.has_world_flag(flag):
			text += "- %s\n" % known_consequences[flag]
			found = true

	if not found:
		text += "- No hay consecuencias globales activas registradas.\n"

	return text

func build_world_memories_text() -> String:
	GameManager.ensure_collectibles()

	var text: String = ""
	var found: bool = false

	for collectible_id in GameManager.get_collectibles():
		var id: String = str(collectible_id)

		if id.begins_with("emotional_memory:world:"):
			text += "- %s\n" % GameManager.get_collectible_label(id)
			found = true

	if not found:
		text += "- Ninguna memoria del mundo registrada todavía.\n"

	return text

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
	text += build_known_info_text(npc_id)

	text += "\nGustos de regalos descubiertos:\n"
	var known_gifts: Array = knowledge.get("gifts", [])

	if known_gifts.is_empty():
		text += "- No has descubierto gustos de regalo todavía.\n"
	else:
		for item_id in known_gifts:
			var item: Dictionary = DataManager.get_item(str(item_id))
			text += "- %s\n" % item.get("name", item_id)
	
	text += "\nHorarios conocidos:\n"
	text += build_known_schedule_text(npc_id)
	
	text += "\nColeccionables:\n"

	var date_memories: Array = collectibles.get("date_memories", [])
	text += "Recuerdos de cita:\n"

	if date_memories.is_empty():
		text += "- Ninguno todavía.\n"
	else:
		for collectible_id in date_memories:
			text += "- %s\n" % GameManager.get_collectible_label(str(collectible_id))
	
	var emotional_memories: Array = collectibles.get("emotional_memories", [])
	text += "\nMemorias emocionales:\n"

	if emotional_memories.is_empty():
		text += "- Ninguna todavía.\n"
	else:
		for collectible_id in emotional_memories:
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
	
	var union_tokens: Array = collectibles.get("union_tokens", [])
	text += "\nPruebas de unión:\n"

	if union_tokens.is_empty():
		text += "- Ninguna todavía.\n"
	else:
		for collectible_id in union_tokens:
			text += "- %s\n" % GameManager.get_collectible_label(str(collectible_id))

	text += "\nNotas:\n"
	var notes: Array = knowledge.get("notes", [])

	if notes.is_empty():
		text += "- Sin notas registradas.\n"
	else:
		for note in notes:
			text += "- %s\n" % str(note)

	detail_label.text = text

func build_known_info_text(npc_id: String) -> String:
	GameManager.ensure_npc_knowledge(npc_id)

	var npc: Dictionary = DataManager.get_npc(npc_id)
	var knowledge: Dictionary = GameManager.player["known_npc_info"][npc_id]
	var known_info: Array = knowledge.get("info", [])
	var info_data: Dictionary = npc.get("info", {})

	if known_info.is_empty():
		return "- No has descubierto información personal todavía.\n"

	var text: String = ""

	for section_id in DataManager.npc_info_schema.keys():
		var section: Dictionary = DataManager.npc_info_schema[section_id]
		var keys: Dictionary = section.get("keys", {})
		var section_text: String = ""
		var has_section_info: bool = false

		for info_key in keys.keys():
			var key: String = str(info_key)

			if not known_info.has(key):
				continue

			if not info_data.has(key):
				continue

			section_text += "- %s: %s\n" % [
				keys.get(key, key),
				str(info_data.get(key, ""))
			]
			has_section_info = true

		if has_section_info:
			text += "%s:\n" % section.get("title", section_id)
			text += section_text
			text += "\n"

	if text == "":
		return "- Has descubierto información, pero no coincide con el esquema actual.\n"

	return text
	
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

func build_known_schedule_text(npc_id: String) -> String:
	GameManager.ensure_npc_knowledge(npc_id)

	var knowledge: Dictionary = GameManager.player["known_npc_info"].get(npc_id, {})
	var known_schedule: Array = knowledge.get("schedule", [])

	for old_key in ["morning", "afternoon", "night"]:
		if known_schedule.has(old_key):
			var migrated_key: String = "weekday:%s" % old_key

			if not known_schedule.has(migrated_key):
				known_schedule.append(migrated_key)

	if known_schedule.is_empty():
		return "- No has registrado horarios todavía.\n"

	var text: String = ""

	var day_types: Array = ["weekday", "saturday", "sunday"]
	var time_blocks: Array = ["morning", "afternoon", "night"]

	for day_type in day_types:
		var day_text: String = ""
		var day_has_info: bool = false

		for time_block in time_blocks:
			var key: String = "%s:%s" % [day_type, time_block]

			if not known_schedule.has(key):
				continue

			var location_id: String = ScheduleSystem.get_schedule_location_for(npc_id, day_type, time_block)

			if location_id == "":
				continue

			var location: Dictionary = DataManager.get_location(location_id)

			day_text += "- %s: %s\n" % [
				ScheduleSystem.get_time_block_label(time_block),
				location.get("name", location_id)
			]

			day_has_info = true

		if day_has_info:
			text += "%s:\n" % get_day_type_label(day_type)
			text += day_text

	if text == "":
		return "- Has visto a este personaje, pero todavía no tienes una rutina clara.\n"

	return text

func get_day_type_label(day_type: String) -> String:
	match day_type:
		"weekday":
			return "Lunes a viernes"
		"saturday":
			return "Sábado"
		"sunday":
			return "Domingo"
		_:
			return day_type
			
func clear_container(container: VBoxContainer) -> void:
	for child in container.get_children():
		child.queue_free()

func setup_fullscreen_root() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0
