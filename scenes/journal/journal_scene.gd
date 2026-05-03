extends Control

var npc_button_container: VBoxContainer
var details_label: RichTextLabel

func _ready() -> void:
	setup_fullscreen_root()
	build_ui()
	build_npc_list()

func build_ui() -> void:
	var root: VBoxContainer = ScreenRoot.create(self)

	root.add_child(UIFactory.title("Bitácora"))

	var body_container: HBoxContainer = HBoxContainer.new()
	body_container.alignment = BoxContainer.ALIGNMENT_CENTER
	body_container.add_theme_constant_override("separation", 18)
	root.add_child(body_container)

	var npc_scroll: ScrollContainer = ScrollContainer.new()
	npc_scroll.custom_minimum_size = Vector2(240, 420)
	npc_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body_container.add_child(npc_scroll)

	npc_button_container = VBoxContainer.new()
	npc_button_container.add_theme_constant_override("separation", 8)
	npc_scroll.add_child(npc_button_container)

	details_label = RichTextLabel.new()
	details_label.custom_minimum_size = Vector2(520, 420)
	details_label.bbcode_enabled = true
	details_label.fit_content = false
	details_label.scroll_active = true
	details_label.add_theme_font_size_override("normal_font_size", 17)
	body_container.add_child(details_label)

	var back_button: Button = UIFactory.button("Volver al mapa")
	back_button.pressed.connect(func(): SceneRouter.go_to_world_map())
	root.add_child(back_button)

func build_npc_list() -> void:
	for child in npc_button_container.get_children():
		child.queue_free()

	var has_known_npcs: bool = false
	var first_npc_id: String = ""

	for npc_id in DataManager.npcs.keys():
		GameManager.ensure_npc_knowledge(npc_id)

		var knowledge: Dictionary = GameManager.player["known_npc_info"][npc_id]

		if not knowledge.get("profile_seen", false):
			continue

		has_known_npcs = true

		if first_npc_id == "":
			first_npc_id = npc_id

		var npc: Dictionary = DataManager.get_npc(npc_id)
		var button: Button = UIFactory.button(npc.get("name", npc_id))
		button.custom_minimum_size = Vector2(220, 42)
		button.pressed.connect(func(): show_npc(npc_id))
		npc_button_container.add_child(button)

	if not has_known_npcs:
		details_label.text = "Todavía no has conocido a nadie."
	else:
		show_npc(first_npc_id)

func show_npc(npc_id: String) -> void:
	GameManager.ensure_relationship(npc_id)
	GameManager.ensure_npc_knowledge(npc_id)

	var npc: Dictionary = DataManager.get_npc(npc_id)
	var relation: Dictionary = GameManager.player["relationships"][npc_id]
	var knowledge: Dictionary = GameManager.player["known_npc_info"][npc_id]

	var friendship: int = int(relation.get("friendship", 0))
	var tension: int = int(relation.get("tension", 0))
	var loyalty: int = int(relation.get("loyalty", 0))
	var jealousy: int = int(relation.get("jealousy", 0))
	var total: int = GameManager.get_total_affinity(npc_id)

	var relationship_state: String = relation.get("relationship_state", "none")
	var relation_label: String = GameManager.get_affinity_label(total, relationship_state)

	var text: String = ""
	text += "[center][font_size=24][color=#f0cfe6]%s[/color][/font_size][/center]\n" % npc.get("name", npc_id)
	text += "[center]%s[/center]\n\n" % npc.get("role", "Sin rol")
	text += "[b]Vínculo total:[/b] %s/100\n" % total
	text += "[b]Amistad:[/b] %s/100\n" % friendship
	text += "[b]Tensión:[/b] %s/100\n" % tension
	text += "[b]Lealtad:[/b] %s/100\n" % loyalty
	text += "[b]Celos:[/b] %s/100\n" % jealousy
	text += "[b]Relación:[/b] %s\n\n" % relation_label
	text += "[i]%s[/i]\n\n" % npc.get("description", "")

	text += build_info_section(npc, knowledge)
	text += build_gift_section(npc, knowledge)
	text += build_schedule_section(npc, knowledge)
	text += build_notes_section(knowledge)

	details_label.text = text

func build_info_section(npc: Dictionary, knowledge: Dictionary) -> String:
	var text: String = "[color=#f0cfe6][b]Información descubierta[/b][/color]\n"

	var known_info: Array = knowledge.get("info", [])
	var info_data: Dictionary = npc.get("info", {})

	for section_id in DataManager.npc_info_schema.keys():
		var section: Dictionary = DataManager.npc_info_schema[section_id]
		var section_title: String = section.get("title", section_id)
		var keys: Dictionary = section.get("keys", {})

		text += "\n[b]%s[/b]\n" % section_title

		for info_key in keys.keys():
			var label: String = keys[info_key]
			var value: String = "????"

			if known_info.has(info_key):
				value = str(info_data.get(info_key, "Sin datos"))

			text += "%s: %s\n" % [label, value]

	text += "\n"
	return text

func build_gift_section(npc: Dictionary, knowledge: Dictionary) -> String:
	var text: String = "[color=#f0cfe6][b]Gustos y regalos[/b][/color]\n"

	var known_gifts: Array = knowledge.get("gifts", [])
	var prefs: Dictionary = npc.get("gift_preferences", {})

	text += build_gift_group("Ama", prefs.get("loves", []), known_gifts)
	text += build_gift_group("Le gusta", prefs.get("likes", []), known_gifts)
	text += build_gift_group("Neutral", prefs.get("neutral", []), known_gifts)
	text += build_gift_group("Odia", prefs.get("hates", []), known_gifts)

	text += "\n"
	return text

func build_gift_group(label: String, items: Array, known_gifts: Array) -> String:
	var shown: Array = []

	for item_id in items:
		if known_gifts.has(item_id):
			var item_data: Dictionary = DataManager.get_item(str(item_id))
			shown.append(str(item_data.get("name", item_id)))
		else:
			shown.append("????")

	if shown.is_empty():
		shown.append("????")

	return "%s: %s\n" % [label, ", ".join(shown)]

func build_schedule_section(npc: Dictionary, knowledge: Dictionary) -> String:
	var text: String = "[color=#f0cfe6][b]Rutina conocida[/b][/color]\n"

	var known_schedule: Array = knowledge.get("schedule", [])
	var schedule: Dictionary = npc.get("schedule", {})

	var labels: Dictionary = {
		"morning": "Mañana",
		"afternoon": "Tarde",
		"night": "Noche"
	}

	for time_block in labels.keys():
		var value: String = "????"

		if known_schedule.has(time_block):
			var location_id: String = schedule.get(time_block, "")
			var location: Dictionary = DataManager.get_location(location_id)
			value = location.get("name", location_id)

		text += "%s: %s\n" % [labels[time_block], value]

	text += "\n"
	return text

func build_notes_section(knowledge: Dictionary) -> String:
	var text: String = "[color=#f0cfe6][b]Notas[/b][/color]\n"

	var notes: Array = knowledge.get("notes", [])

	if notes.is_empty():
		text += "Sin notas todavía.\n"
	else:
		for note in notes:
			text += "- %s\n" % note

	return text

func setup_fullscreen_root() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0
