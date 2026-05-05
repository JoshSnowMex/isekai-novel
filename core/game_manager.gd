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

func start_new_game(player_name: String, class_id: String, gender_identity: String = "man") -> void:
	var class_data := DataManager.get_player_class(class_id)

	player = {
		"name": player_name,
		"class_id": class_id,
		"gender_identity": gender_identity,
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
		"final_union_npc_id": "",
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

	var storylet_results: Array = StoryletSystem.process_storylets({
		"trigger": "day_started"
	})

	for storylet_text in storylet_results:
		add_pending_narrative_message(storylet_text)

	var world_consequence_results: Array = StoryletSystem.process_storylets({
		"trigger": "day_started",
		"force_world_consequence_check": true,
		"allow_multiple_storylets": true
	})

	for consequence_text in world_consequence_results:
		add_pending_narrative_message(consequence_text)

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
	var modified_amount: int = apply_relationship_modifier(npc_id, key, amount)
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
			
		var storylet_results: Array = StoryletSystem.process_storylets(event_context)

		for storylet_text in storylet_results:
			add_pending_narrative_message(storylet_text)

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

	return int((friendship * 0.4) + (tension * 0.4) + (loyalty * 0.2))

func can_invite_to_date(npc_id: String) -> bool:
	if not is_npc_romanceable(npc_id):
		return false
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

func add_pending_narrative_message(message: Variant) -> void:
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

func apply_relationship_modifier(npc_id: String, key: String, amount: int) -> int:
	if amount == 0:
		return 0

	var class_id: String = player.get("class_id", "")
	var class_data: Dictionary = DataManager.get_player_class(class_id)
	var modifiers: Dictionary = class_data.get("relationship_modifiers", {})

	var modifier: float = float(modifiers.get(key, 1.0))

	if key == "tension" and amount > 0:
		modifier *= get_tension_gain_modifier(npc_id)

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
	if not is_npc_romanceable(npc_id):
		return "Este personaje no está disponible como ruta romántica."
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
	for section_id in DataManager.npc_info_schema.keys():
		var section: Dictionary = DataManager.npc_info_schema[section_id]
		var keys: Dictionary = section.get("keys", {})

		if keys.has(info_key):
			return int(section.get("tier", 0))

	return 0

func get_relationship_state_label(state: String) -> String:
	match state:
		"none":
			return "Sin relación"
		"interest":
			return "Interés romántico"
		"dating":
			return "Saliendo"
		"lovers":
			return "Relación íntima"
		"partner":
			return "Vínculo culminado"
		_:
			return state

func get_relationship_state_description(state: String) -> String:
	match state:
		"none":
			return "Aún no hay una relación romántica reconocida."
		"interest":
			return "Hay interés romántico claro, pero todavía no existe compromiso."
		"dating":
			return "Están saliendo. Hay una intención romántica activa."
		"lovers":
			return "Existe una relación más íntima, traviesa y privada."
		"partner":
			return "El vínculo personal con este personaje llegó a su forma máxima. Puede ser formal, íntimo o especial según el personaje."
		_:
			return ""

func get_npc_collectibles(npc_id: String) -> Dictionary:
	ensure_collectibles()
	
	var date_memories: Array = []
	var emotional_memories: Array = []
	var portrait_pieces: Array = []
	var trophies: Array = []
	var union_tokens: Array = []

	for collectible_id in player["collectibles"]:
		var id: String = str(collectible_id)

		if id.begins_with("date_memory:%s:" % npc_id):
			date_memories.append(id)
		elif id.begins_with("emotional_memory:%s:" % npc_id):
			emotional_memories.append(id)
		elif id.begins_with("portrait_piece:%s:" % npc_id):
			portrait_pieces.append(id)
		elif id == "relationship_trophy:%s" % npc_id:
			trophies.append(id)
		elif id.begins_with("union_token:%s:" % npc_id):
			union_tokens.append(id)

	return {
		"date_memories": date_memories,
		"emotional_memories": emotional_memories,
		"portrait_pieces": portrait_pieces,
		"trophies": trophies,
		"union_tokens": union_tokens
	}

func get_collectible_label(collectible_id: String) -> String:
	var parts: PackedStringArray = collectible_id.split(":")

	if collectible_id.begins_with("date_memory:") and parts.size() >= 3:
		var npc_id: String = parts[1]
		var date_location_id: String = parts[2]
		var npc: Dictionary = DataManager.get_npc(npc_id)
		var date_location: Dictionary = DataManager.get_date_location(date_location_id)

		return "Recuerdo de %s en %s" % [
			npc.get("name", npc_id),
			date_location.get("name", date_location_id)
		]

	if collectible_id.begins_with("portrait_piece:") and parts.size() >= 3:
		var npc_id: String = parts[1]
		var piece_index: String = parts[2]
		var npc: Dictionary = DataManager.get_npc(npc_id)

		return "Pieza de retrato %s de %s" % [
			piece_index,
			npc.get("name", npc_id)
		]

	if collectible_id.begins_with("relationship_trophy:") and parts.size() >= 2:
		var npc_id: String = parts[1]
		var npc: Dictionary = DataManager.get_npc(npc_id)

		return "Trofeo de vínculo: %s" % npc.get("name", npc_id)
	
	if collectible_id.begins_with("emotional_memory:") and parts.size() >= 3:
		var npc_id: String = parts[1]
		var memory_id: String = parts[2]

		if npc_id == "world":
			return "Memoria del mundo: %s" % memory_id.replace("_", " ")

		var npc: Dictionary = DataManager.get_npc(npc_id)

		return "Memoria emocional de %s: %s" % [
			npc.get("name", npc_id),
			memory_id.replace("_", " ")
		]

	if collectible_id.begins_with("union_token:") and parts.size() >= 3:
		var npc_id: String = parts[1]
		var token_id: String = parts[2]
		var npc: Dictionary = DataManager.get_npc(npc_id)

		return "Prueba de unión de %s: %s" % [
			npc.get("name", npc_id),
			token_id.replace("_", " ")
		]
	
	return collectible_id

func get_gender_identity() -> String:
	return str(player.get("gender_identity", "man"))


func get_gender_identity_label() -> String:
	match get_gender_identity():
		"man":
			return "Hombre"
		"woman":
			return "Mujer"
		"non_binary":
			return "No binario"
		_:
			return "Hombre"


func get_romantic_compatibility(npc_id: String) -> Dictionary:
	var profile: Dictionary = DataManager.get_npc_story_profile(npc_id)

	if profile.is_empty():
		return {
			"level": "neutral",
			"modifier": 0,
			"description": "No hay perfil narrativo definido."
		}

	if not bool(profile.get("romanceable", true)):
		return {
			"level": "not_romanceable",
			"modifier": -50,
			"description": "Este personaje no está disponible como ruta romántica."
		}

	var gender_identity: String = get_gender_identity()
	var preferred: Array = profile.get("preferred_genders", [])
	var open: Array = profile.get("open_genders", [])
	var strength: int = int(profile.get("preference_strength", 0))

	if preferred.has(gender_identity):
		return {
			"level": "preferred",
			"modifier": strength,
			"description": "La atracción inicial fluye con naturalidad."
		}

	if open.has(gender_identity):
		return {
			"level": "open",
			"modifier": 0,
			"description": "No hay una inclinación inicial clara, pero tampoco una resistencia importante."
		}

	return {
		"level": "unexpected",
		"modifier": -strength,
		"description": "La atracción inicial no encaja con sus preferencias habituales, pero el vínculo puede cambiar lo que las etiquetas no alcanzan a explicar."
	}

func get_tension_gain_modifier(npc_id: String) -> float:
	var compatibility: Dictionary = get_romantic_compatibility(npc_id)
	var modifier: int = int(compatibility.get("modifier", 0))

	if modifier == 0:
		return 1.0

	GameManager.ensure_relationship(npc_id)

	var friendship: int = get_relationship_value(npc_id, "friendship")
	var loyalty: int = get_relationship_value(npc_id, "loyalty")
	var total: int = get_total_affinity(npc_id)

	var relationship_softening: int = int((friendship * 0.25) + (loyalty * 0.35) + (total * 0.2))
	var adjusted_modifier: int = modifier

	if modifier < 0:
		adjusted_modifier = min(0, modifier + relationship_softening)

	return clamp(1.0 + (float(adjusted_modifier) / 100.0), 0.75, 1.25)

func get_romantic_move_modifier(npc_id: String) -> int:
	var compatibility: Dictionary = get_romantic_compatibility(npc_id)
	var modifier: int = int(compatibility.get("modifier", 0))

	if modifier >= 0:
		return int(round(float(modifier) * 0.4))

	var friendship: int = get_relationship_value(npc_id, "friendship")
	var loyalty: int = get_relationship_value(npc_id, "loyalty")
	var softened: int = min(0, modifier + int((friendship * 0.2) + (loyalty * 0.3)))

	return int(round(float(softened) * 0.4))

func is_npc_romanceable(npc_id: String) -> bool:
	var profile: Dictionary = DataManager.get_npc_story_profile(npc_id)

	if profile.is_empty():
		var npc: Dictionary = DataManager.get_npc(npc_id)
		return bool(npc.get("romanceable", true))

	return bool(profile.get("romanceable", true))

func get_info_category_title(category_id: String) -> String:
	var section: Dictionary = DataManager.npc_info_schema.get(category_id, {})
	return str(section.get("title", category_id))


func get_info_keys_for_category(category_id: String) -> Array:
	var section: Dictionary = DataManager.npc_info_schema.get(category_id, {})
	var keys: Dictionary = section.get("keys", {})
	var result: Array = []

	for key in keys.keys():
		result.append(str(key))

	return result


func get_info_category_id_for_key(info_key: String) -> String:
	for section_id in DataManager.npc_info_schema.keys():
		var section: Dictionary = DataManager.npc_info_schema[section_id]
		var keys: Dictionary = section.get("keys", {})

		if keys.has(info_key):
			return str(section_id)

	return ""


func get_info_category_title_for_key(info_key: String) -> String:
	var category_id: String = get_info_category_id_for_key(info_key)

	if category_id == "":
		return "Información"

	return get_info_category_title(category_id)


func get_known_info_count_for_category(npc_id: String, category_id: String) -> int:
	GameManager.ensure_npc_knowledge(npc_id)

	var known_info: Array = player["known_npc_info"][npc_id].get("info", [])
	var category_keys: Array = get_info_keys_for_category(category_id)
	var count: int = 0

	for info_key in known_info:
		if category_keys.has(str(info_key)):
			count += 1

	return count
