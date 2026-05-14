# Isekai Novel — Estado de desarrollo y guía de continuidad

## Propósito de este README

Este README existe para que cualquier nueva conversación de ChatGPT pueda continuar el desarrollo del juego sin perder contexto ni repetir decisiones ya tomadas.

El proyecto es una Visual Novel / simulador de historias inspirado en SimGirls de Newgrounds, pero con una filosofía más narrativa y sistémica:

- No es un dating sim plano.
- La historia debe emerger de relaciones, conocimiento, decisiones, lealtad, celos, tensión, estado del mundo y consecuencias.
- La main storyline no debe depender rígidamente del calendario.
- El calendario sirve más para cumpleaños, aniversarios y memoria emocional.
- Se trabaja siempre pensando en versión final productiva, aunque usemos placeholders.
- No se quieren soluciones temporales ni “luego lo cambiamos”.
- Si se detecta que algo debe cambiarse para ser finalista, se cambia.
- Los placeholders deben usar nombres finales de asset, por ejemplo `Lyria_talking.png`, no `npc1.png`.
- Evitar UI tipo ERP/dashboard.
- Priorizar experiencia de jugador.
- Menos paneles redundantes.
- Las escenas deben sentirse como juego/visual novel, no como app administrativa.

## Perfil del capitán / dueño del proyecto

El dueño del proyecto es backend Java/Spring y novato en Godot.

Necesita instrucciones claras y concretas:

- Archivo exacto.
- Qué reemplazar.
- Dónde pegar.
- Qué probar.
- Si el cambio es grande, preferir reemplazo completo de archivo.
- No dar instrucciones basadas en “probablemente” o “si existe”.
- Antes de proponer cambios, revisar archivos reales del repositorio.
- El repo GitHub está conectado, pero la búsqueda indexada de GitHub puede fallar o no encontrar funciones existentes.
- No confiar en `search` para encontrar funciones.
- Abrir archivos concretos por ruta con `fetch_file` o raw.
- No pedir al usuario que pase archivos si el asistente tiene acceso al repo.
- Si el fetch se trunca, buscar otra forma de leer el archivo real antes de proponer cambios.
- No trabajar contra versiones viejas si el usuario dice que hizo commit o actualizó el repo.

## Repositorio

Repositorio:

```text
JoshSnowMex/isekai-novel
Branch principal actual:

main

README correcto:

readme.md

Importante: el archivo está en minúsculas. No usar README.md.

Filosofía de trabajo acordada
Reglas de desarrollo
Trabajar como si fuera versión final publicable.
No meter código provisional “para probar y luego vemos”.
No hacer soluciones temporales.
No duplicar lógica por escena si debe ser sistema global.
Si algo debe ser común, crear componente/helper reusable.
No modificar varias escenas a ciegas.
Si algo salió mal, estabilizar antes de seguir metiendo features.
Si una escena requiere muchas opciones, usar popup/modal/scroll, no llenar paneles hasta romper pantalla.
Cuando algo es dato, debe ir en JSON/datos, no hardcodeado en escena.
Cuando algo es lógica global, debe ir en sistema/componente global, no copiado en cada escena.
El capitán prefiere cambios por bloques completos o instrucciones exactas, no microparches ambiguos.
Si el cambio en un archivo es grande, dar reemplazo completo.
Si son cambios pequeños, decir exactamente qué buscar y qué reemplazar.
Reglas de UI
Evitar UI tipo ERP/dashboard.
No saturar con paneles.
No repetir información que ya existe en HUD.
El HUD es la fuente principal para dinero, resistencia, acciones y fecha.
Usar modales para listas grandes:
regalos;
lugares de cita;
respuestas;
gestos/movimientos;
carga de partida.
Los paneles inferiores son para información contextual y acciones compactas, no para listas infinitas.
Las tarjetas deben sentirse visuales, especialmente en selección de personajes/clases.
Las pantallas deben sentirse como VN/fantasía, no como formulario administrativo.
Estado general del backend

El backend se considera completo/cerrado para pasar a UI/assets.

Sistemas implementados:

Ciclo de día.
Acciones.
Casa.
Guardado/carga/autosave.
Ubicaciones.
NPC schedules.
Diálogo.
Tienda/items/regalos.
Citas.
Movimientos de cita.
Revelación de información.
Bitácora.
Estado del mundo.
Storylets.
Milestones.
Rivalidades.
Final union.
Calendario emocional.
Postgame completo.
Recompensas dinámicas.

No tocar backend salvo:

bugs claros;
helpers visuales necesarios;
refactors de guardado/carga si se implementan slots.
Estado actual aprobado de escenas
1. Title Screen / MainMenu

Estado: aprobado visualmente tras rediseño.

Archivo:

scenes/menu/main_menu.gd

Características actuales:

Fondo completo con placeholder final:
res://assets/backgrounds/title_luminaria_threshold.png
Panel de título con:
título del juego;
subtítulo;
tono del juego.
Panel de menú con:
Nuevo juego;
Continuar último autosave;
Cargar guardado manual;
Salir.
Continuar último autosave carga autosave si existe y si no manual.
Cargar guardado manual carga manual directamente.
Ambos usan SceneRouter.go_to_current_location_scene() después de cargar.

Pendiente visual:

El panel donde ahora está el texto del título debe convertirse en espacio de logo/título gráfico.
Asset previsto:
assets/ui/title_logo_isekai_novel.png -> logo/título principal para pantalla de título.
Fondo previsto:
assets/backgrounds/title_luminaria_threshold.png -> fondo de pantalla de título.
2. Intro / Onboarding

Estado: aprobado visualmente y funcionalmente.

Archivo:

scenes/intro/intro_scene.gd

Flujo aprobado:

Nuevo juego
→ Prólogo paginado
→ Selección de apariencia
→ Selección de clase/camino
→ Confirmación final
→ WorldMap

Decisiones tomadas:

Prólogo con texto abajo y fondo/arte limpio.
Header compacto arriba.
Panel inferior fijo y estable.
Tarjetas visuales sobre el background, fuera del panel inferior.
Botones siempre consistentes.
Apariencia:
1 fila x 3 tarjetas verticales.
Opciones:
Forastero
Forastera
Forma velada
Clase:
1 fila x 6 tarjetas verticales.
Pensadas para assets de cuerpo completo.
Continuar deshabilitado hasta seleccionar apariencia/clase.
Confirmación final ya no suena a base de datos.
Texto final usa estilo:
Camino elegido: Forastera Sensible, bajo el signo de luz tenue.
El element de clase sí importa como parte de modificadores/identidad de clase, pero no debe mostrarse como campo técnico “Elemento: X”.
Internamente Forma velada puede mapearse a non_binary si backend lo espera, pero el jugador no debe ver “No binario”.

Assets previstos por código:

assets/backgrounds/intro_veil_crossing.png
assets/backgrounds/intro_appearance_selection.png
assets/backgrounds/intro_class_selection.png
assets/backgrounds/intro_confirm_outsider_<appearance>_<class>.png

assets/player/outsider_male_base.png
assets/player/outsider_female_base.png
assets/player/outsider_veiled_base.png

assets/player/outsider_male_<class>.png
assets/player/outsider_female_<class>.png
assets/player/outsider_veiled_<class>.png

Apariencias normalizadas en nombres de assets:

Forastero -> male
Forastera -> female
Forma velada -> veiled

Clases normalizadas esperadas:

sensitive
bold
scholar
charming
steadfast
balanced

Ejemplos:

assets/player/outsider_female_sensitive.png
assets/player/outsider_male_bold.png
assets/player/outsider_veiled_scholar.png
3. WorldMap

Estado: funcional y visualmente mucho más consistente.

Archivo:

scenes/map/world_map.gd

Componentes:

ui/components/location_hover_card.gd
ui/components/world_hud_bar.gd
ui/components/world_action_panel.gd
ui/components/location_map_button.gd

Ya tiene:

HUD superior.
Mapa grande.
Botones globales arriba derecha.
Tarjeta hover.
Ubicaciones clicables.
Click directo entra a ubicación.
NPCs presentes aparecen en hover.
NPC desconocido aparece como ???.
Hover se mueve para no bloquear clicks.
Responsive.
Configurado con canvas_items y expand.

Decisiones:

visit_location(location_id) manda:
home directo a SceneRouter.go_to_home();
shop directo a SceneRouter.go_to_shop();
otras ubicaciones a SceneRouter.go_to_location().
El texto “Viajar” en hover puede ser redundante porque el mouse no llega al hover; considerar removerlo o reemplazarlo por un hint más útil si molesta.

Pendiente menor:

Pase visual final de botones/colores cuando entren assets.
El mapa aún puede beneficiarse de fondo real.
4. LocationScene

Estado: aprobado / funciona correctamente en cada localización.

Archivo:

scenes/location/location_scene.gd

Ya tiene:

Fondo por ubicación desde ui_assets.json.
HUD superior.
Botones globales:
Mapa;
Bitácora;
Guardar;
Cargar.
NPCs presentes como sprites/placeholders clicables.
Desconocidos como ???.
Acciones directas en panel inferior:
acercarse a NPC;
actividades de ubicación.
Las acciones del lugar ya no están escondidas detrás de “Acciones del lugar”.
Si no hay acciones disponibles, aparece opción apropiada.
Al hablar/regalar con NPC, mantiene interacción con NPC.
Si NPC ya no está disponible por schedule, sale de interacción.
Hover de acciones muestra información inmediata en panel inferior.
Tooltips nativos se evitaron por delay/ruido.
Bug de NPCs encimados al cargar fue corregido.
NPCs se posicionan desde izquierda.
No hay funciones duplicadas relacionadas a posicionamiento.

Funciones importantes ya existentes:

get_scaled_character_size()
get_bottom_panel_reserved_height()
get_stable_character_position()
get_character_position()

No duplicar estas funciones.

Decisión aprobada:

LocationScene funciona perfectamente en cada localización.
No tocar salvo bug real.
5. HomeScene

Estado: aprobado / funcional.

Archivo:

scenes/home/home_scene.gd

Decisiones tomadas:

Se eliminó panel lateral redundante.
Casa queda limpia:
HUD;
botones globales arriba derecha;
fondo de casa;
panel inferior.
Dormir mantiene al jugador en casa al despertar.
Dormir procesa mensajes narrativos.
Guardar/cargar funcionan desde casa.
Bitácora desde casa vuelve a casa.
Panel centrado y consistente con otras escenas.

No tocar salvo bugs reales.

6. ShopScene

Estado: aprobado / funcional.

Archivo:

scenes/shop/shop_scene.gd

Decisiones tomadas:

Entrar a tienda desde mapa abre ShopScene directo, no LocationScene.
Tienda es escaparate directo:
no botón intermedio Comprar;
no panel lateral inútil;
click en tarjeta compra directamente;
hover muestra info compacta arriba;
tarjetas cuadradas compactas.
Máximo 6 columnas para reservar espacio derecho.
Espacio derecho reservado para arte/tendero futuro.
Scroll existe, pero debe ocultarse si todo cabe.
Panel informativo arriba izquierda coherente con botones globales.
Preview de items usa shop_preview desde data/items.json, no diccionario hardcodeado en escena.
Descripciones arriba ya no se cortan.
Los regalos se ordenan por precio.

Assets futuros:

assets/backgrounds/location_shop_umbral.png -> fondo de la tienda
assets/npcs/shop_vendor_umbral.png -> tendero o figura del umbral
assets/items/<item>.png -> iconos/cartas de regalos, si se decide usarlos

Pendiente menor:

Reemplazar placeholder del tendero.
Decidir si los objetos tendrán iconos individuales o si se mantiene tarjeta textual elegante.
7. JournalScene / Bitácora

Estado: aprobado / excelente.

Archivo:

scenes/journal/journal_scene.gd

Diseño actual aprobado:

Navegación por capítulos.
Personas como tarjetas.
Detalle narrativo por personaje.
Mundo, calendario, recuerdos y unión separados.
Panel contextual.
Retorno correcto según escena de origen.
Placeholder de fondo final.
Se corrigieron listas infinitas estilo ERP.
Se aplicó grid/bloques donde hacía falta.

No tocar salvo bugs reales.

8. DateScene

Estado: aprobado tras rediseño.

Archivo:

scenes/date/date_scene.gd

Problemas previos resueltos:

Panel inútil de localización eliminado.
Narrativa con mejor espacio.
Header compacto.
Acciones base abajo.
Popup/modal con scroll para:
respuestas;
regalos;
movimientos/gestos;
lugares de cita.
Resumen final ya no se corta.
Modal de regalos funciona.
Modal de lugares de cita funciona.
Cita especial funciona.
Pregunta/respuesta ya no pierde el texto al hover.
No hay listas desbordadas en panel inferior.

Decisión:

DateScene ya está funcional y aprobada.
No tocar salvo bug real o asset pass.
9. Modal global de carga

Estado: aprobado y funcionando.

Archivo nuevo:

ui/components/load_game_modal.gd

Integrado en:

scenes/map/world_map.gd
scenes/location/location_scene.gd
scenes/home/home_scene.gd
scenes/shop/shop_scene.gd

Comportamiento aprobado:

Botón Cargar dentro del juego abre modal.
Modal muestra:
Cargar partida
Último autosave
Guardado manual
Cancelar
Texto de instrucción eliminado porque se sentía tutorial/administrativo.
Si no hay saves, muestra:
No hay partidas guardadas.
Último autosave carga user://autosave.json.
Guardado manual carga user://savegame.json.
Cada archivo vuelve al lugar donde se generó porque cada save contiene current_location_id.
Después de cargar usa:
SceneRouter.go_to_current_location_scene()

Archivos involucrados:

core/save_manager.gd
core/scene_router.gd
ui/components/load_game_modal.gd

Helpers añadidos o esperados:

En SaveManager:

func load_autosave_game() -> bool
func has_autosave_file() -> bool

En SceneRouter:

func load_autosave_and_route() -> bool
func load_manual_and_route() -> bool

Pendiente aprobado para próxima vez:

Agregar opción Volver al título dentro del modal de carga.
No poner botón extra en todos los paneles superiores para no saturar.
Modal final sugerido:
Cargar partida

Último autosave
Guardado manual
Volver al título
Cancelar

La opción Volver al título debe llamar:

SceneRouter.go_to_main_menu()
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

SaveManager guarda:

player
current_day
current_month
current_weekday_index
current_time_block
current_action_index
current_location_id
final_union_npc_id

SceneRouter.go_to_current_location_scene() debe mantenerse así conceptualmente:

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

No guardar/restaurar DateScene todavía salvo decisión explícita. Puede ser complejo y no se necesita de inmediato.

Duda futura: 3 slots de guardado

El sistema de 3 slots NO está implementado.

No es imposible, pero es una refactorización real.

Hoy existe:

user://autosave.json
user://savegame.json

Para 3 slots habría que migrar a algo como:

user://slot_1_autosave.json
user://slot_1_manual.json
user://slot_2_autosave.json
user://slot_2_manual.json
user://slot_3_autosave.json
user://slot_3_manual.json

También haría falta:

GameManager.current_save_slot

Y tocar:

core/save_manager.gd
scenes/menu/main_menu.gd
ui/components/load_game_modal.gd
pantalla de nuevo juego
modal de carga
botones de guardar

Recomendación:

No mezclar save slots con assets.
Tratarlo como bloque independiente futuro:
Save Slots 1/2/3;
nuevo juego elige slot;
cargar muestra slots;
guardar manual guarda en slot activo;
autosave guarda en slot activo.
HUD / tiempo

Estado: corregido.

HUD ya no trunca.
Se mantuvo el día visible porque es mecánica importante:
los NPCs tienen schedule por día;
el jugador necesita saber qué día es para buscar personajes.

No quitar día del HUD.

Assets / placeholders

Regla:

Usar nombres finales de asset.
No usar nombres genéricos tipo npc1.png.
No meter archivos con nombres improvisados.
Primero inventariar lo que el código espera.
Hacer assets por bloque.
Orden recomendado de assets
Title screen.
Onboarding / intro.
Forastero / Forastera / Forma velada base.
Clases del Forastero.
Fondos principales del juego.
NPCs.
Items/iconos si se decide.
Logo/UI polish.
Tabla inicial de assets previstos

Esta tabla es inicial y debe verificarse contra archivos reales antes de generar assets.

Prioridad 1 — Pantalla de título
Asset	Para qué sirve
assets/backgrounds/title_luminaria_threshold.png	Fondo de la pantalla de título. Debe vender el tono general del juego: fantasía isekai, romance, misterio, umbral hacia Luminaria.
assets/ui/title_logo_isekai_novel.png	Logo/título gráfico principal del juego. Sustituirá el texto actual Isekai Novel en el panel de título.

Notas:

El panel de título actual debe convertirse en espacio para logo.
El fondo debe dejar área legible para menú y logo.
Prioridad 2 — Fondos de onboarding
Asset	Para qué sirve
assets/backgrounds/intro_veil_crossing.png	Fondo del prólogo. Representa el cruce del Velo / llegada del protagonista a Luminaria.
assets/backgrounds/intro_appearance_selection.png	Fondo de selección de apariencia. Debe permitir que las tres tarjetas de apariencia se vean claras encima.
assets/backgrounds/intro_class_selection.png	Fondo de selección de clase/camino. Debe permitir seis tarjetas verticales encima sin ruido visual.
assets/backgrounds/intro_confirm_outsider_male_sensitive.png	Fondo de confirmación para Forastero Sensible.
assets/backgrounds/intro_confirm_outsider_male_bold.png	Fondo de confirmación para Forastero Audaz.
assets/backgrounds/intro_confirm_outsider_male_scholar.png	Fondo de confirmación para Forastero Erudito.
assets/backgrounds/intro_confirm_outsider_male_charming.png	Fondo de confirmación para Forastero Encantador.
assets/backgrounds/intro_confirm_outsider_male_steadfast.png	Fondo de confirmación para Forastero Disciplinado/Firme.
assets/backgrounds/intro_confirm_outsider_male_balanced.png	Fondo de confirmación para Forastero Equilibrado.
assets/backgrounds/intro_confirm_outsider_female_sensitive.png	Fondo de confirmación para Forastera Sensible.
assets/backgrounds/intro_confirm_outsider_female_bold.png	Fondo de confirmación para Forastera Audaz.
assets/backgrounds/intro_confirm_outsider_female_scholar.png	Fondo de confirmación para Forastera Erudita.
assets/backgrounds/intro_confirm_outsider_female_charming.png	Fondo de confirmación para Forastera Encantadora.
assets/backgrounds/intro_confirm_outsider_female_steadfast.png	Fondo de confirmación para Forastera Disciplinada/Firme.
assets/backgrounds/intro_confirm_outsider_female_balanced.png	Fondo de confirmación para Forastera Equilibrada.
assets/backgrounds/intro_confirm_outsider_veiled_sensitive.png	Fondo de confirmación para Forma velada Sensible.
assets/backgrounds/intro_confirm_outsider_veiled_bold.png	Fondo de confirmación para Forma velada Audaz.
assets/backgrounds/intro_confirm_outsider_veiled_scholar.png	Fondo de confirmación para Forma velada Erudita.
assets/backgrounds/intro_confirm_outsider_veiled_charming.png	Fondo de confirmación para Forma velada Encantadora.
assets/backgrounds/intro_confirm_outsider_veiled_steadfast.png	Fondo de confirmación para Forma velada Disciplinada/Firme.
assets/backgrounds/intro_confirm_outsider_veiled_balanced.png	Fondo de confirmación para Forma velada Equilibrada.

Nota:

Generar 18 fondos de confirmación puede ser mucho.
Alternativa aceptable: usar un fondo genérico intro_confirm_outsider.png + sprite/tarjeta visual del personaje elegido.
Pero el código actual fue orientado a poder pedir fondos por combinación.
Antes de generar 18 imágenes, decidir si queremos:
una imagen por combinación;
o fondo genérico + personaje visual.

Recomendación del capitán en sesión:

Le gustaba la idea de fondo por combinación elegida.
Pero se puede discutir antes de producir 18 assets.
Prioridad 3 — Apariencia base del Forastero
Asset	Para qué sirve
assets/player/outsider_male_base.png	Tarjeta/sprite base de Forastero masculino en selección de apariencia.
assets/player/outsider_female_base.png	Tarjeta/sprite base de Forastera femenina en selección de apariencia.
assets/player/outsider_veiled_base.png	Tarjeta/sprite base de Forma velada en selección de apariencia.

Notas:

Deben ser cuerpo completo o casi cuerpo completo.
Formato vertical.
Deben funcionar como tarjetas visuales sobre background.
La Forma velada debe sentirse fantasy, no etiqueta política/social.
Prioridad 4 — Clases del Forastero

Cada clase debe tener assets según apariencia elegida.

Forastero masculino
Asset	Para qué sirve
assets/player/outsider_male_sensitive.png	Tarjeta/sprite cuerpo completo para Forastero Sensible.
assets/player/outsider_male_bold.png	Tarjeta/sprite cuerpo completo para Forastero Audaz.
assets/player/outsider_male_scholar.png	Tarjeta/sprite cuerpo completo para Forastero Erudito.
assets/player/outsider_male_charming.png	Tarjeta/sprite cuerpo completo para Forastero Encantador.
assets/player/outsider_male_steadfast.png	Tarjeta/sprite cuerpo completo para Forastero Disciplinado/Firme.
assets/player/outsider_male_balanced.png	Tarjeta/sprite cuerpo completo para Forastero Equilibrado.
Forastera femenina
Asset	Para qué sirve
assets/player/outsider_female_sensitive.png	Tarjeta/sprite cuerpo completo para Forastera Sensible.
assets/player/outsider_female_bold.png	Tarjeta/sprite cuerpo completo para Forastera Audaz.
assets/player/outsider_female_scholar.png	Tarjeta/sprite cuerpo completo para Forastera Erudita.
assets/player/outsider_female_charming.png	Tarjeta/sprite cuerpo completo para Forastera Encantadora.
assets/player/outsider_female_steadfast.png	Tarjeta/sprite cuerpo completo para Forastera Disciplinada/Firme.
assets/player/outsider_female_balanced.png	Tarjeta/sprite cuerpo completo para Forastera Equilibrada.
Forma velada
Asset	Para qué sirve
assets/player/outsider_veiled_sensitive.png	Tarjeta/sprite cuerpo completo para Forma velada Sensible.
assets/player/outsider_veiled_bold.png	Tarjeta/sprite cuerpo completo para Forma velada Audaz.
assets/player/outsider_veiled_scholar.png	Tarjeta/sprite cuerpo completo para Forma velada Erudita.
assets/player/outsider_veiled_charming.png	Tarjeta/sprite cuerpo completo para Forma velada Encantadora.
assets/player/outsider_veiled_steadfast.png	Tarjeta/sprite cuerpo completo para Forma velada Disciplinada/Firme.
assets/player/outsider_veiled_balanced.png	Tarjeta/sprite cuerpo completo para Forma velada Equilibrada.

Notas:

Las tarjetas de clase son 1x6 en horizontal.
Deben ser verticales y legibles aunque sean estrechas.
Mejor no meter demasiada información en la imagen.
La información de ventajas/riesgos va en panel inferior, no en el asset.
Prioridad 5 — Fondos de ubicaciones

Verificar contra data/ui_assets.json, data/locations.json y escenas antes de generar.

Assets mencionados/esperados por filosofía:

Asset	Para qué sirve
assets/backgrounds/world_map_luminaria.png	Fondo del mapa de Luminaria.
assets/backgrounds/location_home_forastero.png	Fondo de la Casa del Forastero.
assets/backgrounds/location_shop_umbral.png	Fondo de la Tienda del Umbral.
assets/backgrounds/location_library_alba.png	Fondo de Biblioteca / Rincón de Alba si existe esa ubicación.
assets/backgrounds/journal_forastero.png	Fondo de la Bitácora / Journal.
assets/backgrounds/date_scene_default.png	Fondo genérico de DateScene si no hay fondo específico de cita.

Pendiente:

Revisar data/ui_assets.json para extraer lista oficial completa.
No generar fondos de ubicación hasta confirmar nombres exactos.
Prioridad 6 — NPCs

Verificar contra data/npcs.json y data/ui_assets.json.

Ejemplos de nombres finales esperados por regla:

Asset	Para qué sirve
assets/npcs/Lyria_talking.png	Sprite/arte de Lyria hablando o en interacción.
assets/npcs/<NPC>_portrait.png	Retrato de NPC para bitácora/modal si se usa.
assets/npcs/<NPC>_location_sprite.png	Sprite de NPC en LocationScene.
assets/npcs/<NPC>_date_sprite.png	Sprite de NPC en DateScene si se separa de talking.

Pendiente:

No generar NPCs hasta revisar data/npcs.json y los nombres reales de NPCs.
Confirmar naming exacto: mayúsculas/minúsculas importan.
Prioridad 7 — Items / regalos

Verificar contra data/items.json.

Potencial:

Asset	Para qué sirve
assets/items/flowers.png	Icono/carta de Flores.
assets/items/ancient_books.png	Icono/carta de Libros antiguos.
assets/items/symbolic_art.png	Icono/carta de Arte simbólico.
assets/items/weapons.png	Icono/carta de Armas.
assets/items/wine.png	Icono/carta de Vino.
assets/items/special_tea.png	Icono/carta de Té especial.
assets/items/sweets.png	Icono/carta de Dulces.
assets/items/simple_jewels.png	Icono/carta de Joyas simples.
assets/items/clothes.png	Icono/carta de Ropa.
assets/items/music_box.png	Icono/carta de Caja de música.
assets/items/maps.png	Icono/carta de Mapas.
assets/items/mana_gems.png	Icono/carta de Gemas de maná.
assets/items/tech_prototypes.png	Icono/carta de Prototipos tecnológicos.
assets/items/trophies.png	Icono/carta de Trofeos.
assets/items/coins.png	Icono/carta de Dinero/monedas.
assets/items/blank_diaries.png	Icono/carta de Diarios en blanco.
assets/items/sacred_objects.png	Icono/carta de Objetos sagrados.
assets/items/gadgets.png	Icono/carta de Gadgets.
assets/items/desserts.png	Icono/carta de Postres.
assets/items/narrative_secrets.png	Icono/carta de Secretos narrativos.

Pendiente:

La ShopScene funciona bien sin iconos; decidir si meter iconos suma o confunde.
Si se meten iconos, mantener claridad de compra/precio.
Archivos clave del proyecto
Core
core/data_manager.gd
core/game_manager.gd
core/save_manager.gd
core/scene_router.gd
Systems
systems/date_system.gd o core/date_system.gd
systems/relationship_system.gd o core/relationship_system.gd
systems/schedule_system.gd o core/schedule_system.gd

Verificar rutas reales antes de tocar.

Scenes
scenes/menu/main_menu.gd
scenes/intro/intro_scene.gd
scenes/map/world_map.gd
scenes/location/location_scene.gd
scenes/home/home_scene.gd
scenes/shop/shop_scene.gd
scenes/journal/journal_scene.gd
scenes/date/date_scene.gd
UI components
ui/components/visual_asset.gd
ui/components/load_game_modal.gd
ui/components/location_map_button.gd
ui/components/world_hud_bar.gd
ui/components/world_action_panel.gd
ui/components/location_hover_card.gd
Data
data/ui_assets.json
data/locations.json
data/items.json
data/date_locations.json
data/date_moves.json
data/npcs.json
data/player_classes.json
Capturas usadas para diagnóstico

El capitán suele subir capturas al root del repo, por ejemplo:

ejemplo.png
ejemplo1.png
ejemplo2.png
tienda1.png
tienda2.png

Antes de opinar sobre UI, revisar esas capturas si existen y si el usuario las menciona.

Estado emocional / nota de continuidad

La sesión anterior fue buena y productiva, pero hubo un tropiezo importante: se propuso una solución provisional para Cargar dentro del juego, copiando helpers por escena y diciendo “luego hacemos modal”. Eso fue contra la filosofía del proyecto.

Corrección aplicada:

Se creó modal global reusable.
Se centralizó carga/ruteo.
Se respetó que autosave/manual vuelvan al lugar donde se generaron.

Regla para siguientes sesiones:

No proponer soluciones “rápidas” si contradicen la versión final.
Si algo debe ser modal/componente global, hacerlo así desde el inicio.
Si el usuario señala que algo va contra filosofía, corregir rumbo sin insistir.
Próximo paso recomendado

Al retomar:

Leer este readme.md.
Revisar archivos reales, no inferir.
Agregar Volver al título al LoadGameModal.
Después hacer inventario oficial de assets leyendo:
data/ui_assets.json
scenes/menu/main_menu.gd
scenes/intro/intro_scene.gd
scenes/map/world_map.gd
scenes/home/home_scene.gd
scenes/shop/shop_scene.gd
scenes/location/location_scene.gd
scenes/date/date_scene.gd
scenes/journal/journal_scene.gd
data/locations.json
data/date_locations.json
data/npcs.json
data/items.json
Devolver tabla oficial:
ruta exacta del asset;
para qué sirve;
prioridad;
escena que lo usa;
si ya está en código o es propuesta.
Empezar assets por bloque, primero:
Title screen;
onboarding.
Prompt sugerido para continuar en otro chat

Usa este prompt exacto:

Estamos haciendo un juego Godot llamado “Isekai Novel”.

Lee primero el archivo `readme.md` del repositorio `JoshSnowMex/isekai-novel` para saber en qué nos quedamos.

Reglas obligatorias:
- No confíes en búsqueda indexada de GitHub para encontrar funciones.
- Abre archivos concretos por ruta antes de proponer cambios.
- No digas “si existe tal función”; verifica el archivo.
- No me pidas archivos si tienes acceso al repo.
- Soy backend Java/Spring y novato en Godot: necesito archivo exacto, qué reemplazar, dónde pegar y qué probar.
- No quiero soluciones temporales ni “luego vemos”.
- Trabajamos como versión final productiva, aunque usemos placeholders.
- Si algo es global, debe ser componente/helper global, no duplicado por escena.
- Evitar UI tipo ERP/dashboard.
- Los placeholders deben tener nombres finales de asset.

Nos quedamos justo antes de iniciar assets.
Antes de assets falta agregar “Volver al título” al modal global de carga.
Después hay que hacer inventario oficial de assets por bloque con tabla:
ruta -> para qué sirve -> prioridad -> escena que lo usa.

