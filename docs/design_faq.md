# FINAL THAW — Design FAQ (Answering Critic's Core Questions)

## Question 1: ¿Qué hace el jugador durante los primeros cinco minutos?

### Minuto 0-1: MainMenu → Test Room
- **0:00-0:15**: MainMenu abre. Jugador presiona "Start Game" (Enter o A en controller).
- **0:15-0:30**: Fade to black, carga test_room (1-2 segundos).
- **0:30-1:00**: Jugador aparece como Elena en test_room. HUD muestra 3 contadores: Elena Safety (3/3), Prototype Integrity (3/3), Civilian Aid (0/10). Tutorial flotante: "WASD para mover. E para interactuar. Q para escanear."

### Minuto 1-3: Primer Puzzle (Power Routing)
- **1:00-1:30**: Jugador explora room, encuentra terminal (brilla en azul). Prompt: "[E] Access - Power Terminal".
- **1:30-2:00**: Jugador interactúa. UI muestra diagrama: "Connect Node 1 → Node 2 → Node 3 → Door". Node 1 ya conectado (verde). Jugador debe conectar Node 1 → Node 2 (arrastrar línea o rotar conector).
- **2:00-2:30**: Jugador conecta. Feedback inmediato: línea brilla verde (correcto) o roja (incorrecto). Si incorrecto: línea se resetea en 0.5 segundos, jugador reintenta.
- **2:30-3:00**: Jugador conecta Node 2 → Node 3, luego Node 3 → Door. Puerta se abre. Mensaje narrativo: "Power restored. The facility remembers me."

### Minuto 3-5: Primer Hazard (Steam Vents)
- **3:00-3:30**: Jugador atraviesa puerta, entra en corredor con steam vents. Tutorial: "Steam vents erupt every 10 seconds. Watch for hiss and white particles."
- **3:30-4:00**: Jugador observa primer vent: 1.0 second telegraph (hissing sound, white particles appear), luego erupción 2 seconds, luego safe window 7 seconds.
- **4:00-5:00**: Jugador cruza durante safe window. Si falla: -1 Prototype Integrity (de 3 a 2), HUD parpadea en rojo, checkpoint guarda. Jugador reintenta desde checkpoint (10 segundos atrás).

**Resultado a los 5 minutos**:
- Jugador ha aprendido: movimiento, interacción, scan, power routing, hazard navigation.
- Jugador ha tomado 3 decisiones: qué terminal activar primero, qué ruta de power usar, cuándo cruzar hazard.
- Jugador ha llegado a primer checkpoint (guardado automático).

---

## Question 2: ¿Qué habilidad aprende el jugador durante la primera hora?

### Hora 0-1: Phase 1-2 (Elena Tutorial + Laboratory)

**Habilidad Principal**: **Risk/Reward Calculation en Hazard Navigation**

**Progresión**:
- **0:00-0:15 (Minuto 0-15)**: Hazard simple (steam vent). Jugador aprende: telegraph → erupción → safe window. Decisión: esperar o arriesgar.
- **0:15-0:30 (Minuto 15-30)**: Hazard doble (2 steam vents sincronizados). Jugador aprende: patrones de timing, safe windows se solapan parcialmente. Decisión: cruzar rápido (más riesgo) o esperar ventana perfecta (más tiempo).
- **0:30-0:45 (Minuto 30-45)**: Hazard + puzzle (vent guarda puerta que requiere power). Jugador aprende: multi-tasking, priorizar threats. Decisión: resolver puzzle primero (seguro, lento) o cruzar hazard para shortcut (rápido, arriesgado).
- **0:45-1:00 (Minuto 45-60)**: Hazard + integrity pressure (Prototype Integrity = 2/3, un error más = 1/3). Jugador aprende: conservative play cuando integrity es bajo. Decisión: arriesgar para speedrun o jugar seguro para preservar integrity.

**Maestría Medible**:
- **Novice (primera hora)**: Cruza hazards en 8-10 segundos, toma 1-2 damage, integrity = 2-3/3.
- **Competent (hora 3-5)**: Cruza hazards en 5-7 segundos, toma 0-1 damage, integrity = 3/3.
- **Expert (hora 10+)**: Cruza hazards en 3-4 segundos, toma 0 damage, integrity = 3/3, usa hazards para skip enemies.

**Por qué esta habilidad**:
Risk/reward calculation es el CORE de FINAL THAW. No es "reaccionar rápido" (como un shooter) ni "memorizar patrones" (como un roguelike). Es **evaluar consecuencias materiales**: "¿Vale la pena perder 1 integrity para ahorrar 30 segundos?" Esta habilidad se transfiere a TODAS las decisiones del juego (civilian rescues, evidence choice, calibration charges).

---

## Question 3: ¿Qué decisión distingue este juego de otros del mismo género?

### Género: Climate Survival / Narrative Action-Adventure

**Decisión Única**: **Evidence Choice (Preserve vs. Erase) con Consecuencias Mecánicas Reales**

**En Phase 12 (Transit Hub)**:
- Jugador descubre: Helix engineered earlier Aster test failure para justificar emergency authority.
- **Opción A: Preserve Evidence**
  - Consecuencia narrativa: Elena y Marcus exponen conspiración, Helix pierde legitimidad pública.
  - Consecuencia mecánica: Final boss más difícil (Elena debe defenderse mientras calibra, Marcus enfrenta 4 waves en lugar de 3).
  - Ending eligibility: Desbloquea Public Thaw (mejor ending) si Civilian Aid ≥4 y Prototype Integrity ≥2.

- **Opción B: Erase Evidence**
  - Consecuencia narrativa: Helix controla narrativa, Aster se deploya inmediatamente pero con distribución controlada.
  - Consecuencia mecánica: Final boss más fácil (Elena calibra sin interrupciones, Marcus enfrenta 2 waves).
  - Ending eligibility: Bloquea Public Thaw, solo disponible Guarded Thaw (ending "neutral").

**Comparación con Otros Juegos**:

| Juego | Decisión "Moral" | Consecuencia Mecánica |
|-------|------------------|----------------------|
| **FINAL THAW** | Preserve/Erase Evidence | Final boss difficulty + ending eligibility |
| The Last of Us Part II | Perdonar o matar a Abby | Solo narrativa (cutscene diferente) |
| Frostpunk | Leyes (guardias armados, racionamiento) | Estadísticas de hope/discontent, no cambia ending final |
| Subnautica | Destroy/Upload Alterra | Solo narrativa (cutscene de 30 segundos diferente) |
| Detroit: Become Human | Múltiples decisiones en QTEs | Ramificación narrativa, pero gameplay idéntico |

**Por qué es único**:
- No es "bueno vs. malo" (como morality meters de BioWare).
- No es "narrativa vs. narrativa" (como Detroit o Life is Strange).
- Es **"qué tipo de bien"**: ¿Vale la pena sufrir más (boss más difícil) para lograr mejor mundo (Public Thaw)? ¿O preferimos solución rápida con compromiso moral (Guarded Thaw)?
- **La decisión es irreversible** (no hay "reload para ver ambos endings" sin perder 2-3 horas).
- **La decisión afecta gameplay medible** (boss difficulty, wave count), no solo cutscenes.

---

## Question 4: ¿Qué cambia entre una partida y otra?

### Variabilidad por Diseño

**Elementos que CAMBIAN**:

1. **Rutas Tomadas**:
   - Phase 6 (Shelter): Jugador puede tomar ruta principal (3 rooms, 10 min) o ruta alternativa con rescates (5 rooms, 15 min).
   - Phase 10 (Dam): Jugador puede usar 0-3 calibration charges. Usar 0 = más lento, más hazards. Usar 3 = rápido, pero sin charges para mandatory obstacle final.

2. **Decisiones Morales**:
   - Civilian Aid: Jugador puede rescatar 0-10 civiles. ≥4 desbloquea Public Thaw. <4 = solo Guarded/Fragile Thaw.
   - Evidence Choice: Preserve (boss más difícil, Public Thaw disponible) o Erase (boss más fácil, solo Guarded Thaw).

3. **Estilo de Juego**:
   - Elena: Stealth (evitar hazards, slow) o Speedrun (atravesar hazards, fast, integrity risk).
   - Marcus: Aggressive (rushdown, alto riesgo/recompensa) o Defensive (cover, block, bajo riesgo, más lento).

4. **Colectibles Encontrados**:
   - Memory Fragments: 24 total, jugador puede encontrar 0-24. 24/24 desbloquea special epilogue scene.
   - Cada memoria revela backstory diferente (Elena's sister Iris, Marcus's failure Amara, Voss's daughter Mumbai).

**Elementos que NO CAMBIAN**:

1. **Puzzle Solutions**: Todas fijas, no randomizadas. Power routing siempre misma solución.
2. **Enemy Placements**: Scavengers/Enforcers siempre en mismos lugares.
3. **Hazard Patterns**: Steam vents siempre 10-second cycle, electrical arcs siempre 0.8s telegraph.
4. **Boss Movesets**: Helix Commander siempre mismo attack order (energy blast → shield → reinforcements → reactor sabotage).

**Por qué esta combinación**:
- **Variabilidad en decisiones** = replayability (jugador quiere ver diferentes endings).
- **Fijeza en ejecución** = mastery (jugador puede speedrun, optimizar, competir).
- **Balance**: Jugador siente que su partida es única (sus decisiones, su estilo) pero puede comparar times con otros jugadores (mismos puzzles, mismos hazards).

**Replayability Metrics**:
- **Primera partida**: 13-15 horas (novice, explora todo, lee todo).
- **Segunda partida**: 8-10 horas (competent, sabe qué decisiones importan, optimiza rutas).
- **Speedrun Any%**: <45 minutos (expert, ignora colectibles, usa skips, perfect hazard navigation).
- **100% Completion**: <8 horas (colecta 24/24 memories, 10/10 civilians, Public Thaw ending).

---

## Question 5: ¿Qué hace que el jugador quiera continuar después del primer fracaso?

### Diseño de Recuperación (No Castigo)

**Primer Fracaso Típico**: Muerte en Phase 2 (Laboratory Room 3, moving platform puzzle).

**Qué Pasa**:
1. **Muerte**: Elena cae al agua, health = 0.
2. **Checkpoint Restart**: Jugador reaparece en entrada de Room 3 (no en Room 1, no en inicio del nivel).
3. **Pérdida de Tiempo**: 1-2 minutos (no 10-15 minutos).
4. **Pérdida de Progreso**: NINGUNA. Memory fragments collectados persisten. Civilian rescues persisten. Prototype Integrity se mantiene (no se pierde por muerte).
5. **Feedback Constructivo**: Mensaje: "Water hazard deals damage over time. Watch for bubble patterns—they show safe windows."

**Por qué Jugador Continúa**:

1. **Pérdida Aceptable**: 1-2 minutos es "okay, puedo intentarlo de nuevo." 10-15 minutos es "voy a dejar el juego."

2. **Aprendizaje Claro**: Jugador sabe QUÉ hizo mal (no esperó safe window) y CÓMO mejorarlo (esperar 8 seconds, cruzar en 2 seconds).

3. **Progreso Persistente**: Jugador no pierde colectibles. Si encontró memory fragment antes de morir, lo mantiene. Esto incentiva exploración ("al menos conseguí la memoria, vale la pena reintentar").

4. **Checkpoints Frecuentes**: Cada 3-5 minutos hay checkpoint. Jugador nunca siente que "perdió media hora."

5. **Skip Option**: Después de 3 muertes en mismo puzzle, juego ofrece: "Skip this section?" (narrativa se adapta, no se obtiene Civilian Aid, pero juego continúa).

**Comparación con Otros Juegos**:

| Juego | Primer Fracaso | Pérdida de Tiempo | Pérdida de Progreso | Jugador Continúa |
|-------|----------------|-------------------|---------------------|------------------|
| **FINAL THAW** | Death en hazard | 1-2 minutos | Ninguna (colectibles persisten) | ✅ Sí (pérdida aceptable) |
| The Long Dark | Congelación | 30-60 minutos | Toda la partida (permadeath) | ❌ Muchos abandonan |
| Dark Souls | Death | 5-15 minutos | Souls perdidas (recuperables si llegas al cuerpo) | ⚠️ Depende (hardcore vs. casual) |
| Subnautica | Death (con permadeath) | 1-2 horas | Toda la base, items, progreso | ❌ La mayoría abandona |
| Celeste | Death en pantalla | 5-30 segundos | Ninguna (respawn inmediato) | ✅ Sí (pérdida mínima) |

**Diseño Intencional**:
FINAL THAW se posiciona entre Celeste (pérdida mínima) y Dark Souls (pérdida moderada). **No es roguelike** (no hay permadeath, no hay pérdida de builds). **No es walking simulator** (hay fracaso real, hay consecuencias). Es **action-adventure con checkpointing generoso**.

---

## Question 6: ¿Cuál es la duración objetivo y cómo se justifica?

### Duración Objetivo: 12-15 Horas (Primera Partida)

**Desglose por Fase**:

| Fase | Tipo | Duración | Justificación |
|------|------|----------|---------------|
| Phase 0-1 | Tutorial | 20-30 min | Necesario para enseñar movement, interaction, scan, combat basics. No más corto (jugador no aprende), no más largo (aburrimiento). |
| Phase 2-3 | Solo Chapters | 30-40 min | Primeros capítulos reales. Ritmo lento para establecer personajes, mecánicas. |
| Phase 4-7 | Act I Escalation | 60-75 min | Ritmo acelera. Combates más largos, puzzles más complejos. |
| Phase 8 | First Joint Mission | 20-25 min | **Inflection point**. Cambio de ritmo (primera vez que Elena y Marcus cooperan). |
| Phase 9-12 | Act II Cooperation | 90-120 min | Pico de complejidad. Switching, synergies, evidence choice. |
| Phase 13 | Final Thaw Station | 25-35 min | **Nivel más largo**. Recombina todas las mecánicas. No más corto (no se siente "final"), no más largo (fatiga). |
| Phase 14 | Final Boss | 15-20 min | Boss más largo. Múltiples fases. No más corto (no se siente épico), no más largo (frustración). |
| Phase 15 | Epilogue + 3 Endings | 10-15 min | Cinemáticas, créditos, stinger. Tiempo para procesar narrativa. |
| Phase 16 | QA (no jugable) | N/A | No cuenta para duración. |
| **Total** | | **12-15 horas** | |

**Justificación de Duración**:

1. **Narrativa**: 12-15 horas es suficiente para desarrollar 2 protagonistas, antagonista complejo, 3 actos, 3 endings. No más corto (personajes planos), no más largo (padding, relleno).

2. **Mecánicas**: 12-15 horas permite enseñar 2 gameplay loops (Elena puzzle, Marcus combat), combinarlos (switching), y masterizarlos (finales). No más corto (jugador no domina), no más largo (repetitivo).

3. **Competencia Directa**:
   - The Last of Us Part II: 25-30 horas (demasiado largo para este tipo de narrativa).
   - A Plague Tale: Innocence: 10-12 horas (similar, pero sin dual-protagonist).
   - Detroit: Become Human: 10-12 horas (similar, pero sin gameplay mastery).
   - **FINAL THAW: 12-15 horas** (sweet spot: suficiente para mastery, no tanto para fatigue).

4. **Replayability**: 12-15 horas primera partida → 8-10 horas segunda → <45 minutos speedrun. Jugador puede completar 2-3 veces sin sentir que "ya lo vio todo."

5. **Precio/Valor**: 12-15 horas justifica precio de $30-40 (indie AA). No es $60 (AAA 40+ horas), no es $15 (indie 5-8 horas).

**Duración por Tipo de Jugador**:

| Tipo | Duración | Cómo |
|------|----------|------|
| Novice (primera partida, explora todo) | 15-18 horas | Lee todo, rescata todos los civiles, encuentra todas las memorias |
| Standard (primera partida, ritmo normal) | 12-15 horas | Sigue ruta principal, rescata algunos civiles |
| Speedrun Any% | <45 minutos | Ignora colectibles, usa skips, perfect execution |
| 100% Completion | <8 horas | Colecta todo, pero optimiza rutas |

---

## Summary: Respuestas Directas

| Pregunta | Respuesta |
|----------|-----------|
| **¿Qué hace el jugador en primeros 5 minutos?** | MainMenu → Test Room → Primer puzzle (power routing) → Primer hazard (steam vent) → Checkpoint. Aprende movimiento, interacción, scan, risk/reward básico. |
| **¿Qué habilidad aprende en primera hora?** | Risk/Reward calculation en hazard navigation. Evalúa: "¿Vale la pena perder integrity para ahorrar tiempo?" Se transfiere a TODAS las decisiones del juego. |
| **¿Qué decisión distingue este juego?** | Evidence Choice (Preserve vs. Erase) con consecuencias mecánicas reales (boss difficulty, ending eligibility). No es "bueno vs. malo", es "qué tipo de bien". |
| **¿Qué cambia entre partidas?** | Rutas tomadas, decisiones morales (Civilian Aid, Evidence), estilo de juego (stealth vs. speedrun), colectibles encontrados. NO cambian: puzzle solutions, enemy placements, hazard patterns. |
| **¿Qué hace que jugador continúe tras fracaso?** | Pérdida aceptable (1-2 minutos, no 10-15), aprendizaje claro (sabe QUÉ y CÓMO mejorar), progreso persistente (colectibles no se pierden), checkpoints frecuentes (3-5 min), skip option tras 3 muertes. |
| **¿Duración objetivo y justificación?** | 12-15 horas (primera partida). Suficiente para narrativa (3 actos, 3 endings), mecánicas (2 loops, switching, mastery), valor ($30-40 precio justo). No demasiado largo (fatiga), no demasiado corto (insuficiente). |

---

## Validación con Playtesters

**Métricas a Recoger en Early Access**:

1. **First 5 Minutes**:
   - ¿Jugadores completan primer puzzle sin hints?
   - ¿Entienden hazard telegraphs (sound, particles)?
   - ¿Llegan a checkpoint en 4-6 minutos?

2. **First Hour**:
   - ¿Jugadores mejoran hazard crossing time (8-10s → 5-7s)?
   - ¿Entienden integrity system (pierden 1, juegan más conservador)?
   - ¿Piden hints o experimentan solos?

3. **Evidence Choice**:
   - ¿Qué % elige Preserve vs. Erase?
   - ¿Entienden consecuencias (boss difficulty, ending eligibility)?
   - ¿Sienten que la decisión "importa"?

4. **Replayability**:
   - ¿Cuántos juegan segunda partida?
   - ¿Eligen diferentes rutas/decisiones?
   - ¿Reportan "se siente diferente"?

5. **Failure Recovery**:
   - ¿Cuántos abandonan tras 3 muertes en mismo puzzle?
   - ¿Usan skip option? ¿Con qué frecuencia?
   - ¿Reportan "frustrante" o "desafiante pero justo"?

6. **Duration**:
   - ¿Completan en 12-15 horas (novice)?
   - ¿Reportan "demasiado largo" o "demasiado corto"?
   - ¿Jugarían New Game+?

**Si métricas no coinciden con objetivos**: Iterar diseño (más hints, más checkpoints, más telegraphs, menos duración).
