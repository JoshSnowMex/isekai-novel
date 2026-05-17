# GAME DESIGN DOCUMENT
## Mireval Chronicles — Un juego de simulación social y narrativa en Avaloria
**Versión:** 0.2  
**Autor del mundo:** Tú  
**Colaboración técnica y de diseño:** Claude  
**Estado:** En definición — no tocar código hasta aprobación completa

---

## ÍNDICE

1. Visión del Proyecto
2. Tono y Audiencia
3. El Mundo — Avaloria y Eldoria
4. Mireval — El Pueblo
5. El Jugador
6. Stats del Jugador
7. Medidores Narrativos Globales
8. Sistemas de Juego
9. El HUD
10. El Mapa y las Ubicaciones
11. Los NPCs — Estructura y Schema
12. El Sistema de Relaciones
13. Las Citas
14. La Bitácora del Forastero
15. El Sistema de Tiempo
16. La Narrativa Base
17. Arquitectura Técnica
18. Estructura de Archivos y JSONs
19. Despliegue — Vercel
20. Filosofía de Desarrollo
21. Pendientes

---

## 1. VISIÓN DEL PROYECTO

Mireval Chronicles es un simulador social de narrativa adulta ambientado en el mundo de fantasía oscura de Avaloria. El jugador, invocado accidentalmente desde otro mundo, debe construir su vida en el pueblo de Mireval relacionándose con sus habitantes mientras descubre, capa a capa, que el mundo que lo rodea esconde una verdad cósmica y peligrosa.

El juego combina:
- **Simulación social profunda** — relaciones multidimensionales con NPCs que viven y evolucionan independientemente del jugador
- **Narrativa emergente** — no hay un guión fijo; la historia del jugador se construye según sus decisiones, relaciones y descubrimientos
- **Horror de fondo** — el peso del lore de Avaloria filtra hacia las relaciones cotidianas, creando disonancia deliberada entre lo romántico y lo perturbador
- **Tono adulto** — relaciones románticas con intimidad real, consecuencias emocionales serias, sin censura innecesaria y sin cruzar a contenido explícito gráfico

**Referencia principal de sistemas:** SimGirls (NewGrounds)  
**Referencias de atmósfera:** Rune Factory, Stardew Valley (interacción NPC), Crusader Kings (relaciones con consecuencias)  
**Referencias visuales:** Proyecto anterior del autor — HUD, mapa de nodos, Bitácora del Forastero

---

## 2. TONO Y AUDIENCIA

### Audiencia
Adultos. El juego no está diseñado para menores. Las relaciones incluyen besos, intimidad narrada, tensión sexual y consecuencias emocionales de las decisiones románticas.

### Tono
- **Superficie:** Un pueblo tranquilo de fantasía medieval donde el jugador construye relaciones
- **Fondo:** Un mundo con una verdad cósmica oscura que se filtra gradualmente
- **Sello autoral:** Las decisiones tienen peso real. El jugador puede enamorarse. Esa persona puede tener una conexión con el ente del vacío sin saberlo. Esa disonancia es intencional y es el corazón del juego.

### Línea de contenido
- ✅ Besos, caricias, escenas de intimidad narradas con intención
- ✅ Tensión sexual, insinuación, consecuencias de la intimidad
- ✅ Horror psicológico, revelaciones perturbadoras del lore
- ✅ Violencia narrativa implícita cuando el lore lo requiere
- ❌ Contenido gráfico explícito sexual
- ❌ Contenido que involucre menores en cualquier contexto adulto

Las escenas íntimas se resuelven con elipsis narrativa — el juego corta a negro y las consecuencias aparecen después. El peso lo lleva el texto, no la gráfica.

---

## 3. EL MUNDO — AVALORIA Y ELDORIA

### Cosmología de Avaloria

En el universo existen dos Arquitectos que diseñan planos en el vacío. El vacío mismo tiene conciencia. Al ser perturbado, despertó a uno de sus hijos — una entidad primordial — para hacerles frente. Los Arquitectos, incapaces de derrotarlo, lo enjaularon. Ese encarcelamiento se convirtió en el plano de Avaloria.

El mundo nació del cuerpo dormido de una entidad que no quería existir como mundo. Eso lo impregna todo.

### El Ciclo y el Cataclismo

Las razas primigenias emergieron de Avaloria y eventualmente descubrieron al ente del vacío aprisionado. Manipuladas por él para intentar liberarlo, casi lo lograron. Una de las razas lo descubrió a tiempo — pero el ente las exterminó antes de volver a dormirse.

Las razas que conocemos hoy son su evolución. Saben, en algún nivel colectivo, que su existencia tiene caducidad si el ente despierta.

### La Iglesia del Sol Velado

Los humanos preservaron la mayor cantidad del conocimiento antiguo. Con él fundaron la Iglesia del Sol Velado — una inquisición sofisticada que se presenta como orden espiritual. Su objetivo real es mantener a todos ignorantes de la verdad del ente, eliminando a quienes se acerquen demasiado.

La Iglesia no es un villano obvio. Es una institución con lógica interna coherente. Hay miembros que creen genuinamente en su misión.

### Los Cinco Continentes
- **Lunaria**
- **Válor**
- **Thalasia**
- **Vordania**
- **Eldoria** — donde ocurre el juego

### Eldoria

**Este:** Presencia humana dominante. Hombres bestia como esclavos. Aquí está Mireval.  
**Oeste:** Los pueblos libres — elfos, enanos, hombres bestia libres. Tierras desérticas y pobres.  
**Emberwind:** El Imperio Humano. El más rico y poderoso. Gobernado por la Iglesia. Profundamente xenófobo.

---

## 4. MIREVAL — EL PUEBLO

### Descripción

Pueblo pequeño de carácter medieval en el este de Eldoria, lejos de la capital. Su distancia del poder hace que las reglas se apliquen con menos rigor — pero nadie vendrá a ayudarte si te metes en problemas. Rodeado por un bosque con importancia narrativa propia.

### Gobierno

Consejo de cinco miembros. Dos están en nómina de la Iglesia del Sol Velado. No es una teocracia obvia — es corrupción institucional sutil que el jugador puede o no descubrir.

### Atmósfera

Por fuera: tranquilo, medieval, con sus rutinas y dramas cotidianos. Por dentro: un lugar donde alguien estuvo a punto de despertar algo que no debía, donde la información es moneda de poder.

---

## 5. EL JUGADOR

### Origen — El Isekai

El jugador proviene de nuestro mundo. Fue invocado accidentalmente por un ritual fallido realizado por el NPC exiliado del bosque. No sabe nada de Avaloria — su ignorancia es premisa, no excusa.

### La Tensión Existencial

Desde el inicio existe una pregunta sin respuesta forzada:
- ¿Quiero volver a mi mundo o me quedo?
- ¿A quién le cuento que soy de otro mundo?
- ¿Puedo confiar en alguien que no puede entender de dónde vengo?

Revelar que eres de otro mundo es un acto de vulnerabilidad con consecuencias reales según a quién y cuándo se lo dices.

---

## 6. STATS DEL JUGADOR

Cinco stats con nombres propios de Avaloria. La Constitución se maneja separada como Resistencia (energía) y no forma parte del gameplay social.

| Stat | Descripción |
|---|---|
| **Fortaleza** | Cuerpo, temple físico, presencia intimidante |
| **Presencia** | Cómo te perciben, tu aura, el don de gentes |
| **Ingenio** | Razonamiento, lectura del mundo, conocimiento |
| **Intuición** | Conexión profunda, espiritualidad, lo que no se ve |
| **Oficio** | Habilidad práctica, destreza manual, agilidad |

### Sistema de Afinidad Stat-NPC

Cada NPC tiene tres listas respecto a los stats del jugador:

- **Afinidad:** Ese stat acelera el avance de la relación
- **Rechazo:** Ese stat frena o retrocede levemente la relación  
- **Neutral:** Sin modificador

El jugador debe elegir en qué invertir según a quién quiere conquistar. No existe un build que funcione para todos.

### Resistencia

Stat numérico visible en el HUD. Determina cuántas acciones físicas puede realizar el jugador por día. Se repone al descansar o dormir. No afecta relaciones sociales directamente pero limita las acciones disponibles.

---

## 7. MEDIDORES NARRATIVOS GLOBALES

Tres ejes que determinan quién es el jugador en Avaloria al final del juego. Visibles en el HUD de forma discreta pero siempre presentes.

| Medidor | Nombre | Qué mide | Cómo sube |
|---|---|---|---|
| **Eco del Vacío** | Corrupción | Cuánto ha cambiado el jugador en lo oscuro | Decisiones moralmente cuestionables, contacto con el ente, rituales |
| **Voto del Sol** | Alineamiento Iglesia | Qué tan comprometido estás con el orden establecido | Apoyar a la Iglesia, mantener secretos, no cuestionar |
| **Grieta** | Alineamiento Ente | Qué tan cerca estás de la verdad que el mundo oculta | Descubrir lore, acercarte al exiliado, hacer preguntas peligrosas |

### Cómo afectan al juego

- **Eco del Vacío alto + Grieta alta** → Los NPCs con Intuición alta lo perciben aunque no sepan qué es
- **Voto del Sol alto** → Los concejales corruptos te protegen; el exiliado desconfía de ti
- **Grieta alta + Voto del Sol bajo** → La Iglesia te considera una amenaza. Consecuencias activas.
- **Eco del Vacío alto + Romance alto** → Las relaciones íntimas tienen un costo narrativo visible
- **Grieta baja** → Vives en Mireval sin saber nada. Final más tranquilo pero incompleto.

### Impacto en Finales

Los tres medidores, combinados con el estado de las relaciones del jugador, determinan qué finales son posibles. Ningún final se escribe linealmente — todos emergen de los números.

---

## 8. SISTEMAS DE JUEGO

### El Loop Central

Cada día tiene 6 bloques de 3 horas:

| Bloque | Horario | Período |
|---|---|---|
| 1 | 8:00 AM | Mañana |
| 2 | 11:00 AM | Mañana |
| 3 | 2:00 PM | Tarde |
| 4 | 5:00 PM | Tarde |
| 5 | 8:00 PM | Noche |
| 6 | 11:00 PM | Noche |

Cada acción consume un bloque y avanza el tiempo. Al dormir o agotar bloques el día termina.

### Acciones Disponibles

| Acción | Resistencia | Dinero | Stat | Nota |
|---|---|---|---|---|
| **Trabajar** | Alta | Bastante | — | Solo en ubicaciones laborales |
| **Trabajo parcial** | Media | Poco | Sube poco | Más ubicaciones disponibles |
| **Entrenar** | Alta | — | Sube bastante | Solo en ubicaciones de entrenamiento |
| **Descansar** | — | — | — | En casa, repone resistencia sin cerrar día |
| **Interactuar con NPC** | Baja | — | — | Solo si el NPC está presente |
| **Dormir** | — | — | — | Cierra el día, repone todo |

### Interacciones con NPCs

Cuando un NPC está presente el jugador puede:
- **Hablar** — diálogo, puede desbloquear información según capa
- **Regalar** — máximo 1 o 2 por día
- **Invitar a cita** — requiere nivel de relación mínimo
- **Proponer relación** — abierta o seria, según nivel alcanzado

### El Mundo Vive

El mundo no pausa cuando el jugador no está presente. Los NPCs:
- Se mueven entre ubicaciones según probabilidades por bloque horario
- Desarrollan y modifican sus relaciones entre ellos independientemente
- Reaccionan a las acciones del jugador con otros NPCs

---

## 9. EL HUD

Referencia visual: proyecto anterior del autor. HUD en barra superior, limpio, tipografía elegante.

### Barra Superior — Información siempre visible

```
[Mes · Día · Día semana · Hora · Período]    [Resistencia · Lúmenes · Acciones]    [Eco del Vacío · Voto del Sol · Grieta]
```

- **Mes / Día / Día de semana / Hora / Período** — contexto temporal completo
- **Resistencia** — energía actual / máximo
- **Lúmenes** — moneda del juego (nombre temático de Avaloria)
- **Acciones** — bloques disponibles en el día actual
- **Eco del Vacío / Voto del Sol / Grieta** — medidores narrativos, discretos pero siempre visibles

### Botones de navegación global
- **Mapa** — vuelve al mapa de Mireval
- **Bitácora** — abre la Bitácora del Forastero
- **Guardar / Cargar**

### Consideración de diseño

Los tres medidores narrativos no deben perderse visualmente. Se muestran como valores numéricos pequeños o barras muy delgadas en el extremo derecho del HUD. El jugador debe poder verlos de un vistazo sin que dominen la pantalla.

---

## 10. EL MAPA Y LAS UBICACIONES

### Estilo Visual

Mapa ilustrado de Mireval con ubicaciones como nodos circulares. Referencia directa al proyecto anterior del autor. Cada nodo tiene nombre visible y al hacer hover muestra quién está presente en ese bloque horario.

### Sistema de Hover

Al pasar el cursor sobre una ubicación:
- Si no hay nadie: muestra solo el nombre del lugar
- Si hay NPCs desconocidos: "Hay alguien aquí"
- Si hay NPCs conocidos: muestra su nombre

El jugador nunca pierde tiempo buscando a ciegas. La información de presencia es visible sin necesidad de visitar el lugar.

### Ubicaciones de Mireval

| Ubicación | Función principal | Notas |
|---|---|---|
| **Casa del Forastero** | Descanso, cerrar día, guardar | Punto de partida cada mañana |
| **Plaza** | Interacción social, eventos | Centro social de Mireval |
| **Café** | Interacción, trabajo parcial | Alta probabilidad de NPCs en mañana/tarde |
| **Taberna** | Interacción, trabajo parcial | Más activa de noche |
| **Mercado** | Comprar regalos, trabajo | Mañana y tarde |
| **Archivo** | Ingenio, lore, trabajo parcial | NPCs académicos o curiosos |
| **Taller** | Fortaleza, Oficio, trabajo | NPCs prácticos |
| **Consejo** | Narrativa política | Descubrir la corrupción institucional |
| **Santuario** | Voto del Sol, Intuición | NPCs ligados a la Iglesia |
| **Umbral** | Grieta, eventos especiales | Lugar con resonancia del ente |
| **Bosque** | Ubicación especial narrativa | Donde vive el exiliado — se desbloquea |

### Sistema de Probabilidades de NPCs

Cada NPC tiene probabilidades de aparición por bloque y ubicación. No es un schedule fijo ni aleatoriedad pura — es un sistema híbrido que se siente orgánico pero nunca frustrante.

```json
"ubicaciones": {
  "bloque_1_8am":  { "cafe": 0.7, "mercado": 0.2, "plaza": 0.1 },
  "bloque_2_11am": { "cafe": 0.4, "plaza": 0.4, "mercado": 0.2 },
  "bloque_3_2pm":  { "plaza": 0.5, "cafe": 0.3, "tienda": 0.2 },
  "bloque_4_5pm":  { "mercado": 0.4, "plaza": 0.4, "archivo": 0.2 },
  "bloque_5_8pm":  { "taberna": 0.6, "plaza": 0.3, "casa": 0.1 },
  "bloque_6_11pm": { "taberna": 0.3, "casa": 0.7 }
}
```

El NPCManager tira los dados al inicio de cada bloque. El jugador ve el resultado en el hover del mapa.

---

## 11. LOS NPCs — ESTRUCTURA Y SCHEMA

### Principio de Escalabilidad

Un NPC = un archivo JSON. Agregar un personaje nuevo en un update futuro es agregar su JSON y sus assets. El NPCManager nunca necesita modificarse para soportar nuevos personajes.

### Schema Completo del JSON de un NPC

El schema integra las capas de conocimiento del proyecto anterior del autor, enriquecidas para Avaloria.

```json
{
  "id": "adelaida",
  "nombre": "Adelaida",
  "raza": "humana",
  "edad": 24,
  "romanceable": true,

  "assets": {
    "portrait_base":    "res://assets/npcs/adelaida/portrait_base.png",
    "portrait_happy":   "res://assets/npcs/adelaida/portrait_happy.png",
    "portrait_sad":     "res://assets/npcs/adelaida/portrait_sad.png",
    "portrait_angry":   "res://assets/npcs/adelaida/portrait_angry.png",
    "portrait_intimate":"res://assets/npcs/adelaida/portrait_intimate.png",
    "sprite_world":     "res://assets/npcs/adelaida/sprite_world.png",
    "placeholder":      "res://assets/placeholders/npc_default.png"
  },

  "stats_afinidad": {
    "afinidad": ["presencia", "intuicion"],
    "rechazo":  ["fortaleza", "oficio"],
    "neutral":  ["ingenio"]
  },

  "ubicaciones": {
    "bloque_1_8am":  { "cafe": 0.7, "mercado": 0.2, "plaza": 0.1 },
    "bloque_2_11am": { "cafe": 0.4, "plaza": 0.4, "mercado": 0.2 },
    "bloque_3_2pm":  { "plaza": 0.5, "cafe": 0.3, "mercado": 0.2 },
    "bloque_4_5pm":  { "mercado": 0.4, "plaza": 0.4, "archivo": 0.2 },
    "bloque_5_8pm":  { "taberna": 0.6, "plaza": 0.3, "casa_adelaida": 0.1 },
    "bloque_6_11pm": { "taberna": 0.2, "casa_adelaida": 0.8 }
  },

  "relaciones_npc": {
    "elena": { "tipo": "conocidas", "afinidad": 40, "tension": 20 }
  },

  "conocimiento": {
    "basico": {
      "tier": 20,
      "desbloqueado_en_nivel": 0,
      "datos": {
        "cumpleanos":      { "label": "Cumpleaños",       "valor": "12 de Floreciente", "descubierto": false },
        "edad":            { "label": "Edad",             "valor": "24",                "descubierto": false },
        "ocupacion":       { "label": "Ocupación",        "valor": "TBD",               "descubierto": false },
        "lugar_favorito":  { "label": "Lugar favorito",   "valor": "El café al amanecer","descubierto": false },
        "comida_favorita": { "label": "Comida favorita",  "valor": "Pan de especias",   "descubierto": false },
        "bebida_favorita": { "label": "Bebida favorita",  "valor": "TBD",               "descubierto": false }
      }
    },
    "gustos": {
      "tier": 30,
      "desbloqueado_en_nivel": 1,
      "datos": {
        "color_favorito":    { "label": "Color favorito",     "valor": "TBD", "descubierto": false },
        "hobby":             { "label": "Hobby",              "valor": "TBD", "descubierto": false },
        "musica_favorita":   { "label": "Música favorita",    "valor": "TBD", "descubierto": false }
      }
    },
    "personalidad": {
      "tier": 40,
      "desbloqueado_en_nivel": 1,
      "datos": {
        "temperamento":         { "label": "Temperamento",          "valor": "TBD", "descubierto": false },
        "que_le_molesta":       { "label": "Qué le molesta",        "valor": "TBD", "descubierto": false },
        "que_le_tranquiliza":   { "label": "Qué le tranquiliza",    "valor": "TBD", "descubierto": false },
        "que_admira":           { "label": "Qué admira en otros",   "valor": "TBD", "descubierto": false },
        "como_expresa_afecto":  { "label": "Cómo expresa afecto",   "valor": "TBD", "descubierto": false }
      }
    },
    "perfil_personal": {
      "tier": 60,
      "desbloqueado_en_nivel": 2,
      "datos": {
        "estilo_favorito":      { "label": "Estilo de ropa",        "valor": "TBD", "descubierto": false },
        "rasgo_orgullo":        { "label": "Rasgo físico de orgullo","valor": "TBD", "descubierto": false },
        "inseguridad":          { "label": "Inseguridad personal",  "valor": "TBD", "descubierto": false },
        "limite_romantico":     { "label": "Límite romántico",      "valor": "TBD", "descubierto": false }
      }
    },
    "deseo_quimica": {
      "tier": 70,
      "desbloqueado_en_nivel": 3,
      "datos": {
        "coqueteo_favorito":    { "label": "Coqueteo que le provoca","valor": "TBD", "descubierto": false },
        "tension_disfrutada":   { "label": "Tensión que disfruta",  "valor": "TBD", "descubierto": false },
        "ritmo_intimo":         { "label": "Ritmo íntimo preferido","valor": "TBD", "descubierto": false },
        "provocacion_aceptada": { "label": "Provocación aceptada",  "valor": "TBD", "descubierto": false },
        "provocacion_incomoda": { "label": "Provocación que incomoda","valor":"TBD", "descubierto": false }
      }
    },
    "historia": {
      "tier": 75,
      "desbloqueado_en_nivel": 3,
      "datos": {
        "recuerdo_importante":  { "label": "Recuerdo importante",   "valor": "TBD", "descubierto": false },
        "herida_emocional":     { "label": "Herida emocional",      "valor": "TBD", "descubierto": false },
        "sueno_personal":       { "label": "Sueño personal",        "valor": "TBD", "descubierto": false },
        "relacion_familiar":    { "label": "Relación familiar",     "valor": "TBD", "descubierto": false },
        "meta_futuro":          { "label": "Meta a futuro",         "valor": "TBD", "descubierto": false }
      }
    },
    "sombra_emocional": {
      "tier": 95,
      "desbloqueado_en_nivel": 4,
      "datos": {
        "patron_danino":        { "label": "Patrón dañino bajo presión","valor":"TBD","descubierto": false },
        "mentira_propia":       { "label": "Mentira que se cuenta",  "valor": "TBD", "descubierto": false },
        "como_hiere":           { "label": "Cómo hiere cuando teme", "valor": "TBD", "descubierto": false },
        "reaccion_celos":       { "label": "Reacción ante celos",   "valor": "TBD", "descubierto": false },
        "reaccion_abandono":    { "label": "Reacción ante abandono", "valor": "TBD", "descubierto": false },
        "punto_ruptura":        { "label": "Punto de ruptura",      "valor": "TBD", "descubierto": false }
      }
    },
    "vinculo_avaloria": {
      "tier": 100,
      "desbloqueado_en_nivel": 5,
      "datos": {
        "secreto_intimo":       { "label": "Secreto importante",    "valor": "TBD", "descubierto": false },
        "verdad_emocional":     { "label": "Verdad emocional",      "valor": "TBD", "descubierto": false },
        "condicion_pareja":     { "label": "Condición para ser pareja","valor":"TBD","descubierto": false },
        "condicion_union_final":{ "label": "Condición de unión final","valor":"TBD","descubierto": false },
        "costo_elegirle":       { "label": "Costo de elegirle",     "valor": "TBD", "descubierto": false },
        "conexion_ente":        { "label": "Su vínculo con el ente","valor": "TBD", "descubierto": false }
      }
    }
  },

  "preguntas_conocimiento": [
    {
      "id": "q_comida",
      "capa": "basico",
      "dato_id": "comida_favorita",
      "pregunta": "¿Cuál es mi comida favorita?",
      "respuesta_correcta": "pan de especias",
      "pista": "Me lo mencionaste cuando hablamos del mercado",
      "efecto_correcto": 5,
      "efecto_incorrecto": -2
    }
  ],

  "regalos": {
    "amados":    ["flores_del_bosque", "pan_especias"],
    "gustados":  ["vela_aromatica", "tela_fina"],
    "neutrales": ["moneda_de_plata"],
    "odiados":   ["huesos_tallados", "simbolo_iglesia"]
  },

  "citas": {
    "movimientos_preferidos": {
      "ama":      ["sutil", "lento", "emocional", "respetuoso"],
      "gusta":    ["romantico", "privado", "verbal"],
      "disgusta": ["publico", "atrevido", "arriesgado"],
      "odia":     ["crudo", "forzado"]
    },
    "umbral_por_ubicacion": {
      "cafe":     60,
      "plaza":    65,
      "taberna":  55,
      "bosque":   80,
      "umbral":   90
    }
  },

  "relacion": {
    "nivel_actual": 0,
    "afinidad_actual": 0,
    "celos": 0,
    "tipo_relacion": "desconocidos",
    "estado_emocional": "neutral",
    "sabe_que_es_forastero": false
  },

  "niveles_relacion": [
    { "nivel": 0, "nombre": "Desconocidos",  "umbral": 0,   "desbloquea_capa": "basico",          "requiere_cita_especial": false },
    { "nivel": 1, "nombre": "Conocidos",     "umbral": 20,  "desbloquea_capa": "gustos",          "requiere_cita_especial": false },
    { "nivel": 2, "nombre": "Amigos",        "umbral": 50,  "desbloquea_capa": "perfil_personal", "requiere_cita_especial": true,  "cita_especial_id": "cita_amistad_adelaida" },
    { "nivel": 3, "nombre": "Cercanos",      "umbral": 100, "desbloquea_capa": "historia",        "requiere_cita_especial": true,  "cita_especial_id": "cita_cercania_adelaida" },
    { "nivel": 4, "nombre": "Íntimos",       "umbral": 175, "desbloquea_capa": "sombra_emocional","requiere_cita_especial": true,  "cita_especial_id": "cita_intimidad_adelaida" },
    { "nivel": 5, "nombre": "Vínculo",       "umbral": 280, "desbloquea_capa": "vinculo_avaloria","requiere_cita_especial": true,  "cita_especial_id": "cita_verdad_adelaida" }
  ],

  "story_role": {
    "veil_sensitivity": 0,
    "social_risk": 0,
    "romantic_disruption": 0,
    "final_union_style": "TBD",
    "postgame_role": "TBD"
  },

  "flags_historia": {
    "primer_encuentro_completado": false,
    "sabe_que_eres_forastero": false,
    "confio_su_secreto": false,
    "vinculo_avaloria_revelado": false
  },

  "dialogo_refs": {
    "primer_encuentro":    "res://data/dialogue/adelaida/primer_encuentro.json",
    "saludo_desconocidos": "res://data/dialogue/adelaida/saludo_desconocidos.json",
    "saludo_conocidos":    "res://data/dialogue/adelaida/saludo_conocidos.json",
    "saludo_amigos":       "res://data/dialogue/adelaida/saludo_amigos.json"
  }
}
```

---

## 12. EL SISTEMA DE RELACIONES

### Dimensiones de una Relación

| Variable | Descripción |
|---|---|
| **Afinidad** | Cuánto le gustas al NPC |
| **Celos** | Nivel de celos hacia el jugador por otros NPCs |
| **Tensión NPC-NPC** | Relación entre NPCs independiente del jugador |
| **Estado emocional** | Neutral, feliz, celosa, enojada, enamorada |

### Relaciones NPC-NPC

El mundo actualiza las relaciones entre NPCs cada día independientemente del jugador. Si dos NPCs tienen tensión y el jugador interactúa con uno frente al otro, hay consecuencias aunque el jugador no haya hecho nada explícitamente malo.

### Los Celos

Se activan cuando un NPC tiene afinidad suficiente y ve al jugador con otro. Cada NPC tiene su propio umbral de celos y forma de reaccionar — definida en su capa `sombra_emocional`.

### Tipos de Relación Formal

- **Relación abierta** — el NPC sabe y acepta otras relaciones; igual puede generar celos
- **Relación seria** — exclusividad; infidelidad tiene consecuencias severas y narrativamente significativas

### Impacto de los Medidores Narrativos

- NPCs con **Intuición alta** perciben el Eco del Vacío del jugador aunque no sepan qué es
- NPCs ligados a la Iglesia reaccionan al **Voto del Sol** — positivamente si es alto, con sospecha si es bajo
- NPCs curiosos o exiliados reaccionan a la **Grieta** — se acercan si es alta, se distancian si es baja

---

## 13. LAS CITAS

### Estructura

Una cita consume un bloque de tiempo completo. Ocurre en una ubicación específica con su propio umbral de éxito.

| Acción | Efecto en % de éxito |
|---|---|
| **Hablar** | El NPC puede hacer pregunta de conocimiento. Correcta: sube %. Incorrecta: baja poco |
| **Regalar** | Amado: sube mucho. Gustado: sube. Neutral: poco. Odiado: baja |
| **Movimiento** | Acción romántica/física. Éxito según nivel de relación, stats del jugador y preferencias del NPC |
| **Terminar** | Evalúa % acumulado contra umbral de la ubicación |

### Evaluación

- **Supera umbral** → Afinidad sube, posible desbloqueo de información
- **Alcanza pero no supera** → Afinidad sube levemente
- **Falla** → Afinidad baja, estado emocional negativo temporal

### Citas Especiales de Nivel

Para avanzar de nivel se requiere una cita especial con:
- Ubicación fija definida por el NPC
- Preguntas de conocimiento obligatorias
- Momento narrativo al superar el umbral
- Posible escena de intimidad narrada según el nivel

### Movimientos en Cita

Cada NPC tiene preferencias de movimientos definidas en su JSON (`ama / gusta / disgusta / odia`). Usar un movimiento amado en el momento correcto tiene bonificación. Usar uno odiado tiene penalización significativa.

---

## 14. LA BITÁCORA DEL FORASTERO

Diario del jugador accesible desde el HUD en cualquier momento. Referencia visual directa al proyecto anterior del autor.

### Secciones

| Sección | Contenido |
|---|---|
| **Personas** | Lista de NPCs conocidos con su ficha individual |
| **Mundo** | Información de Avaloria descubierta gradualmente |
| **Calendario** | Fechas importantes registradas — cumpleaños, eventos |
| **Recuerdos** | Momentos narrativos significativos que el jugador vivió |
| **Unión** | Estado de las relaciones formales activas |

### Ficha Individual de NPC

Al seleccionar un NPC conocido el jugador ve:
- **Estado de relación** — nivel actual y tipo de relación
- **Vínculo** — afinidad y celos actuales
- **Próximo avance** — qué se necesita para subir de nivel
- **Fechas importantes** — las que ha descubierto
- **Información descubierta** — organizada por capas desbloqueadas
- **Regalos conocidos** — los que ha aprendido que le gustan o no
- **Horarios conocidos** — ubicaciones y bloques donde lo ha encontrado

### Principio de Descubrimiento

La Bitácora no es omnisciente. El jugador solo ve lo que ha descubierto. Los horarios conocidos se llenan conforme el jugador encuentra al NPC en distintos bloques. La información de las capas aparece conforme se desbloquea. Esto hace que la Bitácora sea un reflejo real del esfuerzo invertido.

---

## 15. EL SISTEMA DE TIEMPO

### HUD Temporal

Siempre visible: Mes · Día · Día de semana · Hora · Período del día

### Avance

Cada acción consume un bloque y avanza 3 horas. El NPCManager recalcula posiciones al inicio de cada bloque.

### Cierre del Día

Al dormir o agotar bloques:
- El mundo procesa relaciones NPC-NPC del día
- Se actualizan estados emocionales
- Se repone toda la resistencia del jugador
- Avanza la fecha

### Calendario

Hay fechas importantes en Mireval — festividades, días significativos del lore, cumpleaños de NPCs. El jugador las descubre a través de conversaciones y las registra en la Bitácora. Recordar un cumpleaños y actuar en consecuencia tiene efecto positivo en la relación.

---

## 16. LA NARRATIVA BASE

### El Detonante

Un NPC exiliado del pueblo vive en el bosque cercano a Mireval. Llamado sutilmente por el ente del vacío, realizó un ritual. Se asustó. El ritual salió mal e invocó al jugador. Es el único que sabe desde el inicio que el jugador es de otro mundo.

### Conflictos Latentes

No hay guión lineal. Hay una situación inicial con tensiones que el jugador puede explorar o ignorar:
- El exiliado tiene un secreto que el pueblo preferiría no saber
- Dos concejales responden a la Iglesia
- Hay algo enterrado en la historia de Mireval conectado al lore del ente
- Cada NPC tiene en su capa más profunda un vínculo con esa verdad — sin necesariamente saberlo

### Story Flags

Los momentos narrativos tienen condiciones medibles:

```
Escena "Adelaida te confiesa algo":
  afinidad_adelaida >= 60
  celos_adelaida < 30
  visitas_cafe >= 4
  eco_del_vacio_jugador < 40
  flag: confio_su_secreto == false
```

### Finales Emergentes

Emergen de la combinación de medidores narrativos, relaciones y decisiones:

| Condición dominante | Final posible |
|---|---|
| Romance alto + Grieta baja | Te quedas en Mireval sin saber la verdad |
| Grieta alta + Eco bajo | Descubres la verdad y decides qué hacer con ella |
| Eco alto + Voto bajo | El ente te ha cambiado. Las consecuencias son tuyas |
| Voto alto + Grieta baja | La Iglesia te considera aliado. El exiliado desaparece |
| Grieta alta + Eco alto | Eres parte del problema que Avaloria lleva siglos evitando |

---

## 17. ARQUITECTURA TÉCNICA

### Stack

- **Motor:** Godot 4
- **Lenguaje:** GDScript
- **Export targets:** Desktop (Windows/Mac/Linux), Web (WebAssembly)
- **Datos:** JSON por entidad, cargados dinámicamente
- **Saves:** JSON

### Sistemas Globales — Autoloads

| Autoload | Responsabilidad |
|---|---|
| **GameManager** | Estado global: día, hora, bloque, resistencia, lúmenes, medidores narrativos |
| **NPCManager** | Carga NPCs desde JSON, gestiona posiciones por bloque, estados emocionales |
| **RelationshipManager** | Cambios de afinidad, celos, relaciones NPC-NPC, impacto de medidores |
| **DialogManager** | Sistema de diálogo único y reutilizable — ninguna escena lo reimplementa |
| **EventManager** | Story flags, condiciones narrativas, thresholds de escenas |
| **TimeManager** | Bloques horarios, avance del día, cierre de día, calendario |
| **SaveManager** | Guardar y cargar estado completo en JSON |
| **AssetLoader** | Carga assets con fallback automático a placeholder |

### AssetLoader — Principio de Placeholder

```gdscript
# AssetLoader.gd (Autoload)
func load_texture(ruta: String, placeholder: String = "res://assets/placeholders/npc_default.png") -> Texture2D:
    if ResourceLoader.exists(ruta):
        return load(ruta)
    else:
        return load(placeholder)
```

Ninguna escena carga assets directamente. Todo pasa por AssetLoader. Siempre.

### DialogManager

Un solo nodo de diálogo en la escena raíz. Cualquier escena lo llama, nunca lo reimplementa:

```gdscript
DialogManager.show_dialog("adelaida", "primer_encuentro")
```

---

## 18. ESTRUCTURA DE ARCHIVOS Y JSONs

```
res://
├── autoloads/
│   ├── GameManager.gd
│   ├── NPCManager.gd
│   ├── RelationshipManager.gd
│   ├── DialogManager.gd
│   ├── EventManager.gd
│   ├── TimeManager.gd
│   ├── SaveManager.gd
│   └── AssetLoader.gd
│
├── scenes/
│   ├── main/
│   │   └── Main.tscn
│   ├── ui/
│   │   ├── HUD.tscn
│   │   ├── DialogBox.tscn
│   │   ├── MapHover.tscn
│   │   └── Bitacora/
│   │       ├── Bitacora.tscn
│   │       ├── BitacoraPersonas.tscn
│   │       ├── BitacoraNPCFicha.tscn
│   │       ├── BitacoraMundo.tscn
│   │       ├── BitacoraCalendario.tscn
│   │       └── BitacoraRecuerdos.tscn
│   ├── map/
│   │   ├── Mireval.tscn
│   │   └── locations/
│   │       ├── CasaForastero.tscn
│   │       ├── Plaza.tscn
│   │       ├── Cafe.tscn
│   │       ├── Taberna.tscn
│   │       ├── Mercado.tscn
│   │       ├── Archivo.tscn
│   │       ├── Taller.tscn
│   │       ├── Consejo.tscn
│   │       ├── Santuario.tscn
│   │       ├── Umbral.tscn
│   │       └── Bosque.tscn
│   └── minigames/
│       └── Cita.tscn
│
├── data/
│   ├── npcs/
│   │   ├── adelaida.json
│   │   ├── elena.json
│   │   └── exiliado.json
│   ├── dialogue/
│   │   ├── adelaida/
│   │   │   ├── primer_encuentro.json
│   │   │   ├── saludo_desconocidos.json
│   │   │   └── saludo_conocidos.json
│   │   └── elena/
│   ├── locations/
│   │   └── locations.json
│   ├── events/
│   │   └── story_flags.json
│   └── items/
│       └── items.json
│
├── assets/
│   ├── placeholders/
│   │   ├── npc_default.png
│   │   ├── background_default.png
│   │   └── item_default.png
│   ├── npcs/
│   │   ├── adelaida/
│   │   └── elena/
│   ├── backgrounds/
│   ├── ui/
│   └── music/
│
└── saves/
    └── [generado en runtime]
```

---

## 19. DESPLIEGUE — VERCEL

El juego se desplegará en el portafolio personal del autor alojado en Vercel.

### Configuración requerida

Godot Web export requiere headers HTTP específicos. Se configuran en `vercel.json`:

```json
{
  "headers": [
    {
      "source": "/juego/(.*)",
      "headers": [
        { "key": "Cross-Origin-Opener-Policy",   "value": "same-origin" },
        { "key": "Cross-Origin-Embedder-Policy",  "value": "require-corp" }
      ]
    }
  ]
}
```

La exportación de Godot va en la carpeta `/juego` del proyecto de Vercel. El portafolio existente no se modifica.

### Integración con el portafolio

- Sección dedicada al juego con descripción del mundo de Avaloria
- Juego embebido vía exportación web
- Bitácora pública de desarrollo — versión actual y estado del proyecto

---

## 20. FILOSOFÍA DE DESARROLLO

1. **Nunca programar sin acuerdo previo.** Claridad total antes de escribir código.
2. **Pensar siempre en la versión final.** No prototipar para rehacer.
3. **Componentes globales, nunca reimplementados.** Las escenas llaman sistemas, no los contienen.
4. **Un NPC = un archivo.** Agregar contenido nunca toca código existente.
5. **Placeholders siempre.** Todo asset pasa por AssetLoader con su fallback.
6. **El diseño manda.** Si una idea es incorrecta, se dice antes de programar.
7. **Comunicación antes que velocidad.** Asumir es el origen de la mayoría de los problemas.

---

## 21. PENDIENTES

### Alta prioridad — antes de abrir Godot
- [ ] Nombre y perfil del NPC exiliado del bosque
- [ ] Definición inicial de Adelaida — ocupación, personalidad, story_role, vínculo con Avaloria
- [ ] Definición inicial de Elena — ídem
- [ ] Schema de diálogos — cómo se estructura un archivo de diálogo de NPC
- [ ] Nombre del calendario de Avaloria — los meses y estaciones de Mireval

### Media prioridad — antes del primer build jugable
- [ ] Definir los items del Mercado — al menos 10 regalos con sus categorías por NPC
- [ ] Definir las festividades de Mireval y su impacto en el juego
- [ ] Diseño del minijuego de cita — flujo completo de pantalla

### Baja prioridad — para versiones futuras
- [ ] Sistema de reputación pública en Mireval — qué piensa el pueblo del jugador
- [ ] Consecuencias mecánicas de Voto del Sol alto — qué puertas abre con la Iglesia
- [ ] Consecuencias mecánicas de Grieta alta — qué revela el exiliado

---

*Documento vivo — se actualiza con cada sesión de diseño antes de tocar código.*  
*Versión 0.2 — integra referencias visuales del proyecto anterior, schema NPC enriquecido, medidores narrativos globales y sistema híbrido de ubicaciones.*