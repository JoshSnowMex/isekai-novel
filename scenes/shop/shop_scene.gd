extends Control


var hud_bar: WorldHudBar
var shop_frame: PanelContainer
var shop_layer: Control
var background_layer: Control

var info_panel: PanelContainer
var info_title_label: Label
var info_description_label: Label

var global_action_panel: PanelContainer
var global_action_buttons: HBoxContainer

var shop_panel: PanelContainer
var item_scroll: ScrollContainer
var item_grid: GridContainer

var current_message: String = ""
var preview_item_id: String = ""


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
	info_panel.custom_minimum_size = Vector2(540, 46)
	shop_layer.add_child(info_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 4)
	info_panel.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 0)
	margin.add_child(box)

	info_title_label = Label.new()
	info_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	info_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	info_title_label.clip_text = true
	box.add_child(info_title_label)

	info_description_label = Label.new()
	info_description_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_description_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	info_description_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	info_description_label.clip_text = true
	box.add_child(info_description_label)


func build_global_action_panel() -> void:
	global_action_panel = PanelContainer.new()
	global_action_panel.custom_minimum_size = Vector2(430, 46)
	shop_layer.add_child(global_action_panel)

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

	add_global_action("Mapa", func(): _on_map_pressed())
	add_global_action("Bitácora", func(): SceneRouter.go_to_journal(SceneRouter.SHOP_SCENE))
	add_global_action("Guardar", func(): _on_save_pressed())
	add_global_action("Cargar", func(): SceneRouter.go_to_main_menu())


func build_shop_panel() -> void:
	shop_panel = PanelContainer.new()
	shop_panel.custom_minimum_size = Vector2(980, 420)
	shop_layer.add_child(shop_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	shop_panel.add_child(margin)

	item_scroll = ScrollContainer.new()
	item_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	item_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	item_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	margin.add_child(item_scroll)

	item_grid = GridContainer.new()
	item_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item_grid.columns = 5
	item_grid.add_theme_constant_override("h_separation", 8)
	item_grid.add_theme_constant_override("v_separation", 8)
	item_scroll.add_child(item_grid)


func refresh_shop(message: String = "") -> void:
	current_message = message
	GameManager.current_location_id = "shop"
	hud_bar.refresh()

	refresh_info_panel()
	refresh_items()

	call_deferred("refresh_layout_after_frame")


func refresh_info_panel() -> void:
	if preview_item_id != "":
		show_item_preview(preview_item_id)
		return

	if current_message != "":
		info_title_label.text = "Tienda del Umbral"
		info_description_label.text = current_message
		return

	info_title_label.text = "Tienda del Umbral"
	info_description_label.text = "Click en un regalo para comprarlo. Pasa el cursor para ver detalles."


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

	var button: Button = Button.new()
	button.focus_mode = Control.FOCUS_ALL
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(118, 118)
	button.disabled = not can_buy
	button.text = build_item_card_text(item_name, price, owned, can_buy, player_money)

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

	item_grid.add_child(button)


func build_item_card_text(item_name: String, price: int, owned: int, can_buy: bool, player_money: int) -> String:
	var text: String = ""

	text += "[Icono]\n"
	text += "%s\n" % item_name
	text += "%s L" % price

	if owned > 0:
		text += "\n×%s" % owned

	if not can_buy:
		text += "\nFaltan %s" % max(price - player_money, 0)

	return text


func show_item_preview(item_id: String) -> void:
	var item: Dictionary = DataManager.get_item(item_id)
	var item_name: String = str(item.get("name", item_id))
	var description: String = str(item.get("description", ""))
	var price: int = int(item.get("price", 0))
	var owned: int = get_inventory_amount(item_id)
	var money: int = int(GameManager.player.get("money", 0))

	info_title_label.text = "%s · %s Lúmenes" % [
		item_name,
		price
	]

	var text: String = description

	if text == "":
		text = "Un objeto de la tienda."

	if owned > 0:
		text += " Tienes %s." % owned

	if money < price:
		text += " Faltan %s Lúmenes." % max(price - money, 0)

	info_description_label.text = text


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

	current_message = "Compraste %s por %s Lúmenes." % [
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
	current_message = message
	preview_item_id = ""

	info_title_label.text = title
	info_description_label.text = message


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


func add_global_action(text: String, callback: Callable) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_ALL
	button.pressed.connect(callback)
	global_action_buttons.add_child(button)
	return button


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
	var top_height: float = 46.0

	var global_width: float = 430.0
	if shop_layer.size.x < 760:
		global_width = 330.0

	global_action_panel.size = Vector2(global_width, top_height)
	global_action_panel.position = Vector2(
		max(margin, shop_layer.size.x - global_width - margin),
		top_y
	)

	var info_width: float = max(
		260.0,
		shop_layer.size.x - global_width - (margin * 3.0)
	)

	info_panel.size = Vector2(info_width, top_height)
	info_panel.position = Vector2(
		margin,
		top_y
	)

	var panel_width: float = max(360.0, shop_layer.size.x - 24.0)
	var panel_height: float = max(300.0, shop_layer.size.y - top_height - 34.0)

	shop_panel.size = Vector2(panel_width, panel_height)
	shop_panel.position = Vector2(
		12.0,
		top_y + top_height + 12.0
	)

	if panel_width >= 980:
		item_grid.columns = 5
	elif panel_width >= 780:
		item_grid.columns = 4
	elif panel_width >= 600:
		item_grid.columns = 3
	else:
		item_grid.columns = 2


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		if shop_layer != null:
			call_deferred("refresh_layout_after_frame")


func setup_fullscreen_root() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0
