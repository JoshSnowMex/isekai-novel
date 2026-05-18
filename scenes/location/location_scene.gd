extends Control


var hud_bar: WorldHudBar
var location_frame: PanelContainer
var location_layer: Control
var background_layer: Control
var character_layer: Control
var bottom_panel: PanelContainer
var bottom_title_label: Label
var bottom_description_scroll: ScrollContainer
var bottom_description_label: Label
var bottom_actions: GridContainer
var global_action_panel: WorldActionPanel
var modal_layer: ColorRect
var modal_panel: PanelContainer
var modal_title_label: Label
var modal_description_label: Label
var modal_scroll: ScrollContainer
var modal_buttons: VBoxContainer
var modal_footer: HBoxContainer
var current_location_id: String = ""
var last_message: String = ""
var selected_npc_id: String = ""
var character_positions_by_location: Dictionary = {}
var load_game_modal: LoadGameModal

const BASE_LOCATION_SIZE := Vector2(1050.0, 540.0)
const NPC_PRESENCE_CARD_BASE_SIZE := Vector2(250, 360.0)
const NPC_PRESENCE_FRAME_PATH := "res://assets/ui/npc_presence_frame.png"


func _ready() -> void:
	setup_fullscreen_root()
	build_ui()
	load_location(GameManager.current_location_id)
	show_pending_narrative_messages()


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

	location_frame = PanelContainer.new()
	location_frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	location_frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(location_frame)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_bottom", 6)
	location_frame.add_child(margin)

	location_layer = Control.new()
	location_layer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	location_layer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	location_layer.clip_contents = true
	margin.add_child(location_layer)

	background_layer = Control.new()
	background_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	background_layer.offset_left = 0
	background_layer.offset_top = 0
	background_layer.offset_right = 0
	background_layer.offset_bottom = 0
	location_layer.add_child(background_layer)

	character_layer = Control.new()
	character_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	character_layer.offset_left = 0
	character_layer.offset_top = 0
	character_layer.offset_right = 0
	character_layer.offset_bottom = 0
	location_layer.add_child(character_layer)

	build_global_action_panel()
	build_bottom_panel()
	build_modal()
	build_load_game_modal()
	
	call_deferred("refresh_layout_after_frame")

func build_global_action_panel() -> void:
	global_action_panel = WorldActionPanel.new()
	global_action_panel.build()
	location_layer.add_child(global_action_panel)

	global_action_panel.clear_actions()

	global_action_panel.add_action("Mapa", func(): _on_back_pressed())
	global_action_panel.add_action("Bitácora", func(): SceneRouter.go_to_journal(SceneRouter.LOCATION_SCENE))
	global_action_panel.add_action("Guardar", func():
		SaveManager.save_game()
		show_save_confirmation_modal()
	)
	global_action_panel.add_action("Cargar", func():
		load_game_modal.open()
	)

func build_bottom_panel() -> void:
	bottom_panel = PanelContainer.new()
	bottom_panel.custom_minimum_size = Vector2(980, 224)
	bottom_panel.add_theme_stylebox_override("panel", LuminariaTheme.make_transparent_style())
	location_layer.add_child(bottom_panel)

	var panel_texture: TextureRect = TextureRect.new()
	panel_texture.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel_texture.texture = LuminariaTheme.get_world_info_panel_texture()
	panel_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	panel_texture.stretch_mode = TextureRect.STRETCH_SCALE
	panel_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bottom_panel.add_child(panel_texture)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 30)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_right", 30)
	margin.add_theme_constant_override("margin_bottom", 18)
	bottom_panel.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 6)
	margin.add_child(box)

	bottom_title_label = Label.new()
	bottom_title_label.custom_minimum_size = Vector2(1, 24)
	bottom_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom_title_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	bottom_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	bottom_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	bottom_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	LuminariaTheme.apply_content_title(bottom_title_label)
	box.add_child(bottom_title_label)

	bottom_description_scroll = ScrollContainer.new()
	bottom_description_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom_description_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	bottom_description_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	bottom_description_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(bottom_description_scroll)

	bottom_description_label = Label.new()
	bottom_description_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom_description_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	bottom_description_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	bottom_description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bottom_description_label.clip_text = true
	LuminariaTheme.apply_content_body(bottom_description_label)
	bottom_description_scroll.add_child(bottom_description_label)

	bottom_actions = GridContainer.new()
	bottom_actions.columns = 3
	bottom_actions.custom_minimum_size = Vector2(1, 42)
	bottom_actions.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom_actions.size_flags_vertical = Control.SIZE_SHRINK_END
	bottom_actions.add_theme_constant_override("h_separation", 8)
	bottom_actions.add_theme_constant_override("v_separation", 6)
	box.add_child(bottom_actions)
	
func layout_bottom_panel() -> void:
	if bottom_panel == null or location_layer == null:
		return

	var panel_width: float = min(980.0, max(760.0, location_layer.size.x - 72.0))
	var panel_height: float = 224.0

	bottom_panel.size = Vector2(panel_width, panel_height)
	bottom_panel.position = Vector2(
		(location_layer.size.x - panel_width) * 0.5,
		location_layer.size.y - panel_height - 8.0
	)
	
func load_location(location_id: String, message: String = "") -> void:
	current_location_id = location_id
	selected_npc_id = ""

	var location_data: Dictionary = DataManager.get_location(location_id)

	if message != "":
		last_message = message

	hud_bar.refresh()
	rebuild_background()
	show_location_overview(location_data)
	call_deferred("rebuild_characters_after_layout")
	call_deferred("refresh_layout_after_frame")
	
func rebuild_characters_after_layout() -> void:
	await get_tree().process_frame
	rebuild_characters()
	reposition_character_buttons()
	
func rebuild_background() -> void:
	clear_children(background_layer)

	var location_data: Dictionary = DataManager.get_location(current_location_id)
	var location_ui: Dictionary = DataManager.get_location_ui(current_location_id)

	var background_path: String = str(location_ui.get("background", ""))
	var fallback_title: String = str(location_data.get("name", current_location_id))
	var final_asset_name: String = background_path.get_file()

	if final_asset_name == "":
		final_asset_name = "location_%s.png" % current_location_id

	var background: Control = VisualAsset.make_texture_or_placeholder(
		background_path,
		fallback_title,
		"Fondo final: %s" % final_asset_name
	)

	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.offset_left = 0
	background.offset_top = 0
	background.offset_right = 0
	background.offset_bottom = 0
	background_layer.add_child(background)


func rebuild_characters() -> void:
	clear_children(character_layer)
	character_positions_by_location.clear()

	var present_npcs: Array = get_present_npcs()

	for index in range(present_npcs.size()):
		create_character_button(str(present_npcs[index]), index, present_npcs.size())


func get_present_npcs() -> Array:
	var result: Array = []

	for npc_id in DataManager.npcs.keys():
		var id: String = str(npc_id)
		var npc_location_id: String = ScheduleSystem.get_npc_location(id)

		if npc_location_id == current_location_id:
			result.append(id)

	return result

func is_npc_present_here(npc_id: String) -> bool:
	return ScheduleSystem.get_npc_location(npc_id) == current_location_id


func handle_npc_no_longer_available(npc_id: String) -> void:
	var npc: Dictionary = DataManager.get_npc(npc_id)
	var npc_name: String = str(npc.get("name", npc_id))

	selected_npc_id = ""
	rebuild_characters()
	hud_bar.refresh()

	show_location_message(
		"%s ya no está aquí" % npc_name,
		"%s se ha marchado según su rutina. Puedes seguir explorando la ubicación o buscarle más tarde." % npc_name
	)

func create_character_button(npc_id: String, index: int, total: int) -> void:
	var display_name: String = get_npc_display_name(npc_id)
	var is_selected: bool = selected_npc_id == npc_id

	var button: Button = Button.new()
	button.flat = true
	button.focus_mode = Control.FOCUS_ALL
	button.tooltip_text = display_name
	button.text = ""
	button.clip_contents = false
	button.set_meta("npc_id", npc_id)
	LuminariaTheme.apply_transparent_button(button)
	button.mouse_entered.connect(func(): show_character_preview(npc_id))
	button.focus_entered.connect(func(): show_character_preview(npc_id))
	button.pressed.connect(func(): select_npc(npc_id))
	character_layer.add_child(button)

	var card_size: Vector2 = get_scaled_character_size()
	var card_position: Vector2 = get_stable_character_position(npc_id, index, total, card_size)

	button.position = card_position
	button.custom_minimum_size = card_size
	button.size = card_size

	var stage: Control = Control.new()
	stage.set_anchors_preset(Control.PRESET_FULL_RECT)
	stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(stage)

	var frame_backlight: TextureRect = TextureRect.new()
	frame_backlight.texture = VisualAsset.load_texture(NPC_PRESENCE_FRAME_PATH)
	frame_backlight.set_anchors_preset(Control.PRESET_FULL_RECT)
	frame_backlight.offset_left = -card_size.x * 0.025
	frame_backlight.offset_top = -card_size.y * 0.025
	frame_backlight.offset_right = card_size.x * 0.025
	frame_backlight.offset_bottom = card_size.y * 0.025
	frame_backlight.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame_backlight.stretch_mode = TextureRect.STRETCH_SCALE
	frame_backlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame_backlight.modulate = Color(0.72, 0.22, 1.0, 0.0) if not is_selected else Color(0.72, 0.22, 1.0, 0.62)
	stage.add_child(frame_backlight)

	var frame: TextureRect = TextureRect.new()
	frame.texture = VisualAsset.load_texture(NPC_PRESENCE_FRAME_PATH)
	frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	frame.offset_left = 0
	frame.offset_top = 0
	frame.offset_right = 0
	frame.offset_bottom = 0
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.stretch_mode = TextureRect.STRETCH_SCALE
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.modulate = Color(1.06, 0.82, 1.18, 1.0) if is_selected else Color(1.0, 1.0, 1.0, 1.0)
	stage.add_child(frame)
	
	var portrait: TextureRect = TextureRect.new()
	portrait.texture = VisualAsset.load_texture(get_npc_presence_portrait_path(npc_id))
	portrait.set_anchors_preset(Control.PRESET_FULL_RECT)
	portrait.offset_left = card_size.x * 0.12
	portrait.offset_top = card_size.y * 0.16
	portrait.offset_right = -card_size.x * 0.12
	portrait.offset_bottom = -card_size.y * 0.12
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait.modulate = Color(1.0, 1.0, 1.0, 1.0)
	stage.add_child(portrait)

	var name_label: Label = Label.new()
	name_label.position = Vector2(card_size.x * 0.18, card_size.y * 0.880)
	name_label.size = Vector2(card_size.x * 0.64, card_size.y * 0.055)
	name_label.text = display_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.clip_text = true
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	LuminariaTheme.apply_label(name_label, 15, Color(0.98, 0.90, 1.0, 1.0), 2)
	stage.add_child(name_label)

	button.set_meta("name_label", name_label)
	button.set_meta("frame_backlight", frame_backlight)
	button.set_meta("frame", frame)
	button.set_meta("portrait", portrait)
	
func get_npc_presence_portrait_path(npc_id: String) -> String:
	var npc: Dictionary = DataManager.get_npc(npc_id)
	var npc_name: String = str(npc.get("name", npc_id))

	if npc_name != "":
		return "res://assets/portraits/%s_presence_portrait.png" % npc_name

	return "res://assets/portraits/%s_presence_portrait.png" % npc_id.capitalize()

func get_scaled_character_size() -> Vector2:
	var safe_width: float = max(location_layer.size.x, BASE_LOCATION_SIZE.x)
	var safe_height: float = max(location_layer.size.y, BASE_LOCATION_SIZE.y)

	var scale_factor: float = min(
		safe_width / BASE_LOCATION_SIZE.x,
		safe_height / BASE_LOCATION_SIZE.y
	)

	scale_factor = clamp(scale_factor, 0.92, 1.0)

	return NPC_PRESENCE_CARD_BASE_SIZE * scale_factor
	
func get_bottom_panel_reserved_height() -> float:
	return 238.0

func get_stable_character_position(npc_id: String, index: int, total: int, button_size: Vector2) -> Vector2:
	return get_character_position(index, total, button_size)

func get_character_position(index: int, total: int, button_size: Vector2) -> Vector2:
	var reserved_bottom: float = get_bottom_panel_reserved_height()
	var available_height: float = max(260.0, location_layer.size.y - reserved_bottom)

	var gap_x: float = 18.0
	var total_width: float = (button_size.x * float(total)) + (gap_x * float(max(total - 1, 0)))

	var start_x: float = (location_layer.size.x - total_width) * 0.5

	if total >= 3:
		start_x = max(34.0, min(start_x, 220.0))

	var x: float = start_x + (float(index) * (button_size.x + gap_x))
	var y: float = available_height - button_size.y + 8.0

	var min_x: float = 28.0
	var max_x: float = max(min_x, location_layer.size.x - button_size.x - 28.0)

	return Vector2(
		clamp(x, min_x, max_x),
		max(34.0, y)
	)
	
func show_location_overview(location_data: Dictionary, clear_message: bool = false) -> void:
	selected_npc_id = ""
	clear_bottom_actions()
	
	bottom_actions.columns = 3
	bottom_actions.custom_minimum_size = Vector2(1, 42)
	
	if clear_message:
		last_message = ""

	bottom_title_label.text = str(location_data.get("name", current_location_id))
	bottom_description_label.text = str(location_data.get("description", ""))
	
	if GameManager.is_day_exhausted():
		bottom_description_label.text += "\n\nYa no tienes acciones disponibles. Lo mejor es volver a casa o usar el mapa para revisar otras opciones."

	if last_message != "":
		bottom_description_label.text = last_message

	var present_npcs: Array = get_present_npcs()

	for npc_id in present_npcs:
		add_approach_npc_action(str(npc_id))

	add_location_activity_actions(location_data)

	if present_npcs.is_empty() and not has_location_activity_actions(location_data):
		add_bottom_action("No hay nada especial que hacer ahora", func(): pass, true)
		
	call_deferred("refresh_layout_after_frame")

func add_approach_npc_action(npc_id: String) -> void:
	var locked_npc_id: String = npc_id
	var display_name: String = get_npc_display_name(locked_npc_id)

	var button: Button = add_bottom_action(
		"Acercarse a %s" % display_name,
		func(): select_npc(locked_npc_id)
	)

	button.tooltip_text = ""

	button.mouse_entered.connect(func():
		show_npc_approach_preview(locked_npc_id)
	)

	button.focus_entered.connect(func():
		show_npc_approach_preview(locked_npc_id)
	)

	button.mouse_exited.connect(func():
		restore_location_overview_text()
	)
	
func show_npc_approach_preview(npc_id: String) -> void:
	if selected_npc_id != "":
		return

	var npc: Dictionary = DataManager.get_npc(npc_id)
	var display_name: String = get_npc_display_name(npc_id)

	bottom_title_label.text = display_name

	if is_npc_known(npc_id):
		bottom_description_label.text = "Acercarte a %s te permite hablar, dar regalos, pedir favores o invitarle a una cita si hay confianza suficiente." % npc.get("name", npc_id)
	else:
		bottom_description_label.text = "Aún no sabes quién es. Acercarte revelará su identidad y abrirá opciones de interacción."
		
func add_location_activity_actions(location_data: Dictionary) -> void:
	var actions: Dictionary = location_data.get("actions", {})
	var activities: Array = location_data.get("activities", [])

	if GameManager.is_day_exhausted():
		var home_button: Button = add_bottom_action("Ir a casa", func():
			GameManager.current_location_id = "home"
			SceneRouter.go_to_home()
		)
		home_button.tooltip_text = ""
		home_button.mouse_entered.connect(func():
			bottom_title_label.text = "Ir a casa"
			bottom_description_label.text = "Ya no tienes acciones disponibles. Vuelve a casa para cerrar el día o descansar."
		)
		home_button.focus_entered.connect(func():
			bottom_title_label.text = "Ir a casa"
			bottom_description_label.text = "Ya no tienes acciones disponibles. Vuelve a casa para cerrar el día o descansar."
		)
		home_button.mouse_exited.connect(func():
			restore_location_overview_text()
		)
		return
		
	for activity_id in activities:
		var id: String = str(activity_id)
		add_activity_action_button(id)

	if actions.get("train", false):
		var train_button: Button = add_bottom_action("Entrenar", func(): do_train(location_data))
		train_button.tooltip_text = ""
		train_button.mouse_entered.connect(func():
			bottom_title_label.text = "Entrenar"
			bottom_description_label.text = "Mejora una estadística de entrenamiento y consume resistencia."
		)
		train_button.focus_entered.connect(func():
			bottom_title_label.text = "Entrenar"
			bottom_description_label.text = "Mejora una estadística de entrenamiento y consume resistencia."
		)
		train_button.mouse_exited.connect(func():
			restore_location_overview_text()
		)

	if actions.get("work_full", false):
		var work_full_button: Button = add_bottom_action("Trabajar jornada completa", func(): do_work_full())
		work_full_button.tooltip_text = ""
		work_full_button.mouse_entered.connect(func():
			bottom_title_label.text = "Trabajar jornada completa"
			bottom_description_label.text = "Ganas Lúmenes a cambio de una gran cantidad de resistencia."
		)
		work_full_button.focus_entered.connect(func():
			bottom_title_label.text = "Trabajar jornada completa"
			bottom_description_label.text = "Ganas Lúmenes a cambio de una gran cantidad de resistencia."
		)
		work_full_button.mouse_exited.connect(func():
			restore_location_overview_text()
		)

	if actions.get("work_half", false):
		var work_half_button: Button = add_bottom_action("Trabajar medio turno", func(): do_work_half())
		work_half_button.tooltip_text = ""
		work_half_button.mouse_entered.connect(func():
			bottom_title_label.text = "Trabajar medio turno"
			bottom_description_label.text = "Ganas algunos Lúmenes a cambio de resistencia."
		)	
		work_half_button.focus_entered.connect(func():
			bottom_title_label.text = "Trabajar medio turno"
			bottom_description_label.text = "Ganas algunos Lúmenes a cambio de resistencia."
		)
		work_half_button.mouse_exited.connect(func():
			restore_location_overview_text()
		)

	if actions.get("rest", false):
		var rest_button: Button = add_bottom_action("Descansar", func(): do_rest())
		rest_button.tooltip_text = ""
		rest_button.mouse_entered.connect(func():
			bottom_title_label.text = "Descansar"
			bottom_description_label.text = "Recuperas resistencia, pero consumes tiempo."
		)
		rest_button.focus_entered.connect(func():
			bottom_title_label.text = "Descansar"
			bottom_description_label.text = "Recuperas resistencia, pero consumes tiempo."
		)
		rest_button.mouse_exited.connect(func():
			restore_location_overview_text()
		)

	if actions.get("shop", false):
		add_bottom_action("Comprar", func(): SceneRouter.go_to_shop())

func add_activity_action_button(activity_id: String) -> void:
	var locked_activity_id: String = activity_id
	var activity: Dictionary = DataManager.get_activity(locked_activity_id)
	var button: Button = add_bottom_action(
		activity.get("name", locked_activity_id),
		func(): do_activity(locked_activity_id)
	)

	button.tooltip_text = ""

	button.mouse_entered.connect(func():
		show_activity_preview(locked_activity_id)
	)

	button.focus_entered.connect(func():
		show_activity_preview(locked_activity_id)
	)

	button.mouse_exited.connect(func():
		restore_location_overview_text()
	)
	

func show_activity_preview(activity_id: String) -> void:
	if selected_npc_id != "":
		return

	var activity: Dictionary = DataManager.get_activity(activity_id)

	bottom_title_label.text = str(activity.get("name", activity_id))
	bottom_description_label.text = get_activity_tooltip(activity_id)
	
func restore_location_overview_text() -> void:
	if selected_npc_id != "":
		return

	var location_data: Dictionary = DataManager.get_location(current_location_id)

	bottom_title_label.text = str(location_data.get("name", current_location_id))
	bottom_description_label.text = str(location_data.get("description", ""))

	if GameManager.is_day_exhausted():
		bottom_description_label.text += "\n\nYa no tienes acciones disponibles. Lo mejor es volver a casa o usar el mapa para revisar otras opciones."
	
func has_location_activity_actions(location_data: Dictionary) -> bool:
	var actions: Dictionary = location_data.get("actions", {})
	var activities: Array = location_data.get("activities", [])

	if not activities.is_empty():
		return true

	if actions.get("train", false):
		return true

	if actions.get("work_full", false):
		return true

	if actions.get("work_half", false):
		return true

	if actions.get("rest", false):
		return true

	if actions.get("shop", false):
		return true

	return false

func get_activity_tooltip(activity_id: String) -> String:
	var activity: Dictionary = DataManager.get_activity(activity_id)

	var description: String = str(activity.get("description", ""))
	var stat: String = str(activity.get("stat", ""))
	var base_stat_gain: int = int(activity.get("base_stat_gain", activity.get("base_gain", 0)))
	var base_money_gain: int = int(activity.get("base_money_gain", activity.get("money_gain", 0)))
	var stamina_cost: int = int(activity.get("stamina_cost", 0))

	var effects: Array = []

	if stat != "" and base_stat_gain > 0:
		effects.append("Mejora %s: +%s" % [
			GameManager.get_stat_label(stat),
			base_stat_gain
		])

	if base_money_gain > 0:
		var estimated_money: Dictionary = GameManager.get_activity_money_estimate(activity_id)
		effects.append("Lúmenes: %s-%s" % [
			estimated_money.get("min", base_money_gain),
			estimated_money.get("max", base_money_gain)
		])

	if stamina_cost > 0:
		effects.append("Resistencia: -%s" % stamina_cost)

	if effects.is_empty():
		return description

	if description == "":
		return " | ".join(effects)

	return "%s\n%s" % [
		description,
		" | ".join(effects)
	]
	
func show_location_actions(location_data: Dictionary) -> void:
	selected_npc_id = ""
	clear_bottom_actions()

	bottom_title_label.text = "Acciones de %s" % location_data.get("name", current_location_id)
	bottom_description_label.text = "Elige qué hacer en esta ubicación. Estas acciones consumen tiempo si corresponde."

	var actions: Dictionary = location_data.get("actions", {})
	var activities: Array = location_data.get("activities", [])

	for activity_id in activities:
		var id: String = str(activity_id)
		add_activity_action_button(id)

	if actions.get("train", false):
		add_bottom_action("Entrenar", func(): do_train(location_data))

	if actions.get("work_full", false):
		add_bottom_action("Trabajar jornada completa", func(): do_work_full())

	if actions.get("work_half", false):
		add_bottom_action("Trabajar medio turno", func(): do_work_half())

	if actions.get("rest", false):
		add_bottom_action("Descansar", func(): do_rest())

	if actions.get("shop", false):
		add_bottom_action("Comprar", func(): SceneRouter.go_to_shop())

	if bottom_actions.get_child_count() == 0:
		bottom_description_label.text = "No hay acciones disponibles aquí por ahora."

	add_bottom_action("Volver", func(): show_location_overview(DataManager.get_location(current_location_id), true))


func show_character_preview(npc_id: String) -> void:
	if selected_npc_id != "":
		return

	var npc: Dictionary = DataManager.get_npc(npc_id)
	var display_name: String = get_npc_display_name(npc_id)

	bottom_title_label.text = display_name

	if is_npc_known(npc_id):
		bottom_description_label.text = "Está aquí. Puedes acercarte y decidir cómo relacionarte con %s." % npc.get("name", npc_id)
	else:
		bottom_description_label.text = "Ves a alguien en esta zona, pero todavía no sabes quién es."


func select_npc(npc_id: String) -> void:
	selected_npc_id = npc_id

	GameManager.mark_npc_seen(npc_id)
	GameManager.reveal_npc_schedule(npc_id, "%s:%s" % [
		ScheduleSystem.get_day_type(),
		GameManager.current_time_block
	])

	rebuild_characters()
	interact_npc(npc_id)
	
func refresh_character_labels() -> void:
	for character_button in character_layer.get_children():
		if not character_button.has_meta("npc_id"):
			continue

		var npc_id: String = str(character_button.get_meta("npc_id"))
		var is_selected: bool = selected_npc_id == npc_id

		var label: Label = character_button.get_meta("name_label") as Label
		var frame_backlight: TextureRect = character_button.get_meta("frame_backlight") as TextureRect
		var frame: TextureRect = character_button.get_meta("frame") as TextureRect
		var portrait: TextureRect = character_button.get_meta("portrait") as TextureRect

		if label != null:
			label.text = get_npc_display_name(npc_id)

		if frame_backlight != null:
			frame_backlight.modulate = Color(0.72, 0.22, 1.0, 0.0) if not is_selected else Color(0.72, 0.22, 1.0, 0.62)

		if frame != null:
			frame.modulate = Color(1.06, 0.82, 1.18, 1.0) if is_selected else Color(1.0, 1.0, 1.0, 1.0)

		if portrait != null:
			portrait.modulate = Color(1.0, 1.0, 1.0, 1.0)

		character_button.tooltip_text = get_npc_display_name(npc_id)
		
func interact_npc(npc_id: String) -> void:
	clear_bottom_actions()

	var npc: Dictionary = DataManager.get_npc(npc_id)
	var npc_name: String = npc.get("name", npc_id)

	bottom_title_label.text = npc_name
	bottom_description_label.text = "Elige cómo acercarte a %s." % npc_name

	bottom_actions.columns = 3
	bottom_actions.custom_minimum_size = Vector2(1, 82)

	add_bottom_action("Hablar", func(): talk_to_npc(npc_id), GameManager.is_day_exhausted())
	add_bottom_action("Regalar", func(): show_gift_selection(npc_id), GameManager.is_day_exhausted())

	var petition_disabled: bool = GameManager.is_day_exhausted() or not PetitionSystem.has_any_available_petition(npc_id)
	add_bottom_action("Pedir favor", func(): show_petitions(npc_id), petition_disabled)

	var date_disabled: bool = GameManager.is_day_exhausted() or not GameManager.can_invite_to_date(npc_id)
	add_bottom_action("Invitar a cita", func(): show_date_location_selection(npc_id), date_disabled)

	var step_id: String = RelationshipSystem.get_next_step_id(npc_id)

	if step_id != "":
		var step: Dictionary = DataManager.get_relationship_step(step_id)
		var can_start_special: bool = RelationshipSystem.can_start_step(npc_id, step_id)

		add_bottom_action(
			"Avance",
			func(): SceneRouter.go_to_date(npc_id, "", "special", step_id),
			GameManager.is_day_exhausted() or not can_start_special
		)

	add_bottom_action("Volver", func():
		selected_npc_id = ""
		show_location_overview(DataManager.get_location(current_location_id), true)
		rebuild_characters()
	)

	call_deferred("refresh_layout_after_frame")
	
func show_npc_result(npc_id: String, message: String) -> void:
	hud_bar.refresh()

	if not is_npc_present_here(npc_id):
		handle_npc_no_longer_available(npc_id)
		return

	selected_npc_id = npc_id
	rebuild_characters()

	var npc: Dictionary = DataManager.get_npc(npc_id)
	var npc_name: String = str(npc.get("name", npc_id))

	open_result_modal(
		npc_name,
		message,
		func():
			close_choice_modal()
			interact_npc(npc_id)
	)
	
func show_gift_selection(npc_id: String) -> void:
	GameManager.ensure_relationship(npc_id)

	var relation: Dictionary = GameManager.player["relationships"][npc_id]
	var npc: Dictionary = DataManager.get_npc(npc_id)
	var npc_name: String = str(npc.get("name", npc_id))

	bottom_title_label.text = "Regalo para %s" % npc_name

	if relation.get("gift_given_today", false):
		bottom_description_label.text = "Ya le diste un regalo hoy."
		return

	var gifts: Array = GameManager.get_gift_items_in_inventory()

	if gifts.is_empty():
		bottom_description_label.text = "No tienes regalos disponibles."
		return

	gifts.sort_custom(func(a, b):
		var item_a: Dictionary = DataManager.get_item(str(a.get("item_id", "")))
		var item_b: Dictionary = DataManager.get_item(str(b.get("item_id", "")))

		var price_a: int = int(item_a.get("price", item_a.get("cost", 0)))
		var price_b: int = int(item_b.get("price", item_b.get("cost", 0)))

		if price_a == price_b:
			return str(item_a.get("name", a.get("item_id", ""))) < str(item_b.get("name", b.get("item_id", "")))

		return price_a < price_b
	)

	bottom_description_label.text = "Elige con cuidado. Un regalo puede acercar... o alejar."

	open_choice_modal(
		"Regalo para %s" % npc_name,
		"Selecciona un regalo de tu inventario. Los objetos están ordenados por precio para que coincidan mejor con la tienda."
	)

	for entry in gifts:
		var item_entry: Dictionary = entry
		var item_id: String = str(item_entry.get("item_id", ""))
		var amount: int = int(item_entry.get("amount", 0))
		var item_data: Dictionary = DataManager.get_item(item_id)

		add_modal_choice_button(
			"%s x%s" % [item_data.get("name", item_id), amount],
			func(): give_gift(npc_id, item_id)
		)

	add_modal_footer_button("Volver", func():
		close_choice_modal()
		interact_npc(npc_id)
	)
	
func show_petitions(npc_id: String) -> void:
	clear_bottom_actions()

	var npc: Dictionary = DataManager.get_npc(npc_id)
	var petition_ids: Array = PetitionSystem.get_available_petitions(npc_id)

	bottom_title_label.text = "Pedir favor a %s" % npc.get("name", npc_id)

	if petition_ids.is_empty():
		bottom_description_label.text = "No hay nada que puedas pedirle ahora."
	else:
		bottom_description_label.text = "Algunas peticiones cruzan una línea. Elige con cuidado."

		for petition_id in petition_ids:
			var id: String = str(petition_id)
			var petition: Dictionary = DataManager.get_petition(id)
			add_bottom_action(petition.get("name", id), func(): confirm_petition(id))

	add_bottom_action("Volver", func(): interact_npc(npc_id))


func confirm_petition(petition_id: String) -> void:
	clear_bottom_actions()

	var petition: Dictionary = DataManager.get_petition(petition_id)
	var npc_id: String = petition.get("npc_id", "")
	var npc: Dictionary = DataManager.get_npc(npc_id)

	bottom_title_label.text = npc.get("name", npc_id)
	bottom_description_label.text = petition.get("request_text", "")

	add_bottom_action("Hacer la petición", func(): perform_petition(petition_id))
	add_bottom_action("No todavía", func(): interact_npc(npc_id))


func show_date_location_selection(npc_id: String) -> void:
	var npc: Dictionary = DataManager.get_npc(npc_id)
	var npc_name: String = str(npc.get("name", npc_id))
	var locations: Array = DateSystem.get_available_date_locations(npc_id)

	bottom_title_label.text = "Invitar a cita"
	bottom_description_label.text = "Elige dónde pasar tiempo con %s." % npc_name

	if locations.is_empty():
		bottom_description_label.text = "No hay lugares de cita disponibles por ahora."
		return

	open_choice_modal(
		"Cita con %s" % npc_name,
		"Selecciona un lugar. Cada ubicación tiene ambiente, dificultad y consecuencias distintas."
	)

	for date_location_id in locations:
		var locked_location_id: String = str(date_location_id)
		var date_location: Dictionary = DataManager.get_date_location(locked_location_id)

		add_modal_choice_button(
			build_date_location_button_text(locked_location_id),
			func(): start_date_from_modal(npc_id, locked_location_id)
		)

	add_modal_footer_button("Volver", func():
		close_choice_modal()
		interact_npc(npc_id)
	)

func build_date_location_button_text(date_location_id: String) -> String:
	var date_location: Dictionary = DataManager.get_date_location(date_location_id)

	var name: String = str(date_location.get("name", date_location_id))
	var threshold: int = int(date_location.get("success_threshold", 70))
	var mood_tags: Array = date_location.get("mood_tags", [])

	var mood_text: String = ""
	if not mood_tags.is_empty():
		mood_text = "\nAmbiente: %s" % ", ".join(mood_tags)

	return "%s\nÉxito desde %s%%%s" % [
		name,
		threshold,
		mood_text
	]


func start_date_from_modal(npc_id: String, date_location_id: String) -> void:
	close_choice_modal()
	SceneRouter.go_to_date(npc_id, date_location_id)

func give_gift(npc_id: String, item_id: String) -> void:
	close_choice_modal()
	if not is_npc_present_here(npc_id):
		handle_npc_no_longer_available(npc_id)
		return

	if not GameManager.can_perform_action(5):
		reload_scene(GameManager.get_action_blocked_message(5))
		return

	GameManager.ensure_relationship(npc_id)
	GameManager.ensure_npc_knowledge(npc_id)

	var relation: Dictionary = GameManager.player["relationships"][npc_id]

	if relation.get("gift_given_today", false):
		show_location_message("Regalo no disponible", "Ya le diste un regalo hoy.")
		return

	if not GameManager.has_item(item_id):
		show_location_message("Regalo no disponible", "Ya no tienes ese objeto.")
		return

	var npc: Dictionary = DataManager.get_npc(npc_id)
	var item: Dictionary = DataManager.get_item(item_id)
	var prefs: Dictionary = npc.get("gift_preferences", {})

	var result: int = 0
	var reaction: String = ""
	var gift_strategy: String = "gift_neutral"

	if item_id in prefs.get("loves", []):
		result = randi_range(5, 6)
		reaction = "Su reacción lo dice todo. Has tocado una fibra muy personal."
		gift_strategy = "gift_loved"

		GameManager.record_emotional_date(
			npc_id,
			"first_loved_gift",
			"Primer regalo amado"
		)

	elif item_id in prefs.get("likes", []):
		result = randi_range(3, 4)
		reaction = "Acepta el regalo con una calidez difícil de fingir."
		gift_strategy = "gift_liked"
	elif item_id in prefs.get("hates", []):
		result = randi_range(-5, -4)
		reaction = "La incomodidad aparece de inmediato. Fue una mala elección."
		gift_strategy = "gift_hated"
	else:
		result = randi_range(1, 2)
		reaction = "Acepta el gesto con cortesía."
		gift_strategy = "gift_neutral"

	var relationship_text: String = ""

	if result > 0:
		relationship_text += GameManager.add_relationship_value(npc_id, "friendship", result)

		if result >= 3:
			var tension_bonus: int = 1
			relationship_text += GameManager.add_relationship_value(npc_id, "tension", tension_bonus)
	else:
		relationship_text += GameManager.add_relationship_value(npc_id, "friendship", result)
		relationship_text += GameManager.add_relationship_value(npc_id, "jealousy", 2)

	relation["gift_given_today"] = true

	GameManager.remove_item(item_id, 1)
	GameManager.reveal_npc_gift(npc_id, item_id)

	var message: String = "%s\nRegalo: %s\nAmistad: %+d%s" % [
		reaction,
		item.get("name", item_id),
		result,
		relationship_text
	]

	var reveal_chance: float = 0.25

	match gift_strategy:
		"gift_loved":
			reveal_chance = 0.85
		"gift_liked":
			reveal_chance = 0.60
		"gift_neutral":
			reveal_chance = 0.25
		"gift_hated":
			reveal_chance = 0.55

	if randf() < reveal_chance:
		var info_key: String = GameManager.reveal_npc_info_by_strategy(npc_id, {
			"strategy": gift_strategy,
			"max_tier": 90,
			"include_next_step_missing": true
		})

		if info_key != "":
			message += "\n\n" + GameManager.format_discovered_info(npc_id, info_key)

	var postgame_gift_text: String = process_postgame_gift_effect(npc_id, gift_strategy)

	if postgame_gift_text != "":
		message += "\n\n" + postgame_gift_text

	GameManager.consume_action(5)
	hud_bar.refresh()
	SaveManager.autosave_game()
	show_npc_result(npc_id, message)


func talk_to_npc(npc_id: String) -> void:
	if not is_npc_present_here(npc_id):
		handle_npc_no_longer_available(npc_id)
		return

	if not GameManager.can_perform_action(5):
		reload_scene(GameManager.get_action_blocked_message(5))
		return

	GameManager.ensure_relationship(npc_id)
	GameManager.ensure_npc_knowledge(npc_id)

	var npc: Dictionary = DataManager.get_npc(npc_id)

	var friendship_gain: int = randi_range(2, 4)
	var tension_gain: int = 0

	if randf() < 0.35:
		tension_gain = 1

	var relationship_text: String = GameManager.add_relationship_value(npc_id, "friendship", friendship_gain)

	if tension_gain > 0:
		relationship_text += GameManager.add_relationship_value(npc_id, "tension", tension_gain)

	var dialogue_line: String = DialogueSystem.get_dialogue_line(npc_id, "casual")

	var message: String = "%s\n\nAmistad +%s" % [
		dialogue_line,
		friendship_gain
	]

	if tension_gain > 0:
		message += "\nTensión +%s" % tension_gain

	message += relationship_text

	var reveal_chance: float = 0.45

	if not GameManager.get_missing_info_for_next_relationship_step(npc_id, 60).is_empty():
		reveal_chance = 0.75

	if randf() < reveal_chance:
		var info_key: String = GameManager.reveal_npc_info_by_strategy(npc_id, {
			"strategy": "talk",
			"max_tier": 70,
			"include_next_step_missing": true
		})

		if info_key != "":
			message += "\n\n" + GameManager.format_discovered_info(npc_id, info_key)

	GameManager.add_npc_note(
		npc_id,
		"Una conversación casual dejó ver algo más profundo de %s." % npc.get("name", npc_id)
	)

	GameManager.consume_action(5)
	hud_bar.refresh()
	SaveManager.autosave_game()
	show_npc_result(npc_id, message)


func do_activity(activity_id: String) -> void:
	if GameManager.is_day_exhausted():
		reload_scene("Ya no te queda tiempo útil hoy. Deberías volver a casa y dormir.")
		return

	var result_message: String = GameManager.perform_activity(activity_id)
	hud_bar.refresh()
	rebuild_characters()
	SaveManager.autosave_game()
	reload_scene(result_message)


func do_train(location_data: Dictionary) -> void:
	var stat: String = location_data.get("train_stat", "intellect")
	GameManager.player["stats"][stat] += 1
	GameManager.consume_action(10)
	hud_bar.refresh()
	rebuild_characters()
	reload_scene("Entrenas y mejoras %s." % stat)


func do_work_full() -> void:
	GameManager.player["money"] += 20
	GameManager.consume_action(25)
	hud_bar.refresh()
	rebuild_characters()
	reload_scene("Trabajas una jornada completa.\nDinero +20")


func do_work_half() -> void:
	GameManager.player["money"] += 10
	GameManager.consume_action(15)
	hud_bar.refresh()
	rebuild_characters()
	reload_scene("Trabajas medio turno.\nDinero +10")


func do_rest() -> void:
	GameManager.player["stamina"] = min(
		int(GameManager.player.get("stamina", 0)) + 20,
		int(GameManager.player.get("max_stamina", 100))
	)
	GameManager.consume_action(5)
	hud_bar.refresh()
	rebuild_characters()
	reload_scene("Descansas un momento.\nResistencia +20")


func perform_petition(petition_id: String) -> void:
	if not GameManager.can_perform_action(5):
		reload_scene(GameManager.get_action_blocked_message(5))
		return

	var result: Dictionary = PetitionSystem.perform_petition(petition_id)
	var petition: Dictionary = DataManager.get_petition(petition_id)
	var npc_id: String = petition.get("npc_id", "")

	GameManager.consume_action(5)
	GameManager.add_npc_note(
		npc_id,
		"Una petición cruzó un límite y dejó consecuencias."
	)

	SaveManager.autosave_game()
	reload_scene(result.get("text", "La petición terminó."))


func process_postgame_gift_effect(npc_id: String, gift_strategy: String) -> String:
	if not PostgameSystem.is_postgame_started():
		return ""

	var partner_id: String = PostgameSystem.get_partner_id()

	if partner_id == npc_id:
		match gift_strategy:
			"gift_loved":
				return PostgameSystem.strengthen_final_union(
					4,
					"El regalo tocó algo importante en tu unión definitiva."
				)
			"gift_liked":
				return PostgameSystem.strengthen_final_union(
					2,
					"El gesto cuidó la unión definitiva."
				)
			"gift_hated":
				return PostgameSystem.strain_final_union(
					4,
					"El regalo hirió una zona sensible de la unión definitiva."
				)
			_:
				return ""

	var strain: int = 0

	match gift_strategy:
		"gift_loved":
			strain = 2
		"gift_liked":
			strain = 1
		_:
			strain = 0

	if strain <= 0:
		return ""

	PostgameSystem.add_postgame_state_value("outside_temptation", strain)

	return PostgameSystem.strain_final_union(
		strain,
		"Dar regalos significativos a otra persona después de una unión definitiva genera tensión."
	)

func reload_scene(message: String = "") -> void:
	SaveManager.autosave_game()
	hud_bar.refresh()

	if message == "":
		show_location_overview(DataManager.get_location(current_location_id), true)
		return

	show_location_message(
		DataManager.get_location(current_location_id).get("name", current_location_id),
		message
	)
	
func show_location_message(title: String, message: String) -> void:
	selected_npc_id = ""
	clear_bottom_actions()

	bottom_title_label.text = title
	bottom_description_label.text = message

	add_bottom_action(
		"Continuar",
		func(): show_location_overview(DataManager.get_location(current_location_id), true)
	)

func show_pending_narrative_messages() -> void:
	var messages: Array = GameManager.consume_pending_narrative_messages()

	if messages.is_empty():
		return

	var combined_text: String = ""

	for message in messages:
		combined_text += format_narrative_message(message)
		combined_text += "\n\n"

	show_location_message(
		"El Velo se agita",
		combined_text.strip_edges()
	)

	SaveManager.autosave_game()


func format_narrative_message(message: Variant) -> String:
	if message is Dictionary:
		var entry: Dictionary = message
		var title: String = str(entry.get("name", entry.get("title", "Hito narrativo")))
		var text: String = str(entry.get("text", entry.get("message", "")))

		if text == "":
			return title

		return "%s\n\n%s" % [title, text]

	return str(message)


func add_bottom_action(text: String, callback: Callable, disabled: bool = false) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.disabled = disabled
	button.focus_mode = Control.FOCUS_ALL
	button.clip_text = true
	button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	button.custom_minimum_size = Vector2(1, 34)

	if not disabled:
		button.pressed.connect(callback)

	LuminariaTheme.apply_content_action_button(button)
	bottom_actions.add_child(button)
	return button
	
func clear_bottom_actions() -> void:
	clear_children(bottom_actions)


func clear_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()


func is_npc_known(npc_id: String) -> bool:
	if not GameManager.player.has("known_npc_info"):
		return false

	if not GameManager.player["known_npc_info"].has(npc_id):
		return false

	var knowledge: Dictionary = GameManager.player["known_npc_info"][npc_id]
	return bool(knowledge.get("profile_seen", false))


func get_npc_display_name(npc_id: String) -> String:
	if not is_npc_known(npc_id):
		return "???"

	var npc: Dictionary = DataManager.get_npc(npc_id)
	return str(npc.get("name", npc_id))

func clamp_character_position(position_value: Vector2, character_size: Vector2) -> Vector2:
	var margin: float = 8.0
	var max_x: float = max(margin, location_layer.size.x - character_size.x - margin)
	var max_y: float = max(margin, location_layer.size.y - character_size.y - margin)

	return Vector2(
		clamp(position_value.x, margin, max_x),
		clamp(position_value.y, margin, max_y)
	)

func get_location_scale() -> float:
	var safe_width: float = max(location_layer.size.x, 1.0)
	var safe_height: float = max(location_layer.size.y, 1.0)

	var scale_x: float = safe_width / BASE_LOCATION_SIZE.x
	var scale_y: float = safe_height / BASE_LOCATION_SIZE.y

	return min(scale_x, scale_y)


func refresh_layout_after_frame() -> void:
	await get_tree().process_frame
	layout_overlay_controls()
	reposition_character_buttons()

func reposition_character_buttons() -> void:
	var character_buttons: Array = []

	for child in character_layer.get_children():
		if child.has_meta("npc_id"):
			character_buttons.append(child)

	var total: int = character_buttons.size()

	for index in range(total):
		var button: Button = character_buttons[index] as Button

		if button == null:
			continue

		var npc_id: String = str(button.get_meta("npc_id"))
		var button_size: Vector2 = get_scaled_character_size()
		var button_position: Vector2 = get_stable_character_position(npc_id, index, total, button_size)

		button.position = button_position
		button.custom_minimum_size = button_size
		button.size = button_size
		
func layout_overlay_controls() -> void:
	if global_action_panel == null or bottom_panel == null or location_layer == null:
		return

	var margin: float = 10.0

	var global_size: Vector2 = Vector2(430.0, 60.0)

	if location_layer.size.x < 900:
		global_size = Vector2(380.0, 54.0)

	global_action_panel.size = global_size
	global_action_panel.custom_minimum_size = global_size
	global_action_panel.position = Vector2(
		max(margin, location_layer.size.x - global_size.x - margin),
		margin
	)

	var bottom_margin: float = 14.0
	var bottom_height: float = min(224.0, max(184.0, location_layer.size.y * 0.34))
	var bottom_width: float = min(980.0, max(760.0, location_layer.size.x - 72.0))

	bottom_panel.size = Vector2(bottom_width, bottom_height)
	bottom_panel.position = Vector2(
		(location_layer.size.x - bottom_width) / 2.0,
		max(8.0, location_layer.size.y - bottom_height - bottom_margin)
	)
	
	if modal_layer != null:
		modal_layer.size = location_layer.size

		var modal_width: float = clamp(location_layer.size.x * 0.62, 520.0, 760.0)
		var modal_height: float = clamp(location_layer.size.y * 0.46, 280.0, 430.0)

		if modal_panel != null and modal_panel.has_meta("compact_info_modal"):
			modal_width = clamp(location_layer.size.x * 0.42, 440.0, 540.0)
			modal_height = 128.0

		modal_panel.size = Vector2(modal_width, modal_height)
		modal_panel.position = Vector2(
			(location_layer.size.x - modal_width) / 2.0,
			(location_layer.size.y - modal_height) / 2.0
		)
		
func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		if location_layer != null:
			call_deferred("refresh_layout_after_frame")
			call_deferred("rebuild_characters")


func _on_back_pressed() -> void:
	SceneRouter.go_to_world_map()


func setup_fullscreen_root() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0

func build_modal() -> void:
	modal_layer = ColorRect.new()
	modal_layer.color = Color(0, 0, 0, 0.55)
	modal_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	modal_layer.visible = false
	modal_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	location_layer.add_child(modal_layer)

	modal_panel = PanelContainer.new()
	modal_panel.custom_minimum_size = Vector2(520, 360)
	modal_layer.add_child(modal_panel)
	
	modal_panel.add_theme_stylebox_override("panel", LuminariaTheme.make_transparent_style())

	var modal_panel_texture: TextureRect = TextureRect.new()
	modal_panel_texture.set_anchors_preset(Control.PRESET_FULL_RECT)
	modal_panel_texture.texture = LuminariaTheme.get_world_info_panel_texture()
	modal_panel_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	modal_panel_texture.stretch_mode = TextureRect.STRETCH_SCALE
	modal_panel_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	modal_panel.add_child(modal_panel_texture)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 40)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_right", 40)
	margin.add_theme_constant_override("margin_bottom", 28)
	modal_panel.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)

	modal_title_label = Label.new()
	modal_title_label.custom_minimum_size = Vector2(1, 28)
	modal_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	modal_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	modal_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	modal_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	LuminariaTheme.apply_content_title(modal_title_label)
	box.add_child(modal_title_label)

	modal_description_label = Label.new()
	modal_description_label.custom_minimum_size = Vector2(1, 52)
	modal_description_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	modal_description_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	modal_description_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	modal_description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	LuminariaTheme.apply_content_body(modal_description_label)
	box.add_child(modal_description_label)

	modal_scroll = ScrollContainer.new()
	modal_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	modal_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	modal_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	modal_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	box.add_child(modal_scroll)

	modal_buttons = VBoxContainer.new()
	modal_buttons.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	modal_buttons.add_theme_constant_override("separation", 8)
	modal_scroll.add_child(modal_buttons)

	modal_footer = HBoxContainer.new()
	modal_footer.alignment = BoxContainer.ALIGNMENT_CENTER
	modal_footer.add_theme_constant_override("separation", 10)
	box.add_child(modal_footer)

func open_result_modal(title: String, message: String, continue_callback: Callable) -> void:
	open_choice_modal(title, message)
	add_modal_footer_button("Continuar", continue_callback)
	
func open_choice_modal(title: String, description: String) -> void:
	clear_children(modal_buttons)
	clear_children(modal_footer)

	if modal_panel != null:
		modal_panel.remove_meta("compact_info_modal")

	modal_title_label.custom_minimum_size = Vector2(1, 28)
	modal_description_label.custom_minimum_size = Vector2(1, 52)
	modal_footer.custom_minimum_size = Vector2(1, 40)
	modal_title_label.text = title
	modal_description_label.text = description
	modal_description_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	modal_description_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP

	modal_layer.visible = true
	modal_layer.move_to_front()
	call_deferred("refresh_layout_after_frame")


func close_choice_modal() -> void:
	if modal_layer != null:
		modal_layer.visible = false


func add_modal_choice_button(text: String, callback: Callable) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_ALL
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(1, 48)
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.pressed.connect(callback)

	modal_buttons.add_child(button)
	return button


func add_modal_footer_button(text: String, callback: Callable) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_ALL
	button.pressed.connect(callback)
	LuminariaTheme.apply_content_action_button(button)
	button.custom_minimum_size = Vector2(190, 40)

	modal_footer.add_child(button)
	return button

func load_continue_from_location() -> void:
	if SaveManager.load_continue_game():
		SceneRouter.go_to_current_location_scene()
		return

	show_location_message(
		"No hay partida guardada",
		"No se encontró autosave ni guardado manual."
	)

func build_load_game_modal() -> void:
	load_game_modal = LoadGameModal.new()
	location_layer.add_child(load_game_modal)
	load_game_modal.hide_modal()

func open_compact_info_modal(title: String, message: String, continue_callback: Callable) -> void:
	clear_children(modal_buttons)
	clear_children(modal_footer)

	if modal_panel != null:
		modal_panel.set_meta("compact_info_modal", true)

	modal_title_label.custom_minimum_size = Vector2(1, 24)
	modal_description_label.custom_minimum_size = Vector2(1, 48)
	modal_footer.custom_minimum_size = Vector2(1, 38)

	modal_title_label.text = title
	modal_description_label.text = message
	modal_description_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	modal_description_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	add_modal_footer_button("Continuar", continue_callback)

	modal_layer.visible = true
	modal_layer.move_to_front()
	call_deferred("refresh_layout_after_frame")
	
func show_save_confirmation_modal() -> void:
	open_compact_info_modal(
		"Partida guardada",
		"El progreso fue guardado manualmente.\nPuedes continuar explorando esta zona.",
		func():
			close_choice_modal()
			show_location_overview(DataManager.get_location(current_location_id), true)
	)
