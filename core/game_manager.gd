extends Node

signal game_started
signal time_changed
signal player_changed

var player: Dictionary = {}
var current_day: int = 1
var current_month: int = 1
var current_weekday_index: int = 0
var current_time_block: String = "morning"
var current_action_index: int = 0
var current_location_id: String = "home"

const WEEKDAYS := [
	"Lunes",
	"Martes",
	"Miércoles",
	"Jueves",
	"Viernes",
	"Sábado",
	"Domingo"
]

const TIME_BLOCKS := [
	"morning",
	"afternoon",
	"night"
]

const ACTIONS_PER_BLOCK := {
	"morning": 2,
	"afternoon": 3,
	"night": 2
}

func start_new_game(player_name: String, class_id: String) -> void:
	var class_data := DataManager.get_player_class(class_id)

	player = {
		"name": player_name,
		"class_id": class_id,
		"money": 100,
		"stamina": 100,
		"max_stamina": 100,
		"stats": {
			"strength": 1,
			"intellect": 1,
			"charm": 1,
			"discipline": 1,
			"intuition": 1
		},
		"known_npc_info": {},
		"relationships": {},
		"inventory": [
			{
				"item_id": "flowers",
				"amount": 1
			},
			{
				"item_id": "bread",
				"amount": 1
			}
		],
		"daily_flags": {}
	}

	if class_data.has("starting_stats"):
		for stat_name in class_data["starting_stats"].keys():
			player["stats"][stat_name] = class_data["starting_stats"][stat_name]

	current_day = 1
	current_month = 1
	current_weekday_index = 0
	current_time_block = "morning"
	current_action_index = 0
	current_location_id = "home"

	emit_signal("game_started")
	emit_signal("player_changed")
	emit_signal("time_changed")

func consume_action(cost_stamina: int = 0) -> void:
	if is_day_exhausted():
		return

	player["stamina"] = max(player["stamina"] - cost_stamina, 0)
	current_action_index += 1

	if current_action_index >= ACTIONS_PER_BLOCK[current_time_block]:
		advance_time_block()

	emit_signal("time_changed")
	emit_signal("player_changed")

func advance_time_block() -> void:
	current_action_index = 0

	var index := TIME_BLOCKS.find(current_time_block)

	if index < TIME_BLOCKS.size() - 1:
		current_time_block = TIME_BLOCKS[index + 1]
	else:
		current_action_index = ACTIONS_PER_BLOCK["night"]

func sleep_until_next_day() -> void:
	current_time_block = "morning"
	current_action_index = 0
	current_day += 1
	current_weekday_index = (current_weekday_index + 1) % 7

	if current_day > 30:
		current_day = 1
		current_month += 1

	player["stamina"] = player["max_stamina"]
	player["daily_flags"] = {}

	current_location_id = "home"

	reset_daily_relationship_flags()
	
	emit_signal("time_changed")
	emit_signal("player_changed")

func is_day_exhausted() -> bool:
	return current_time_block == "night" and current_action_index >= ACTIONS_PER_BLOCK["night"]

func get_actions_remaining() -> int:
	return max(ACTIONS_PER_BLOCK[current_time_block] - current_action_index, 0)

func get_weekday_name() -> String:
	return WEEKDAYS[current_weekday_index]

func get_time_label() -> String:
	match current_time_block:
		"morning":
			return "Mañana"
		"afternoon":
			return "Tarde"
		"night":
			return "Noche"
		_:
			return "Desconocido"

func has_active_game() -> bool:
	return not player.is_empty()

func reset_daily_relationship_flags() -> void:
	for npc_id in player["relationships"].keys():
		player["relationships"][npc_id]["gift_given_today"] = false

func ensure_relationship(npc_id: String) -> void:
	if not player["relationships"].has(npc_id):
		player["relationships"][npc_id] = {
			"friendship": 0,
			"tension": 0,
			"loyalty": 0,
			"jealousy": 0,
			"gift_given_today": false,
			"relationship_state": "none"
		}

	if not player["relationships"][npc_id].has("relationship_state"):
		player["relationships"][npc_id]["relationship_state"] = "none"

func ensure_npc_knowledge(npc_id: String) -> void:
	if not player["known_npc_info"].has(npc_id):
		player["known_npc_info"][npc_id] = {
			"profile_seen": false,
			"info": [],
			"gifts": [],
			"schedule": [],
			"notes": []
		}

func mark_npc_seen(npc_id: String) -> void:
	ensure_relationship(npc_id)
	ensure_npc_knowledge(npc_id)
	player["known_npc_info"][npc_id]["profile_seen"] = true

func reveal_npc_info(npc_id: String, info_key: String) -> void:
	ensure_npc_knowledge(npc_id)

	var known_info: Array = player["known_npc_info"][npc_id]["info"]
	if not known_info.has(info_key):
		known_info.append(info_key)

func reveal_npc_gift(npc_id: String, item_id: String) -> void:
	ensure_npc_knowledge(npc_id)

	var known_gifts: Array = player["known_npc_info"][npc_id]["gifts"]
	if not known_gifts.has(item_id):
		known_gifts.append(item_id)

func reveal_npc_schedule(npc_id: String, time_block: String) -> void:
	ensure_npc_knowledge(npc_id)

	var known_schedule: Array = player["known_npc_info"][npc_id]["schedule"]
	if not known_schedule.has(time_block):
		known_schedule.append(time_block)

func add_npc_note(npc_id: String, note: String) -> void:
	ensure_npc_knowledge(npc_id)

	var notes: Array = player["known_npc_info"][npc_id]["notes"]
	if not notes.has(note):
		notes.append(note)

func get_affinity_label(affinity: int, relationship_state: String) -> String:
	if relationship_state == "interest":
		return "Interés mutuo"
	if relationship_state == "dating":
		return "Saliendo"
	if relationship_state == "lovers":
		return "Amantes"
	if relationship_state == "partner":
		return "Pareja formal"

	if affinity >= 90:
		return "Tensión no resuelta"
	if affinity >= 80:
		return "Deseo contenido"
	if affinity >= 60:
		return "Tensión romántica"
	if affinity >= 40:
		return "Confianza inicial"
	if affinity >= 20:
		return "Curiosidad"

	return "Distante"

func get_available_info_to_reveal(npc_id: String) -> Array:
	ensure_npc_knowledge(npc_id)

	var npc: Dictionary = DataManager.get_npc(npc_id)
	var info_data: Dictionary = npc.get("info", {})
	var known_info: Array = player["known_npc_info"][npc_id]["info"]
	var available: Array = []

	for info_key in info_data.keys():
		if not known_info.has(info_key):
			available.append(info_key)

	return available

func reveal_random_npc_info(npc_id: String) -> String:
	var available: Array = get_available_info_to_reveal(npc_id)

	if available.is_empty():
		return ""

	var index: int = randi_range(0, available.size() - 1)
	var info_key: String = available[index]

	reveal_npc_info(npc_id, info_key)

	return info_key

func get_info_label(info_key: String) -> String:
	for section_id in DataManager.npc_info_schema.keys():
		var section: Dictionary = DataManager.npc_info_schema[section_id]
		var keys: Dictionary = section.get("keys", {})

		if keys.has(info_key):
			return keys[info_key]

	return info_key

func add_item(item_id: String, amount: int = 1) -> void:
	if not player.has("inventory"):
		player["inventory"] = []

	for entry in player["inventory"]:
		var item_entry: Dictionary = entry

		if item_entry.get("item_id", "") == item_id:
			item_entry["amount"] = int(item_entry.get("amount", 0)) + amount
			return

	player["inventory"].append({
		"item_id": item_id,
		"amount": amount
	})

func remove_item(item_id: String, amount: int = 1) -> bool:
	if not player.has("inventory"):
		player["inventory"] = []

	for entry in player["inventory"]:
		var item_entry: Dictionary = entry

		if item_entry.get("item_id", "") == item_id:
			var current_amount: int = int(item_entry.get("amount", 0))

			if current_amount < amount:
				return false

			item_entry["amount"] = current_amount - amount

			if item_entry["amount"] <= 0:
				player["inventory"].erase(entry)

			return true

	return false

func has_item(item_id: String, amount: int = 1) -> bool:
	if not player.has("inventory"):
		return false

	for entry in player["inventory"]:
		var item_entry: Dictionary = entry

		if item_entry.get("item_id", "") == item_id:
			return int(item_entry.get("amount", 0)) >= amount

	return false

func get_gift_items_in_inventory() -> Array:
	var result: Array = []

	if not player.has("inventory"):
		return result

	for entry in player["inventory"]:
		var item_entry: Dictionary = entry
		var item_id: String = item_entry.get("item_id", "")
		var amount: int = int(item_entry.get("amount", 0))
		var item_data: Dictionary = DataManager.get_item(item_id)

		if amount > 0 and item_data.get("type", "") == "gift":
			result.append(item_entry)

	return result

func buy_item(item_id: String, amount: int = 1) -> bool:
	var item: Dictionary = DataManager.get_item(item_id)
	var price: int = int(item.get("price", 0))
	var total_cost: int = price * amount

	if int(player.get("money", 0)) < total_cost:
		return false

	player["money"] -= total_cost
	add_item(item_id, amount)

	return true

func perform_activity(activity_id: String) -> String:
	var activity: Dictionary = DataManager.get_activity(activity_id)

	if activity.is_empty():
		return "Actividad no encontrada."

	var stamina_cost: int = int(activity.get("stamina_cost", 0))

	if int(player.get("stamina", 0)) < stamina_cost:
		return "No tienes suficiente resistencia para esta actividad."

	var stat: String = activity.get("stat", "")
	var base_gain: int = int(activity.get("base_gain", 0))
	var money_gain: int = int(activity.get("money_gain", 0))
	var class_id: String = player.get("class_id", "")
	var class_data: Dictionary = DataManager.get_player_class(class_id)
	var modifiers: Dictionary = class_data.get("growth_modifiers", {})

	var modifier: float = float(modifiers.get(stat, 1.0))
	var final_gain: int = max(1, int(round(float(base_gain) * modifier)))

	if stat != "":
		player["stats"][stat] = int(player["stats"].get(stat, 0)) + final_gain

	player["money"] = int(player.get("money", 0)) + money_gain

	consume_action(stamina_cost)

	return "%s\n\n%s +%s\nDinero +%s\nResistencia -%s" % [
		activity.get("description", "Actividad completada."),
		stat,
		final_gain,
		money_gain,
		stamina_cost
	]

func add_affinity(npc_id: String, amount: int) -> String:
	ensure_relationship(npc_id)

	var relation: Dictionary = player["relationships"][npc_id]
	var old_value: int = int(relation.get("affinity", 0))
	var new_value: int = clamp(old_value + amount, 0, 100)
	
	var message: String = ""

	relation["affinity"] = new_value
	
	var event_texts: Array = EventSystem.process_affinity_events(npc_id, new_value)

	for text in event_texts:
		message += "\n\n" + text

	var real_change: int = new_value - old_value

	if real_change > 0:
		var rivalry_results: Array = RivalrySystem.process_affinity_change(npc_id, real_change)

		for result in rivalry_results:
			var affected_npc_id: String = result.get("affected_npc_id", "")
			var affected_npc: Dictionary = DataManager.get_npc(affected_npc_id)
			var affected_name: String = affected_npc.get("name", affected_npc_id)
			var penalty: int = int(result.get("penalty", 0))

			message += "\n%s parece distante últimamente. Afinidad -%s" % [
				affected_name,
				penalty
			]

	return message

func add_relationship_value(npc_id: String, key: String, amount: int) -> String:
	ensure_relationship(npc_id)

	var relation: Dictionary = player["relationships"][npc_id]

	var old_value: int = int(relation.get(key, 0))
	var new_value: int = clamp(old_value + amount, 0, 100)

	relation[key] = new_value

	var real_change: int = new_value - old_value
	var message: String = ""

	if key == "tension" and real_change > 0:
		var rivalry_results: Array = RivalrySystem.process_affinity_change(npc_id, real_change)

		for result in rivalry_results:
			var affected_npc_id: String = result.get("affected_npc_id", "")
			var affected_npc: Dictionary = DataManager.get_npc(affected_npc_id)
			var affected_name: String = affected_npc.get("name", affected_npc_id)
			var penalty: int = int(result.get("penalty", 0))

			message += "\n%s parece distante últimamente. Celos +%s" % [
				affected_name,
				penalty
			]

	return message

func get_total_affinity(npc_id: String) -> int:
	ensure_relationship(npc_id)

	var relation: Dictionary = player["relationships"][npc_id]

	var friendship: int = int(relation.get("friendship", 0))
	var tension: int = int(relation.get("tension", 0))
	var loyalty: int = int(relation.get("loyalty", 0))

	# Peso ajustable
	return int((friendship * 0.4) + (tension * 0.4) + (loyalty * 0.2))
