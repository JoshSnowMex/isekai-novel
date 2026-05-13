extends Control


var hud_bar: WorldHudBar

var journal_frame: PanelContainer
var journal_layer: Control
var background_layer: Control

var top_info_panel: PanelContainer
var top_info_label: Label

var global_action_panel: PanelContainer
var global_action_buttons: HBoxContainer

var nav_panel: PanelContainer
var nav_buttons: VBoxContainer

var content_panel: PanelContainer
var content_title_label: Label
var content_subtitle_label: Label
var content_scroll: ScrollContainer
var content_container: VBoxContainer

var selected_section: String = "people"
var selected_npc_id: String = ""

const SECTION_WORLD := "world"
const SECTION_PEOPLE := "people"
const SECTION_CALENDAR := "calendar"
const SECTION_MEMORIES := "memories"
const SECTION_UNION := "union"


func _ready() -> void:
	setup_fullscreen_root()
	build_ui()
	show_section(SECTION_PEOPLE)


func build_ui() -> void:
	var root: VBoxContainer = VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 0
	root.offset_top = 0
	root.offset_right = 0
	root.offset_bottom = 0
	root.add_theme_constant_override("separation", 4)
	add_child(root)

	hud_bar = WorldHudBar.new()
	hud_bar.build()
	root.add_child(hud_bar)

	journal_frame = PanelContainer.new()
	journal_frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	journal_frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(journal_frame)

	var frame_margin: MarginContainer = MarginContainer.new()
	frame_margin.add_theme_constant_override("margin_left", 6)
	frame_margin.add_theme_constant_override("margin_top", 6)
	frame_margin.add_theme_constant_override("margin_right", 6)
	frame_margin.add_theme_constant_override("margin_bottom", 6)
	journal_frame.add_child(frame_margin)

	journal_layer = Control.new()
	journal_layer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	journal_layer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	journal_layer.clip_contents = true
	frame_margin.add_child(journal_layer)

	background_layer = Control.new()
	background_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	background_layer.offset_left = 0
	background_layer.offset_top = 0
	background_layer.offset_right = 0
	background_layer.offset_bottom = 0
	journal_layer.add_child(background_layer)

	build_background()
	build_top_info_panel()
	build_global_action_panel()
	build_nav_panel()
	build_content_panel()

	call_deferred("refresh_layout_after_frame")


func build_background() -> void:
	clear_children(background_layer)

	var background: Control = VisualAsset.make_texture_or_placeholder(
		"res://assets/backgrounds/journal_forastero.png",
		"Bitácora del Forastero",
		"Fondo final: journal_forastero.png"
	)

	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.offset_left = 0
	background.offset_top = 0
	background.offset_right = 0
	background.offset_bottom = 0
	background_layer.add_child(background)


func build_top_info_panel() -> void:
	top_info_panel = PanelContainer.new()
	top_info_panel.custom_minimum_size = Vector2(540, 46)
	journal_layer.add_child(top_info_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 6)
	top_info_panel.add_child(margin)

	top_info_label = Label.new()
	top_info_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_info_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	top_info_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	top_info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	top_info_label.clip_text = true
	margin.add_child(top_info_label)


func build_global_action_panel() -> void:
	global_action_panel = PanelContainer.new()
	global_action_panel.custom_minimum_size = Vector2(250, 46)
	journal_layer.add_child(global_action_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 6)
	global_action_panel.add_child(margin)

	global_action_buttons = HBoxContainer.new()
	global_action_buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	global_action_buttons.add_theme_constant_override("separation", 8)
	margin.add_child(global_action_buttons)

	add_global_action("Volver", func(): SceneRouter.return_from_journal())
	add_global_action("Guardar", func():
		SaveManager.save_game()
		set_context("Partida guardada desde la bitácora.")
	)


func build_nav_panel() -> void:
	nav_panel = PanelContainer.new()
	nav_panel.custom_minimum_size = Vector2(190, 360)
	journal_layer.add_child(nav_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	nav_panel.add_child(margin)

	nav_buttons = VBoxContainer.new()
	nav_buttons.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nav_buttons.size_flags_vertical = Control.SIZE_EXPAND_FILL
	nav_buttons.add_theme_constant_override("separation", 8)
	margin.add_child(nav_buttons)


func build_content_panel() -> void:
	content_panel = PanelContainer.new()
	content_panel.custom_minimum_size = Vector2(720, 360)
	journal_layer.add_child(content_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 10)
	content_panel.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 8)
	margin.add_child(box)

	content_title_label = Label.new()
	content_title_label.custom_minimum_size = Vector2(1, 28)
	content_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	content_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	content_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(content_title_label)

	content_subtitle_label = Label.new()
	content_subtitle_label.custom_minimum_size = Vector2(1, 38)
	content_subtitle_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_subtitle_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	content_subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	content_subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(content_subtitle_label)

	content_scroll = ScrollContainer.new()
	content_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	box.add_child(content_scroll)

	content_container = VBoxContainer.new()
	content_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_container.add_theme_constant_override("separation", 10)
	content_scroll.add_child(content_container)

func show_section(section_id: String) -> void:
	selected_section = section_id
	selected_npc_id = ""

	hud_bar.refresh()
	build_nav_buttons()

	match section_id:
		SECTION_WORLD:
			show_world_section()
		SECTION_PEOPLE:
			show_people_section()
		SECTION_CALENDAR:
			show_calendar_section()
		SECTION_MEMORIES:
			show_memories_section()
		SECTION_UNION:
			show_union_section()
		_:
			show_people_section()

	call_deferred("refresh_layout_after_frame")


func build_nav_buttons() -> void:
	clear_children(nav_buttons)

	add_nav_button("Personas", SECTION_PEOPLE, "Relaciones, secretos, horarios y recuerdos asociados a cada personaje.")
	add_nav_button("Mundo", SECTION_WORLD, "Estado de Luminaria, presión del Velo y consecuencias globales.")
	add_nav_button("Calendario", SECTION_CALENDAR, "Fechas emocionales, aniversarios y momentos que la historia recuerda.")
	add_nav_button("Recuerdos", SECTION_MEMORIES, "Memorias, trofeos y fragmentos conseguidos durante la partida.")
	add_nav_button("Unión", SECTION_UNION, "Progreso hacia la unión definitiva y consecuencias posteriores.")


func add_nav_button(text: String, section_id: String, hint: String) -> void:
	var button: Button = Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_ALL
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(1, 42)
	button.disabled = selected_section == section_id

	if not button.disabled:
		button.pressed.connect(func(): show_section(section_id))

	button.mouse_entered.connect(func(): set_context(hint))
	button.focus_entered.connect(func(): set_context(hint))

	nav_buttons.add_child(button)


func show_people_section() -> void:
	top_info_label.text = "Bitácora · Personas"
	content_title_label.text = "Personas conocidas"
	content_subtitle_label.text = "Cada vínculo deja rastros: afinidad, secretos, rutinas, regalos y memorias. No todo lo desconocido está ausente; a veces solo espera ser nombrado."
	set_context("Selecciona una tarjeta para abrir el expediente emocional de ese personaje.")

	clear_children(content_container)

	var known_count: int = 0

	for npc_id in DataManager.npcs.keys():
		if is_npc_known(str(npc_id)):
			known_count += 1

	add_text_card("Progreso", "Personajes conocidos: %s/%s" % [
		known_count,
		DataManager.npcs.keys().size()
	])

	var grid: GridContainer = GridContainer.new()
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	content_container.add_child(grid)

	for npc_id in DataManager.npcs.keys():
		add_npc_card(grid, str(npc_id))


func add_npc_card(parent: Node, npc_id: String) -> void:
	var npc: Dictionary = DataManager.get_npc(npc_id)
	var known: bool = is_npc_known(npc_id)
	var display_name: String = "???"

	if known:
		display_name = str(npc.get("name", npc_id))

	var button: Button = Button.new()
	button.focus_mode = Control.FOCUS_ALL
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(260, 92)

	if known:
		GameManager.ensure_relationship(npc_id)
		var relation: Dictionary = GameManager.player["relationships"][npc_id]
		var total: int = GameManager.get_total_affinity(npc_id)
		var state: String = str(relation.get("relationship_state", "none"))

		button.text = "%s\n%s · Vínculo %s\n%s" % [
			display_name,
			GameManager.get_relationship_state_label(state),
			total,
			get_npc_card_hint(npc_id)
		]

		button.pressed.connect(func(): show_npc_detail_view(npc_id))
		button.mouse_entered.connect(func(): set_context("Abrir detalles de %s." % display_name))
		button.focus_entered.connect(func(): set_context("Abrir detalles de %s." % display_name))
	else:
		button.text = "???\nPersona no conocida\nBusca encuentros en Luminaria."
		button.pressed.connect(func(): show_unknown_npc_detail_view())
		button.mouse_entered.connect(func(): set_context("Aún no sabes quién es. Interactúa con personajes en ubicaciones para revelar identidades."))
		button.focus_entered.connect(func(): set_context("Aún no sabes quién es. Interactúa con personajes en ubicaciones para revelar identidades."))

	parent.add_child(button)


func get_npc_card_hint(npc_id: String) -> String:
	var collectibles: Dictionary = GameManager.get_npc_collectibles(npc_id)
	var memory_count: int = int(collectibles.get("date_memories", []).size()) + int(collectibles.get("emotional_memories", []).size())

	if memory_count > 0:
		return "%s memoria(s)" % memory_count

	var knowledge: Dictionary = GameManager.player.get("known_npc_info", {}).get(npc_id, {})
	var known_info: Array = knowledge.get("info", [])

	if not known_info.is_empty():
		return "%s secreto(s)" % known_info.size()

	return "sin memorias registradas"


func show_unknown_npc_detail_view() -> void:
	top_info_label.text = "Bitácora · Persona desconocida"
	content_title_label.text = "???"
	content_subtitle_label.text = "Hay presencias que todavía no tienen nombre en tu historia."
	set_context("Encuentra personajes en sus ubicaciones y acércate a ellos para abrir su registro.")

	clear_children(content_container)

	add_text_card(
		"Registro incompleto",
		"Todavía no tienes información suficiente para registrar detalles. Interactúa con personajes en distintas ubicaciones para descubrir quiénes son, qué desean y qué papel pueden tener en tu historia."
	)

	add_action_card("Volver a personas", "Regresa al listado de personajes.", func(): show_people_section())


func show_npc_detail_view(npc_id: String) -> void:
	selected_npc_id = npc_id
	GameManager.ensure_relationship(npc_id)
	GameManager.ensure_npc_knowledge(npc_id)

	var npc: Dictionary = DataManager.get_npc(npc_id)
	var relation: Dictionary = GameManager.player["relationships"][npc_id]
	var state: String = str(relation.get("relationship_state", "none"))

	top_info_label.text = "Bitácora · Personas"
	content_title_label.text = str(npc.get("name", npc_id))
	content_subtitle_label.text = "%s · Vínculo total %s" % [
		GameManager.get_relationship_state_label(state),
		GameManager.get_total_affinity(npc_id)
	]
	set_context("Este registro mezcla datos descubiertos y memoria emocional. Lo que falta también importa.")

	clear_children(content_container)

	add_action_card("← Volver a personas", "Regresa al listado de personajes conocidos.", func(): show_people_section())

	add_text_card("Estado de relación", "%s\n\n%s" % [
		GameManager.get_relationship_state_label(state),
		GameManager.get_relationship_state_description(state)
	])

	add_text_card("Vínculo", build_npc_affinity_summary(npc_id))
	add_text_card("Próximo avance", build_progression_text(npc_id))
	add_text_card("Unión definitiva", build_final_union_progress_text(npc_id))

	var postgame_text: String = build_npc_postgame_text(npc_id)
	if postgame_text != "":
		add_text_card("Vida compartida", postgame_text)

	add_text_card("Fechas importantes", build_emotional_calendar_text(npc_id))
	add_text_card("Información descubierta", build_known_info_text(npc_id))
	add_text_card("Regalos conocidos", build_known_gifts_text(npc_id))
	add_text_card("Horarios conocidos", build_known_schedule_text(npc_id))
	add_text_card("Coleccionables", build_npc_collectibles_text(npc_id))
	add_text_card("Notas", build_npc_notes_text(npc_id))


func build_npc_affinity_summary(npc_id: String) -> String:
	var relation: Dictionary = GameManager.player["relationships"][npc_id]

	return "- Amistad: %s\n- Tensión: %s\n- Lealtad: %s\n- Celos: %s\n- Total: %s" % [
		int(relation.get("friendship", 0)),
		int(relation.get("tension", 0)),
		int(relation.get("loyalty", 0)),
		int(relation.get("jealousy", 0)),
		GameManager.get_total_affinity(npc_id)
	]


func build_known_gifts_text(npc_id: String) -> String:
	GameManager.ensure_npc_knowledge(npc_id)

	var knowledge: Dictionary = GameManager.player["known_npc_info"][npc_id]
	var known_gifts: Array = knowledge.get("gifts", [])

	if known_gifts.is_empty():
		return "- No has descubierto gustos de regalo todavía."

	var text: String = ""

	for item_id in known_gifts:
		var item: Dictionary = DataManager.get_item(str(item_id))
		text += "- %s\n" % item.get("name", item_id)

	return text.strip_edges()


func build_npc_collectibles_text(npc_id: String) -> String:
	var collectibles: Dictionary = GameManager.get_npc_collectibles(npc_id)
	var text: String = ""

	text += "Recuerdos de cita:\n"
	text += build_collectible_list(collectibles.get("date_memories", []), "Ninguno todavía.")
	text += "\n\nMemorias emocionales:\n"
	text += build_collectible_list(collectibles.get("emotional_memories", []), "Ninguna todavía.")
	text += "\n\nPiezas de retrato:\n"
	text += build_collectible_list(collectibles.get("portrait_pieces", []), "Ninguna todavía.")
	text += "\n\nTrofeos:\n"
	text += build_collectible_list(collectibles.get("trophies", []), "No obtenido.")
	text += "\n\nPruebas de unión:\n"
	text += build_collectible_list(collectibles.get("union_tokens", []), "Ninguna todavía.")

	return text

func build_collectible_list(values: Array, empty_text: String) -> String:
	if values.is_empty():
		return "- %s" % empty_text

	var text: String = ""

	for collectible_id in values:
		var label: String = get_safe_collectible_label(str(collectible_id))

		if label == "":
			continue

		text += "- %s\n" % label

	if text.strip_edges() == "":
		return "- %s" % empty_text

	return text.strip_edges()

func get_safe_collectible_label(collectible_id: String) -> String:
	var clean_id: String = collectible_id.strip_edges()

	if clean_id == "":
		return ""

	if clean_id.to_lower() == "page that should not exist":
		return "Memoria emocional registrada"

	var label: String = GameManager.get_collectible_label(clean_id).strip_edges()

	if label == "":
		return prettify_collectible_id(clean_id)

	if label.to_lower() == "page that should not exist":
		return "Memoria emocional registrada"

	return label


func prettify_collectible_id(collectible_id: String) -> String:
	var text: String = collectible_id.replace("_", " ").replace(":", " · ")
	var parts: PackedStringArray = text.split(" ", false)
	var pretty_parts: Array = []

	for part in parts:
		var p: String = str(part)

		if p.length() <= 1:
			pretty_parts.append(p.to_upper())
		else:
			pretty_parts.append(p.substr(0, 1).to_upper() + p.substr(1))

	return " ".join(pretty_parts)
	
func build_npc_notes_text(npc_id: String) -> String:
	GameManager.ensure_npc_knowledge(npc_id)

	var knowledge: Dictionary = GameManager.player["known_npc_info"][npc_id]
	var notes: Array = knowledge.get("notes", [])

	if notes.is_empty():
		return "- Sin notas registradas."

	var text: String = ""

	for note in notes:
		text += "- %s\n" % str(note)

	return text.strip_edges()

func add_calendar_npc_card(parent: Node, npc_id: String) -> void:
	var npc: Dictionary = DataManager.get_npc(npc_id)
	var name: String = str(npc.get("name", npc_id))
	var calendar_text: String = build_emotional_calendar_text(npc_id)
	var summary: String = summarize_block_text(calendar_text, 2)

	var button: Button = Button.new()
	button.text = "%s\n%s" % [name, summary]
	button.focus_mode = Control.FOCUS_ALL
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(260, 86)
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.pressed.connect(func(): show_calendar_npc_detail(npc_id))
	button.mouse_entered.connect(func(): set_context("Ver calendario emocional de %s." % name))
	button.focus_entered.connect(func(): set_context("Ver calendario emocional de %s." % name))
	parent.add_child(button)


func show_calendar_npc_detail(npc_id: String) -> void:
	var npc: Dictionary = DataManager.get_npc(npc_id)
	var name: String = str(npc.get("name", npc_id))

	top_info_label.text = "Bitácora · Calendario · %s" % name
	content_title_label.text = name
	content_subtitle_label.text = "Fechas, promesas y heridas asociadas a este vínculo."
	set_context("Detalle del calendario emocional.")

	clear_children(content_container)

	add_action_card("← Volver al calendario", "Regresa al resumen del calendario emocional.", func(): show_calendar_section())
	add_text_card("Fechas importantes", build_emotional_calendar_text(npc_id))
	
func show_world_section() -> void:
	GameManager.ensure_world_state()

	var global_tension: int = GameManager.get_world_state_value("global_tension")
	var world_instability: int = GameManager.get_world_state_value("world_instability")
	var romantic_pressure: int = GameManager.get_world_state_value("romantic_pressure")

	top_info_label.text = "Bitácora · Mundo"
	content_title_label.text = "Estado de Luminaria"
	content_subtitle_label.text = "El mundo responde a tensión, memoria, deseo y consecuencias."
	set_context("Elige un bloque para leer detalle sin perderte en una lista larga.")

	clear_children(content_container)

	add_text_card("Lectura general", "Tensión global: %s · %s\nVelo: %s · %s\nPresión romántica: %s · %s" % [
		global_tension,
		get_world_state_level_label(global_tension),
		world_instability,
		get_world_state_level_label(world_instability),
		romantic_pressure,
		get_world_state_level_label(romantic_pressure)
	])

	add_action_card(
		"Interpretación",
		summarize_block_text(build_world_state_interpretation(global_tension, world_instability, romantic_pressure), 2),
		func(): show_world_detail("Interpretación", build_world_state_interpretation(global_tension, world_instability, romantic_pressure))
	)

	add_action_card(
		"Eje dominante del Velo",
		summarize_block_text(build_veil_axis_text(), 2),
		func(): show_world_detail("Eje dominante del Velo", build_veil_axis_text())
	)

	add_action_card(
		"Consecuencias activas",
		summarize_block_text(build_active_world_consequences_text(), 2),
		func(): show_world_detail("Consecuencias activas", build_active_world_consequences_text())
	)

	add_action_card(
		"Memorias del mundo",
		summarize_block_text(build_world_memories_text(), 2),
		func(): show_world_detail("Memorias del mundo", build_world_memories_text())
	)

	add_action_card(
		"Después de la unión",
		summarize_block_text(build_postgame_status_text(), 2),
		func(): show_world_detail("Después de la unión", build_postgame_status_text())
	)

	add_action_card(
		"Unión definitiva",
		summarize_block_text(build_final_union_text(), 2),
		func(): show_world_detail("Unión definitiva", build_final_union_text())
	)

func show_world_detail(title: String, body: String) -> void:
	top_info_label.text = "Bitácora · Mundo · %s" % title
	content_title_label.text = title
	content_subtitle_label.text = "Detalle del estado del mundo."
	set_context("Detalle de mundo.")

	clear_children(content_container)

	add_action_card("← Volver a mundo", "Regresa al resumen del mundo.", func(): show_world_section())
	add_text_card(title, body)
	
func show_calendar_section() -> void:
	top_info_label.text = "Bitácora · Calendario"
	content_title_label.text = "Calendario emocional"
	content_subtitle_label.text = "Los momentos importantes quedan agrupados por persona para evitar perderse en una lista interminable."
	set_context("Elige una tarjeta para ver fechas concretas.")

	clear_children(content_container)

	add_text_card("Resumen global", build_global_emotional_calendar_summary())

	var grid: GridContainer = GridContainer.new()
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	content_container.add_child(grid)

	var any_known: bool = false

	for npc_id in DataManager.npcs.keys():
		if is_npc_known(str(npc_id)):
			any_known = true
			add_calendar_npc_card(grid, str(npc_id))

	if not any_known:
		add_text_card("Sin registros personales", "Aún no hay fechas emocionales asociadas a personajes conocidos.")

func show_memories_section() -> void:
	top_info_label.text = "Bitácora · Recuerdos"
	content_title_label.text = "Memorias y fragmentos"
	content_subtitle_label.text = "Los recuerdos se agrupan por origen para que puedas revisarlos sin una lista interminable."
	set_context("Elige un bloque para ver sus recuerdos.")

	clear_children(content_container)

	add_action_card(
		"Memorias del mundo",
		summarize_block_text(build_world_memories_text(), 2),
		func(): show_world_memories_detail()
	)

	var grid: GridContainer = GridContainer.new()
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	content_container.add_child(grid)

	var any_known: bool = false

	for npc_id in DataManager.npcs.keys():
		if is_npc_known(str(npc_id)):
			any_known = true
			add_memory_npc_card(grid, str(npc_id))

	if not any_known:
		add_text_card("Sin memorias personales", "Aún no hay recuerdos asociados a personajes conocidos.")
		
func add_memory_npc_card(parent: Node, npc_id: String) -> void:
	var npc: Dictionary = DataManager.get_npc(npc_id)
	var name: String = str(npc.get("name", npc_id))
	var collectibles: Dictionary = GameManager.get_npc_collectibles(npc_id)

	var total: int = 0
	total += int(collectibles.get("date_memories", []).size())
	total += int(collectibles.get("emotional_memories", []).size())
	total += int(collectibles.get("portrait_pieces", []).size())
	total += int(collectibles.get("trophies", []).size())
	total += int(collectibles.get("union_tokens", []).size())

	var button: Button = Button.new()
	button.text = "%s\n%s recuerdo(s) registrado(s)" % [name, total]
	button.focus_mode = Control.FOCUS_ALL
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(260, 82)
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.pressed.connect(func(): show_memory_npc_detail(npc_id))
	button.mouse_entered.connect(func(): set_context("Ver recuerdos asociados a %s." % name))
	button.focus_entered.connect(func(): set_context("Ver recuerdos asociados a %s." % name))
	parent.add_child(button)


func show_world_memories_detail() -> void:
	top_info_label.text = "Bitácora · Recuerdos · Mundo"
	content_title_label.text = "Memorias del mundo"
	content_subtitle_label.text = "Eventos y consecuencias que Luminaria conserva."
	set_context("Detalle de memorias del mundo.")

	clear_children(content_container)

	add_action_card("← Volver a recuerdos", "Regresa al resumen de recuerdos.", func(): show_memories_section())
	add_text_card("Memorias del mundo", build_world_memories_text())


func show_memory_npc_detail(npc_id: String) -> void:
	var npc: Dictionary = DataManager.get_npc(npc_id)
	var name: String = str(npc.get("name", npc_id))

	top_info_label.text = "Bitácora · Recuerdos · %s" % name
	content_title_label.text = name
	content_subtitle_label.text = "Recuerdos, piezas y pruebas asociadas a este vínculo."
	set_context("Detalle de recuerdos personales.")

	clear_children(content_container)

	add_action_card("← Volver a recuerdos", "Regresa al resumen de recuerdos.", func(): show_memories_section())
	add_text_card("Coleccionables", build_npc_collectibles_text(npc_id))
	
func show_union_section() -> void:
	top_info_label.text = "Bitácora · Unión"
	content_title_label.text = "Unión definitiva"
	content_subtitle_label.text = "Una ruta final no es solo un cierre: cambia qué tipo de historia continúa después."
	set_context("Revisa estado actual, candidatos y consecuencias posteriores.")

	clear_children(content_container)

	add_action_card(
		"Estado actual",
		summarize_block_text(build_final_union_text(), 2),
		func(): show_union_state_detail()
	)

	add_action_card(
		"Después de la unión",
		summarize_block_text(build_postgame_status_text(), 2),
		func(): show_union_after_detail()
	)

	if FinalUnionSystem.has_final_union():
		var chosen_npc_id: String = FinalUnionSystem.get_final_union_npc_id()
		var chosen_npc: Dictionary = DataManager.get_npc(chosen_npc_id)
		add_action_card(
			"Vínculo elegido: %s" % chosen_npc.get("name", chosen_npc_id),
			summarize_block_text(build_final_union_progress_text(chosen_npc_id), 2),
			func(): show_union_npc_detail(chosen_npc_id)
		)
	else:
		var grid: GridContainer = GridContainer.new()
		grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.columns = 2
		grid.add_theme_constant_override("h_separation", 10)
		grid.add_theme_constant_override("v_separation", 10)
		content_container.add_child(grid)

		var any_known: bool = false

		for npc_id in DataManager.npcs.keys():
			if is_npc_known(str(npc_id)):
				any_known = true
				add_union_npc_card(grid, str(npc_id))

		if not any_known:
			add_text_card("Sin candidatos conocidos", "Aún no hay vínculos suficientes para mostrar candidatos de unión.")

func add_union_npc_card(parent: Node, npc_id: String) -> void:
	var npc: Dictionary = DataManager.get_npc(npc_id)
	var name: String = str(npc.get("name", npc_id))
	var progress_text: String = build_final_union_progress_text(npc_id)

	var button: Button = Button.new()
	button.text = "%s\n%s" % [name, summarize_block_text(progress_text, 2)]
	button.focus_mode = Control.FOCUS_ALL
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(260, 88)
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.pressed.connect(func(): show_union_npc_detail(npc_id))
	button.mouse_entered.connect(func(): set_context("Ver progreso de unión con %s." % name))
	button.focus_entered.connect(func(): set_context("Ver progreso de unión con %s." % name))
	parent.add_child(button)


func show_union_state_detail() -> void:
	top_info_label.text = "Bitácora · Unión · Estado"
	content_title_label.text = "Estado actual"
	content_subtitle_label.text = "Resumen de la ruta final y sus bloqueos."
	set_context("Detalle del estado de unión.")

	clear_children(content_container)

	add_action_card("← Volver a unión", "Regresa al resumen de unión.", func(): show_union_section())
	add_text_card("Estado actual", build_final_union_text())


func show_union_after_detail() -> void:
	top_info_label.text = "Bitácora · Unión · Después"
	content_title_label.text = "Después de la unión"
	content_subtitle_label.text = "Consecuencias posteriores a la elección definitiva."
	set_context("Detalle de consecuencias posteriores.")

	clear_children(content_container)

	add_action_card("← Volver a unión", "Regresa al resumen de unión.", func(): show_union_section())
	add_text_card("Después de la unión", build_postgame_status_text())


func show_union_npc_detail(npc_id: String) -> void:
	var npc: Dictionary = DataManager.get_npc(npc_id)
	var name: String = str(npc.get("name", npc_id))

	top_info_label.text = "Bitácora · Unión · %s" % name
	content_title_label.text = name
	content_subtitle_label.text = "Progreso y requisitos hacia la unión definitiva."
	set_context("Detalle de candidato de unión.")

	clear_children(content_container)

	add_action_card("← Volver a unión", "Regresa al resumen de unión.", func(): show_union_section())
	add_text_card("Progreso de unión", build_final_union_progress_text(npc_id))
	
func add_text_card(title: String, body: String) -> PanelContainer:
	var card: PanelContainer = PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_container.add_child(card)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 8)
	card.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 4)
	margin.add_child(box)

	var title_label: Label = Label.new()
	title_label.text = title
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(title_label)

	var body_label: Label = Label.new()
	body_label.text = body if body.strip_edges() != "" else "- Sin información registrada."
	body_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(body_label)

	return card

func summarize_block_text(text: String, max_lines: int = 2) -> String:
	var clean_text: String = text.strip_edges()

	if clean_text == "":
		return "Sin información registrada."

	var raw_lines: PackedStringArray = clean_text.split("\n", false)
	var lines: Array = []

	for raw_line in raw_lines:
		var line: String = str(raw_line).strip_edges()

		if line == "":
			continue

		if line.begins_with("- "):
			line = line.substr(2).strip_edges()

		lines.append(line)

		if lines.size() >= max_lines:
			break

	var summary: String = " · ".join(lines)

	if summary.length() > 150:
		summary = summary.substr(0, 147).strip_edges() + "..."

	return summary
	
func add_action_card(title: String, hint: String, callback: Callable) -> void:
	var button: Button = Button.new()
	button.text = "%s\n%s" % [title, hint]
	button.focus_mode = Control.FOCUS_ALL
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(1, 64)
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.pressed.connect(callback)
	button.mouse_entered.connect(func(): set_context(hint))
	button.focus_entered.connect(func(): set_context(hint))
	content_container.add_child(button)

func set_context(text: String) -> void:
	var clean_text: String = text.strip_edges()

	if clean_text.length() > 72:
		clean_text = clean_text.substr(0, 69).strip_edges() + "..."

	if selected_section == SECTION_PEOPLE:
		top_info_label.text = "Bitácora · Personas · %s" % clean_text
	elif selected_section == SECTION_WORLD:
		top_info_label.text = "Bitácora · Mundo · %s" % clean_text
	elif selected_section == SECTION_CALENDAR:
		top_info_label.text = "Bitácora · Calendario · %s" % clean_text
	elif selected_section == SECTION_MEMORIES:
		top_info_label.text = "Bitácora · Recuerdos · %s" % clean_text
	elif selected_section == SECTION_UNION:
		top_info_label.text = "Bitácora · Unión · %s" % clean_text
	else:
		top_info_label.text = "Bitácora · %s" % clean_text


func add_global_action(text: String, callback: Callable) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_ALL
	button.pressed.connect(callback)
	global_action_buttons.add_child(button)
	return button


func is_npc_known(npc_id: String) -> bool:
	if not GameManager.player.has("known_npc_info"):
		return false

	if not GameManager.player["known_npc_info"].has(npc_id):
		return false

	var knowledge: Dictionary = GameManager.player["known_npc_info"].get(npc_id, {})
	var known_info: Array = knowledge.get("info", [])
	var known_gifts: Array = knowledge.get("gifts", [])
	var notes: Array = knowledge.get("notes", [])

	if bool(knowledge.get("profile_seen", false)):
		return true

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

	return text.strip_edges()


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
			return "- %s" % axes[flag]

	return "- Todavía no hay una interpretación dominante. El mundo espera a que tus vínculos le den forma."


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
		text += "- No hay consecuencias globales activas registradas."

	return text.strip_edges()


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
		text += "- Ninguna memoria del mundo registrada todavía."

	return text.strip_edges()


func build_final_union_text() -> String:
	if not FinalUnionSystem.has_final_union():
		return "- Todavía no has elegido una unión definitiva."

	var npc_id: String = FinalUnionSystem.get_final_union_npc_id()
	var npc: Dictionary = DataManager.get_npc(npc_id)
	var requirement: Dictionary = DataManager.get_final_union_requirement(npc_id)

	return "- %s · %s" % [
		npc.get("name", npc_id),
		requirement.get("name", "Unión final")
	]


func build_postgame_status_text() -> String:
	if not PostgameSystem.is_postgame_started():
		return "- No ha comenzado. La historia aún no tiene una unión definitiva."

	var text: String = PostgameSystem.get_postgame_status_text()
	var stability: int = PostgameSystem.get_postgame_state_value("final_union_stability")

	if stability <= 35:
		text += "\n- Advertencia: la unión definitiva necesita atención urgente."
	elif stability <= 55:
		text += "\n- La unión resiste, pero hay tensión acumulada."
	else:
		text += "\n- La unión se mantiene estable."

	return text


func build_known_info_text(npc_id: String) -> String:
	GameManager.ensure_npc_knowledge(npc_id)

	var npc: Dictionary = DataManager.get_npc(npc_id)
	var knowledge: Dictionary = GameManager.player["known_npc_info"][npc_id]
	var known_info: Array = knowledge.get("info", [])
	var info_data: Dictionary = npc.get("info", {})

	if known_info.is_empty():
		return "- No has descubierto información personal todavía."

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
		return "- Has descubierto información, pero no coincide con el esquema actual."

	return text.strip_edges()


func build_emotional_calendar_text(npc_id: String) -> String:
	var calendar: Dictionary = GameManager.get_npc_emotional_calendar(npc_id)

	if calendar.is_empty():
		return "- Todavía no hay fechas importantes registradas."

	var order: Array = [
		"first_date",
		"first_successful_date",
		"first_excellent_date",
		"first_perfect_date",
		"relationship_interest_day",
		"relationship_dating_day",
		"relationship_lovers_day",
		"relationship_partner_day",
		"final_union_day"
	]

	var text: String = ""

	GameManager.ensure_npc_knowledge(npc_id)
	var knowledge: Dictionary = GameManager.player["known_npc_info"].get(npc_id, {})
	var known_info: Array = knowledge.get("info", [])
	var npc: Dictionary = DataManager.get_npc(npc_id)
	var info_data: Dictionary = npc.get("info", {})

	if known_info.has("birthday") and info_data.has("birthday"):
		text += "- Cumpleaños: %s\n" % str(info_data.get("birthday", ""))

	for key in order:
		if not calendar.has(key):
			continue

		var data: Dictionary = calendar[key]
		text += "- %s: Día %s · %s\n" % [
			data.get("label", key),
			int(data.get("day", 1)),
			GameManager.get_time_block_label(str(data.get("time_block", "")))
		]

	var extra_keys: Array = []

	for key in calendar.keys():
		if not order.has(key):
			extra_keys.append(key)

	extra_keys.sort()

	for key in extra_keys:
		var data: Dictionary = calendar[key]
		text += "- %s: Día %s · %s\n" % [
			data.get("label", key),
			int(data.get("day", 1)),
			GameManager.get_time_block_label(str(data.get("time_block", "")))
		]

	if text == "":
		return "- Todavía no hay fechas importantes registradas."

	return text.strip_edges()


func build_final_union_progress_text(npc_id: String) -> String:
	var text: String = ""
	var requirement: Dictionary = DataManager.get_final_union_requirement(npc_id)

	if FinalUnionSystem.has_final_union():
		if FinalUnionSystem.get_final_union_npc_id() == npc_id:
			text += "- Este personaje es tu unión definitiva."
		else:
			var chosen_id: String = FinalUnionSystem.get_final_union_npc_id()
			var chosen_npc: Dictionary = DataManager.get_npc(chosen_id)
			text += "- Ya elegiste una unión definitiva con %s." % chosen_npc.get("name", chosen_id)

		return text

	text += "- Tipo: %s\n" % requirement.get("name", "Unión final")

	var reason: String = FinalUnionSystem.get_blocked_reason(npc_id)

	if reason == "":
		text += "- Disponible: sí"
	else:
		text += "- Disponible: no\n"
		text += "- Motivo: %s" % reason

	return text


func build_progression_text(npc_id: String) -> String:
	var text: String = ""
	var step_id: String = RelationshipSystem.get_next_step_id(npc_id)

	if step_id == "":
		text += "- Esta ruta personal ya llegó a su estado máximo disponible."
		return text

	var step: Dictionary = DataManager.get_relationship_step(step_id)
	text += "- %s\n" % step.get("name", step_id)

	if RelationshipSystem.can_start_step(npc_id, step_id):
		text += "- Disponible: sí\n"
	else:
		text += "- Disponible: no\n"
		text += "- Motivo: %s\n" % RelationshipSystem.get_blocked_reason(npc_id, step_id)

	var required_categories: Dictionary = step.get("required_info_categories", {})

	if required_categories.is_empty():
		text += "- Información requerida: no\n"
	else:
		text += "- Información requerida:\n"

		for category_id in required_categories.keys():
			var required_count: int = int(required_categories[category_id])
			var known_count: int = RelationshipSystem.get_known_info_count_for_category(npc_id, str(category_id))
			var category_title: String = GameManager.get_info_category_title(str(category_id))

			text += "  · %s: %s/%s\n" % [
				category_title,
				known_count,
				required_count
			]

	if step.get("required_successful_date", false):
		var has_date: bool = GameManager.has_world_flag("successful_date:%s" % npc_id)
		text += "- Cita normal exitosa: %s\n" % ("sí" if has_date else "no")

	text += "- Vínculo requerido: %s" % int(step.get("required_total_affinity", 0))

	return text.strip_edges()


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
		return "- No has registrado horarios todavía."

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
		return "- Has visto a este personaje, pero todavía no tienes una rutina clara."

	return text.strip_edges()


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


func build_global_emotional_calendar_summary() -> String:
	var calendar: Dictionary = GameManager.get_emotional_calendar()

	if calendar.is_empty():
		return "- Todavía no hay fechas emocionales registradas."

	var text: String = ""
	var found: bool = false

	for npc_id in calendar.keys():
		var npc_calendar: Dictionary = calendar[npc_id]

		if npc_calendar.is_empty():
			continue

		var npc: Dictionary = DataManager.get_npc(str(npc_id))
		var count: int = npc_calendar.keys().size()

		text += "- %s: %s fecha(s) importante(s) registrada(s).\n" % [
			npc.get("name", npc_id),
			count
		]
		found = true

	if not found:
		return "- Todavía no hay fechas emocionales registradas."

	return text.strip_edges()


func build_npc_postgame_text(npc_id: String) -> String:
	if not PostgameSystem.is_postgame_started():
		return ""

	if PostgameSystem.get_partner_id() != npc_id:
		return ""

	var config: Dictionary = DataManager.get_postgame_partner_config(npc_id)
	var text: String = ""
	text += "- Ruta: %s\n" % config.get("postgame_title", "Unión final")
	text += "- Tema: %s\n" % config.get("pressure_theme", "La unión definitiva empieza a tener consecuencias.")
	text += "- %s: %s" % [
		config.get("stability_label", "Estabilidad de unión"),
		PostgameSystem.get_postgame_state_value("final_union_stability")
	]

	return text


func clear_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()


func refresh_layout_after_frame() -> void:
	await get_tree().process_frame
	layout_overlay_controls()

func layout_overlay_controls() -> void:
	if journal_layer == null:
		return

	var margin: float = 10.0
	var top_height: float = 46.0
	var gap: float = 10.0

	var global_width: float = 250.0
	var nav_width: float = 190.0

	if journal_layer.size.x < 900:
		global_width = 230.0
		nav_width = 170.0

	global_action_panel.size = Vector2(global_width, top_height)
	global_action_panel.position = Vector2(
		max(margin, journal_layer.size.x - global_width - margin),
		margin
	)

	var top_width: float = max(320.0, journal_layer.size.x - global_width - (margin * 3.0))
	top_info_panel.size = Vector2(top_width, top_height)
	top_info_panel.position = Vector2(margin, margin)

	var content_top: float = margin + top_height + gap
	var content_height: float = max(280.0, journal_layer.size.y - content_top - margin)

	nav_panel.size = Vector2(nav_width, content_height)
	nav_panel.position = Vector2(margin, content_top)

	var content_x: float = margin + nav_width + gap
	var content_width: float = max(360.0, journal_layer.size.x - content_x - margin)

	content_panel.size = Vector2(content_width, content_height)
	content_panel.position = Vector2(content_x, content_top)
	
func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		if journal_layer != null:
			call_deferred("refresh_layout_after_frame")


func setup_fullscreen_root() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0
