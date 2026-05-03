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
		"daily_flags": {},
		"world_flags": [],
		"world_state": {
			"global_tension": 0,
			"world_instability": 0,
			"romantic_pressure": 0
		},
		"pending_narrative_messages": [],
		"collectibles": [],
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

	var milestone_results: Array = MilestoneSystem.process_milestones({
		"trigger": "day_started"
	})

	for milestone in milestone_results:
		add_pending_narrative_message(milestone)

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
	var base_stat_gain: int = int(activity.get("base_stat_gain", activity.get("base_gain", 0)))
	var base_money_gain: int = int(activity.get("base_money_gain", activity.get("money_gain", 0)))
	var work_modifier_key: String = activity.get("work_modifier_key", "none")

	var class_id: String = player.get("class_id", "")
	var class_data: Dictionary = DataManager.get_player_class(class_id)

	var growth_modifiers: Dictionary = class_data.get("growth_modifiers", {})
	var work_modifiers: Dictionary = class_data.get("work_modifiers", {})

	var stat_modifier: float = float(growth_modifiers.get(stat, 1.0))
	var money_modifier: float = float(work_modifiers.get(work_modifier_key, 1.0))

	var final_stat_gain: int = 0
	var final_money_gain: int = 0

	if base_stat_gain > 0 and stat != "":
		final_stat_gain = max(1, int(round(float(base_stat_gain) * stat_modifier)))
		player["stats"][stat] = int(player["stats"].get(stat, 0)) + final_stat_gain

	if base_money_gain > 0:
		final_money_gain = max(1, int(round(float(base_money_gain) * money_modifier)))
		player["money"] = int(player.get("money", 0)) + final_money_gain

	consume_action(stamina_cost)

	var stat_label: String = get_stat_label(stat)

	var result: String = activity.get("description", "Actividad completada.")
	result += "\n\n"

	if final_stat_gain > 0:
		result += "%s +%s\n" % [stat_label, final_stat_gain]

	if final_money_gain > 0:
		result += "Dinero +%s\n" % final_money_gain

	result += "Resistencia -%s" % stamina_cost

	return result

func add_affinity(npc_id: String, amount: int) -> String:
	return add_relationship_value(npc_id, "friendship", amount)

func add_relationship_value(npc_id: String, key: String, amount: int) -> String:
	ensure_relationship(npc_id)

	var relation: Dictionary = player["relationships"][npc_id]

	var old_value: int = int(relation.get(key, 0))
	var modified_amount: int = apply_relationship_modifier(key, amount)
	var new_value: int = clamp(old_value + modified_amount, 0, 100)

	relation[key] = new_value

	var real_change: int = new_value - old_value
	var message: String = ""

	if real_change == 0:
		return message

	if key == "friendship" or key == "tension" or key == "loyalty" or key == "jealousy":
		var total: int = get_total_affinity(npc_id)

		var event_context: Dictionary = {
			"trigger": "relationship_changed",
			"npc_id": npc_id,
			"changed_key": key,
			"amount": real_change,
			"total": total
		}

		var event_texts: Array = EventSystem.process_events(event_context)

		for text in event_texts:
			message += "\n\n" + str(text)

		var milestone_results: Array = MilestoneSystem.process_milestones(event_context)

		for milestone in milestone_results:
			add_pending_narrative_message(milestone)

	if key == "tension" and real_change > 0:
		var rivalry_results: Array = RivalrySystem.process_affinity_change(npc_id, real_change)

		for result in rivalry_results:
			var affected_npc_id: String = result.get("affected_npc_id", "")
			var affected_npc: Dictionary = DataManager.get_npc(affected_npc_id)
			var affected_name: String = affected_npc.get("name", affected_npc_id)
			var penalty: int = int(result.get("penalty", 0))

			add_relationship_value(affected_npc_id, "jealousy", penalty)

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

func can_invite_to_date(npc_id: String) -> bool:
	ensure_relationship(npc_id)

	var relation: Dictionary = player["relationships"][npc_id]
	var friendship: int = int(relation.get("friendship", 0))
	var tension: int = int(relation.get("tension", 0))
	var loyalty: int = int(relation.get("loyalty", 0))
	var jealousy: int = int(relation.get("jealousy", 0))
	var total: int = get_total_affinity(npc_id)

	if jealousy >= 80:
		return false

	if relation.get("relationship_state", "none") != "none":
		return true

	if total >= 35:
		return true

	if friendship >= 25:
		return true

	if friendship >= 18 and tension >= 5:
		return true

	if friendship >= 18 and loyalty >= 5:
		return true

	return false

func get_relationship_value(npc_id: String, key: String) -> int:
	ensure_relationship(npc_id)

	var relation: Dictionary = player["relationships"][npc_id]
	return int(relation.get(key, 0))

func add_world_flag(flag: String) -> void:
	if not player.has("world_flags"):
		player["world_flags"] = []

	if not player["world_flags"].has(flag):
		player["world_flags"].append(flag)

func has_world_flag(flag: String) -> bool:
	if not player.has("world_flags"):
		player["world_flags"] = []

	return player["world_flags"].has(flag)

func ensure_world_state() -> void:
	if not player.has("world_state"):
		player["world_state"] = {
			"global_tension": 0,
			"world_instability": 0,
			"romantic_pressure": 0
		}

func add_world_state_value(key: String, amount: int) -> void:
	ensure_world_state()

	var old_value: int = int(player["world_state"].get(key, 0))
	var new_value: int = clamp(old_value + amount, 0, 100)

	player["world_state"][key] = new_value

func get_world_state_value(key: String) -> int:
	ensure_world_state()
	return int(player["world_state"].get(key, 0))

func add_pending_narrative_message(message: Dictionary) -> void:
	if not player.has("pending_narrative_messages"):
		player["pending_narrative_messages"] = []

	player["pending_narrative_messages"].append(message)

func consume_pending_narrative_messages() -> Array:
	if not player.has("pending_narrative_messages"):
		player["pending_narrative_messages"] = []

	var messages: Array = player["pending_narrative_messages"].duplicate()
	player["pending_narrative_messages"].clear()

	return messages

func can_perform_action(required_stamina: int = 0) -> bool:
	if is_day_exhausted():
		return false

	if int(player.get("stamina", 0)) < required_stamina:
		return false

	return true

func get_action_blocked_message(required_stamina: int = 0) -> String:
	if is_day_exhausted():
		return "Ya no te queda tiempo útil hoy. Deberías volver a casa y dormir."

	if int(player.get("stamina", 0)) < required_stamina:
		return "No tienes suficiente resistencia para hacer eso."

	return ""

func apply_relationship_modifier(key: String, amount: int) -> int:
	if amount == 0:
		return 0

	var class_id: String = player.get("class_id", "")
	var class_data: Dictionary = DataManager.get_player_class(class_id)
	var modifiers: Dictionary = class_data.get("relationship_modifiers", {})

	var modifier: float = float(modifiers.get(key, 1.0))
	var modified: int = int(round(float(amount) * modifier))

	if amount > 0:
		return max(1, modified)

	if amount < 0:
		return min(-1, modified)

	return modified
	
func get_stat_label(stat: String) -> String:
	match stat:
		"strength":
			return "Fuerza"
		"intellect":
			return "Intelecto"
		"charm":
			return "Encanto"
		"discipline":
			return "Disciplina"
		"intuition":
			return "Intuición"
		_:
			return stat

func get_date_blocked_reason(npc_id: String) -> String:
	ensure_relationship(npc_id)

	var relation: Dictionary = player["relationships"][npc_id]
	var friendship: int = int(relation.get("friendship", 0))
	var tension: int = int(relation.get("tension", 0))
	var loyalty: int = int(relation.get("loyalty", 0))
	var jealousy: int = int(relation.get("jealousy", 0))
	var total: int = get_total_affinity(npc_id)

	if jealousy >= 80:
		return "La tensión emocional es demasiado alta. Ahora mismo no parece buen momento para una cita."

	if total >= 35 or friendship >= 25 or (friendship >= 18 and tension >= 5) or (friendship >= 18 and loyalty >= 5):
		return ""

	return "Aún no hay suficiente confianza para invitarle a una cita."

func ensure_collectibles() -> void:
	if not player.has("collectibles"):
		player["collectibles"] = []

func add_collectible(collectible_id: String) -> void:
	ensure_collectibles()

	if not player["collectibles"].has(collectible_id):
		player["collectibles"].append(collectible_id)

func has_collectible(collectible_id: String) -> bool:
	ensure_collectibles()
	return player["collectibles"].has(collectible_id)

func get_collectibles() -> Array:
	ensure_collectibles()
	return player["collectibles"]

func get_info_tier(info_key: String) -> int:
	var tier_20: Array = [
		"favorite_place",
		"hobby",
		"favorite_color",
		"favorite_food"
	]

	var tier_40: Array = [
		"phone",
		"routine",
		"light_romantic_preference",
		"dislikes"
	]

	var tier_60: Array = [
		"height",
		"favorite_style",
		"minor_insecurity",
		"accepted_affectionate_gesture"
	]

	var tier_80: Array = [
		"measurements",
		"emotional_fear",
		"romantic_desire",
		"ideal_date"
	]

	var tier_100: Array = [
		"intimate_secret",
		"partner_condition"
	]

	if tier_20.has(info_key):
		return 20

	if tier_40.has(info_key):
		return 40

	if tier_60.has(info_key):
		return 60

	if tier_80.has(info_key):
		return 80

	if tier_100.has(info_key):
		return 100

	return 0
