import json
from pathlib import Path

path = Path("data/npcs.json")

with path.open("r", encoding="utf-8") as f:
    npcs = json.load(f)

schedules = {
    "lyria": {
        "default": {
            "morning": "library",
            "afternoon": "library",
            "night": "private_study"
        },
        "saturday": {
            "morning": "archives",
            "afternoon": "library",
            "night": "private_study"
        },
        "sunday": {
            "morning": "private_study",
            "afternoon": "plaza",
            "night": ""
        },
        "conditions": [
            {
                "conditions": {
                    "relationship": {
                        "npc_id": "lyria",
                        "state": "dating"
                    }
                },
                "night": "library"
            }
        ]
    },
    "aeris": {
        "default": {
            "morning": "observatory",
            "afternoon": "arcane_library",
            "night": "private_study"
        },
        "saturday": {
            "morning": "observatory",
            "afternoon": "library",
            "night": "observatory"
        },
        "sunday": {
            "morning": "",
            "afternoon": "observatory",
            "night": "observatory"
        },
        "conditions": [
            {
                "conditions": {
                    "world_flags": {
                        "has_all": ["aeris_suspects_anchor"]
                    }
                },
                "night": "observatory"
            }
        ]
    },
    "eryon": {
        "default": {
            "morning": "archives",
            "afternoon": "plaza",
            "night": "private_study"
        },
        "saturday": {
            "morning": "archives",
            "afternoon": "tavern",
            "night": "plaza"
        },
        "sunday": {
            "morning": "",
            "afternoon": "archives",
            "night": "tavern"
        },
        "conditions": [
            {
                "conditions": {
                    "relationship": {
                        "npc_id": "eryon",
                        "state": "dating"
                    }
                },
                "night": "private_study"
            }
        ]
    },
    "rhea": {
        "default": {
            "morning": "guild",
            "afternoon": "market",
            "night": "tavern"
        },
        "saturday": {
            "morning": "guild",
            "afternoon": "forest",
            "night": "tavern"
        },
        "sunday": {
            "morning": "",
            "afternoon": "plaza",
            "night": "tavern"
        },
        "conditions": [
            {
                "conditions": {
                    "world_flags": {
                        "has_all": ["village_security_weakened"]
                    }
                },
                "morning": "guild",
                "afternoon": "guild",
                "night": "guild"
            }
        ]
    },
    "nova": {
        "default": {
            "morning": "workshop",
            "afternoon": "workshop",
            "night": "plaza"
        },
        "saturday": {
            "morning": "workshop",
            "afternoon": "market",
            "night": "tavern"
        },
        "sunday": {
            "morning": "",
            "afternoon": "workshop",
            "night": "plaza"
        },
        "conditions": [
            {
                "conditions": {
                    "world_flags": {
                        "has_all": ["unstable_prototype_awakened"]
                    }
                },
                "night": "workshop"
            }
        ]
    },
    "seraphine": {
        "default": {
            "morning": "sanctuary",
            "afternoon": "sanctuary",
            "night": "library"
        },
        "saturday": {
            "morning": "sanctuary",
            "afternoon": "plaza",
            "night": "sanctuary"
        },
        "sunday": {
            "morning": "sanctuary",
            "afternoon": "sanctuary",
            "night": ""
        },
        "conditions": [
            {
                "conditions": {
                    "relationship": {
                        "npc_id": "seraphine",
                        "state": "lovers"
                    }
                },
                "night": "library"
            }
        ]
    },
    "kael": {
        "default": {
            "morning": "guild",
            "afternoon": "forest",
            "night": "tavern"
        },
        "saturday": {
            "morning": "forest",
            "afternoon": "guild",
            "night": "tavern"
        },
        "sunday": {
            "morning": "forest",
            "afternoon": "",
            "night": "tavern"
        },
        "conditions": [
            {
                "conditions": {
                    "relationship": {
                        "npc_id": "kael",
                        "state": "dating"
                    }
                },
                "night": "forest"
            }
        ]
    },
    "myr": {
        "default": {
            "morning": "workshop",
            "afternoon": "plaza",
            "night": "threshold"
        },
        "saturday": {
            "morning": "market",
            "afternoon": "workshop",
            "night": "threshold"
        },
        "sunday": {
            "morning": "",
            "afternoon": "forest",
            "night": "threshold"
        },
        "conditions": [
            {
                "conditions": {
                    "relationship": {
                        "npc_id": "myr",
                        "state": "lovers"
                    }
                },
                "night": "workshop"
            }
        ]
    },
    "axiom": {
        "default": {
            "morning": "threshold",
            "afternoon": "observatory",
            "night": "threshold"
        },
        "saturday": {
            "morning": "threshold",
            "afternoon": "",
            "night": "threshold"
        },
        "sunday": {
            "morning": "",
            "afternoon": "threshold",
            "night": "threshold"
        },
        "conditions": [
            {
                "conditions": {
                    "relationship": {
                        "npc_id": "axiom",
                        "state": "partner"
                    }
                },
                "afternoon": "threshold",
                "night": "threshold"
            }
        ]
    },
    "taren": {
        "default": {
            "morning": "guild",
            "afternoon": "council_hall",
            "night": "tavern"
        },
        "saturday": {
            "morning": "guild",
            "afternoon": "guild",
            "night": ""
        },
        "sunday": {
            "morning": "",
            "afternoon": "council_hall",
            "night": "tavern"
        },
        "conditions": [
            {
                "conditions": {
                    "world_flags": {
                        "has_all": ["guild_order_weakened"]
                    }
                },
                "morning": "guild",
                "afternoon": "guild"
            }
        ]
    },
    "rhein": {
        "default": {
            "morning": "forest",
            "afternoon": "forest",
            "night": "sanctuary"
        },
        "saturday": {
            "morning": "forest",
            "afternoon": "plaza",
            "night": "forest"
        },
        "sunday": {
            "morning": "forest",
            "afternoon": "",
            "night": "threshold"
        },
        "conditions": [
            {
                "conditions": {
                    "world_state": {
                        "world_instability": {
                            "min": 20
                        }
                    }
                },
                "night": "forest"
            }
        ]
    },
    "selene": {
        "default": {
            "morning": "council_hall",
            "afternoon": "plaza",
            "night": "library"
        },
        "saturday": {
            "morning": "council_hall",
            "afternoon": "market",
            "night": ""
        },
        "sunday": {
            "morning": "",
            "afternoon": "sanctuary",
            "night": "council_hall"
        },
        "conditions": [
            {
                "conditions": {
                    "world_flags": {
                        "has_all": ["council_is_watching"]
                    }
                },
                "afternoon": "council_hall",
                "night": "council_hall"
            }
        ]
    },
    "elara": {
        "default": {
            "morning": "market",
            "afternoon": "plaza",
            "night": "tavern"
        },
        "saturday": {
            "morning": "market",
            "afternoon": "tavern",
            "night": "tavern"
        },
        "sunday": {
            "morning": "",
            "afternoon": "plaza",
            "night": "tavern"
        },
        "conditions": [
            {
                "conditions": {
                    "world_state": {
                        "romantic_pressure": {
                            "min": 20
                        }
                    }
                },
                "afternoon": "plaza",
                "night": "tavern"
            }
        ]
    }
}

missing = []

for npc_id, schedule in schedules.items():
    if npc_id not in npcs:
        missing.append(npc_id)
        continue

    npcs[npc_id]["schedule"] = schedule

with path.open("w", encoding="utf-8") as f:
    json.dump(npcs, f, ensure_ascii=False, indent="\t")

if missing:
    print("NPCs no encontrados:", ", ".join(missing))
else:
    print("npcs.json actualizado correctamente.")