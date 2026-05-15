# Luminaria: Crónicas del Velo — Estado de desarrollo y guía de continuidad

## Propósito de este README

Este README existe para que una nueva conversación de ChatGPT pueda continuar el desarrollo del juego sin perder contexto ni repetir errores.

El proyecto vive en:

```text
JoshSnowMex/isekai-novel

Archivo correcto:

readme.md

Importante: está en minúsculas. No buscar README.md.

Regla crítica del repositorio

El repo está conectado por GitHub, pero la búsqueda indexada puede fallar o no encontrar funciones existentes.

Por eso:

No confiar en búsqueda indexada para localizar funciones.
Abrir archivos concretos por ruta.
Usar fetch_file por ruta exacta.
Si el usuario dice que actualizó el repo, asumir que hizo commit/push y revisar el archivo real antes de responder.
Si el usuario menciona ejemplo.png, ejemplo1.png, tienda1.png, etc., asumir que esas capturas ya están en el repo y deben revisarse si hace falta.
No decir “si existe” cuando se puede revisar.
No dar instrucciones basadas en memoria si el archivo puede revisarse.
Filosofía de trabajo

El dueño del proyecto es programador backend Java/Spring y novato en Godot.

Necesita instrucciones claras:

Archivo exacto.
Qué buscar.
Qué reemplazar.
Dónde pegar.
Qué probar.
Si el cambio es grande, dar reemplazo completo de archivo.
Si el cambio es pequeño, dar instrucciones puntuales.
No hacer cambios tentativos o parches “por mientras”.
No duplicar lógica si debe ser global.
No tocar archivos aprobados salvo bug real.
No mezclar bloques grandes no relacionados.
Si una solución debe ser productiva/finalista, hacerla así desde el inicio.
Si se abre una decisión creativa o estructural importante, detenerse y acordarla antes de implementar.

Regla emocional/práctica del proyecto:

El ritmo de trabajo es bueno cuando se avanza con cambios concretos y finalistas. El usuario se frustra con retrabajo, cambios a ciegas y pruebas repetidas sobre el mismo archivo.

Qué es el juego

Título final:

Luminaria: Crónicas del Velo

No es una VN plana ni un dating sim simple. Es un simulador de historias basado en citas, vínculos y consecuencias.

La historia debe emerger de:

relaciones;
conocimiento;
decisiones;
lealtad;
celos;
tensión;
estado del mundo;
consecuencias;
memoria emocional;
postgame y unión final.

La main storyline no debe depender rígidamente del calendario. El calendario sirve más para cumpleaños, aniversarios, schedules y memoria emocional.

Estado general del backend

El backend se considera completo/cerrado para pasar a UI/assets.

Sistemas implementados:

ciclo de día;
acciones;
casa;
guardado/carga/autosave;
ubicaciones;
NPC schedules;
diálogo;
tienda/items/regalos;
citas;
movimientos de cita;
revelación de información;
bitácora;
estado del mundo;
storylets;
milestones;
rivalidades;
final union;
calendario emocional;
postgame completo;
recompensas dinámicas.

No tocar backend salvo:

bugs claros;
helpers visuales necesarios;
refactor formal de save slots si se decide hacer ese bloque.
Estado técnico importante: resolución, resize y Godot

Hubo una sesión muy frustrante investigando resize/fullscreen.

Conclusión cerrada:

En el editor/runner de Godot, el resize puede parecer roto.
En build exportado real de Windows, el resize funciona correctamente.
Se validó exportando el juego: el juego corre, maximiza/redimensiona bien, y los valores del label de prueba cambiaban consistentemente.
Por tanto, el problema era el runner/editor de Godot, no el proyecto.
No volver a diagnosticar fullscreen/resize únicamente desde el runner del editor.

Configuración actual estable en project.godot:

[display]

window/size/viewport_width=1280
window/size/viewport_height=720
window/stretch/mode="canvas_items"
window/stretch/aspect="expand"

Notas:

No reintroducir WindowManager.
No meter scripts para forzar root/viewport.
No tocar escenas por este tema salvo bug visible en build exportado.
Si vuelve a haber dudas de fullscreen/resize, validar en build exportado, no solo en Godot editor.

Export templates:

Ya se instalaron plantillas de exportación.
Se pudo exportar un build Windows exitosamente.
Estado actual aprobado de escenas
1. Title Screen / MainMenu

Estado: integrado visualmente y congelado por ahora.

Archivos:

scenes/menu/MainMenu.tscn
scenes/menu/main_menu.gd
data/ui_assets.json
ui/components/luminaria_button_style.gd
ui/components/visual_asset.gd

Título final:

Luminaria: Crónicas del Velo

Assets integrados:

assets/backgrounds/title_luminaria_threshold.png
assets/ui/title_logo_luminaria_cronicas_del_velo.png
assets/ui/button_velo_normal.png

Características actuales:

Fondo real desde data/ui_assets.json.
Logo real desde data/ui_assets.json.
El logo ya reemplazó el panel textual de título.
El logo está grande y cargado hacia la izquierda.
Menú con botones:
Nuevo juego;
Continuar;
Cargar partida;
Salir.
El panel contenedor del menú está transparente.
Los botones usan LuminariaButtonStyle.
button_velo_normal.png se usa como primer asset visual de botones.
El estilo de botón está pensado como base global, aunque por ahora se usa en title screen.

Notas importantes:

No volver a usar assets/ui/title_logo_isekai_novel.png.
El title screen no está perfecto eterno, pero queda congelado por ahora.
No seguir puliendo title screen hasta avanzar otros bloques visuales.
Si se cambia el estilo global de botones, hacerlo desde ui/components/luminaria_button_style.gd, no copiando estilos por escena.
Ya se quitó el debug label del viewport.
2. Intro / Onboarding

Estado: funcional, aprobado estructuralmente, pendiente de arte final.

Archivo:

scenes/intro/intro_scene.gd

Flujo:

Nuevo juego
→ Prólogo paginado
→ Selección de apariencia
→ Selección de clase/camino
→ Confirmación final
→ WorldMap

Fondos base esperados:

assets/backgrounds/intro_veil_crossing.png
assets/backgrounds/intro_appearance_selection.png
assets/backgrounds/intro_class_selection.png

Confirmación dinámica esperada por patrón:

assets/backgrounds/intro_confirm_outsider_<appearance>_<class>.png

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

Decisión pendiente importante:

Antes de producir 18 fondos de confirmación, decidir si se hará:

un fondo por combinación, o
fondo genérico + sprite/personaje del Forastero.

Recomendación actual:

No empezar Intro en la misma sesión que se toque resolución/title. Tratar Intro como bloque visual separado.

3. WorldMap

Estado: funcional y responsive.

Archivo:

scenes/map/world_map.gd

Componentes:

ui/components/location_hover_card.gd
ui/components/world_hud_bar.gd
ui/components/world_action_panel.gd
ui/components/location_map_button.gd

Características:

HUD superior.
Mapa grande.
Botones globales arriba derecha.
Tarjeta hover.
Ubicaciones clicables.
Click directo entra a ubicación.
NPCs presentes aparecen en hover.
NPC desconocido aparece como ???.
Responsive al tamaño disponible.
Usa BASE_MAP_SIZE.
Escala posiciones y tamaños de ubicaciones.
Recalcula ubicaciones en resize con rebuild_locations().
Usa fondo desde data/ui_assets.json.

No tocar salvo bug real o asset pass.

4. LocationScene

Estado: aprobado / funcional.

Archivo:

scenes/location/location_scene.gd

Características:

Fondo por ubicación desde ui_assets.json.
HUD superior.
Botones globales.
NPCs presentes como sprites/placeholders clicables.
Desconocidos como ???.
Interacciones desde panel inferior:
hablar;
regalar;
pedir favor;
invitar a cita;
avances especiales;
cerrar.
Acciones del lugar disponibles sin lista administrativa.
Hover de acciones muestra info inmediata.
Tooltips nativos evitados.
Bug de NPCs encimados corregido.
Funciones de posicionamiento ya existen. No duplicarlas.

Funciones importantes que ya existen y NO deben duplicarse:

get_scaled_character_size()
get_bottom_panel_reserved_height()
get_stable_character_position()
get_character_position()

No tocar salvo bug real.

5. HomeScene

Estado: aprobado / funcional.

Archivo:

scenes/home/home_scene.gd

Características:

HUD.
Botones globales.
Fondo de casa.
Panel inferior limpio.
Dormir mantiene al jugador en casa al despertar.
Dormir procesa mensajes narrativos.
Guardar/cargar funcionan desde casa.
Bitácora desde casa vuelve a casa.

No tocar salvo bug real.

6. ShopScene

Estado: aprobado / funcional.

Archivo:

scenes/shop/shop_scene.gd

Características:

Entra directo desde mapa.
No requiere LocationScene intermedia.
Escaparate directo.
Click en tarjeta compra.
Hover muestra info compacta.
Tarjetas compactas.
Máximo 6 columnas.
Espacio derecho reservado para tendero/arte futuro.
Preview de items usa shop_preview desde data/items.json.
Scroll existe, pero debe ocultarse si todo cabe.

Assets futuros posibles:

assets/backgrounds/location_shop_umbral.png
assets/portraits/shop_vendor_umbral.png
assets/items/<item>.png

No tocar salvo bug real o asset pass.

7. JournalScene / Bitácora

Estado: aprobado / funcional.

Archivo:

scenes/journal/journal_scene.gd

Características:

Navegación por capítulos.
Personas como tarjetas.
Detalle narrativo por personaje.
Mundo, calendario, recuerdos y unión separados.
Panel contextual.
Retorno correcto según escena de origen.
Evita listas infinitas tipo ERP.

No tocar salvo bug real.

8. DateScene

Estado: aprobado / funcional.

Archivo:

scenes/date/date_scene.gd

Características:

Header compacto.
Narrativa con buen espacio.
Acciones base abajo.
Popup/modal con scroll para:
respuestas;
regalos;
movimientos/gestos;
lugares de cita.
Resumen final ya no se corta.
Modal de regalos funciona.
Modal de lugares funciona.
Cita especial funciona.
Pregunta/respuesta ya no pierde texto al hover.

No tocar salvo bug real o asset pass.

9. LoadGameModal

Estado: aprobado y funcionando.

Archivo:

ui/components/load_game_modal.gd

Integrado en:

scenes/map/world_map.gd
scenes/location/location_scene.gd
scenes/home/home_scene.gd
scenes/shop/shop_scene.gd

Comportamiento actual:

Cargar partida

Último autosave
Guardado manual
Volver al título
Cancelar

Notas:

“Volver al título” ya está hecho y funcionando.
El README viejo decía que era pendiente; ya no lo es.
No volver a tratarlo como tarea pendiente.
Guardado / carga

Estado actual:

Autosave funciona.
Guardado manual funciona.
Cargar desde title funciona.
Cargar desde dentro del juego funciona con modal global.
Autosave vuelve a donde se generó.
Guardado manual vuelve a donde se generó.

Archivos:

core/save_manager.gd
core/scene_router.gd
ui/components/load_game_modal.gd

Rutas actuales:

user://autosave.json
user://savegame.json

SceneRouter.go_to_current_location_scene() debe conservar conceptualmente:

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

No implementar save slots todavía.

Save slots futuros

No implementado.

Si se decide hacer, tratar como bloque independiente:

Save Slots 1/2/3

No mezclar con assets ni UI visual.

Posible estructura futura:

user://slot_1_autosave.json
user://slot_1_manual.json
user://slot_2_autosave.json
user://slot_2_manual.json
user://slot_3_autosave.json
user://slot_3_manual.json

Requiere tocar:

core/save_manager.gd
core/game_manager.gd
scenes/menu/main_menu.gd
ui/components/load_game_modal.gd
pantalla de nuevo juego
modal de carga
botones de guardar
Assets y arte

Existe inventario oficial:

docs/assets_inventory.md

Este archivo debe consultarse antes de generar assets.

Reglas:

Usar rutas finales desde el inicio.
No usar nombres genéricos.
Las capturas de trabajo (ejemplo.png, ejemplo1.png, etc.) no son assets finales.
Los assets finales viven en assets/**.
Usar data/ui_assets.json como fuente de rutas cuando aplique.
Si algo visual debe poder cambiar sin tocar código, debe ir a ui_assets.json.

Assets integrados hasta ahora:

assets/backgrounds/title_luminaria_threshold.png
assets/ui/title_logo_luminaria_cronicas_del_velo.png
assets/ui/button_velo_normal.png

Siguiente bloque visual recomendado:

Intro / Onboarding

Pero empezar solo después de confirmar que no hay pendientes técnicos abiertos.

data/ui_assets.json

Este archivo controla rutas visuales para:

title screen;
intro;
world map;
locations;
NPC portraits/sprites;
UI;
buttons.

Debe preferirse sobre rutas hardcodeadas.

Antes de agregar un asset final, verificar si ya hay una ruta esperada ahí.

Música/audio

Se investigó música IA, pero la mayoría de servicios útiles requieren pago/licencia para descargar o usar comercialmente.

Regla recomendada:

Música final: .ogg
Música temporal o referencia: .mp3 permitido
Efectos de sonido: .wav

Fuentes posibles:

OpenGameArt;
Pixabay Music;
FreePD;
Incompetech;
Itch.io asset packs.

Si se usa música con atribución, crear:

docs/audio_credits.md

con:

archivo local
nombre original
autor
fuente
licencia
URL
requiere atribución sí/no

No mezclar audio con el bloque visual actual.

Capturas de referencia

El usuario puede subir capturas al repo como:

ejemplo.png
ejemplo1.png
ejemplo2.png
tienda1.png
tienda2.png

Regla:

Si el usuario menciona una captura, asumir que el repo ya fue actualizado.
Revisar la imagen o el archivo correspondiente si es necesario.
No pedir que confirme si ya subió o actualizó.

Estas capturas son temporales y desaparecerán al final del proyecto. No son assets finales.

Archivos clave

Core:

core/data_manager.gd
core/game_manager.gd
core/save_manager.gd
core/scene_router.gd

Scenes:

scenes/menu/MainMenu.tscn
scenes/menu/main_menu.gd
scenes/intro/intro_scene.gd
scenes/map/world_map.gd
scenes/location/location_scene.gd
scenes/home/home_scene.gd
scenes/shop/shop_scene.gd
scenes/journal/journal_scene.gd
scenes/date/date_scene.gd

UI components:

ui/components/visual_asset.gd
ui/components/luminaria_button_style.gd
ui/components/load_game_modal.gd
ui/components/location_map_button.gd
ui/components/world_hud_bar.gd
ui/components/world_action_panel.gd
ui/components/location_hover_card.gd

Data:

data/ui_assets.json
data/locations.json
data/items.json
data/date_locations.json
data/date_moves.json
data/npcs.json
data/player_classes.json

Docs:

docs/assets_inventory.md
Escenas aprobadas: no tocar salvo bug real

No modificar sin razón clara:

scenes/location/location_scene.gd
scenes/home/home_scene.gd
scenes/shop/shop_scene.gd
scenes/journal/journal_scene.gd
scenes/date/date_scene.gd
scenes/map/world_map.gd
scenes/intro/intro_scene.gd
scenes/menu/main_menu.gd

main_menu.gd queda congelado por ahora salvo bug real o cambio global de botones.

Próximo paso recomendado

La siguiente sesión debería empezar así:

Leer readme.md.
Revisar docs/assets_inventory.md.
Revisar data/ui_assets.json.
Confirmar que no hay debug label en main_menu.gd.
No tocar resolución/fullscreen salvo que falle en build exportado.
Empezar bloque visual de Intro / Onboarding por separado.

Bloque sugerido:

Intro / Onboarding — arte final del prólogo y selección

Primer asset recomendado:

assets/backgrounds/intro_veil_crossing.png

Después:

assets/backgrounds/intro_appearance_selection.png
assets/backgrounds/intro_class_selection.png

Antes de generar 18 fondos de confirmación, decidir si se usará fondo por combinación o fondo genérico + sprite del Forastero.

Prompt sugerido para continuar en otro chat

Usa este prompt:

Estamos haciendo un juego Godot llamado “Luminaria: Crónicas del Velo” en el repositorio `JoshSnowMex/isekai-novel`.

Antes de responder, conéctate al repo y lee `readme.md` en minúsculas. Luego revisa `docs/assets_inventory.md` y `data/ui_assets.json`.

Reglas obligatorias:
- No confíes en búsqueda indexada del repo; falla con frecuencia.
- Abre archivos por ruta exacta con fetch_file.
- Si digo que actualicé el repo o menciono `ejemplo.png`, asume que el repo está actualizado.
- No propongas parches temporales.
- No dupliques lógica si debe ser global.
- Si el cambio es grande, dame reemplazo completo de archivo.
- Si el cambio es puntual, dime archivo exacto, qué buscar y qué reemplazar.
- No tocar escenas aprobadas salvo bug real.
- No diagnosticar resize/fullscreen desde el runner/editor de Godot: ya se validó que el build exportado de Windows sí redimensiona correctamente.
- Si vuelve a haber dudas de resolución, validar en build exportado.

Estado actual:
- Backend cerrado.
- Title screen integrado con fondo, logo y botón visual.
- Resize funciona correctamente en build exportado.
- LoadGameModal ya tiene “Volver al título”.
- El siguiente bloque recomendado es Intro / Onboarding visual, empezando por `assets/backgrounds/intro_veil_crossing.png`.

Quiero continuar desde ahí de forma ordenada y finalista.

Después de reemplazarlo, haz commit/checkpoint. Este README ya deja registrado que el problema de resize 