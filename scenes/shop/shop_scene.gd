extends Control


var hud_bar: WorldHudBar
var shop_frame: PanelContainer
var shop_layer: Control
var background_layer: Control
var info_panel: PanelContainer
var info_label: Label
var global_action_panel: WorldActionPanel
var shop_panel: Control
var item_scroll: ScrollContainer
var item_grid: GridContainer
var current_message: String = ""
var preview_item_id: String = ""
var vendor_placeholder: Control
var vendor_sprite: TextureRect
var load_game_modal: LoadGameModal

func _ready() -> void:
	setup_fullscreen_root()
	build_ui()
	refresh_shop()
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

	shop_frame = PanelContainer.new()
	shop_frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shop_frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(shop_frame)

	var frame_margin: MarginContainer = MarginContainer.new()
	frame_margin.add_theme_constant_override("margin_left", 6)
	frame_margin.add_theme_constant_override("margin_top", 6)
	frame_margin.add_theme_constant_override("margin_right", 6)
	frame_margin.add_theme_constant_override("margin_bottom", 6)
	shop_frame.add_child(frame_margin)

	shop_layer = Control.new()
	shop_layer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shop_layer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	shop_layer.clip_contents = true
	frame_margin.add_child(shop_layer)

	background_layer = Control.new()
	background_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	background_layer.offset_left = 0
	background_layer.offset_top = 0
	background_layer.offset_right = 0
	background_layer.offset_bottom = 0
	shop_layer.add_child(background_layer)

	build_background()
	build_info_panel()
	build_global_action_panel()
	build_shop_panel()
	build_vendor_placeholder()
	build_load_game_modal()
	
	call_deferred("refresh_layout_after_frame")


func build_background() -> void:
	clear_children(background_layer)

	var location_data: Dictionary = DataManager.get_location("shop")
	var location_ui: Dictionary = DataManager.get_location_ui("shop")

	var background_path: String = str(location_ui.get("background", ""))
	var fallback_title: String = str(location_data.get("name", "Tienda del Umbral"))
	var final_asset_name: String = background_path.get_file()

	if final_asset_name == "":
		final_asset_name = "location_shop_umbral.png"

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

func build_info_panel() -> void:
	info_panel = PanelContainer.new()
	info_panel.custom_minimum_size = Vector2(560, 104)
	info_panel.add_theme_stylebox_override("panel", LuminariaTheme.make_transparent_style())
	shop_layer.add_child(info_panel)

	var panel_texture: TextureRect = TextureRect.new()
	panel_texture.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel_texture.texture = LuminariaTheme.get_world_info_panel_texture()
	panel_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	panel_texture.stretch_mode = TextureRect.STRETCH_SCALE
	panel_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_panel.add_child(panel_texture)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 20)
	info_panel.add_child(margin)

	info_label = Label.new()
	info_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	info_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_label.clip_text = true
	LuminariaTheme.apply_content_body(info_label)
	margin.add_child(info_label)

func build_global_action_panel() -> void:
	global_action_panel = WorldActionPanel.new()
	global_action_panel.build()
	shop_layer.add_child(global_action_panel)

	global_action_panel.clear_actions()

	global_action_panel.add_action("Mapa", func(): _on_map_pressed())
	global_action_panel.add_action("Bitácora", func(): SceneRouter.go_to_journal(SceneRouter.SHOP_SCENE))
	global_action_panel.add_action("Guardar", func(): _on_save_pressed())
	global_action_panel.add_action("Cargar", func():
		load_game_modal.open()
	)

func build_shop_panel() -> void:
	shop_panel = Control.new()
	shop_panel.custom_minimum_size = Vector2(980, 420)
	shop_layer.add_child(shop_panel)

	item_scroll = ScrollContainer.new()
	item_scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	item_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	item_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	shop_panel.add_child(item_scroll)

	item_grid = GridContainer.new()
	item_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item_grid.columns = 5
	item_grid.add_theme_constant_override("h_separation", 20)
	item_grid.add_theme_constant_override("v_separation", 8)
	item_scroll.add_child(item_grid)

func refresh_shop(message: String = "") -> void:
	current_message = message
	GameManager.current_location_id = "shop"
	hud_bar.refresh()

	refresh_info_panel()
	refresh_items()

	call_deferred("update_scroll_visibility")


func refresh_info_panel() -> void:
	if preview_item_id != "":
		show_item_preview(preview_item_id)
		return

	if current_message != "":
		info_label.text = current_message
		return

	info_label.text = "Tienda del Umbral\nRegalos pequeños, consecuencias grandes."


func refresh_items() -> void:
	clear_children(item_grid)

	var item_ids: Array = get_shop_item_ids()

	for item_id in item_ids:
		add_item_card(str(item_id))

	if item_ids.is_empty():
		var empty_label: Label = Label.new()
		empty_label.text = "No hay objetos disponibles por ahora."
		empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		item_grid.add_child(empty_label)


func get_shop_item_ids() -> Array:
	var result: Array = []

	for item_id in DataManager.items.keys():
		var item: Dictionary = DataManager.get_item(str(item_id))

		if item.get("type", "") != "gift":
			continue

		result.append(str(item_id))

	result.sort_custom(func(a, b):
		var item_a: Dictionary = DataManager.get_item(str(a))
		var item_b: Dictionary = DataManager.get_item(str(b))

		var price_a: int = int(item_a.get("price", 0))
		var price_b: int = int(item_b.get("price", 0))

		if price_a == price_b:
			return str(item_a.get("name", a)) < str(item_b.get("name", b))

		return price_a < price_b
	)

	return result

func add_item_card(item_id: String) -> void:
	var locked_item_id: String = item_id
	var item: Dictionary = DataManager.get_item(locked_item_id)
	var item_name: String = str(item.get("name", locked_item_id))
	var price: int = int(item.get("price", 0))
	var owned: int = get_inventory_amount(locked_item_id)
	var player_money: int = int(GameManager.player.get("money", 0))
	var can_buy: bool = player_money >= price

	var cell: VBoxContainer = VBoxContainer.new()
	cell.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	cell.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	cell.alignment = BoxContainer.ALIGNMENT_CENTER
	cell.custom_minimum_size = Vector2(86, 104)
	cell.add_theme_constant_override("separation", 8)
	item_grid.add_child(cell)

	var button: Button = Button.new()
	button.focus_mode = Control.FOCUS_ALL
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	button.custom_minimum_size = Vector2(82, 82)
	button.size = Vector2(82, 82)
	button.disabled = not can_buy
	button.text = ""
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_stylebox_override("normal", make_shop_item_icon_style(false, can_buy))
	button.add_theme_stylebox_override("hover", make_shop_item_icon_style(true, can_buy))
	button.add_theme_stylebox_override("pressed", make_shop_item_icon_style(true, can_buy))
	button.add_theme_stylebox_override("focus", make_shop_item_icon_style(true, can_buy))
	button.add_theme_stylebox_override("disabled", make_shop_item_icon_style(false, false))
	cell.add_child(button)

	var icon: TextureRect = TextureRect.new()
	icon.texture = load_item_icon(locked_item_id)
	icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	icon.offset_left = 1
	icon.offset_top = 1
	icon.offset_right = -1
	icon.offset_bottom = -1
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_SCALE
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.modulate = Color(1, 1, 1, 1.0 if can_buy else 0.48)
	button.add_child(icon)

	var label: Label = Label.new()
	label.custom_minimum_size = Vector2(96, 18)
	label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.clip_text = true
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.text = build_item_card_text(item_name, price, owned, can_buy, player_money)
	LuminariaTheme.apply_label(label, 13, Color(0.98, 0.94, 1.0, 1.0 if can_buy else 0.58), 3)
	cell.add_child(label)

	if can_buy:
		button.pressed.connect(func():
			buy_item(locked_item_id)
		)

	button.mouse_entered.connect(func():
		preview_item_id = locked_item_id
		show_item_preview(locked_item_id)
	)

	button.focus_entered.connect(func():
		preview_item_id = locked_item_id
		show_item_preview(locked_item_id)
	)

	button.mouse_exited.connect(func():
		preview_item_id = ""
		refresh_info_panel()
	)

	button.focus_exited.connect(func():
		preview_item_id = ""
		refresh_info_panel()
	)
	
func load_item_icon(item_id: String) -> Texture2D:
	var path: String = "res://assets/shop/items/item_%s.png" % item_id

	if ResourceLoader.exists(path):
		return load(path)

	return null
	
func make_shop_item_icon_style(is_hovered: bool, is_enabled: bool) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()

	if not is_enabled:
		style.bg_color = Color(0.018, 0.016, 0.024, 0.46)
		style.border_color = Color(0.28, 0.24, 0.36, 0.38)
		style.shadow_color = Color(0, 0, 0, 0.20)
		style.shadow_size = 3
	elif is_hovered:
		style.bg_color = Color(0.12, 0.055, 0.20, 0.58)
		style.border_color = Color(0.78, 0.58, 1.0, 0.92)
		style.shadow_color = Color(0.48, 0.22, 0.90, 0.36)
		style.shadow_size = 9
	else:
		style.bg_color = Color(0.025, 0.022, 0.036, 0.58)
		style.border_color = Color(0.55, 0.44, 0.72, 0.64)
		style.shadow_color = Color(0, 0, 0, 0.28)
		style.shadow_size = 5

	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1

	style.corner_radius_top_left = 7
	style.corner_radius_top_right = 7
	style.corner_radius_bottom_left = 7
	style.corner_radius_bottom_right = 7

	style.content_margin_left = 0
	style.content_margin_top = 0
	style.content_margin_right = 0
	style.content_margin_bottom = 0
	style.shadow_offset = Vector2(0, 2)

	return style

func get_item_card_size() -> Vector2:
	var panel_width: float = max(shop_panel.size.x, 1.0)
	var columns: int = max(item_grid.columns, 1)
	var spacing: float = 8.0 * float(max(columns - 1, 0))
	var inner_margin: float = 48.0
	var available_width: float = max(panel_width - inner_margin - spacing, 120.0)
	var raw_size: float = floor(available_width / float(columns))

	var size_value: float = clamp(raw_size, 92.0, 116.0)

	return Vector2(size_value, size_value)

func show_item_preview(item_id: String) -> void:
	var item: Dictionary = DataManager.get_item(item_id)
	var item_name: String = str(item.get("name", item_id))
	var description: String = str(item.get("shop_preview", item.get("description", "")))
	var price: int = int(item.get("price", 0))
	var owned: int = get_inventory_amount(item_id)
	var money: int = int(GameManager.player.get("money", 0))

	var first_line: String = "%s  ·  %s L" % [item_name, price]

	if owned > 0:
		first_line += "  ·  En bolsa: %s" % owned

	if money < price:
		first_line += "  ·  Lúmenes insuficientes"

	info_label.text = "%s\n%s" % [
		first_line,
		description
	]
	
func buy_item(item_id: String) -> void:
	var item: Dictionary = DataManager.get_item(item_id)
	var item_name: String = str(item.get("name", item_id))
	var price: int = int(item.get("price", 0))

	if int(GameManager.player.get("money", 0)) < price:
		current_message = "No tienes suficientes Lúmenes para comprar %s." % item_name
		preview_item_id = ""
		refresh_shop(current_message)
		return

	var success: bool = GameManager.buy_item(item_id, 1)

	if not success:
		current_message = "No fue posible comprar %s." % item_name
		preview_item_id = ""
		refresh_shop(current_message)
		return

	SaveManager.autosave_game()
	hud_bar.refresh()

	current_message = "Compraste %s · %s L" % [
		item_name,
		price
	]

	preview_item_id = item_id
	refresh_shop(current_message)
	show_item_preview(item_id)


func get_inventory_amount(item_id: String) -> int:
	if not GameManager.player.has("inventory"):
		return 0

	var total: int = 0

	for entry in GameManager.player.get("inventory", []):
		var item_entry: Dictionary = entry

		if str(item_entry.get("item_id", "")) == item_id:
			total += int(item_entry.get("amount", 0))

	return total


func show_shop_message(title: String, message: String) -> void:
	current_message = "%s · %s" % [title, message]
	preview_item_id = ""
	info_label.text = current_message


func show_pending_narrative_messages() -> void:
	var messages: Array = GameManager.consume_pending_narrative_messages()

	if messages.is_empty():
		return

	var combined_text: String = ""

	for message in messages:
		combined_text += format_narrative_message(message)
		combined_text += "\n\n"

	show_shop_message(
		"El Velo se agita",
		combined_text.strip_edges()
	)

	SaveManager.autosave_game()
	hud_bar.refresh()


func format_narrative_message(message: Variant) -> String:
	if message is Dictionary:
		var entry: Dictionary = message
		var title: String = str(entry.get("name", entry.get("title", "Hito narrativo")))
		var text: String = str(entry.get("text", entry.get("message", "")))

		if text == "":
			return title

		return "%s\n\n%s" % [title, text]

	return str(message)


func _on_save_pressed() -> void:
	SaveManager.save_game()
	show_shop_message(
		"Partida guardada",
		"El progreso fue guardado manualmente en la Tienda del Umbral."
	)


func _on_map_pressed() -> void:
	SceneRouter.go_to_world_map()

func clear_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()

func refresh_layout_after_frame() -> void:
	await get_tree().process_frame
	layout_overlay_controls()

func layout_overlay_controls() -> void:
	if shop_layer == null:
		return

	var margin: float = 10.0
	var top_y: float = 10.0

	var global_size: Vector2 = Vector2(430.0, 60.0)

	if shop_layer.size.x < 900:
		global_size = Vector2(380.0, 54.0)

	global_action_panel.size = global_size
	global_action_panel.custom_minimum_size = global_size
	global_action_panel.position = Vector2(
		max(margin, shop_layer.size.x - global_size.x - margin),
		top_y
	)

	var info_width: float = max(
		360.0,
		shop_layer.size.x - global_size.x - (margin * 3.0)
	)

	info_panel.size = Vector2(info_width, 104.0)
	info_panel.position = Vector2(
		margin,
		top_y
	)

	var panel_top: float = top_y + 118.0
	var vendor_width: float = 250.0

	if shop_layer.size.x < 900:
		vendor_width = 190.0

	var vendor_gap: float = 4.0
	var grid_right_reserve: float = 120.0
	var vendor_visual_offset: float = 220.0
	var available_width: float = shop_layer.size.x - 48.0
	var panel_width: float = max(500.0, available_width - vendor_width - vendor_gap - grid_right_reserve)
	var panel_height: float = max(300.0, shop_layer.size.y - panel_top - 24.0)

	shop_panel.size = Vector2(panel_width, panel_height)
	shop_panel.position = Vector2(
		24.0,
		panel_top
	)

	if panel_width >= 760:
		item_grid.columns = 7
	elif panel_width >= 620:
		item_grid.columns = 6
	elif panel_width >= 480:
		item_grid.columns = 5
	else:
		item_grid.columns = 4

	if vendor_placeholder != null:
		vendor_placeholder.visible = true
		vendor_placeholder.size = Vector2(vendor_width, panel_height)
		vendor_placeholder.position = Vector2(
			shop_layer.size.x - vendor_width - vendor_visual_offset,
			panel_top
		)
		
func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		if shop_layer != null:
			call_deferred("update_scroll_visibility")


func setup_fullscreen_root() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0

func update_scroll_visibility() -> void:
	await get_tree().process_frame

	if item_scroll == null or item_grid == null:
		return

	var content_height: float = item_grid.size.y
	var viewport_height: float = item_scroll.size.y

	if content_height > viewport_height + 4.0:
		item_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	else:
		item_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER

func build_vendor_placeholder() -> void:
	vendor_placeholder = Control.new()
	vendor_placeholder.custom_minimum_size = Vector2(220, 420)
	vendor_placeholder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shop_layer.add_child(vendor_placeholder)

	vendor_sprite = TextureRect.new()
	vendor_sprite.texture = load_vendor_texture()
	vendor_sprite.set_anchors_preset(Control.PRESET_FULL_RECT)
	vendor_sprite.offset_left = 0
	vendor_sprite.offset_top = 4
	vendor_sprite.offset_right = -32
	vendor_sprite.offset_bottom = -4
	vendor_sprite.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	vendor_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	vendor_sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vendor_placeholder.add_child(vendor_sprite)

func load_vendor_texture() -> Texture2D:
	var path: String = "res://assets/shop/npc_vendor.png"

	if ResourceLoader.exists(path):
		return load(path)

	return null
	
func load_continue_from_shop() -> void:
	if SaveManager.load_continue_game():
		SceneRouter.go_to_current_location_scene()
		return

	show_shop_message(
		"No hay partida guardada",
		"No se encontró autosave ni guardado manual."
	)

func build_load_game_modal() -> void:
	load_game_modal = LoadGameModal.new()
	shop_layer.add_child(load_game_modal)
	load_game_modal.hide_modal()

func build_item_card_text(item_name: String, price: int, owned: int, can_buy: bool, player_money: int) -> String:
	var text: String = item_name

	if owned > 0:
		text += " ×%s" % owned

	if not can_buy:
		text += " -%s L" % max(price - player_money, 0)

	return text

func get_shop_item_short_name(item_id: String, item_name: String) -> String:
	match item_id:
		"tech_prototypes":
			return "Prototipos"
		"blank_diaries":
			return "Diarios"
		"narrative_secrets":
			return "Secretos"
		"sacred_objects":
			return "Sagrados"
		"simple_jewels":
			return "Joyas"
		"ancient_books":
			return "Libros"
		_:
			return item_name

func build_item_card_text(item_name: String, price: int, owned: int, can_buy: bool, player_money: int) -> String:
	var text: String = get_shop_item_short_name(item_name)

	if owned > 0:
		text += " ×%s" % owned

	if not can_buy:
		text += " -%s L" % max(price - player_money, 0)

	return text
