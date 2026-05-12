# Isekai Novel — Estado del Proyecto

## Resumen

Isekai Novel es un simulador de historias basado en citas, inspirado en juegos tipo Sim Girls, pero diseñado para que las relaciones generen consecuencias narrativas reales en el mundo.

El objetivo no es crear un dating sim plano donde subir afinidad desbloquea escenas fijas por calendario. El objetivo es crear un sistema donde la historia emerge de:

- vínculos con NPCs;
- afinidad, tensión, lealtad y celos;
- conocimiento real del personaje;
- decisiones del jugador;
- consecuencias sobre el mundo;
- elección de unión final;
- tensión postgame.

La UI actual está entrando en fase final funcional. Todavía usamos placeholders, pero deben nombrarse y organizarse como assets finales para que luego solo se reemplacen imágenes, fondos y sprites sin reescribir gameplay.

---

## Filosofía de desarrollo

Este proyecto se trabaja con filosofía de versión final desde el inicio.

Reglas importantes:

1. No hacer soluciones temporales si ya sabemos que después deberán reemplazarse.
2. No crear sistemas “por ahora” si el sistema final debe estar separado.
3. Preferir arquitectura clara y modular desde el inicio.
4. Evitar repetir ciclos de “primero lo hacemos simple, luego lo expandimos, luego lo separamos”.
5. Si algo va a ser un sistema propio, se crea como sistema propio desde el principio.
6. La UI puede usar placeholders, pero la estructura visual debe ser la final.
7. Los placeholders deben tener nombres finales:
   - `Lyria_talking.png`
   - `map_library_alba.png`
   - `world_map_luminaria.png`
   - no `npc1.png`, `test.jpg`, `placeholder2.png`.
8. El usuario prefiere instrucciones directas:
   - qué archivo tocar;
   - qué bloque reemplazar;
   - dónde poner código nuevo;
   - sin pedir confirmación innecesaria.
9. Solo detenerse para decisiones creativas, narrativas o estructurales importantes.
10. Si el usuario dice que hizo commit/checkpoint, asumir que el repo fue actualizado y revisar archivos reales antes de proponer cambios.

---

## Estado general

Backend/sistemas principales: cerrado para pasar a UI.

Ya están implementados:

- ciclo de día;
- bloques horarios;
- acciones por bloque;
- casa del Forastero;
- descanso/dormir;
- guardado manual;
- autosave;
- carga;
- mapa;
- ubicaciones;
- NPC schedules;
- diálogo;
- regalos;
- tienda;
- citas;
- movimientos de cita;
- compatibilidad de movimientos por personalidad/lugar/intimidad;
- revelación inteligente de información;
- bitácora;
- estado del mundo;
- storylets dinámicos;
- milestones;
- rivalidades/celos;
- progresión de relación;
- final union;
- calendario emocional;
- postgame completo;
- recompensas dinámicas de citas;
- UI foundation inicial;
- World Map visual funcional.

---

## Sistemas principales

### Core

Ubicación:

```text
/core
Archivos principales:

core/data_manager.gd
core/game_manager.gd
core/save_manager.gd
core/scene_router.gd

Responsabilidades:

DataManager: carga JSONs y expone getters.
GameManager: estado global, día/hora, jugador, relaciones, mundo, inventario, conocimiento NPC, narrativa pendiente.
SaveManager: guardado/carga/autosave.
SceneRouter: navegación entre escenas.
Data

Ubicación:

/data

Archivos actuales importantes:

activities.json
date_locations.json
date_moves.json
dialogues.json
events.json
game_config.json
items.json
locations.json
milestones.json
npcs.json
npc_info_schema.json
petitions.json
player_classes.json
relationship_steps.json
rivalries.json
final_union_requirements.json
postgame_config.json
postgame_storylets.json
ui_assets.json

Notas:

ui_assets.json contiene rutas finales previstas para fondos, edificios, retratos y sprites.
Los assets no tienen que existir todavía; si no existen, la UI usa placeholders.
Las rutas deben conservar nombres finales.
Relación y NPCs

La relación no es solo afinidad.

Valores:

friendship
tension
loyalty
jealousy

Estados de relación:

none
interest
dating
lovers
partner

La progresión depende de:

afinidad total;
amistad;
tensión;
lealtad;
celos;
información conocida del NPC;
citas exitosas;
condiciones narrativas.

Cada NPC tiene información organizada por categorías en npc_info_schema.json. La información se revela con lógica priorizada para que avanzar de relación no dependa de azar injusto.

Categorías trabajadas:

básico;
gustos;
personalidad;
contacto;
perfil personal;
íntimo;
historia;
romance;
sombra emocional;
deseo/química;
costo/responsabilidad;
final.
Citas

Sistema:

systems/date/date_system.gd
scenes/date/date_scene.gd
data/date_locations.json
data/date_moves.json

Las citas tienen:

localización;
progreso;
errores;
movimientos desbloqueados;
movimientos físicos/coquetos/íntimos;
compatibilidad por NPC;
compatibilidad por localización;
compatibilidad por privacidad;
éxito, excelente o perfecto.

Las recompensas son dinámicas por rango.

Ejemplo conceptual:

"perfect_rewards": {
  "friendship": { "min": 9, "max": 12 },
  "tension": { "min": 10, "max": 14 },
  "loyalty": { "min": 8, "max": 12 }
}

DateSystem resuelve los rangos, aplica bonus por lugar adecuado y muestra valores reales en el resumen.

Las citas postgame también afectan la estabilidad de la unión final.

Final Union

Sistema:

systems/final_union/final_union_system.gd
data/final_union_requirements.json

La unión final representa la elección definitiva de pareja del jugador.

Al completarla:

marca final_union_chosen;
guarda final_union_npc_id;
registra fecha emocional;
otorga collectible/token;
activa PostgameSystem.
Calendario emocional

El juego registra fechas importantes por NPC:

primera cita;
primera cita exitosa;
primera cita excelente;
primera cita perfecta;
avances de relación;
unión final;
regalos amados memorables;
otras memorias emocionales.

Se guarda en:

GameManager.player["emotional_calendar"]

Se muestra en la bitácora.

Postgame

Sistema:

systems/postgame/postgame_system.gd
data/postgame_config.json
data/postgame_storylets.json

El postgame ya está completo a nivel sistémico.

Al iniciar postgame:

marca postgame_started;
marca postgame_partner:<npc_id>;
crea postgame_state;
establece:
final_union_stability;
postgame_pressure;
outside_temptation;
aplica cambios iniciales al mundo;
dispara reacciones inmediatas de otros NPCs.

Cada día:

sube presión/tentación;
revisa celos y rutas avanzadas con otros NPCs;
afecta estabilidad de unión;
dispara storylets postgame si se cumplen condiciones.

Citas/regalos después de final union:

con la pareja fortalecen unión;
con otros NPCs generan tensión/tentación.
UI Foundation

Ya existen componentes UI iniciales:

ui/components/visual_asset.gd
ui/components/location_map_button.gd
ui/components/world_hud_bar.gd
ui/components/world_action_panel.gd
ui/components/location_hover_card.gd
ui/components/world_status_panel.gd

world_status_panel.gd quedó de iteraciones anteriores y puede conservarse si es útil, pero el World Map actual ya no usa panel derecho grande.

Estado actual de UI
World Map

Archivo:

scenes/map/world_map.gd

Estado:

HUD superior funcional.
Mapa grande.
Marcadores/edificios clicables.
Botones globales compactos:
Bitácora;
Guardar;
Menú.
Tarjeta hover inferior izquierda.
Click en ubicación entra directamente.
NPCs presentes aparecen dinámicamente.
Si el jugador no conoce al NPC, aparece ???.
Al conocerlo, aparece su nombre.
Las posiciones y tamaños se escalan según tamaño real de ventana.
La ventana ya puede expandir correctamente al maximizar.

Configuración importante en project.godot:

display/window/size/viewport_width=1152
display/window/size/viewport_height=648
display/window/size/mode=2
display/window/stretch/mode="canvas_items"
display/window/stretch/aspect="expand"
display/window/size/resizable=true
display/window/stretch/scale=1.0

Si el juego no expande al maximizar, revisar estas líneas.

Diseño visual acordado para World Map

Regla final:

HUD arriba.
Mapa grande.
Botones globales arriba derecha.
Tarjeta hover abajo izquierda.
Edificios/ubicaciones independientes.
Click directo para entrar.
Sin lista duplicada.
Sin panel derecho invasivo.

Los edificios deben tratarse como assets separados del fondo.

El fondo ideal:

world_map_luminaria.png

debe ser una planicie/mapa base con caminos, río, suelo, etc.

Los edificios deben ser assets separados:

map_home_forastero.png
map_library_alba.png
map_tavern_puente_rojo.png
...

Esto permite mover edificios desde ui_assets.json sin redibujar el fondo.

Próximo paso

Siguiente pantalla:

LocationScene final funcional con personajes clicables

Objetivo:

click en edificio del mapa
→ entrar a ubicación
→ ver fondo de ubicación
→ ver personajes presentes como sprites/placeholders clicables
→ click en personaje
→ acciones del personaje

No debe ser una lista administrativa.

Diseño esperado:

HUD superior compacto
Fondo de ubicación
Personajes presentes como placeholders/sprites
Tarjeta de personaje seleccionable
Acciones:
- hablar
- regalar
- pedir favor
- invitar a cita
- volver

Reglas:

Si NPC no fue conocido, mostrar ???.
Si fue conocido, mostrar nombre.
Usar ui_assets.json para sprite/retrato/fondo.
Si asset no existe, usar placeholder con nombre final.
Mantener backend intacto.
No tocar sistemas de relación/cita salvo helper visual si fuera inevitable.

Archivos probables:

scenes/location/location_scene.gd
ui/components/location_character_button.gd
ui/components/location_character_card.gd

Usar:

WorldHudBar
VisualAsset
DataManager.get_location_ui()
DataManager.get_npc_ui()
GameManager.mark_npc_seen()
Forma de trabajo recomendada con ChatGPT

Al continuar:

Revisar archivos reales del repo antes de proponer cambios.
No asumir funciones si no se revisaron.
Entregar bloques grandes pero concretos.
Indicar:
archivo;
bloque a reemplazar;
código completo si conviene;
qué probar.
Evitar planes innecesarios cuando ya hay decisión.
Pedir confirmación solo para decisiones creativas/narrativas o cambios estructurales.
Si el usuario dice que hizo commit, revisar el repo actualizado.
Recordar que GitHub no indexa bien por búsqueda; abrir archivos concretos por ruta.
El usuario es novato en Godot, pero programador backend Java/Spring.
Explicar lo necesario de Godot cuando haya errores de lógica o UI.
Último estado validado

La última iteración corrigió el World Map responsive:

posiciones/tamaños escalan con ventana;
botones dejan de salirse al reducir;
HUD usa texto limpio;
tarjeta hover queda abajo izquierda;
ventana expande correctamente al maximizar;
arquitectura está lista para pasar a LocationScene.

Siguiente bloque recomendado:

Implementar LocationScene final funcional con personajes clicables.

---

# 2. Prompt para nuevo chat

Copia y pega esto al iniciar el nuevo chat:

```text
Hola, continuemos el desarrollo de mi juego Godot “Isekai Novel”.

Contexto importante:
- Estoy trabajando en un repositorio GitHub llamado `JoshSnowMex/isekai-novel`.
- El repo está conectado por GitHub, pero por un error no indexa bien por búsqueda de palabras. No confíes en search para encontrar funciones; abre archivos concretos por ruta.
- Antes de proponer cambios, revisa los archivos pertinentes del repo.
- Soy programador backend Java/Spring, pero novato en Godot. Necesito instrucciones claras: archivo, qué reemplazar, dónde pegar código y qué probar.
- No quiero soluciones temporales. Trabajamos siempre pensando en versión final, aunque usemos placeholders.
- Los placeholders deben tener nombres finales de asset, por ejemplo `Lyria_talking.png`, no `npc1.png`.
- Prefiero bloques grandes y concretos. No quiero conversaciones de “plan → confirmación → código” salvo que sea una decisión creativa, narrativa o estructural importante.
- Si digo que hice commit/checkpoint, asume que el repo fue actualizado y revísalo antes de continuar.
- El estilo de trabajo que veníamos teniendo era bueno: directo, con buen humor, pero preciso.

Filosofía del juego:
- No es un dating sim plano. Es un simulador de historias basado en citas.
- La historia debe emerger de relaciones, conocimiento, decisiones, lealtad, celos, tensión, estado del mundo y consecuencias.
- La main storyline no debe depender rígidamente del calendario.
- El calendario sirve más para cumpleaños, aniversarios y memoria emocional.
- Todos los sistemas principales del backend ya están cerrados para pasar a UI.

Estado actual:
- Backend completo:
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
- UI foundation iniciada.
- World Map ya fue convertido a UI final funcional:
  - HUD superior;
  - mapa grande;
  - botones globales arriba derecha;
  - tarjeta hover abajo izquierda;
  - ubicaciones clicables como placeholders cuadrados;
  - click directo entra a ubicación;
  - NPCs presentes se muestran en hover;
  - NPC desconocido aparece como `???`;
  - responsive al tamaño de ventana;
  - configurado con `canvas_items` y `expand`.

Archivos importantes:
- `core/data_manager.gd`
- `core/game_manager.gd`
- `core/save_manager.gd`
- `core/scene_router.gd`
- `scenes/map/world_map.gd`
- `scenes/location/location_scene.gd`
- `data/ui_assets.json`
- `ui/components/visual_asset.gd`
- `ui/components/location_map_button.gd`
- `ui/components/world_hud_bar.gd`
- `ui/components/world_action_panel.gd`
- `ui/components/location_hover_card.gd`

Siguiente paso:
Quiero continuar con `LocationScene final funcional con personajes clicables`.

Objetivo:
- Al entrar a una ubicación desde el mapa, debe mostrarse el fondo de la ubicación.
- Los NPCs presentes deben aparecer como sprites/placeholders clicables.
- Si el jugador no conoce al NPC, debe aparecer como `???`.
- Si ya lo conoce, debe aparecer su nombre.
- Al hacer click en un NPC, aparece una tarjeta/panel de acciones:
  - hablar;
  - regalar;
  - pedir favor;
  - invitar a cita;
  - volver/cerrar selección.
- No quiero lista administrativa de NPCs si podemos evitarla.
- La escena debe quedar lista para reemplazar placeholders por assets reales usando `ui_assets.json`.
- No tocar backend salvo helpers visuales necesarios.
- Revisa primero el repo actualizado y luego dame el bloque grande de implementación.

Por favor continúa desde ahí.