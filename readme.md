# Luminaria: Crónicas del Velo — Estado de desarrollo y guía de continuidad

## Propósito de este README

Este archivo existe para que una nueva conversación de ChatGPT pueda continuar el desarrollo del juego sin perder contexto, sin repetir errores y sin volver a tocar bloques ya aprobados.

Repositorio:

```text
JoshSnowMex/isekai-novel
```

Archivo correcto:

```text
readme.md
```

Importante: está en minúsculas. No buscar únicamente `README.md`.

---

## Prompt recomendado para iniciar la siguiente sesión

Usar este prompt al empezar una nueva conversación:

```text
Hola, vamos a continuar el proyecto Godot “Luminaria: Crónicas del Velo” en el repo `JoshSnowMex/isekai-novel`.

Antes de proponer cambios, abre y lee directamente `readme.md` en minúsculas desde el repositorio usando ruta exacta. Ese archivo contiene el estado actualizado, reglas de trabajo, escenas aprobadas, estructura del proyecto, assets integrados, pendientes y decisiones tomadas.

Reglas obligatorias:
- No confíes en la búsqueda indexada de GitHub; falla con frecuencia.
- Abre archivos por ruta exacta usando fetch_file.
- Si digo que actualicé el repo, asume que hice commit/push y revisa el archivo real.
- Si menciono una captura o imagen que está en el repo, ábrela por ruta directa si la ruta está clara; no uses búsqueda indexada.
- Si subo una captura al chat, úsala como referencia visual temporal.
- No digas “si existe” cuando puedes revisar el archivo.
- No propongas parches temporales.
- No pongas algo “mientras tanto” para cambiarlo luego: apunta a versión final desde la primera solución.
- No dupliques lógica si algo debe ser global.
- Si crees que mi idea no es correcta, dímelo antes de escribir código para que lo acordemos.
- Si el cambio es grande, dame reemplazo completo de función o archivo.
- Si el cambio es puntual, dime archivo exacto, qué buscar y qué reemplazar.
- No tocar escenas aprobadas salvo bug real o asset pass acordado.
- No diagnosticar resize/fullscreen desde el runner/editor de Godot; ya se validó que el build exportado de Windows redimensiona correctamente.
- Cuando una UI no pueda quedar bonita solo con StyleBoxFlat, dilo pronto y pide asset estructural reutilizable.
- Mantén un tono desenfadado, pero preciso.

Último gran avance cerrado: LocationScene recibió un rediseño fuerte. Los NPCs ahora se muestran como cards clickeables con frame y portrait, el panel inferior quedó limpio, los resultados usan modal, regalos usan grid de 4 columnas y los flujos se validaron. No tocar LocationScene salvo bug real.

Quiero continuar de forma ordenada y finalista desde el estado documentado en `readme.md`.
```

---

## Regla crítica del repositorio

El repo está conectado por GitHub, pero la búsqueda indexada no es confiable. Puede no encontrar funciones, PNGs, archivos recién actualizados o incluso rutas que sí existen.

Por eso:

- No confiar en búsqueda indexada.
- Abrir archivos concretos por ruta exacta.
- Usar fetch_file por ruta.
- Si el usuario dice que actualizó el repo, asumir commit/push y revisar el archivo real.
- Si hay error de compilación, revisar el archivo actual antes de dar instrucciones.
- No decir “si existe” cuando se puede revisar.
- No dar instrucciones basadas en memoria si el archivo puede abrirse.

Si GitHub no permite ver bien un archivo crítico, el usuario puede subirlo directamente al chat. Trabajar entonces contra ese archivo subido.

---

## Filosofía de trabajo

El dueño del proyecto es programador backend Java/Spring y está aprendiendo Godot. Necesita guía concreta.

Reglas de respuesta esperadas:

- Archivo exacto.
- Qué buscar.
- Qué reemplazar.
- Dónde pegar.
- Qué probar.

Si el cambio es grande, dar reemplazo completo de función o archivo.
Si el cambio es pequeño, dar instrucciones puntuales.

No hacer:

- parches temporales;
- “por ahora luego lo globalizamos”;
- duplicar componentes locales si deben ser globales;
- retocar a ciegas;
- asumir que algo existe sin revisar;
- mezclar muchos bloques no relacionados;
- romper escenas aprobadas por cambios estéticos no acordados.

Regla aprendida en UI:

```text
Layout y comportamiento → código.
Identidad visual fuerte → assets estructurales reutilizables.
```

No insistir durante horas en StyleBoxFlat si la pieza necesita identidad visual real. Si empieza a verse como Bootstrap oscuro, cortar rápido y pedir asset estructural.

---

## Qué es el juego

Título final:

```text
Luminaria: Crónicas del Velo
```

No es una VN plana ni un dating sim simple. Es un simulador narrativo basado en:

- citas;
- vínculos;
- consecuencias;
- conocimiento;
- lealtad;
- celos;
- tensión;
- estado del mundo;
- memoria emocional;
- postgame;
- unión final.

La historia debe emerger de sistemas y decisiones. La main storyline no debe depender rígidamente del calendario. El calendario sirve más para cumpleaños, aniversarios, schedules y memoria emocional.

---

## Estado general del backend

El backend se considera completo/cerrado para pasar a UI/assets.

Sistemas implementados:

- ciclo de día;
- acciones;
- casa;
- guardado/carga/autosave;
- ubicaciones;
- NPC schedules;
- diálogo;
- tienda/items/regalos;
- citas;
- movimientos de cita;
- revelación de información;
- bitácora;
- estado del mundo;
- storylets;
- milestones;
- rivalidades;
- final union;
- calendario emocional;
- postgame completo;
- recompensas dinámicas.

No tocar backend salvo:

- bug claro;
- helper visual necesario;
- refactor formal de save slots si se decide hacer ese bloque.

---

## Resize, fullscreen y Godot

Tema cerrado.

Hubo una sesión difícil investigando resize/fullscreen. Conclusión:

- El runner/editor de Godot puede mostrar comportamiento engañoso.
- El build exportado real de Windows sí redimensiona correctamente.

Se validó exportando el juego. El juego corre, maximiza/redimensiona bien y los valores del label de prueba cambiaban consistentemente.

No volver a diagnosticar fullscreen/resize únicamente desde el editor.

Configuración estable en `project.godot`:

```ini
[display]

window/size/viewport_width=1280
window/size/viewport_height=720
window/stretch/mode="canvas_items"
window/stretch/aspect="expand"
```

No reintroducir:

- WindowManager;
- scripts para forzar root/viewport;
- hacks de resize por escena.

Si vuelve a haber duda, validar con build exportado.

---

## Assets estructurales visuales aprobados

Estos assets sí aportan identidad visual y deben reutilizarse:

```text
assets/ui/world_top_nav_panel.png
assets/ui/world_hover_info_panel.png
assets/ui/button_velo_normal.png
assets/ui/title_logo_luminaria_cronicas_del_velo.png
assets/ui/npc_presence_frame.png
```

Regla:

- No volver a resolver esos paneles con StyleBoxFlat plano.
- Usar estos assets como base visual cuando aplique.
- El frame de presencia NPC ya está validado; no pedir otro asset para ese caso salvo rediseño explícito.

---

# Escenas y estado actual

## 1. Title Screen / Main Menu

Estado: aprobado/congelado salvo bug real.

Archivos:

```text
scenes/menu/MainMenu.tscn
scenes/menu/main_menu.gd
data/ui_assets.json
ui/components/luminaria_button_style.gd
ui/components/visual_asset.gd
```

Características:

- fondo real;
- logo real;
- botones Nuevo juego / Continuar / Cargar partida / Salir;
- botón visual con asset;
- panel contenedor transparente;
- sin debug label.

No tocar salvo bug real o cambio global de botones acordado.

---

## 2. Intro / Onboarding

Estado: actualizado visualmente y funcionando.

Archivo:

```text
scenes/intro/intro_scene.gd
```

Flujo:

```text
Nuevo juego
→ Prólogo paginado
→ Selección de apariencia
→ Selección de clase/camino
→ Confirmación final
→ WorldMap
```

Cambios ya integrados:

- botones inferiores usan estilo visual consistente;
- bottom panel usa asset morado;
- pantalla de confirmación tiene panel derecho morado;
- panel de confirmación tiene tamaño alineado al marco del personaje;
- sello/clase usa morados/fríos;
- se evitó volver al look Bootstrap.

Fondos base esperados:

```text
assets/backgrounds/intro_veil_crossing.png
assets/backgrounds/intro_appearance_selection.png
assets/backgrounds/intro_class_selection.png
```

Confirmación dinámica esperada por patrón:

```text
assets/backgrounds/intro_confirm_outsider_<appearance>_<class>.png
```

Apariencias normalizadas:

```text
male
female
veiled
```

Clases normalizadas:

```text
sensitive
bold
scholar
charming
steadfast
balanced
```

Decisión previa: evitar producir 18 fondos de confirmación si se puede componer con assets más globales. Preferir soluciones mantenibles.

---

## 3. WorldMap

Estado: aprobado.

Archivo:

```text
scenes/map/world_map.gd
```

Componentes:

```text
ui/components/world_hud_bar.gd
ui/components/world_action_panel.gd
ui/components/location_map_button.gd
ui/components/location_hover_card.gd
```

Características aprobadas:

- fondo real de mapa;
- sprites reales de ubicaciones;
- halos morados permanentes;
- hover visual funcionando;
- click entra a ubicación;
- top nav con asset dedicado;
- panel informativo con asset dedicado;
- guardado/carga desde WorldMap vuelve al WorldMap;
- NPCs presentes aparecen en hover;
- NPC desconocido aparece como ???.

Assets de iconos de ubicaciones:

```text
assets/map/locations/map_location_home_forastero.png
assets/map/locations/map_location_library_alba.png
assets/map/locations/map_location_market_puente_rojo.png
assets/map/locations/map_location_shop_umbral.png
assets/map/locations/map_location_observatory_velo.png
assets/map/locations/map_location_arcane_library_ateneo.png
assets/map/locations/map_location_private_study.png
assets/map/locations/map_location_archives_velo.png
assets/map/locations/map_location_plaza_luminaria.png
assets/map/locations/map_location_guild_alba_roja.png
assets/map/locations/map_location_tavern_puente_rojo.png
assets/map/locations/map_location_workshop_arcano.png
assets/map/locations/map_location_sanctuary_velo_quieto.png
assets/map/locations/map_location_forest_herido.png
assets/map/locations/map_location_council_hall.png
assets/map/locations/map_location_threshold_umbral.png
```

No tocar salvo bug real.

---

## 4. LocationScene

Estado: aprobado / funcional / **rediseño de NPCs cerrado**.

Archivo:

```text
scenes/location/location_scene.gd
```

Cambios importantes cerrados en la última sesión:

- Se eliminó el patrón anterior de sprite de cuerpo completo flotando en el escenario.
- Los NPCs presentes ahora se muestran como **cards clickeables** usando `assets/ui/npc_presence_frame.png`.
- Los portraits de presencia usan assets dedicados:

```text
assets/portraits/<Nombre>_presence_portrait.png
```

Ejemplos:

```text
assets/portraits/Lyria_presence_portrait.png
assets/portraits/Seraphine_presence_portrait.png
assets/portraits/Selene_presence_portrait.png
```

- El nombre del NPC vive en la placa inferior del frame.
- El portrait puede sobresalir levemente sobre el marco; visualmente se aprobó.
- El frame/portrait quedó ajustado a mano con offsets correctos; no reabrir salvo bug real.
- Si hay varios NPCs, se muestran como varias cards centradas.
- La interacción con NPC se hace clickeando el portrait/card.
- Se eliminaron del overview los botones redundantes de “Acercarse a X”.
- El panel inferior vuelve a quedar para descripción y acciones de ubicación.
- Si un NPC deja de estar presente por schedule, su card desaparece y se vuelve al overview sin mensaje de confirmación.
- Acciones de ubicación, hablar y regalar muestran resultados en modal, no como texto con botón Continuar en el panel inferior.
- Guardado manual muestra modal compacto.
- Cargar usa `LoadGameModal`.
- Modal de regalos muestra inventario en grid de 4 columnas con botones visuales.
- El modal de regalos reabre correctamente después de usar Volver.
- Los resultados de revisión de LocationScene fueron exitosos.

Funciones/bloques importantes:

```text
create_character_button()
get_npc_presence_portrait_path()
get_scaled_character_size()
get_bottom_panel_reserved_height()
get_character_position()
show_location_overview()
interact_npc()
show_gift_selection()
build_modal_choice_grid()
add_modal_grid_button()
show_location_result()
show_npc_result()
open_result_modal()
open_compact_info_modal()
close_choice_modal()
layout_overlay_controls()
```

Notas críticas de implementación:

- `close_choice_modal()` debe limpiar `modal_buttons`, `modal_footer`, metas como `compact_info_modal` y `gift_modal`, y restaurar márgenes/tamaños del modal. Esto corrigió el bug donde regalos no reaparecía al volver a abrir.
- `show_gift_selection()` usa `gift_modal` para layout especial más ancho/alto y grid de 4 columnas.
- `open_compact_info_modal()` se usa para confirmaciones cortas como guardado.
- `open_result_modal()` se usa para resultados narrativos o de acciones.
- `show_location_message()` debe quedar como fallback/mensajes narrativos raros, no para resultados normales de acciones.

No tocar LocationScene salvo:

- bug real;
- nuevo asset pass explícito;
- comportamiento confirmado incorrecto en pruebas.

---

## 5. HomeScene

Estado: aprobado / funcional.

Archivo:

```text
scenes/home/home_scene.gd
```

Características:

- HUD global;
- top nav global;
- fondo de casa;
- panel inferior con asset visual;
- botones de acciones consistentes;
- dormir mantiene al jugador en casa al despertar;
- dormir procesa mensajes narrativos;
- guardar/cargar funcionan desde casa;
- bitácora vuelve a casa.

Nota: se corrigió un bug donde `main_title_label` se había perdido y `main_actions` estaba duplicado. No volver a tocar esa función sin revisar el archivo real.

---

## 6. ShopScene

Estado: funcional y visualmente aprobado en general, con deuda menor de legibilidad de labels.

Archivo:

```text
scenes/shop/shop_scene.gd
```

Características actuales:

- HUD global;
- top nav global con WorldActionPanel;
- info panel superior con asset morado;
- fondo real de tienda;
- tendera integrada desde asset;
- grid de objetos con iconos reales;
- hover/click solo sobre el cuadro del icono;
- texto debajo no debería activar compra;
- 7 columnas aprobadas;
- nombre/precio/preview se muestra en info panel al hover.

Asset de tendera:

```text
assets/shop/npc_vendor.png
```

Assets de items:

```text
assets/shop/items/item_ancient_books.png
assets/shop/items/item_symbolic_art.png
assets/shop/items/item_weapons.png
assets/shop/items/item_flowers.png
assets/shop/items/item_wine.png
assets/shop/items/item_special_tea.png
assets/shop/items/item_sweets.png
assets/shop/items/item_simple_jewels.png
assets/shop/items/item_clothes.png
assets/shop/items/item_music_box.png
assets/shop/items/item_maps.png
assets/shop/items/item_mana_gems.png
assets/shop/items/item_tech_prototypes.png
assets/shop/items/item_trophies.png
assets/shop/items/item_coins.png
assets/shop/items/item_blank_diaries.png
assets/shop/items/item_sacred_objects.png
assets/shop/items/item_gadgets.png
assets/shop/items/item_desserts.png
assets/shop/items/item_narrative_secrets.png
```

IDs reales de `data/items.json`:

```text
ancient_books
symbolic_art
weapons
flowers
wine
special_tea
sweets
simple_jewels
clothes
music_box
maps
mana_gems
tech_prototypes
trophies
coins
blank_diaries
sacred_objects
gadgets
desserts
narrative_secrets
```

Importante:

```text
simple_jewels, no simple_jewelry.
coins, no money.
```

Labels cortos deseados en tienda:

```text
tech_prototypes → Prototipos
blank_diaries → Diarios
narrative_secrets → Secretos
sacred_objects → Sagrados
simple_jewels → Joyas
ancient_books → Libros
```

Deuda visual menor:

- Los labels debajo de items siguen siendo poco legibles en algunos casos.
- No es bloqueante porque el info panel muestra nombre completo y precio al hover.
- No volver a meter panel/cintilla grande detrás de cada label: agranda y ensucia el grid.

Mejoras futuras posibles:

- ocultar labels y depender del info panel;
- mostrar label solo en hover;
- crear mini asset de placa de item si realmente hace falta.

No tocar más la tienda salvo bug real o decisión explícita de mejorar labels.

---

## 7. JournalScene / Bitácora

Estado: aprobado / funcional.

Archivo:

```text
scenes/journal/journal_scene.gd
```

Características:

- navegación por capítulos;
- personas como tarjetas;
- detalle narrativo por personaje;
- mundo, calendario, recuerdos y unión separados;
- panel contextual;
- retorno correcto según escena de origen.

No tocar salvo bug real o asset pass acordado.

---

## 8. DateScene

Estado: aprobado / funcional, pero candidato recomendado para próximo pass visual.

Archivo:

```text
scenes/date/date_scene.gd
```

Características actuales:

- header compacto;
- narrativa con buen espacio;
- acciones base abajo;
- popup/modal con scroll para respuestas, regalos, movimientos y lugares;
- resumen final ya no se corta;
- modal de regalos funciona;
- modal de lugares funciona;
- cita especial funciona;
- pregunta/respuesta ya no pierde texto al hover.

Pendiente visual probable:

- Aplicar el mismo lenguaje visual de paneles/botones si aún se siente viejo comparado con LocationScene.
- Revisar solo cuando se decida hacer pass visual de citas.
- Antes de código: abrir `scenes/date/date_scene.gd`, revisar estructura real y pedir/usar captura actual.

---

## 9. LoadGameModal

Estado: aprobado / funcionando visualmente.

Archivo:

```text
ui/components/load_game_modal.gd
```

Integrado en:

```text
scenes/map/world_map.gd
scenes/location/location_scene.gd
scenes/home/home_scene.gd
scenes/shop/shop_scene.gd
```

Comportamiento:

- Último autosave
- Guardado manual
- Volver al título
- Cancelar

Ya usa panel visual consistente y botones coherentes. No tratar “Volver al título” como pendiente; ya existe.

---

# Guardado / carga

Estado actual:

- Autosave funciona.
- Guardado manual funciona.
- Cargar desde título funciona.
- Cargar desde dentro del juego funciona con modal global.
- Autosave vuelve a donde se generó.
- Guardado manual vuelve a donde se generó.
- Guardar desde WorldMap vuelve a WorldMap.
- Guardar desde LocationScene muestra modal compacto.
- Dormir solo puede hacerse en casa y debe dejarte en casa al avanzar el día.

Archivos:

```text
core/save_manager.gd
core/scene_router.gd
ui/components/load_game_modal.gd
```

Rutas actuales:

```text
user://autosave.json
user://savegame.json
```

`SceneRouter.go_to_current_location_scene()` debe conservar conceptualmente:

```gdscript
func go_to_current_location_scene() -> void:
	var location_id: String = str(GameManager.current_location_id)

	if location_id == "":
		go_to_world_map()
		return

	if location_id == "home":
		go_to_home()
		return

	if location_id == "shop":
		go_to_shop()
		return

	go_to_location()
```

No implementar save slots todavía.

---

## Save slots futuros

No implementado.

Si se decide hacer, tratar como bloque independiente:

```text
Save Slots 1/2/3
```

No mezclar con asset pass.

Posible estructura futura:

```text
user://slot_1_autosave.json
user://slot_1_manual.json
user://slot_2_autosave.json
user://slot_2_manual.json
user://slot_3_autosave.json
user://slot_3_manual.json
```

Requiere tocar:

```text
core/save_manager.gd
core/game_manager.gd
scenes/menu/main_menu.gd
ui/components/load_game_modal.gd
pantalla de nuevo juego
modal de carga
botones de guardar
```

---

# Assets y arte

Existe inventario oficial:

```text
docs/assets_inventory.md
```

Consultar antes de generar assets.

Reglas:

- Usar rutas finales desde el inicio.
- No usar nombres genéricos.
- Las capturas de trabajo no son assets finales.
- Los assets finales viven en `assets/**`.
- Usar `data/ui_assets.json` como fuente de rutas cuando aplique.
- Si algo visual debe poder cambiar sin tocar código, debe ir a `data/ui_assets.json`.

Capturas temporales pueden llamarse:

```text
ejemplo.png
evidencia.png
tienda1.png
tienda2.png
```

No tratarlas como assets finales.

---

## data/ui_assets.json

Archivo clave para rutas visuales.

Controla rutas para:

- title screen;
- intro;
- world map;
- locations;
- NPC portraits/sprites;
- UI;
- buttons.

Preferir este archivo sobre rutas hardcodeadas cuando aplique.

Excepción actual aceptada:

```text
assets/shop/npc_vendor.png
assets/shop/items/item_<id>.png
```

Estas rutas están hardcodeadas en ShopScene por ahora. Si se vuelve necesario hacerlas configurables, mover a `data/ui_assets.json` o `data/items.json` como asset path por item.

---

# Música/audio

Tema investigado pero no integrado.

Reglas recomendadas:

- Música final: `.ogg`
- Música temporal/referencia: `.mp3` permitido
- Efectos de sonido: `.wav`

Fuentes posibles:

- OpenGameArt
- Pixabay Music
- FreePD
- Incompetech
- Itch.io asset packs

Si se usa música con atribución, crear:

```text
docs/audio_credits.md
```

Con:

- archivo local
- nombre original
- autor
- fuente
- licencia
- URL
- requiere atribución sí/no

No mezclar audio con pass visual salvo que se acuerde.

---

# Árbol lógico del proyecto

Core:

```text
core/data_manager.gd
core/game_manager.gd
core/save_manager.gd
core/scene_router.gd
```

Scenes:

```text
scenes/menu/MainMenu.tscn
scenes/menu/main_menu.gd
scenes/intro/intro_scene.gd
scenes/map/world_map.gd
scenes/location/location_scene.gd
scenes/home/home_scene.gd
scenes/shop/shop_scene.gd
scenes/journal/journal_scene.gd
scenes/date/date_scene.gd
```

UI components:

```text
ui/components/visual_asset.gd
ui/components/luminaria_theme.gd
ui/components/luminaria_button_style.gd
ui/components/load_game_modal.gd
ui/components/location_map_button.gd
ui/components/world_hud_bar.gd
ui/components/world_action_panel.gd
ui/components/location_hover_card.gd
```

Data:

```text
data/ui_assets.json
data/locations.json
data/items.json
data/date_locations.json
data/date_moves.json
data/npcs.json
data/player_classes.json
```

Docs:

```text
docs/assets_inventory.md
```

Assets principales:

```text
assets/backgrounds/
assets/ui/
assets/map/locations/
assets/shop/
assets/shop/items/
assets/player/
assets/portraits/
```

---

# Escenas aprobadas: no tocar salvo bug real

No modificar sin razón clara:

```text
scenes/map/world_map.gd
scenes/location/location_scene.gd
scenes/home/home_scene.gd
scenes/shop/shop_scene.gd
scenes/journal/journal_scene.gd
scenes/date/date_scene.gd
scenes/intro/intro_scene.gd
scenes/menu/main_menu.gd
```

Si se toca una escena aprobada, debe ser por:

- bug real;
- asset pass acordado;
- componente global que afecta varias escenas de forma controlada.

---

# Pendientes recomendados para próxima sesión

El proyecto está en etapa final de UI/assets.

Siguientes bloques posibles, en orden sugerido:

## Opción A — DateScene visual pass

Revisar si DateScene ya se siente consistente con:

```text
world_hover_info_panel.png
world_top_nav_panel.png
button_velo_normal.png
HUD global
modales más pulidos
```

Antes de tocar código:

1. Abrir directo `scenes/date/date_scene.gd`.
2. Revisar si reutiliza o duplica lógica visual.
3. Pedir/usar captura actual de DateScene.
4. Acordar si el pass será solo visual o también de flujo.

No tocar backend de citas salvo bug claro.

## Opción B — Journal visual pass

Revisar bitácora con el nuevo lenguaje visual.
No tocar backend de bitácora; solo paneles/botones si hace falta.

## Opción C — fondos restantes / asset audit

El usuario indicó que los fondos faltantes ya están listos o casi listos. No asumir que faltan sin revisar `data/ui_assets.json` y `docs/assets_inventory.md`.

Si se revisan fondos:

- abrir `data/ui_assets.json`;
- abrir `docs/assets_inventory.md`;
- validar rutas reales por ubicación.

## Opción D — mejorar labels de tienda

Deuda menor. No prioritaria.

Posibles soluciones futuras:

- quitar labels y depender del info panel;
- label solo en hover;
- mini asset de placa de item;
- aumentar contraste con shader/outline más fino.

No volver a meter panel grande detrás del texto.

---

# Último estado de sesión

Cerrado hoy:

- LocationScene rediseñada para reemplazar sprites flotantes por cards de presencia de NPC.
- Frame `assets/ui/npc_presence_frame.png` validado.
- Portraits `<Nombre>_presence_portrait.png` integrados y encuadrados.
- Lyria, Seraphine, Selene probadas visualmente.
- Nombre del NPC ajustado en placa inferior.
- Botones “Acercarse a X” eliminados del panel inferior.
- Interacción por click en portrait aprobada.
- Panel inferior recuperado para descripción/acciones de ubicación.
- Modal compacto para guardado corregido.
- Modal de resultados para hablar/regalar/acciones corregido.
- Acciones de ubicación ahora muestran resultado en modal.
- Si un NPC se va por schedule, desaparece sin mensaje molesto.
- Modal de regalos convertido a grid visual de 4 columnas.
- Bug de reabrir regalos después de Volver corregido limpiando estado en `close_choice_modal()`.
- Revisiones de LocationScene exitosas.

El usuario terminó la sesión satisfecho pero señaló que fue extenuante; próxima sesión debe evitar parches a ciegas y leer archivos reales antes de proponer cambios.

---

# Recordatorio final para el próximo asistente

No empieces buscando globalmente.
Primero abre por ruta:

```text
readme.md
docs/assets_inventory.md
data/ui_assets.json
```

Después abre solo los archivos necesarios por ruta exacta.

No contestes con “probablemente”, “si existe”, “debería haber”.
Revisa el archivo real y da instrucciones puntuales.
