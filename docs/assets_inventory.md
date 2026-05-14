# Luminaria: Crónicas del Velo — Inventario oficial de arte

## Reglas del inventario

- Usar rutas finales desde el inicio.
- No usar nombres genéricos como `npc1.png`, `bg_test.png`, `placeholder_final.png`.
- Respetar mayúsculas/minúsculas exactas.
- Si el asset ya está llamado por código o JSON, no cambiar la ruta salvo decisión explícita.
- Las capturas tipo `ejemplo.png`, `ejemplo1.png`, `tienda1.png`, etc. son referencia temporal de trabajo, no assets finales.
- Primero producir por bloques: Title Screen → Intro/Onboarding → Mapa/Ubicaciones → NPCs → Items/UI polish.
- Toda ruta visual nueva debe preferir `data/ui_assets.json` cuando aplique.
- Los estilos reutilizables deben vivir en helpers globales antes de copiarse entre escenas.

---

## Estado actual — Title Screen

El title screen ya tiene fondo, logo y primer botón visual integrados.

| Tipo | Asset | Uso | Archivo / sistema que lo usa | Estado |
|---|---|---|---|---|
| Background | `assets/backgrounds/title_luminaria_threshold.png` | Fondo principal de pantalla de título. | `data/ui_assets.json` → `title_screen.background`; `scenes/menu/main_menu.gd` | Integrado y visible |
| UI / Logo | `assets/ui/title_logo_luminaria_cronicas_del_velo.png` | Logo principal del juego. Incluye título y subtítulo visual. | `data/ui_assets.json` → `title_screen.logo`; `scenes/menu/main_menu.gd` | Integrado y visible |
| UI / Button | `assets/ui/button_velo_normal.png` | Placa visual base para botones del menú principal. | `data/ui_assets.json` → `buttons.menu_*`; `ui/components/luminaria_button_style.gd` | Integrado como primera versión |
| UI helper | `ui/components/luminaria_button_style.gd` | Helper global para aplicar estilo visual de botones. | `scenes/menu/main_menu.gd` | Integrado; por ahora usado en title screen |

### Notas del title screen

- El título final del juego es `Luminaria: Crónicas del Velo`.
- Ya no debe usarse `assets/ui/title_logo_isekai_novel.png`.
- El panel visual del título fue reemplazado por logo grande sin panel.
- El menú conserva estructura simple, pero el panel contenedor está transparente.
- El estilo de botón se está validando como base global antes de llevarlo al resto del juego.
- El title screen queda congelado por ahora salvo bug real o ajuste global de resolución.

---

## Prioridad 2 — Intro / Onboarding: fondos base

| Tipo | Asset | Uso | Archivo que lo usa | Estado |
|---|---|---|---|---|
| Background | `assets/backgrounds/intro_veil_crossing.png` | Prólogo / cruce del Velo. | `data/ui_assets.json` → `intro.prologue_background`; `scenes/intro/intro_scene.gd` | Pendiente de arte final |
| Background | `assets/backgrounds/intro_appearance_selection.png` | Selección de apariencia. Debe permitir tres tarjetas legibles encima. | `data/ui_assets.json` → `intro.appearance_background`; `scenes/intro/intro_scene.gd` | Pendiente de arte final |
| Background | `assets/backgrounds/intro_class_selection.png` | Selección de clase/camino. Debe permitir seis tarjetas verticales encima. | `data/ui_assets.json` → `intro.class_background`; `scenes/intro/intro_scene.gd` | Pendiente de arte final |

---

## Prioridad 2B — Intro / Onboarding: fondos de confirmación

Estos assets están soportados mediante patrón dinámico:

```text
assets/backgrounds/intro_confirm_outsider_<appearance>_<class>.png
El patrón vive en:

data/ui_assets.json → intro.confirm_background_pattern

Apariencias normalizadas:

male
female
veiled

Clases normalizadas:

sensitive
bold
scholar
charming
steadfast
balanced
Tipo	Asset	Uso	Estado
Background	assets/backgrounds/intro_confirm_outsider_male_sensitive.png	Confirmación: Forastero Sensible.	Soportado por código dinámico
Background	assets/backgrounds/intro_confirm_outsider_male_bold.png	Confirmación: Forastero Audaz.	Soportado por código dinámico
Background	assets/backgrounds/intro_confirm_outsider_male_scholar.png	Confirmación: Forastero Erudito.	Soportado por código dinámico
Background	assets/backgrounds/intro_confirm_outsider_male_charming.png	Confirmación: Forastero Encantador.	Soportado por código dinámico
Background	assets/backgrounds/intro_confirm_outsider_male_steadfast.png	Confirmación: Forastero Firme / Disciplinado.	Soportado por código dinámico
Background	assets/backgrounds/intro_confirm_outsider_male_balanced.png	Confirmación: Forastero Equilibrado.	Soportado por código dinámico
Background	assets/backgrounds/intro_confirm_outsider_female_sensitive.png	Confirmación: Forastera Sensible.	Soportado por código dinámico
Background	assets/backgrounds/intro_confirm_outsider_female_bold.png	Confirmación: Forastera Audaz.	Soportado por código dinámico
Background	assets/backgrounds/intro_confirm_outsider_female_scholar.png	Confirmación: Forastera Erudita.	Soportado por código dinámico
Background	assets/backgrounds/intro_confirm_outsider_female_charming.png	Confirmación: Forastera Encantadora.	Soportado por código dinámico
Background	assets/backgrounds/intro_confirm_outsider_female_steadfast.png	Confirmación: Forastera Firme / Disciplinada.	Soportado por código dinámico
Background	assets/backgrounds/intro_confirm_outsider_female_balanced.png	Confirmación: Forastera Equilibrada.	Soportado por código dinámico
Background	assets/backgrounds/intro_confirm_outsider_veiled_sensitive.png	Confirmación: Forma velada Sensible.	Soportado por código dinámico
Background	assets/backgrounds/intro_confirm_outsider_veiled_bold.png	Confirmación: Forma velada Audaz.	Soportado por código dinámico
Background	assets/backgrounds/intro_confirm_outsider_veiled_scholar.png	Confirmación: Forma velada Erudita.	Soportado por código dinámico
Background	assets/backgrounds/intro_confirm_outsider_veiled_charming.png	Confirmación: Forma velada Encantadora.	Soportado por código dinámico
Background	assets/backgrounds/intro_confirm_outsider_veiled_steadfast.png	Confirmación: Forma velada Firme / Disciplinada.	Soportado por código dinámico
Background	assets/backgrounds/intro_confirm_outsider_veiled_balanced.png	Confirmación: Forma velada Equilibrada.	Soportado por código dinámico
Decisión pendiente

No producir estos 18 fondos hasta decidir si la confirmación final usará:

fondo por combinación, o
fondo genérico + sprite del Forastero.
Prioridad 3 — Player / Apariencia base

Ruta recomendada:

assets/player/
Tipo	Asset	Uso	Estado
Player sprite / card	assets/player/outsider_male_base.png	Tarjeta visual base de Forastero.	Pendiente de integración visual
Player sprite / card	assets/player/outsider_female_base.png	Tarjeta visual base de Forastera.	Pendiente de integración visual
Player sprite / card	assets/player/outsider_veiled_base.png	Tarjeta visual base de Forma velada.	Pendiente de integración visual
Prioridad 4 — Player / Clases del Forastero

Ruta recomendada:

assets/player/
Tipo	Asset	Uso	Estado
Player sprite / card	assets/player/outsider_male_sensitive.png	Clase Sensible.	Pendiente
Player sprite / card	assets/player/outsider_male_bold.png	Clase Audaz.	Pendiente
Player sprite / card	assets/player/outsider_male_scholar.png	Clase Erudito.	Pendiente
Player sprite / card	assets/player/outsider_male_charming.png	Clase Encantador.	Pendiente
Player sprite / card	assets/player/outsider_male_steadfast.png	Clase Firme / Disciplinado.	Pendiente
Player sprite / card	assets/player/outsider_male_balanced.png	Clase Equilibrado.	Pendiente
Player sprite / card	assets/player/outsider_female_sensitive.png	Clase Sensible.	Pendiente
Player sprite / card	assets/player/outsider_female_bold.png	Clase Audaz.	Pendiente
Player sprite / card	assets/player/outsider_female_scholar.png	Clase Erudita.	Pendiente
Player sprite / card	assets/player/outsider_female_charming.png	Clase Encantadora.	Pendiente
Player sprite / card	assets/player/outsider_female_steadfast.png	Clase Firme / Disciplinada.	Pendiente
Player sprite / card	assets/player/outsider_female_balanced.png	Clase Equilibrada.	Pendiente
Player sprite / card	assets/player/outsider_veiled_sensitive.png	Clase Sensible.	Pendiente
Player sprite / card	assets/player/outsider_veiled_bold.png	Clase Audaz.	Pendiente
Player sprite / card	assets/player/outsider_veiled_scholar.png	Clase Erudita.	Pendiente
Player sprite / card	assets/player/outsider_veiled_charming.png	Clase Encantadora.	Pendiente
Player sprite / card	assets/player/outsider_veiled_steadfast.png	Clase Firme / Disciplinada.	Pendiente
Player sprite / card	assets/player/outsider_veiled_balanced.png	Clase Equilibrada.	Pendiente
Prioridad 5 — World Map

Referenciado en data/ui_assets.json.

Tipo	Asset	Uso	Estado
Background	assets/backgrounds/world_map_luminaria.png	Fondo principal del mapa de Luminaria.	En datos / pendiente de arte final
Map icon	assets/backgrounds/map_home_forastero.png	Icono de Casa en mapa.	En datos / pendiente
Map icon	assets/backgrounds/map_library_alba.png	Icono de Biblioteca.	En datos / pendiente
Map icon	assets/backgrounds/map_market_puente_rojo.png	Icono de Mercado.	En datos / pendiente
Map icon	assets/backgrounds/map_shop_umbral.png	Icono de Tienda.	En datos / pendiente
Map icon	assets/backgrounds/map_observatory_velo.png	Icono de Observatorio.	En datos / pendiente
Map icon	assets/backgrounds/map_arcane_library_ateneo.png	Icono de Ateneo / Biblioteca arcana.	En datos / pendiente
Map icon	assets/backgrounds/map_private_study.png	Icono de Estudio privado.	En datos / pendiente
Map icon	assets/backgrounds/map_archives_velo.png	Icono de Archivos.	En datos / pendiente
Map icon	assets/backgrounds/map_plaza_luminaria.png	Icono de Plaza.	En datos / pendiente
Map icon	assets/backgrounds/map_guild_alba_roja.png	Icono de Gremio.	En datos / pendiente
Map icon	assets/backgrounds/map_tavern_puente_rojo.png	Icono de Taberna.	En datos / pendiente
Map icon	assets/backgrounds/map_workshop_arcano.png	Icono de Taller.	En datos / pendiente
Map icon	assets/backgrounds/map_sanctuary_velo_quieto.png	Icono de Santuario.	En datos / pendiente
Map icon	assets/backgrounds/map_forest_herido.png	Icono de Bosque herido.	En datos / pendiente
Map icon	assets/backgrounds/map_council_hall.png	Icono de Consejo.	En datos / pendiente
Map icon	assets/backgrounds/map_threshold_umbral.png	Icono de Umbral.	En datos / pendiente
Prioridad 6 — Fondos de ubicaciones

Referenciados en data/ui_assets.json.

Tipo	Asset	Uso	Estado
Background	assets/backgrounds/location_home_forastero.png	Casa del Forastero.	En datos / pendiente
Background	assets/backgrounds/location_library_alba.png	Biblioteca / zona de saber.	En datos / pendiente
Background	assets/backgrounds/location_market_puente_rojo.png	Mercado.	En datos / pendiente
Background	assets/backgrounds/location_shop_umbral.png	Tienda del Umbral.	En datos / pendiente
Background	assets/backgrounds/location_observatory_velo.png	Observatorio.	En datos / pendiente
Background	assets/backgrounds/location_arcane_library_ateneo.png	Ateneo / biblioteca arcana.	En datos / pendiente
Background	assets/backgrounds/location_private_study.png	Estudio privado.	En datos / pendiente
Background	assets/backgrounds/location_archives_velo.png	Archivos del Velo.	En datos / pendiente
Background	assets/backgrounds/location_plaza_luminaria.png	Plaza de Luminaria.	En datos / pendiente
Background	assets/backgrounds/location_guild_alba_roja.png	Gremio.	En datos / pendiente
Background	assets/backgrounds/location_tavern_puente_rojo.png	Taberna.	En datos / pendiente
Background	assets/backgrounds/location_workshop_arcano.png	Taller arcano.	En datos / pendiente
Background	assets/backgrounds/location_sanctuary_velo_quieto.png	Santuario.	En datos / pendiente
Background	assets/backgrounds/location_forest_herido.png	Bosque herido.	En datos / pendiente
Background	assets/backgrounds/location_council_hall.png	Salón del Consejo.	En datos / pendiente
Background	assets/backgrounds/location_threshold_umbral.png	Umbral.	En datos / pendiente
Prioridad 7 — NPC portraits y sprites

Ruta real usada actualmente:

assets/portraits/

No usar assets/npcs/ salvo decisión explícita.

Cada NPC espera:

assets/portraits/<Name>_portrait_neutral.png
assets/portraits/<Name>_talking.png
assets/portraits/<Name>_location_sprite.png

Personajes:

Lyria
Aeris
Eryon
Rhea
Nova
Seraphine
Kael
Myr
Axiom
Taren
Rhein
Selene
Elara

Estado general: en datos / pendiente de arte final.

Prioridad 8 — UI base
Tipo	Asset	Uso	Estado
UI texture	assets/backgrounds/ui_panel_velo.png	Textura/piel visual para paneles.	En datos / pendiente
UI texture	assets/backgrounds/ui_button_default.png	Textura base de botones antigua.	En datos / revisar si queda obsoleta
UI texture	assets/backgrounds/ui_button_hover.png	Textura hover antigua.	En datos / revisar si queda obsoleta
UI texture	assets/ui/button_velo_normal.png	Botón base nuevo estilo Velo.	Integrado en title screen
Prioridad 9 — Items / regalos

data/items.json define regalos y shop_preview, pero actualmente los iconos no están conectados a UI.

Ruta recomendada si se integran iconos:

assets/items/<item_id>.png

Estado general: propuesto / no prioritario.

Prioridad 10 — Fondos específicos de citas

data/date_locations.json define lugares de cita, pero por ahora varias citas pueden reutilizar fondos de ubicación mediante location_id.

Estado general: propuesto / post-NPCs y post-fondos base.

Orden recomendado de producción
Title Screen — congelado por ahora.
Resolver resize/fullscreen antes de aprobar más composición visual.
Intro / Onboarding como bloque visual separado.
World Map y ubicaciones principales.
NPCs por personaje completo.
UI polish global.
Items y fondos específicos de citas.