# README_CONTINUAR — Isekai Novel / Luminaria

Este archivo resume el estado actual del proyecto para continuar el desarrollo en otro chat.

## Nota importante para el siguiente chat

El repositorio existe en GitHub, pero el conector de GitHub suele fallar con el indexado en este proyecto. Para continuar correctamente, pedir acceso directo a archivos concretos del repositorio, no búsquedas generales indexadas.

Prompt sugerido para el nuevo chat:

> Estoy trabajando en un proyecto Godot llamado `isekai-novel`, un dating sim / story sim isekai data-driven. El conector de GitHub no está indexando bien el repositorio, así que no busques por índice: abre directamente el archivo `README_CONTINUAR.md` en la raíz del repo y úsalo como contexto principal. Después revisa directamente los archivos que te pida por ruta exacta. Quiero continuar desde el estado descrito ahí.

Repo:
`JoshSnowMex/isekai-novel`

## Visión general del juego

El juego es un dating sim / story sim isekai llamado provisionalmente Luminaria.

La historia no debe ser una ruta lineal clásica. El jugador llega a un mundo atravesado por el Velo, una capa de separación entre mundos, posibilidades y versiones de la realidad. El Velo no es solo magia: funciona como memoria del universo. Registra lo que fue, lo que pudo ser y lo que no debería ser.

El jugador no es “el héroe elegido” clásico. Es una variable externa, alguien que no pertenece a ninguna versión previa del mundo. Su verdadero poder narrativo no es combate ni magia: son sus relaciones con los NPCs.

El dating sim es el motor principal del avance narrativo. Las relaciones desbloquean historia, peticiones indebidas, consecuencias, celos, hitos y finales.

Tema central:
- “¿Qué personas tocaste?”
- “¿Qué precio tuvo quererlas?”
- “¿El destino existe o lo fabricamos por miedo?”

## Lore base

### El Velo

El Velo es una capa de separación entre mundos, posibilidades y versiones de la realidad.

No juzga, pero equilibra.

Cuando se altera demasiado la realidad:
- aparecen contradicciones temporales
- personas recuerdan cosas que no pasaron
- lugares existen solo a veces
- NPCs pueden cambiar según decisiones pasadas
- el mundo busca coherencia y cobra costos

### El jugador

El jugador llega porque el Velo necesitaba un punto de anclaje emocional externo.

No fue invocado directamente por nadie.

### El Consejo

El Consejo es ambiguo:
- cree proteger la estabilidad
- toma decisiones frías
- sacrifica individuos por el bien mayor
- no es villano simple, pero sus soluciones son moralmente cuestionables

### La profecía

La profecía es autocumplida porque fue manipulada.

Existía una predicción vaga, reinterpretada por generaciones. Aeris, Eryon y el Consejo han intervenido sobre ella de forma preventiva.

Tema:
> El Forastero no cumple la profecía. La profecía lo encierra.

### Amor y costo

Enamorar a alguien debe costar otra posibilidad:
- pierdes confianza de otro NPC
- alteras una decisión correcta
- haces que alguien rompa un voto
- vuelves el mundo más inestable
- generas celos o consecuencias futuras

## Arquitectura general

El proyecto está construido de forma modular y data-driven. La mayoría del contenido debe vivir en JSON, no quemado en código.

La lógica está separada en sistemas:
- `DataManager`
- `GameManager`
- `SaveManager`
- `SceneRouter`
- `ConditionSystem`
- `EventSystem`
- `MilestoneSystem`
- `RivalrySystem`
- `PetitionSystem`
- `DialogueSystem`
- `DateSystem`
- `RelationshipSystem`

Autoloads importantes:
- `DataManager`
- `GameManager`
- `SaveManager`
- `SceneRouter`
- `RivalrySystem`
- `EventSystem`
- `ConditionSystem`
- `MilestoneSystem`
- `PetitionSystem`
- `DialogueSystem`
- `DateSystem`
- `RelationshipSystem`

## Estado actual confirmado

Ya funcionan:

- Menú principal
- Nuevo juego
- Continuar
- Clases del jugador
- Ciclo de días
- Ciclo de tiempo por bloques
- Resistencia
- Acciones por bloque
- Dormir hasta el siguiente día
- Trabajo / entrenamiento / medio tiempo
- Modificadores de clase para stats, dinero y relaciones
- Localizaciones con identidad
- NPCs desde JSON
- Regalos
- Inventario
- Tienda
- Bitácora
- NPCs desconocidos como `???`
- Relaciones multi-eje
- Rivalidades / celos básicos
- Diálogos contextuales
- Peticiones indebidas
- Citas normales 2.0
- Lugares de cita
- Movimientos románticos con riesgo
- Límites de acciones por cita
- Regalos durante cita
- Resumen de cita con scroll
- Coleccionables por NPC + ubicación
- Citas especiales
- Progresión de relación
- Piezas de retrato
- Trofeo de vínculo
- Hitos narrativos diarios del Velo
- Ciclo de 14 días probado sin problemas
- Relaciones progresan correctamente

## Estados de relación

Estados internos actuales:

none
interest
dating
lovers
partner

Interpretación oficial:

none      → sin relación
interest  → interés romántico claro
dating    → están saliendo
lovers    → relación íntima / traviesa / amantes no-final
partner   → vínculo culminado personal con ese NPC

Importante:
partner NO significa necesariamente matrimonio o pareja formal tradicional. Significa que el vínculo personal con ese NPC llegó a su forma máxima.

Según el NPC puede interpretarse como:

pareja formal
amante declarado
pacto íntimo
compañero de destino
ancla existencial
vínculo culminado no convencional

El juego debe permitir harem:

varios NPCs en interest
varios en dating
varios en lovers
varios en partner

Eso no debe bloquearse, pero debe tener consecuencias narrativas:

celos
rivalidades
diálogos fríos
presión romántica
peticiones rechazadas
eventos de drama
cambios de disponibilidad

La futura elección final de historia debe ser separada:

final_union_npc_id

o flag:

final_union:<npc_id>

Solo debe haber una unión final narrativa, aunque el jugador pueda tener varias relaciones culminadas.

Sistema de relación multi-eje

Cada NPC tiene varios valores:

friendship
tension
loyalty
jealousy
relationship_state

Total de vínculo:

friendship * 0.4 + tension * 0.4 + loyalty * 0.2

No debe volver a usarse una sola afinidad plana.

Interpretación:

friendship: confianza / cercanía emocional
tension: química / coqueteo / deseo
loyalty: disposición a arriesgarse o cruzar límites
jealousy: celos / inseguridad / presión emocional
Peticiones indebidas

Existen como mecánica central.

Una petición indebida es pedirle a un NPC que cruce una línea:

ocultar información
mentir
retrasar un mensaje
usar influencia
romper un voto
crear un objeto inestable
intimidar a alguien
abrir una posibilidad del Velo

No son contenido sexual. Son límites narrativos.

Archivos:

res://data/petitions.json
res://systems/petition/petition_system.gd

Funcionalidad esperada:

disponible solo con condiciones
éxito o rechazo
aplica efectos
agrega world_flags
afecta world_state
puede disparar eventos / milestones
consume acción
se guarda
DialogueSystem

El sistema de diálogos ya existe y funciona.

Archivos:

res://data/dialogues.json
res://systems/dialogue/dialogue_system.gd

El diálogo es data-driven.

Cada bloque usa:

{
  "npc_id": "aeris",
  "category": "casual",
  "priority": 100,
  "conditions": {},
  "lines": []
}

El sistema filtra por:

NPC
categoría
condiciones
relación
estado de relación
world_flags
world_state
contexto

Debe seguirse el principio:

NPC = quién habla
category = tono
conditions = cuándo tiene sentido
lines = qué puede decir

Los NPCs tienen centro temático, pero no cárcel temática. Pueden hablar de temas de otros si el contexto lo justifica.

Ejemplos de centros temáticos:

Aeris: Velo, verdad, profecía, observación
Lyria: biblioteca, secretos, registros, prudencia
Eryon: ironía, profecía manipulada, narrativas falsas
Seraphine: fe, culpa, deseo, voto
Nova: prototipos, caos, fallas de realidad
Axiom: finitud, existencia, amor metafísico
Elara: rumores, deseo social, taberna
Rhea: protección directa, fuerza, lealtad
Kael: protección, silencio, heridas
Myr: cambio, identidad fluida, alquimia
Taren: orden, control, Consejo/gremio
Rhein: bosque, raíces, memoria natural
Selene: mensajes, Consejo, neutralidad rota
DateSystem — Citas normales 2.0

Archivos:

res://data/date_locations.json
res://data/date_moves.json
res://systems/date/date_system.gd
res://scenes/date/date_scene.gd

Flujo:

Invitar a cita
→ elegir lugar
→ inicia cita con progreso inicial
→ hablar / regalo / movimiento
→ terminar cita
→ resumen con recompensa y coleccionable

Las citas normales:

no suben relationship_state automáticamente
sí registran una cita exitosa
sí dan coleccionables por NPC + lugar
sí descubren información
sí descubren gustos de regalos
sí preparan la cita especial

Límites actuales:

talks max 3
questions max 2
moves max 2
gifts max 1

Los movimientos no se pueden repetir en la misma cita.

El jugador puede fallar movimientos románticos. No se deben mostrar solo opciones seguras. El diseño debe tentar al jugador a equivocarse.

Tono de movimientos:

coqueto
picante
adulto
sugerente
NO eroge
NO hentai
NO explícito

Coleccionable de cita:

date_memory:<npc_id>:<date_location_id>
RelationshipSystem — Citas especiales

Archivos:

res://data/relationship_steps.json
res://systems/relationship/relationship_system.gd

Sirve para subir estados:

none → interest
interest → dating
dating → lovers
lovers → partner

No basta con puntos. Requiere:

umbral de relación
cita normal exitosa previa
conocer información del tier requerido
responder preguntas del NPC en una cita especial

Esto funciona como mini-examen emocional:

Tener una cita exitosa no significa conocer al NPC. Para avanzar de relación debes haber aprendido suficiente sobre esa persona.

Cada subida da:

portrait_piece:<npc_id>:1
portrait_piece:<npc_id>:2
portrait_piece:<npc_id>:3
portrait_piece:<npc_id>:4

Al llegar a partner:

relationship_trophy:<npc_id>
NPC info tiers

GameManager.get_info_tier(info_key) define tiers:

Tier 20:

favorite_place
hobby
favorite_color
favorite_food

Tier 40:

phone
routine
light_romantic_preference
dislikes

Tier 60:

height
favorite_style
minor_insecurity
accepted_affectionate_gesture

Tier 80:

measurements
emotional_fear
romantic_desire
ideal_date

Tier 100:

intimate_secret
partner_condition
Coleccionables

Coleccionables actuales:

date_memory:<npc_id>:<date_location_id>
portrait_piece:<npc_id>:<index>
relationship_trophy:<npc_id>

UI futura puede representar estos IDs con imágenes, cartas, CGs o piezas visuales sin cambiar lógica.

Bitácora

Archivo:

res://scenes/journal/journal_scene.gd

Estado actual:

funciona
muestra NPCs conocidos
muestra NPCs desconocidos como ???
no revela información gratis
muestra:
estado de relación
descripción del estado
amistad/tensión/lealtad/celos
total de vínculo
próximo avance
motivo si está bloqueado
información descubierta con tier
gustos de regalos descubiertos
recuerdos de cita
piezas de retrato
trofeo de vínculo
notas
Milestones del Velo

Archivos:

res://data/milestones.json
res://systems/milestone/milestone_system.gd

Ya se creó MilestoneSystem y se agregó como Autoload.

GameManager.sleep_until_next_day() dispara:

MilestoneSystem.process_milestones({
  "trigger": "day_started"
})

Los resultados se guardan en:

pending_narrative_messages

Importante: add_pending_narrative_message acepta Variant, porque puede recibir strings de milestones.

Milestones narrativos de demo 14 días:

día 2: primera contradicción
día 3: Aeris nota patrón
día 4: Consejo empieza a mirar
día 5: rumores
día 6: recuerdo ajeno
día 7: primera semana pesa
día 9: mundo se repite mal
día 10: advertencia del Consejo
día 12: costo de coherencia
día 14: cierre de arco demo
ConditionSystem

Debe soportar:

"relationship": {
  "state": "dating"
}

y:

"context": {
  "to_state": "dating"
}

Se revisó que inicialmente no lo soportaba. Debe usarse una versión que soporte:

relationship numérico
relationship state
context exacto
context numérico
world_flags
world_state
inventory
time
player_stats
EventSystem

Eventos reactivos por relación usan trigger:

relationship_step_completed

Contexto esperado:

{
  "trigger": "relationship_step_completed",
  "npc_id": npc_id,
  "step_id": step_id,
  "to_state": to_state
}

Eventos de estado:

interest
dating
lovers
partner

Estos deben afectar:

romantic_pressure
global_tension
world_instability
world_flags
World State

player["world_state"]:

{
  "global_tension": 0,
  "world_instability": 0,
  "romantic_pressure": 0
}

Usos:

tensión social
inestabilidad del Velo
presión romántica / harem / celos
Clases del jugador

Archivo:

res://data/player_classes.json

Clases:

Forastero Sensible
Forastero Audaz
Forastero Erudito
Forastero Encantador
Forastero Disciplinado
Forastero Equilibrado

El equilibrado usa modificadores en 1.0 para no romper nada y no aplicar ventajas reales.

Clases afectan:

stats iniciales
crecimiento de stats
dinero por trabajo
relación
Actividades y ubicaciones

Archivos:

res://data/activities.json
res://data/locations.json

Se decidió que NO todas las ubicaciones permitan todo.

Regla:

cada ubicación tiene identidad
entrenar fuerte solo en lugares especializados
trabajo completo solo donde tenga sentido económico
medio tiempo puede ser más común
las ganancias varían por ubicación

Entrenamientos fuertes:

strength    → Gremio
intellect   → Ateneo Arcano
charm       → Plaza
discipline  → Santuario
intuition   → Umbral
UI actual

Se hicieron varias correcciones de layout horizontal/PC.

Pantallas con scroll ya corregidas:

mundo/mapa
tienda
citas
resumen de citas
bitácora

Falta seguir revisando scroll en pantallas largas futuras.

Problemas ya resueltos
Godot no reconocía DateSystem: se resolvió recreando el archivo y autoload.
Resumen de cita desaparecía rápido: ahora requiere botón Continuar.
Resumen de cita no scrolleaba: corregido.
Movimientos de cita se podían spamear: corregido.
Bitácora mostraba nombres de NPCs sin conocerlos: corregido con ???.
Citas no desbloqueaban bien porque se exigía demasiada tensión: ajustado.
Tienda no permitía volver por falta de scroll/layout: corregido.
Mapa/lugares tenían problemas de layout vertical en pantalla horizontal: corregido.
add_pending_narrative_message tenía tipo incorrecto para strings: debe quedar como Variant.
Archivos clave a revisar al continuar

Core:

res://core/game_manager.gd
res://core/data_manager.gd
res://core/scene_router.gd

Systems:

res://systems/condition/condition_system.gd
res://systems/event/event_system.gd
res://systems/milestone/milestone_system.gd
res://systems/rivalry/rivalry_system.gd
res://systems/petition/petition_system.gd
res://systems/dialogue/dialogue_system.gd
res://systems/date/date_system.gd
res://systems/relationship/relationship_system.gd

Scenes:

res://scenes/world_map/world_map.gd
res://scenes/location/location_scene.gd
res://scenes/date/date_scene.gd
res://scenes/journal/journal_scene.gd
res://scenes/shop/shop_scene.gd

Data:

res://data/npcs.json
res://data/dialogues.json
res://data/events.json
res://data/milestones.json
res://data/petitions.json
res://data/relationship_steps.json
res://data/date_locations.json
res://data/date_moves.json
res://data/activities.json
res://data/locations.json
res://data/items.json
res://data/player_classes.json
res://data/rivalries.json
res://data/npc_info_schema.json
Qué falta para primera entrega
1. Confirmar milestones visibles

Ya se disparan al dormir. Falta confirmar si los pending_narrative_messages se muestran de forma elegante al entrar al mapa.

Si no se muestran bien, revisar world_map.gd.

2. Estado del mundo en UI

Agregar una pantalla o sección en bitácora para mostrar:

global_tension
world_instability
romantic_pressure
flags principales conocidos

Puede llamarse:

Estado del mundo
3. Final Union básico

Implementar sistema separado de relationship_state.

No usar partner para la elección final única.

Propuesta:

final_union:<npc_id>

o:

player["final_union_npc_id"] = npc_id

Requisitos:

NPC en partner
día mínimo o milestone demo_arc_completed
world_state bajo cierto umbral o decisión narrativa
una escena final de elección

Solo debe haber uno.

Debe afectar postgame:

otros NPCs reaccionan
celos o aceptación según personalidad
epílogo principal
posibilidad de continuar postgame
4. Reacciones de harem más visibles

Ahora el harem se permite. Falta hacerlo más reactivo:

si tienes varios dating, subir romantic_pressure
si tienes varios lovers, disparar eventos de celos
si tienes varios partner, crear eventos de tensión fuerte
no bloquear, solo consecuencias
5. Balance

Probar 14 días y ajustar:

ganancias de hablar
ganancias de regalos
progreso de cita
costos de stamina
dinero de trabajos
precios de regalos
requisitos de relationship_steps

Objetivo:

en 14 días se debe poder llegar razonablemente a interest o dating con un NPC si el jugador se enfoca
no debería poder maximizar a todos sin esfuerzo
pero sí debe sentirse posible progresar con varios si el jugador entiende el sistema
6. Más contenido narrativo

Prioridad:

Aeris
Lyria
Eryon

Crear mini-ruta fuerte de demo:

Aeris introduce el Velo
Lyria introduce registros/secretos
Eryon introduce profecía manipulada
Consejo presiona
Día 14 deja gancho fuerte
7. Revisión de textos

Hay que revisar:

typos
consistencia de nombres
Lyria debe quedarse como Lyria
no volver a usar Lyra si no corresponde
tono adulto sugerente pero no explícito
evitar que todos los NPCs suenen igual
8. Coleccionables UI futura

Por ahora son IDs en bitácora. En UI final pueden ser:

cartas
piezas de retrato
CGs
recuerdos
trofeos

No cambiar lógica.

Siguiente paso recomendado

Al iniciar nuevo chat, lo más productivo sería pedir:

Revisar directamente world_map.gd para confirmar cómo muestra pending_narrative_messages.
Si no está bien, implementar una pantalla/modal simple de mensajes narrativos pendientes.
Luego implementar FinalUnionSystem básico.
Luego implementar WorldState en bitácora.
Luego balancear 14 días.

Prompt sugerido:

Ya leíste README_CONTINUAR.md. Continuemos desde ahí. Primero abre directamente res://scenes/world_map/world_map.gd, res://core/game_manager.gd, res://systems/milestone/milestone_system.gd y dime si los mensajes narrativos pendientes de milestones se están mostrando bien. Si no, dame el reemplazo de archivos para corregirlo.

Estilo de trabajo preferido

El usuario prefiere:

trabajar por bloques completos
recibir archivos completos cuando sea posible
evitar rehacer arquitectura
definir arquitectura antes de código si afecta futuro
mantener todo modular
usar JSON para contenido
usar sistemas separados para lógica
no quemar contenido narrativo en código
avanzar rápido hacia primera entrega jugable

El usuario suele probar en Godot y reportar errores de línea.
Responder con correcciones concretas y rutas exactas.