Isekai Novel — Inventario inicial de arte
Reglas del inventario
Usar rutas finales desde el inicio.
No usar nombres genéricos como npc1.png, bg_test.png, placeholder_final.png.
Respetar mayúsculas/minúsculas exactas.
Si el asset ya está llamado por código o JSON, no cambiar la ruta salvo decisión explícita.
Las capturas tipo ejemplo.png, tienda1.png, etc. son referencia temporal, no assets finales.
Primero producir por bloques: Title Screen → Intro/Onboarding → Mapa/Ubicaciones → NPCs → Items/UI polish.
Prioridad 1 — Title Screen
Tipo	Asset	Uso	Archivo que lo usa	Estado
Background	assets/backgrounds/title_luminaria_threshold.png	Fondo principal de pantalla de título. Debe vender fantasía isekai, romance, misterio y entrada al Velo.	scenes/menu/main_menu.gd	En código
UI / Logo	assets/ui/title_logo_isekai_novel.png	Logo gráfico principal para sustituir el texto actual del panel de título.	Pendiente de integrar en scenes/menu/main_menu.gd	Propuesto

Dirección visual: esta pantalla debe sentirse como portada del juego, no menú administrativo. El fondo debe dejar espacio limpio para logo y botones.

Prioridad 2 — Intro / Onboarding: fondos base
Tipo	Asset	Uso	Archivo que lo usa	Estado
Background	assets/backgrounds/intro_veil_crossing.png	Prólogo / cruce del Velo.	scenes/intro/intro_scene.gd	En código
Background	assets/backgrounds/intro_appearance_selection.png	Selección de apariencia. Debe permitir tres tarjetas legibles encima.	scenes/intro/intro_scene.gd	En código
Background	assets/backgrounds/intro_class_selection.png	Selección de clase/camino. Debe permitir seis tarjetas verticales encima.	scenes/intro/intro_scene.gd	En código
Prioridad 2B — Intro / Onboarding: fondos de confirmación

Estos assets sí están esperados por código mediante patrón dinámico:

assets/backgrounds/intro_confirm_outsider_<appearance>_<class>.png

Las apariencias normalizadas son:

male
female
veiled

Las clases normalizadas esperadas son:

sensitive
bold
scholar
charming
steadfast
balanced
Tipo	Asset	Uso	Archivo que lo usa	Estado
Background	assets/backgrounds/intro_confirm_outsider_male_sensitive.png	Confirmación: Forastero Sensible.	scenes/intro/intro_scene.gd	En código dinámico
Background	assets/backgrounds/intro_confirm_outsider_male_bold.png	Confirmación: Forastero Audaz.	scenes/intro/intro_scene.gd	En código dinámico
Background	assets/backgrounds/intro_confirm_outsider_male_scholar.png	Confirmación: Forastero Erudito.	scenes/intro/intro_scene.gd	En código dinámico
Background	assets/backgrounds/intro_confirm_outsider_male_charming.png	Confirmación: Forastero Encantador.	scenes/intro/intro_scene.gd	En código dinámico
Background	assets/backgrounds/intro_confirm_outsider_male_steadfast.png	Confirmación: Forastero Firme / Disciplinado.	scenes/intro/intro_scene.gd	En código dinámico
Background	assets/backgrounds/intro_confirm_outsider_male_balanced.png	Confirmación: Forastero Equilibrado.	scenes/intro/intro_scene.gd	En código dinámico
Background	assets/backgrounds/intro_confirm_outsider_female_sensitive.png	Confirmación: Forastera Sensible.	scenes/intro/intro_scene.gd	En código dinámico
Background	assets/backgrounds/intro_confirm_outsider_female_bold.png	Confirmación: Forastera Audaz.	scenes/intro/intro_scene.gd	En código dinámico
Background	assets/backgrounds/intro_confirm_outsider_female_scholar.png	Confirmación: Forastera Erudita.	scenes/intro/intro_scene.gd	En código dinámico
Background	assets/backgrounds/intro_confirm_outsider_female_charming.png	Confirmación: Forastera Encantadora.	scenes/intro/intro_scene.gd	En código dinámico
Background	assets/backgrounds/intro_confirm_outsider_female_steadfast.png	Confirmación: Forastera Firme / Disciplinada.	scenes/intro/intro_scene.gd	En código dinámico
Background	assets/backgrounds/intro_confirm_outsider_female_balanced.png	Confirmación: Forastera Equilibrada.	scenes/intro/intro_scene.gd	En código dinámico
Background	assets/backgrounds/intro_confirm_outsider_veiled_sensitive.png	Confirmación: Forma velada Sensible.	scenes/intro/intro_scene.gd	En código dinámico
Background	assets/backgrounds/intro_confirm_outsider_veiled_bold.png	Confirmación: Forma velada Audaz.	scenes/intro/intro_scene.gd	En código dinámico
Background	assets/backgrounds/intro_confirm_outsider_veiled_scholar.png	Confirmación: Forma velada Erudita.	scenes/intro/intro_scene.gd	En código dinámico
Background	assets/backgrounds/intro_confirm_outsider_veiled_charming.png	Confirmación: Forma velada Encantadora.	scenes/intro/intro_scene.gd	En código dinámico
Background	assets/backgrounds/intro_confirm_outsider_veiled_steadfast.png	Confirmación: Forma velada Firme / Disciplinada.	scenes/intro/intro_scene.gd	En código dinámico
Background	assets/backgrounds/intro_confirm_outsider_veiled_balanced.png	Confirmación: Forma velada Equilibrada.	scenes/intro/intro_scene.gd	En código dinámico

Decisión importante: hacer 18 fondos puede quedar precioso, pero es caro. Si queremos hacerlo bien a la primera, yo no produciría estos 18 todavía hasta cerrar si el look final será “fondo por combinación” o “fondo genérico + sprite del Forastero”. El código hoy soporta los 18.

Prioridad 3 — Player / Apariencia base

El código muestra estos nombres en tarjetas, pero actualmente solo como texto. Para que sean assets reales integrables, la ruta recomendada es:

assets/player/<asset>
Tipo	Asset	Uso	Archivo relacionado	Estado
Player sprite / card	assets/player/outsider_male_base.png	Tarjeta visual base de Forastero.	scenes/intro/intro_scene.gd	Nombre en código, ruta aún por integrar visualmente
Player sprite / card	assets/player/outsider_female_base.png	Tarjeta visual base de Forastera.	scenes/intro/intro_scene.gd	Nombre en código, ruta aún por integrar visualmente
Player sprite / card	assets/player/outsider_veiled_base.png	Tarjeta visual base de Forma velada.	scenes/intro/intro_scene.gd	Nombre en código, ruta aún por integrar visualmente

Dirección visual: cuerpo completo o casi completo, formato vertical. La Forma velada debe sentirse como identidad fantástica del Velo, no como etiqueta social moderna.

Prioridad 4 — Player / Clases del Forastero

El código genera estos nombres dinámicamente:

outsider_<appearance>_<class>.png

Ruta recomendada para assets:

assets/player/
Forastero masculino
Tipo	Asset	Uso	Estado
Player sprite / card	assets/player/outsider_male_sensitive.png	Clase Sensible.	Nombre esperado por código
Player sprite / card	assets/player/outsider_male_bold.png	Clase Audaz.	Nombre esperado por código
Player sprite / card	assets/player/outsider_male_scholar.png	Clase Erudito.	Nombre esperado por código
Player sprite / card	assets/player/outsider_male_charming.png	Clase Encantador.	Nombre esperado por código
Player sprite / card	assets/player/outsider_male_steadfast.png	Clase Firme / Disciplinado.	Nombre esperado por código
Player sprite / card	assets/player/outsider_male_balanced.png	Clase Equilibrado.	Nombre esperado por código
Forastera femenina
Tipo	Asset	Uso	Estado
Player sprite / card	assets/player/outsider_female_sensitive.png	Clase Sensible.	Nombre esperado por código
Player sprite / card	assets/player/outsider_female_bold.png	Clase Audaz.	Nombre esperado por código
Player sprite / card	assets/player/outsider_female_scholar.png	Clase Erudita.	Nombre esperado por código
Player sprite / card	assets/player/outsider_female_charming.png	Clase Encantadora.	Nombre esperado por código
Player sprite / card	assets/player/outsider_female_steadfast.png	Clase Firme / Disciplinada.	Nombre esperado por código
Player sprite / card	assets/player/outsider_female_balanced.png	Clase Equilibrada.	Nombre esperado por código
Forma velada
Tipo	Asset	Uso	Estado
Player sprite / card	assets/player/outsider_veiled_sensitive.png	Clase Sensible.	Nombre esperado por código
Player sprite / card	assets/player/outsider_veiled_bold.png	Clase Audaz.	Nombre esperado por código
Player sprite / card	assets/player/outsider_veiled_scholar.png	Clase Erudita.	Nombre esperado por código
Player sprite / card	assets/player/outsider_veiled_charming.png	Clase Encantadora.	Nombre esperado por código
Player sprite / card	assets/player/outsider_veiled_steadfast.png	Clase Firme / Disciplinada.	Nombre esperado por código
Player sprite / card	assets/player/outsider_veiled_balanced.png	Clase Equilibrada.	Nombre esperado por código

Nota productiva: estos 18 sprites importan más que los 18 fondos de confirmación. Si vamos por impacto visual real, yo haría primero los 3 base y luego los 18 de clase antes de meter fondos de confirmación individuales.

Prioridad 5 — World Map

Referenciado en data/ui_assets.json.

Tipo	Asset	Uso	Archivo que lo usa	Estado
Background	assets/backgrounds/world_map_luminaria.png	Fondo principal del mapa de Luminaria.	data/ui_assets.json / scenes/map/world_map.gd	En datos
Map icon	assets/backgrounds/map_home_forastero.png	Icono de Casa en mapa.	data/ui_assets.json	En datos
Map icon	assets/backgrounds/map_library_alba.png	Icono de Biblioteca.	data/ui_assets.json	En datos
Map icon	assets/backgrounds/map_market_puente_rojo.png	Icono de Mercado.	data/ui_assets.json	En datos
Map icon	assets/backgrounds/map_shop_umbral.png	Icono de Tienda.	data/ui_assets.json	En datos
Map icon	assets/backgrounds/map_observatory_velo.png	Icono de Observatorio.	data/ui_assets.json	En datos
Map icon	assets/backgrounds/map_arcane_library_ateneo.png	Icono de Ateneo / Biblioteca arcana.	data/ui_assets.json	En datos
Map icon	assets/backgrounds/map_private_study.png	Icono de Estudio privado.	data/ui_assets.json	En datos
Map icon	assets/backgrounds/map_archives_velo.png	Icono de Archivos.	data/ui_assets.json	En datos
Map icon	assets/backgrounds/map_plaza_luminaria.png	Icono de Plaza.	data/ui_assets.json	En datos
Map icon	assets/backgrounds/map_guild_alba_roja.png	Icono de Gremio.	data/ui_assets.json	En datos
Map icon	assets/backgrounds/map_tavern_puente_rojo.png	Icono de Taberna.	data/ui_assets.json	En datos
Map icon	assets/backgrounds/map_workshop_arcano.png	Icono de Taller.	data/ui_assets.json	En datos
Map icon	assets/backgrounds/map_sanctuary_velo_quieto.png	Icono de Santuario.	data/ui_assets.json	En datos
Map icon	assets/backgrounds/map_forest_herido.png	Icono de Bosque herido.	data/ui_assets.json	En datos
Map icon	assets/backgrounds/map_council_hall.png	Icono de Consejo.	data/ui_assets.json	En datos
Map icon	assets/backgrounds/map_threshold_umbral.png	Icono de Umbral.	data/ui_assets.json	En datos
Prioridad 6 — Fondos de ubicaciones

Referenciados en data/ui_assets.json.

Tipo	Asset	Uso	Archivo que lo usa	Estado
Background	assets/backgrounds/location_home_forastero.png	Casa del Forastero.	data/ui_assets.json	En datos
Background	assets/backgrounds/location_library_alba.png	Biblioteca / zona de saber.	data/ui_assets.json	En datos
Background	assets/backgrounds/location_market_puente_rojo.png	Mercado.	data/ui_assets.json	En datos
Background	assets/backgrounds/location_shop_umbral.png	Tienda del Umbral.	data/ui_assets.json	En datos
Background	assets/backgrounds/location_observatory_velo.png	Observatorio.	data/ui_assets.json	En datos
Background	assets/backgrounds/location_arcane_library_ateneo.png	Ateneo / biblioteca arcana.	data/ui_assets.json	En datos
Background	assets/backgrounds/location_private_study.png	Estudio privado.	data/ui_assets.json	En datos
Background	assets/backgrounds/location_archives_velo.png	Archivos del Velo.	data/ui_assets.json	En datos
Background	assets/backgrounds/location_plaza_luminaria.png	Plaza de Luminaria.	data/ui_assets.json	En datos
Background	assets/backgrounds/location_guild_alba_roja.png	Gremio.	data/ui_assets.json	En datos
Background	assets/backgrounds/location_tavern_puente_rojo.png	Taberna.	data/ui_assets.json	En datos
Background	assets/backgrounds/location_workshop_arcano.png	Taller arcano.	data/ui_assets.json	En datos
Background	assets/backgrounds/location_sanctuary_velo_quieto.png	Santuario.	data/ui_assets.json	En datos
Background	assets/backgrounds/location_forest_herido.png	Bosque herido.	data/ui_assets.json	En datos
Background	assets/backgrounds/location_council_hall.png	Salón del Consejo.	data/ui_assets.json	En datos
Background	assets/backgrounds/location_threshold_umbral.png	Umbral.	data/ui_assets.json	En datos
Prioridad 7 — NPC portraits y sprites

Referenciados en data/ui_assets.json. Ojo: la ruta real usada actualmente es:

assets/portraits/

No assets/npcs/.

Lyria
Tipo	Asset	Uso	Estado
Portrait	assets/portraits/Lyria_portrait_neutral.png	Retrato neutral.	En datos
Talking sprite	assets/portraits/Lyria_talking.png	Arte de conversación/interacción.	En datos
Location sprite	assets/portraits/Lyria_location_sprite.png	Sprite en localización.	En datos
Aeris
Tipo	Asset	Uso	Estado
Portrait	assets/portraits/Aeris_portrait_neutral.png	Retrato neutral.	En datos
Talking sprite	assets/portraits/Aeris_talking.png	Arte de conversación/interacción.	En datos
Location sprite	assets/portraits/Aeris_location_sprite.png	Sprite en localización.	En datos
Eryon
Tipo	Asset	Uso	Estado
Portrait	assets/portraits/Eryon_portrait_neutral.png	Retrato neutral.	En datos
Talking sprite	assets/portraits/Eryon_talking.png	Arte de conversación/interacción.	En datos
Location sprite	assets/portraits/Eryon_location_sprite.png	Sprite en localización.	En datos
Rhea
Tipo	Asset	Uso	Estado
Portrait	assets/portraits/Rhea_portrait_neutral.png	Retrato neutral.	En datos
Talking sprite	assets/portraits/Rhea_talking.png	Arte de conversación/interacción.	En datos
Location sprite	assets/portraits/Rhea_location_sprite.png	Sprite en localización.	En datos
Nova
Tipo	Asset	Uso	Estado
Portrait	assets/portraits/Nova_portrait_neutral.png	Retrato neutral.	En datos
Talking sprite	assets/portraits/Nova_talking.png	Arte de conversación/interacción.	En datos
Location sprite	assets/portraits/Nova_location_sprite.png	Sprite en localización.	En datos
Seraphine
Tipo	Asset	Uso	Estado
Portrait	assets/portraits/Seraphine_portrait_neutral.png	Retrato neutral.	En datos
Talking sprite	assets/portraits/Seraphine_talking.png	Arte de conversación/interacción.	En datos
Location sprite	assets/portraits/Seraphine_location_sprite.png	Sprite en localización.	En datos
Kael
Tipo	Asset	Uso	Estado
Portrait	assets/portraits/Kael_portrait_neutral.png	Retrato neutral.	En datos
Talking sprite	assets/portraits/Kael_talking.png	Arte de conversación/interacción.	En datos
Location sprite	assets/portraits/Kael_location_sprite.png	Sprite en localización.	En datos
Myr
Tipo	Asset	Uso	Estado
Portrait	assets/portraits/Myr_portrait_neutral.png	Retrato neutral.	En datos
Talking sprite	assets/portraits/Myr_talking.png	Arte de conversación/interacción.	En datos
Location sprite	assets/portraits/Myr_location_sprite.png	Sprite en localización.	En datos
Axiom
Tipo	Asset	Uso	Estado
Portrait	assets/portraits/Axiom_portrait_neutral.png	Retrato neutral.	En datos
Talking sprite	assets/portraits/Axiom_talking.png	Arte de conversación/interacción.	En datos
Location sprite	assets/portraits/Axiom_location_sprite.png	Sprite en localización.	En datos
Taren
Tipo	Asset	Uso	Estado
Portrait	assets/portraits/Taren_portrait_neutral.png	Retrato neutral.	En datos
Talking sprite	assets/portraits/Taren_talking.png	Arte de conversación/interacción.	En datos
Location sprite	assets/portraits/Taren_location_sprite.png	Sprite en localización.	En datos
Rhein
Tipo	Asset	Uso	Estado
Portrait	assets/portraits/Rhein_portrait_neutral.png	Retrato neutral.	En datos
Talking sprite	assets/portraits/Rhein_talking.png	Arte de conversación/interacción.	En datos
Location sprite	assets/portraits/Rhein_location_sprite.png	Sprite en localización.	En datos
Selene
Tipo	Asset	Uso	Estado
Portrait	assets/portraits/Selene_portrait_neutral.png	Retrato neutral.	En datos
Talking sprite	assets/portraits/Selene_talking.png	Arte de conversación/interacción.	En datos
Location sprite	assets/portraits/Selene_location_sprite.png	Sprite en localización.	En datos
Elara
Tipo	Asset	Uso	Estado
Portrait	assets/portraits/Elara_portrait_neutral.png	Retrato neutral.	En datos
Talking sprite	assets/portraits/Elara_talking.png	Arte de conversación/interacción.	En datos
Location sprite	assets/portraits/Elara_location_sprite.png	Sprite en localización.	En datos

Nota importante: aunque antes hablábamos de assets/npcs/Lyria_talking.png, el archivo real data/ui_assets.json usa assets/portraits/Lyria_talking.png. Para no romper nada, el inventario oficial debe respetar assets/portraits/.

Prioridad 8 — UI base

Referenciado en data/ui_assets.json.

Tipo	Asset	Uso	Archivo que lo usa	Estado
UI texture	assets/backgrounds/ui_panel_velo.png	Textura/piel visual para paneles.	data/ui_assets.json	En datos
UI texture	assets/backgrounds/ui_button_default.png	Textura base de botones.	data/ui_assets.json	En datos
UI texture	assets/backgrounds/ui_button_hover.png	Textura hover de botones.	data/ui_assets.json	En datos

Nota: esto debe tratarse como polish visual global. No conviene hacerlo antes de definir bien estilo de title/intro, porque debe heredar esa identidad visual.

Prioridad 9 — Items / regalos

data/items.json define los regalos y shop_preview, pero no vi rutas de iconos en el JSON. Por eso estos assets son propuestos, no conectados todavía.

Ruta recomendada si decidimos meter iconos:

assets/items/<item_id>.png
Tipo	Asset	Uso	Estado
Item icon	assets/items/ancient_books.png	Libros antiguos.	Propuesto
Item icon	assets/items/symbolic_art.png	Arte simbólico.	Propuesto
Item icon	assets/items/weapons.png	Armas.	Propuesto
Item icon	assets/items/flowers.png	Flores.	Propuesto
Item icon	assets/items/wine.png	Vino.	Propuesto
Item icon	assets/items/special_tea.png	Té especial.	Propuesto
Item icon	assets/items/sweets.png	Dulces.	Propuesto
Item icon	assets/items/simple_jewels.png	Joyas simples.	Propuesto
Item icon	assets/items/clothes.png	Ropa.	Propuesto
Item icon	assets/items/music_box.png	Caja de música.	Propuesto
Item icon	assets/items/maps.png	Mapas.	Propuesto
Item icon	assets/items/mana_gems.png	Gemas de maná.	Propuesto
Item icon	assets/items/tech_prototypes.png	Prototipos tecnológicos.	Propuesto
Item icon	assets/items/trophies.png	Trofeos.	Propuesto
Item icon	assets/items/coins.png	Dinero / monedas.	Propuesto
Item icon	assets/items/blank_diaries.png	Diarios en blanco.	Propuesto
Item icon	assets/items/sacred_objects.png	Objetos sagrados.	Propuesto
Item icon	assets/items/gadgets.png	Gadgets.	Propuesto
Item icon	assets/items/desserts.png	Postres.	Propuesto
Item icon	assets/items/narrative_secrets.png	Secretos narrativos.	Propuesto

Decisión recomendada: no empezar por items. La tienda ya funciona visualmente con tarjetas. Los items suman, pero no son el primer cuello de presentación del juego.

Prioridad 10 — Fondos específicos de citas

data/date_locations.json define lugares de cita, pero no vi rutas directas a fondos específicos de cita. Varias citas usan location_id, así que pueden reutilizar fondos de ubicación.

Estos serían propuestos solo si queremos que DateScene tenga fondos más románticos/específicos que la ubicación normal.

Tipo	Asset	Uso	Estado
Date background	assets/backgrounds/date_plaza_date.png	Paseo por la Plaza.	Propuesto
Date background	assets/backgrounds/date_market_date.png	Recorrido por el Mercado.	Propuesto
Date background	assets/backgrounds/date_tea_room_date.png	Té en sala tranquila.	Propuesto
Date background	assets/backgrounds/date_library_date.png	Rincón de la Biblioteca.	Propuesto
Date background	assets/backgrounds/date_garden_walk_date.png	Jardines apartados.	Propuesto
Date background	assets/backgrounds/date_tavern_date.png	Mesa apartada en la Taberna.	Propuesto
Date background	assets/backgrounds/date_forest_date.png	Sendero del Bosque Herido.	Propuesto
Date background	assets/backgrounds/date_observatory_date.png	Noche en el Observatorio.	Propuesto
Date background	assets/backgrounds/date_beach_date.png	Playa lejana.	Propuesto
Date background	assets/backgrounds/date_mountain_date.png	Montañas.	Propuesto
Date background	assets/backgrounds/date_sanctuary_date.png	Jardín del Santuario.	Propuesto
Date background	assets/backgrounds/date_arcane_date.png	Sala reservada del Ateneo.	Propuesto
Date background	assets/backgrounds/date_private_study_date.png	Estudio privado.	Propuesto
Date background	assets/backgrounds/date_hot_springs_date.png	Baño termal privado.	Propuesto
Date background	assets/backgrounds/date_forbidden_archive_date.png	Archivo prohibido de noche.	Propuesto
Date background	assets/backgrounds/date_threshold_date.png	Encuentro en el Umbral.	Propuesto

Decisión recomendada: esto va después de NPCs y fondos base. No lo metería todavía porque puede expandir mucho el alcance.

Orden recomendado de producción

Para que quede bien a la primera, yo trabajaría así:

Bloque A — Identidad inicial del juego
assets/backgrounds/title_luminaria_threshold.png
assets/ui/title_logo_isekai_novel.png
assets/backgrounds/intro_veil_crossing.png
assets/backgrounds/intro_appearance_selection.png
assets/backgrounds/intro_class_selection.png

Este bloque define el tono del juego. Si sale bien, todo lo demás puede seguir esa estética.

Bloque B — Forastero
assets/player/outsider_male_base.png
assets/player/outsider_female_base.png
assets/player/outsider_veiled_base.png
Los 18 outsider_<appearance>_<class>.png

Este bloque mejora muchísimo la intro y hace que el onboarding deje de sentirse placeholder.

Bloque C — Mapa y ubicaciones principales
assets/backgrounds/world_map_luminaria.png
Fondos de:
casa;
plaza;
biblioteca;
tienda;
mercado;
taberna;
bosque;
santuario;
umbral.
Luego iconos del mapa.
Bloque D — NPCs

Primero por personaje:

portrait_neutral
talking
location_sprite

No haría todos los portraits sueltos primero y luego todos los talking. Mejor cerrar cada personaje completo para poder probarlo en juego.

Bloque E — UI polish e items
ui_panel_velo.png
ui_button_default.png
ui_button_hover.png
iconos de items si decidimos que sí suman.
Recomendación final

Yo crearía docs/assets_inventory.md con esta tabla, pero lo haría después de una segunda pasada rápida leyendo también:

scenes/date/date_scene.gd
scenes/journal/journal_scene.gd
scenes/shop/shop_scene.gd
scenes/location/location_scene.gd
scenes/map/world_map.gd
data/npcs.json
data/player_classes.json

La tabla de arriba ya es una base sólida, pero antes de commitearla como “oficial” prefiero esa segunda pasada para no dejar fuera un fondo de journal, un asset de tienda, o alguna ruta usada directamente en escena.