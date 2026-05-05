extends Node


func is_postgame_started() -> bool:
	return GameManager.has_world_flag("postgame_started")


func get_partner_id() -> String:
	return str(GameManager.player.get("final_union_npc_id", ""))


func start_postgame(partner_id: String) -> Array:
	var messages: Array = []

	if partner_id == "":
		return messages

	if is_postgame_started():
		return messages

	GameManager.add_world_flag("postgame_started")
	GameManager.add_world_flag("postgame_day_started")
	GameManager.add_world_flag("postgame_partner:%s" % partner_id)

	GameManager.ensure_world_state()
	ensure_postgame_state()

	var config: Dictionary = DataManager.get_postgame_partner_config(partner_id)

	set_postgame_state_value(
		"final_union_stability",
		int(config.get("starting_final_union_stability", 70))
	)
	set_postgame_state_value(
		"postgame_pressure",
		int(config.get("starting_postgame_pressure", 10))
	)
	set_postgame_state_value(
		"outside_temptation",
		int(config.get("starting_outside_temptation", 5))
	)

	for key in config.get("world_state_on_start", {}).keys():
		GameManager.add_world_state_value(str(key), int(config["world_state_on_start"][key]))

	for flag in config.get("add_world_flags_on_start", []):
		GameManager.add_world_flag(str(flag))

	messages.append(build_postgame_start_text(partner_id, config))

	var reaction_text: String = process_immediate_reactions(partner_id)

	if reaction_text != "":
		messages.append(reaction_text)

	return messages


func build_postgame_start_text(partner_id: String, config: Dictionary) -> String:
	var npc: Dictionary = DataManager.get_npc(partner_id)

	var text: String = "Postgame iniciado: %s\n\n" % config.get("postgame_title", "Unión definitiva")
	text += "La elección de %s no detiene el mundo.\n\n" % npc.get("name", partner_id)
	text += "%s" % config.get(
		"pressure_theme",
		"La unión definitiva empieza a tener consecuencias visibles."
	)

	return text


func ensure_postgame_state() -> void:
	if not GameManager.player.has("postgame_state"):
		GameManager.player["postgame_state"] = {}

	var state: Dictionary = GameManager.player["postgame_state"]

	if not state.has("final_union_stability"):
		state["final_union_stability"] = 70

	if not state.has("postgame_pressure"):
		state["postgame_pressure"] = 0

	if not state.has("outside_temptation"):
		state["outside_temptation"] = 0

	if not state.has("days_since_postgame_started"):
		state["days_since_postgame_started"] = 0

	if not state.has("last_storylet_days"):
		state["last_storylet_days"] = {}


func get_postgame_state_value(key: String) -> int:
	ensure_postgame_state()
	return int(GameManager.player["postgame_state"].get(key, 0))


func set_postgame_state_value(key: String, value: int) -> void:
	ensure_postgame_state()
	GameManager.player["postgame_state"][key] = clamp(value, 0, 100)


func add_postgame_state_value(key: String, amount: int) -> void:
	set_postgame_state_value(key, get_postgame_state_value(key) + amount)


func process_immediate_reactions(partner_id: String) -> String:
	var text: String = ""
	var affected_count: int = 0

	for npc_id in DataManager.npcs.keys():
		if npc_id == partner_id:
			continue

		if not GameManager.is_npc_romanceable(npc_id):
			continue

		GameManager.ensure_relationship(npc_id)
		var relation: Dictionary = GameManager.player["relationships"][npc_id]
		var state: String = str(relation.get("relationship_state", "none"))
		var total: int = GameManager.get_total_affinity(npc_id)
		var jealousy: int = int(relation.get("jealousy", 0))
		var tension: int = int(relation.get("tension", 0))
		var loyalty: int = int(relation.get("loyalty", 0))

		var npc: Dictionary = DataManager.get_npc(npc_id)
		var npc_name: String = npc.get("name", npc_id)

		var line: String = ""

		if state in ["dating", "lovers", "partner"]:
			GameManager.add_relationship_value(npc_id, "jealousy", 12)
			add_postgame_state_value("postgame_pressure", 4)
			add_postgame_state_value("outside_temptation", 3)
			line = "- %s recibe la noticia como una herida que intenta convertir en dignidad." % npc_name
		elif jealousy >= 50 or tension >= 60:
			GameManager.add_relationship_value(npc_id, "jealousy", 8)
			add_postgame_state_value("outside_temptation", 2)
			line = "- %s no dice nada directo, pero la forma de mirar cambia." % npc_name
		elif loyalty >= 45 or total >= 60:
			GameManager.add_relationship_value(npc_id, "loyalty", 2)
			GameManager.add_relationship_value(npc_id, "jealousy", 3)
			line = "- %s acepta tu elección, aunque aceptarla no significa que no duela." % npc_name

		if line != "":
			text += "%s\n" % line
			affected_count += 1
			GameManager.add_npc_note(npc_id, "Reaccionó a la unión definitiva del Forastero.")

	if affected_count == 0:
		return ""

	return "Reacciones a la unión definitiva:\n%s" % text.strip_edges()


func process_daily_postgame() -> Array:
	var messages: Array = []

	if not is_postgame_started():
		return messages

	ensure_postgame_state()

	GameManager.player["postgame_state"]["days_since_postgame_started"] = int(
		GameManager.player["postgame_state"].get("days_since_postgame_started", 0)
	) + 1

	var partner_id: String = get_partner_id()
	var config: Dictionary = DataManager.get_postgame_partner_config(partner_id)

	add_postgame_state_value(
		"postgame_pressure",
		int(config.get("daily_postgame_pressure_gain", 1))
	)
	add_postgame_state_value(
		"outside_temptation",
		int(config.get("daily_outside_temptation_gain", 1))
	)

	apply_daily_pressure_effects(config)
	apply_relationship_pressure_from_other_routes(partner_id, config)

	var storylet_messages: Array = process_postgame_storylets()

	for message in storylet_messages:
		messages.append(message)

	return messages


func apply_daily_pressure_effects(config: Dictionary) -> void:
	var pressure_rule: Dictionary = config.get("daily_stability_loss_from_pressure", {})
	var pressure_min: int = int(pressure_rule.get("pressure_min", 60))
	var pressure_loss: int = int(pressure_rule.get("loss", 2))

	if get_postgame_state_value("postgame_pressure") >= pressure_min:
		add_postgame_state_value("final_union_stability", -pressure_loss)

	var temptation_rule: Dictionary = config.get("daily_stability_loss_from_temptation", {})
	var temptation_min: int = int(temptation_rule.get("temptation_min", 60))
	var temptation_loss: int = int(temptation_rule.get("loss", 2))

	if get_postgame_state_value("outside_temptation") >= temptation_min:
		add_postgame_state_value("final_union_stability", -temptation_loss)


func apply_relationship_pressure_from_other_routes(partner_id: String, config: Dictionary) -> void:
	var high_jealousy_threshold: int = int(config.get("high_jealousy_threshold", 45))
	var very_high_jealousy_threshold: int = int(config.get("very_high_jealousy_threshold", 70))
	var jealousy_pressure_gain: int = int(config.get("jealousy_pressure_gain", 2))
	var advanced_route_pressure_gain: int = int(config.get("advanced_route_pressure_gain", 3))
	var advanced_states: Array = config.get("advanced_route_states", ["dating", "lovers", "partner"])

	for npc_id in DataManager.npcs.keys():
		if npc_id == partner_id:
			continue

		if not GameManager.is_npc_romanceable(npc_id):
			continue

		GameManager.ensure_relationship(npc_id)

		var relation: Dictionary = GameManager.player["relationships"][npc_id]
		var jealousy: int = int(relation.get("jealousy", 0))
		var state: String = str(relation.get("relationship_state", "none"))

		if jealousy >= very_high_jealousy_threshold:
			add_postgame_state_value("outside_temptation", jealousy_pressure_gain + 2)
			add_postgame_state_value("postgame_pressure", jealousy_pressure_gain + 1)
		elif jealousy >= high_jealousy_threshold:
			add_postgame_state_value("outside_temptation", jealousy_pressure_gain)

		if advanced_states.has(state):
			add_postgame_state_value("postgame_pressure", advanced_route_pressure_gain)


func process_postgame_storylets() -> Array:
	var available: Array = []

	for storylet_id in DataManager.postgame_storylets.keys():
		var storylet: Dictionary = DataManager.get_postgame_storylet(storylet_id)

		if is_postgame_storylet_available(str(storylet_id), storylet):
			available.append({
				"id": str(storylet_id),
				"storylet": storylet
			})

	if available.is_empty():
		return []

	available.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a["storylet"].get("priority", 0)) > int(b["storylet"].get("priority", 0))
	)

	var selected: Dictionary = available[0]
	var selected_id: String = selected["id"]
	var selected_storylet: Dictionary = selected["storylet"]

	var text: String = complete_postgame_storylet(selected_id, selected_storylet)

	if text == "":
		return []

	return [text]


func is_postgame_storylet_available(storylet_id: String, storylet: Dictionary) -> bool:
	var partner_id: String = str(storylet.get("partner_id", ""))

	if partner_id != "" and partner_id != get_partner_id():
		return false

	if not bool(storylet.get("repeatable", false)):
		if GameManager.has_world_flag("postgame_storylet_completed:%s" % storylet_id):
			return false

	var cooldown_days: int = int(storylet.get("cooldown_days", 0))

	if cooldown_days > 0 and not is_postgame_storylet_cooldown_ready(storylet_id, cooldown_days):
		return false

	var conditions: Dictionary = storylet.get("conditions", {})

	if not check_world_flag_conditions(conditions.get("world_flags", {})):
		return false

	if not check_world_state_conditions(conditions.get("world_state", {})):
		return false

	if not check_postgame_state_conditions(conditions.get("postgame_state", {})):
		return false

	return true


func is_postgame_storylet_cooldown_ready(storylet_id: String, cooldown_days: int) -> bool:
	ensure_postgame_state()

	var last_days: Dictionary = GameManager.player["postgame_state"].get("last_storylet_days", {})
	var current_day_count: int = int(GameManager.player["postgame_state"].get("days_since_postgame_started", 0))

	if not last_days.has(storylet_id):
		return true

	return current_day_count - int(last_days[storylet_id]) >= cooldown_days


func check_world_flag_conditions(flags: Dictionary) -> bool:
	for flag in flags.get("has_all", []):
		if not GameManager.has_world_flag(str(flag)):
			return false

	for flag in flags.get("missing_all", []):
		if GameManager.has_world_flag(str(flag)):
			return false

	return true


func check_world_state_conditions(conditions: Dictionary) -> bool:
	for key in conditions.keys():
		var rule: Dictionary = conditions[key]
		var value: int = GameManager.get_world_state_value(str(key))

		if rule.has("min") and value < int(rule["min"]):
			return false

		if rule.has("max") and value > int(rule["max"]):
			return false

	return true


func check_postgame_state_conditions(conditions: Dictionary) -> bool:
	for key in conditions.keys():
		var rule: Dictionary = conditions[key]
		var value: int = get_postgame_state_value(str(key))

		if rule.has("min") and value < int(rule["min"]):
			return false

		if rule.has("max") and value > int(rule["max"]):
			return false

	return true


func complete_postgame_storylet(storylet_id: String, storylet: Dictionary) -> String:
	if not bool(storylet.get("repeatable", false)):
		GameManager.add_world_flag("postgame_storylet_completed:%s" % storylet_id)

	if int(storylet.get("cooldown_days", 0)) > 0:
		ensure_postgame_state()
		GameManager.player["postgame_state"]["last_storylet_days"][storylet_id] = int(
			GameManager.player["postgame_state"].get("days_since_postgame_started", 0)
		)

	var effects: Dictionary = storylet.get("effects", {})

	for flag in effects.get("add_world_flags", []):
		GameManager.add_world_flag(str(flag))

	for key in effects.get("world_state", {}).keys():
		GameManager.add_world_state_value(str(key), int(effects["world_state"][key]))

	for key in effects.get("postgame_state", {}).keys():
		add_postgame_state_value(str(key), int(effects["postgame_state"][key]))

	for collectible_id in effects.get("collectibles", []):
		GameManager.add_collectible(str(collectible_id))

	return str(storylet.get("text", ""))


func strengthen_final_union(amount: int, reason: String = "") -> String:
	if not is_postgame_started():
		return ""

	add_postgame_state_value("final_union_stability", amount)
	add_postgame_state_value("postgame_pressure", -max(1, int(amount / 2)))

	if reason == "":
		return ""

	return "%s Estabilidad de unión +%s" % [reason, amount]


func strain_final_union(amount: int, reason: String = "") -> String:
	if not is_postgame_started():
		return ""

	add_postgame_state_value("final_union_stability", -amount)
	add_postgame_state_value("postgame_pressure", max(1, int(amount / 2)))

	if reason == "":
		return ""

	return "%s Estabilidad de unión -%s" % [reason, amount]


func get_postgame_status_text() -> String:
	if not is_postgame_started():
		return "El postgame todavía no ha comenzado."

	var partner_id: String = get_partner_id()
	var partner: Dictionary = DataManager.get_npc(partner_id)
	var config: Dictionary = DataManager.get_postgame_partner_config(partner_id)

	var stability: int = get_postgame_state_value("final_union_stability")
	var pressure: int = get_postgame_state_value("postgame_pressure")
	var temptation: int = get_postgame_state_value("outside_temptation")

	var text: String = ""
	text += "Etapa postgame activa\n"
	text += "Unión definitiva: %s\n" % partner.get("name", partner_id)
	text += "Ruta postgame: %s\n" % config.get("postgame_title", "Unión final")
	text += "%s: %s · %s\n" % [
		config.get("stability_label", "Estabilidad de unión"),
		stability,
		get_postgame_level_label(stability)
	]
	text += "Presión postgame: %s · %s\n" % [
		pressure,
		get_postgame_level_label(pressure)
	]
	text += "Tentación externa: %s · %s\n" % [
		temptation,
		get_postgame_level_label(temptation)
	]

	return text


func get_postgame_level_label(value: int) -> String:
	if value >= 80:
		return "muy alto"
	if value >= 60:
		return "alto"
	if value >= 35:
		return "medio"
	if value >= 15:
		return "leve"

	return "bajo"
