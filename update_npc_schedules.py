import json
from pathlib import Path

path = Path("data/npc_story_profiles.json")

with path.open("r", encoding="utf-8") as f:
    profiles = json.load(f)

preferences = {
    "lyria": {
        "loves": ["subtle", "gentle", "slow_tension", "intellectual", "respectful"],
        "likes": ["romantic", "private", "verbal", "emotional"],
        "dislikes": ["public", "bold", "risky", "playful"],
        "hates": ["exhibitionist", "crude", "forceful", "sexual"]
    },
    "aeris": {
        "loves": ["gentle", "emotional", "respectful", "slow_tension"],
        "likes": ["romantic", "private", "vulnerable", "verbal"],
        "dislikes": ["bold", "public", "risky"],
        "hates": ["forceful", "possessive"]
    },
    "eryon": {
        "loves": ["verbal", "teasing", "flirty", "slow_tension"],
        "likes": ["bold", "playful", "private", "romantic"],
        "dislikes": ["possessive", "simple", "gentle"],
        "hates": ["forceful"]
    },
    "rhea": {
        "loves": ["physical", "bold", "clear", "playful"],
        "likes": ["romantic", "private", "teasing", "direct"],
        "dislikes": ["overly_formal", "passive", "subtle"],
        "hates": ["humiliation", "manipulative"]
    },
    "nova": {
        "loves": ["playful", "teasing", "bold", "risky"],
        "likes": ["flirty", "clever", "physical", "private"],
        "dislikes": ["traditional", "possessive", "gentle"],
        "hates": ["controlling", "forceful"]
    },
    "seraphine": {
        "loves": ["gentle", "respectful", "emotional", "slow_tension"],
        "likes": ["romantic", "private", "vulnerable"],
        "dislikes": ["public", "bold", "teasing", "sexual"],
        "hates": ["crude", "mocking_faith", "forceful", "exhibitionist"]
    },
    "kael": {
        "loves": ["quiet", "physical", "gentle", "clear"],
        "likes": ["private", "romantic", "slow_tension"],
        "dislikes": ["public", "verbal", "teasing"],
        "hates": ["performative", "forceful"]
    },
    "myr": {
        "loves": ["playful", "sensual", "curious", "private"],
        "likes": ["flirty", "bold", "gentle", "risky"],
        "dislikes": ["possessive", "traditional"],
        "hates": ["controlling", "objectifying"]
    },
    "axiom": {
        "loves": ["gentle", "curious", "emotional", "respectful"],
        "likes": ["private", "romantic", "vulnerable"],
        "dislikes": ["sexual", "public", "teasing"],
        "hates": ["possessive", "objectifying"]
    },
    "taren": {
        "loves": ["respectful", "mature", "private", "clear"],
        "likes": ["romantic", "slow_tension", "verbal"],
        "dislikes": ["public", "playful", "risky"],
        "hates": ["humiliation", "irresponsible"]
    },
    "rhein": {
        "loves": ["gentle", "slow_tension", "natural", "respectful"],
        "likes": ["physical", "private", "romantic"],
        "dislikes": ["public", "rushed", "bold"],
        "hates": ["disrespectful", "forceful"]
    },
    "selene": {
        "loves": ["subtle", "respectful", "private", "verbal"],
        "likes": ["romantic", "slow_tension", "clear"],
        "dislikes": ["public", "bold", "risky"],
        "hates": ["politically_reckless", "forceful"]
    },
    "elara": {
        "loves": ["flirty", "playful", "public", "teasing"],
        "likes": ["bold", "physical", "romantic", "sexual"],
        "dislikes": ["ashamed", "cold"],
        "hates": ["using_her", "humiliation"]
    }
}

for npc_id, prefs in preferences.items():
    if npc_id not in profiles:
        print(f"ADVERTENCIA: perfil no encontrado: {npc_id}")
        continue

    profiles[npc_id]["date_move_preferences"] = prefs

with path.open("w", encoding="utf-8") as f:
    json.dump(profiles, f, ensure_ascii=False, indent="\t")

print("npc_story_profiles.json actualizado con preferencias de movimientos.")