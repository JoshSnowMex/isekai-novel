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
- El repo GitHub está conectado, pero la búsqueda indexada de GitHub puede fallar o no encontrar funciones existentes. No confiar en search para encontrar funciones. Abrir archivos concretos por ruta.

Importante: si se usa ChatGPT con GitHub connector, abrir archivos con `fetch_file` o raw, no inferir.

## Repositorio

Repositorio:

JoshSnowMex/isekai-novel
Branch principal actual:

main
Filosofía de trabajo acordada
Evitar UI tipo ERP/dashboard.
Priorizar experiencia de jugador.
Menos paneles redundantes.
El HUD debe ser la fuente principal para dinero, resistencia, acciones y fecha.
Las escenas deben sentirse como juego/visual novel, no como app administrativa.
No pedir al usuario que revise archivos si el asistente tiene acceso al repo.
No basarse en búsqueda indexada para confirmar si una función existe.
Abrir el archivo real antes de dar instrucciones.
Si una iteración sale mal, estabilizar antes de seguir metiendo features.
Si una escena requiere muchas opciones, usar popup/modal/scroll, no llenar el panel inferior hasta romper la pantalla.
Estado general del backend

El backend se considera completo/cerrado para pasar a UI.

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

No tocar backend salvo helpers visuales necesarios o bugs claros.

Escenas UI trabajadas
1. WorldMap

Estado: funcional, pero necesita pase visual/consistencia.

Ya tiene:

HUD superior.
Mapa grande.
Botones globales arriba derecha.
Tarjeta hover.
Ubicaciones clicables.
Click directo entra a ubicación.
NPCs presentes deberían aparecer en hover.
NPC desconocido aparece como ???.
Responsive.
Configurado con canvas_items y expand.

Problemas/pendientes conocidos:

El hover de ubicaciones se ajustó para moverse y no bloquear clicks.
El hover debe mostrar NPCs presentes usando ScheduleSystem.get_npc_location(id), no schedule directo viejo.
El panel del mapa a veces se ve raro con textos largos. Ajustar textos, no necesariamente el panel.
Los botones globales del WorldMap no son consistentes visualmente con escenas nuevas. En WorldMap están en tonos morados y estilo diferente; se quiere estandarizar con las escenas actuales.
El HUD trunca Mañana/fecha en algunas resoluciones. Revisar ui/components/world_hud_bar.gd y compactar o redistribuir texto.

Archivo importante:

scenes/map/world_map.gd
ui/components/location_hover_card.gd
ui/components/world_hud_bar.gd
ui/components/world_action_panel.gd

Nota crítica:
visit_location(location_id) debe mandar shop directo a SceneRouter.go_to_shop() y home directo a SceneRouter.go_to_home().

2. LocationScene

Estado: funcional, pero con bug intermitente de sprites NPC encimados.

Ya tiene:

Fondo por ubicación desde ui_assets.json.
HUD superior.
Botones globales:
Mapa
Bitácora
Guardar
Cargar
NPCs presentes como sprites/placeholders clicables.
Desconocidos como ???.
Acciones directas en panel inferior:
Acercarse a NPC.
Actividades de ubicación.
Las acciones del lugar ya no deberían estar escondidas detrás de “Acciones del lugar”.
Si no hay acciones disponibles, aparece Ir a casa.
Al hablar/regalar con NPC, se mantiene en interacción con NPC.
Si NPC ya no está disponible por schedule, debe salir de interacción.
Hover de acciones muestra información inmediata en panel inferior.
Tooltips nativos se evitaron por delay/ruido.

Problemas/pendientes conocidos:

En biblioteca de noche, cuando hay Selene y Seraphina, sus sprites a veces aparecen encimados o centrados.
El problema parece intermitente después de guardar/cargar o reentrar.
location_scene.gd ya tiene:
get_scaled_character_size()
get_bottom_panel_reserved_height()
get_stable_character_position()
get_character_position()
No duplicar esas funciones.
Si vuelve el error de duplicado, revisar que solo exista una copia.
Actualmente rebuild_characters() limpia character_positions_by_location.clear().
show_character_preview() ya no debería reconstruir botones ni meter Acciones del lugar.

Archivo importante:

scenes/location/location_scene.gd

Nota crítica:
No dar instrucciones sobre funciones de LocationScene sin abrir el archivo completo o raw. Ya hubo problemas por confiar en búsqueda indexada.

3. HomeScene

Estado: correcto / funcional.

Decisiones tomadas:

Se eliminó panel lateral Vínculos y cierre porque repetía HUD y se encimaba.
Casa queda limpia:
HUD.
Botones globales arriba derecha.
Fondo de casa.
Panel inferior.
Dormir mantiene al jugador en casa al despertar.
Dormir procesa mensajes narrativos.
Guardar/cargar funcionan desde casa.
Bitácora desde casa debe volver a casa.

Archivo:

scenes/home/home_scene.gd

Pendiente menor:
Ninguno urgente.

4. ShopScene

Estado: correcto / funcional tras varias iteraciones.

Decisiones tomadas:

Entrar a tienda desde mapa debe abrir ShopScene directo, no LocationScene.
La tienda es escaparate directo:
No botón intermedio Comprar.
No panel lateral.
No panel inferior innecesario.
Click en tarjeta compra directamente.
Hover muestra info compacta arriba.
Tarjetas cuadradas compactas.
Máximo 6 columnas para reservar espacio derecho.
Espacio derecho reservado para arte/tendero futuro.
Scroll existe, pero debe ocultarse si todo cabe.
Panel informativo arriba izquierda debe ser coherente con botones globales.

Archivo:

scenes/shop/shop_scene.gd

Pendiente menor:
Agregar assets reales de objetos/tendero en el futuro.

5. JournalScene / Bitácora

Estado: excelente / aprobado.

Diseño actual aprobado:

Navegación por capítulos.
Personas como tarjetas.
Detalle narrativo por personaje.
Mundo, calendario, recuerdos y unión separados.
Panel contextual.
Retorno correcto según escena de origen.
Placeholder de fondo final.

Archivo:

scenes/journal/journal_scene.gd

No tocar salvo bugs reales.

6. DateScene

Estado: NO aprobado / necesita rediseño.

La primera propuesta se sintió bien al inicio, pero después de pruebas largas se confirmó que la UI actual no sirve.

Problemas reportados:

Panel de localización ocupa espacio y aporta poco.
Panel narrativo es demasiado pequeño.
Resumen final se sale de pantalla.
Acciones/respuestas/gestos se desbordan.
Acciones en HBox abajo no escalan para:
muchas respuestas;
muchos gestos;
regalos;
textos largos.
Agrandar panel inferior empeoró la UI.
Progreso corregido de 100/73 a “Progreso 100% · Éxito desde 73%”, pero quedó oculto por encimamiento.
Para respuestas y gestos se necesita estrategia diferente.
Se confirmó que preguntas sí aparecen; inicialmente parecía que no por azar.
Respuestas incorrectas en cita especial ya se pudieron seleccionar, pero la navegación sigue siendo mala.

Conclusión de diseño:

La DateScene debe rehacerse con estructura:

Top:
- Header compacto:
  Cita con Lyria · Biblioteca/Jardines · Progreso 80% · Éxito desde 73%

Centro:
- NPC / sprite a la derecha o integrado visualmente.
- Panel narrativo grande con scroll.

Abajo:
- Solo acciones base compactas:
  Hablar
  Regalar
  Gesto
  Terminar cita

Opciones largas:
- Popup/modal centrado con scroll para:
  respuestas de preguntas;
  selección de regalos;
  selección de gestos;
  confirmaciones importantes.

Importante:
No intentar resolver listas largas agrandando el panel inferior. Eso rompe la escena.

Archivo:

scenes/date/date_scene.gd

Siguiente tarea real:
Reemplazo completo de date_scene.gd con popup/modal y narrativa grande.

Guardado / carga

Estado: parcialmente corregido.

SaveManager guarda:

player
current_day
current_month
current_weekday_index
current_time_block
current_action_index
current_location_id
final_union_npc_id

Archivo:

core/save_manager.gd

SceneRouter ya tiene:

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

Archivo:

core/scene_router.gd

main_menu.gd ya llama:

SceneRouter.go_to_current_location_scene()

en continuar y cargar guardado manual.

Archivo:

scenes/menu/main_menu.gd

Pendientes:

Confirmar en juego que cargar desde guardado manual vuelve a:
Casa si guardaste en casa.
LocationScene si guardaste en biblioteca.
ShopScene si guardaste en tienda.
No guardar/restaurar DateScene todavía salvo decisión explícita. Puede ser complejo y no se necesita de inmediato.
HUD / tiempo

Se propuso y aplicó concepto de horas para hacer el avance del día más perceptible.

Idea:

08:00 · Mañana
10:00 · Mañana
12:00 · Tarde
15:00 · Tarde
18:00 · Tarde
20:00 · Noche
22:00 · Noche
Medianoche

Problema actual:
En WorldMap puede truncarse texto como Mañana.

Archivo:

ui/components/world_hud_bar.gd

Pendiente:
Compactar layout del HUD para evitar truncamiento.

Assets / placeholders

Regla:

Usar nombres finales de asset.
No usar nombres genéricos tipo npc1.png.

Ejemplos:

Lyria_talking.png
location_home_forastero.png
location_shop_umbral.png
journal_forastero.png
date_scene_default.png

Archivo central:

data/ui_assets.json
Archivos clave del proyecto
core/data_manager.gd
core/game_manager.gd
core/save_manager.gd
core/scene_router.gd

systems/date_system.gd o core/date_system.gd
systems/relationship_system.gd o core/relationship_system.gd
systems/schedule_system.gd o core/schedule_system.gd

scenes/map/world_map.gd
scenes/location/location_scene.gd
scenes/home/home_scene.gd
scenes/shop/shop_scene.gd
scenes/journal/journal_scene.gd
scenes/date/date_scene.gd
scenes/menu/main_menu.gd

ui/components/visual_asset.gd
ui/components/location_map_button.gd
ui/components/world_hud_bar.gd
ui/components/world_action_panel.gd
ui/components/location_hover_card.gd

data/ui_assets.json
data/locations.json
data/items.json
data/date_locations.json
data/date_moves.json
Capturas usadas para diagnóstico

El capitán suele subir capturas al root del repo, por ejemplo:

ejemplo.png
tienda1.png
tienda2.png

Antes de opinar sobre UI, revisar esas capturas si existen.

Estado emocional / nota de continuidad

La sesión más reciente fue frustrante porque se dieron instrucciones basadas en suposiciones y búsqueda indexada fallida. Evitar repetir eso.

Regla para el siguiente chat:

Abrir archivo real.
Leerlo.
Si el fetch se trunca, usar raw/fetch o pedir rangos si la herramienta lo permite.
No decir “si existe tal función”.
No pedir al capitán que revise algo que el asistente puede revisar.
No proponer cambios sin ubicar el estado actual del archivo.
No tocar varias escenas al mismo tiempo si hay inestabilidad.
Priorizar estabilizar antes de avanzar.
Próximo paso recomendado

No avanzar a nuevas features.

Primero hacer estabilización:

Confirmar que LocationScene compila tras eliminar duplicados.
Probar biblioteca de noche con Selene y Seraphina:
no deben encimarse;
deben aparecer alineadas desde izquierda.
Confirmar guardado/carga:
guardar en casa y cargar vuelve a casa;
guardar en biblioteca y cargar vuelve a biblioteca;
guardar en tienda y cargar vuelve a tienda.
Confirmar WorldMap hover:
muestra NPCs presentes;
no trunca mal textos importantes.
Luego rehacer DateScene completa con popup/modal.

Última advertencia importante

No repetir el error de modificar DateScene por pedazos. La escena debe reemplazarse completa cuando se retome, porque la estructura actual es la causa de la mala experiencia.


Lamento de verdad la vuelta absurda de hoy, capitán. Este README deja candados explícitos para que al retomar no se vuelva a trabajar contra archivos imaginarios ni contra estados viejos.

Prompt sugerido para continuar en otro chat

Usa este prompt exacto:

Hola, continuemos el desarrollo de mi juego Godot “Isekai Novel”.

Contexto obligatorio:
- Revisa primero el README.md actualizado del repositorio.
- El repo es `JoshSnowMex/isekai-novel`.
- No confíes en la búsqueda indexada de GitHub para encontrar funciones; puede fallar.
- Antes de proponer cambios, abre los archivos concretos por ruta y lee el estado real.
- No me digas “si existe tal función”; verifica tú el archivo.
- No me pidas que te pase archivos si tienes acceso al repo.
- Soy backend Java/Spring y novato en Godot, necesito instrucciones exactas: archivo, qué reemplazar, dónde pegar y qué probar.
- Si el cambio es grande, dame reemplazo completo de archivo.
- No quiero soluciones temporales ni UI tipo ERP/dashboard.
- Trabajamos como versión final productiva, aunque usemos placeholders.
- Los placeholders deben tener nombres finales de asset.

Estado actual:
- Backend completo/cerrado.
- UI aprobada:
  - WorldMap funcional pero necesita ajuste visual/consistencia.
  - HomeScene aprobada.
  - ShopScene aprobada.
  - JournalScene aprobada.
  - LocationScene funcional pero hay que confirmar bug de sprites encimados.
- DateScene NO aprobada. Debe rehacerse con:
  - narrativa grande con scroll;
  - header compacto;
  - acciones base abajo;
  - popup/modal con scroll para respuestas, regalos y gestos;
  - sin panel grande inútil de localización;
  - sin opciones desbordadas.

Antes de tocar DateScene:
1. Revisa `scenes/location/location_scene.gd`.
2. Confirma que no haya funciones duplicadas.
3. Confirma que los NPCs se posicionan desde izquierda.
4. Revisa `core/save_manager.gd`, `core/scene_router.gd`, `scenes/menu/main_menu.gd`.
5. Confirma que cargar partida vuelve a la escena correspondiente usando `SceneRouter.go_to_current_location_scene()`.

Después de esa revisión, dame:
- diagnóstico breve basado en archivos reales;
- correcciones puntuales si hay bug;
- y luego el reemplazo completo de `scenes/date/date_scene.gd` con popup/modal.