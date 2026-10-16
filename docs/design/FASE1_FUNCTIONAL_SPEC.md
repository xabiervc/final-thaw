# FASE1 — Especificación funcional de implementación (v2.1)

> **Nota v4.0 (2026-10-15, as-built):** STAFF-M1 se ha eliminado; la sección silenciosa la sostiene la fase de sospecha de la unidad. G exterior solo se acciona tras leer el registro. Sin handoff de escena: la Fase 2 continúa en el mismo nivel. Ver [FASE1_PREMIUM_AUDIT.md](FASE1_PREMIUM_AUDIT.md) (v4.0).

> **Nota v3.0 (2026-10-15, as-built):** Por el cambio de datums, el panel de E y los controles de P2 quedan 3 m más altos. Nuevas decisiones de persecución: telemetría de contención, persiana R1 y barrido urgente (C10). El contrato eléctrico no cambia. Fuente de verdad del as-built y de las contradicciones resueltas: [FASE1_PREMIUM_AUDIT.md](FASE1_PREMIUM_AUDIT.md).

**Estado:** contrato funcional revisado para el diseño de edificio completo, puzle distribuido y huida interior. Las nuevas fases de persecución y salida alternativa aún no están implementadas ni validadas en Godot. No se afirma aceptación de runtime.  
**Autoridad:** arquitectura espacial objetivo en `FASE1_ARCHITECTURAL_LAYOUT.md v3.1`; grafo objetivo en `FASE1_SPATIAL_GRAPH.md v3.1`; objetivo ampliado de huellas/colisiones en el bloque de rediseño de `FASE1_GREYBOX_SPEC.md` (la geometría construida sigue en el registro as-built); progresión en `fase1_fase2_mapa_progresion.md v2.1`; contrato Aster sin cambios en `FASE1_LOGIC_CONTRACT.md`.

**Actualización de diseño acordada (2026-10-16):** el objetivo espacial nuevo está en `FASE1_ARCHITECTURAL_LAYOUT.md v3.1`, `FASE1_SPATIAL_GRAPH.md v3.1`, `FASE1_GREYBOX_SPEC.md` (bloque de rediseño) y `fase1_fase2_mapa_progresion.md v2.1`. Se conserva íntegro el puzle Aster/field-notes; la siguiente cadena es adicional y todavía no está implementada.

## Nueva cadena funcional: energía auxiliar y puerta de transferencia (objetivo, no as-built)

1. **Código del cajón:** la pizarra de turnos define B → D → A → C. La tira de presión muestra A=3, B=0, C=7, D=4; el jugador deduce 0437. Ningún texto entrega el código completo.
2. **Contenido del cajón:** SERVICE_KEY + INSULATED_BRIDGE. Son dos objetos distintos y no se consumen al inspeccionar.
3. **Subestación de P−2:** SERVICE_KEY abre la puerta. El panel presenta un terminal vacío con silueta/señalización compatible con INSULATED_BRIDGE.
4. **PowerRestored:** requiere llave válida, puente colocado en el terminal correcto y seccionador activado. La respuesta visible/audible incluye relés, zumbido, luces parciales, bombas auxiliares y alimentación disponible para el ascensor. La lógica Aster no se modifica: el estado de mantenimiento Aster sigue controlando su propia plataforma/luces; el ascensor solo queda operativo cuando existe alimentación auxiliar y la condición de mantenimiento requerida por el contrato existente está activa.
5. **Descubrimiento de puerta:** en el taller muerto de P−2, la franja limpia, marcas de arrastre y corriente de aire conducen a inspeccionar el panel. Se revela la puerta oculta, pero no se abre.
6. **Pista y llave de transferencia:** una nota de mantenimiento remite al armario seco elevado del almacén de repuestos. El símbolo del armario coincide con el de la puerta. Se obtiene TRANSFER_KEY; no es SERVICE_KEY.
7. **Aster preservado:** la secuencia de `FASE1_LOGIC_CONTRACT.md`, la hipótesis del cuaderno de campo y la consulta del registro restringido se mantienen como requisitos narrativos. La nueva cadena no debe cambiar los estados, salidas, historial o reglas del modelo Aster.
8. **Apertura del umbral:** la puerta requiere HiddenDoorDiscovered + TRANSFER_KEY + PowerRestored + RESTRICTED_RECORD_READ. La apertura revela el vestíbulo técnico del segundo edificio activo. No se puede sustituir por la salida de emergencia ni por una transición en P+3.

Las banderas nuevas son de sesión y no requieren cambios en el esquema de guardado. Antes de implementación se deben añadir pruebas de estados previos, orden de exploración alternativo, interacción repetida, llave equivocada, puente ausente, alimentación parcial y reinicio de misión. La integración no se considera aceptada hasta ejecutar las suites de Godot y probar manualmente el recorrido.

**Límite de lectura:** las secciones heredadas que siguen conservan el contrato Aster y documentan la ruta G→patio del runtime actual. Sus coordenadas P−1/M/P2 y el evento G no son la topología objetivo del rediseño. Para el nuevo greybox se aplican las cotas, nodos y umbral P−2 definidos en los documentos de arquitectura/progresión de arriba; el contrato interno Aster sigue siendo autoridad sin cambios.

## 1. Objetivo jugable

**As-built:** Elena investiga Aster, consulta el archivo, abre G y escapa por la instalación hasta el patio. **Objetivo rediseñado:** conserva íntegra la investigación Aster y añade una cadena de energía auxiliar y una llave de transferencia. El umbral narrativo pasa a la puerta oculta de P−2; al otro lado, Elena observa a personal humano en una instalación activa antes de ser detectada. La huida híbrida en primera persona conecta después con el aparcamiento y la calle. La secuencia G→patio y la unidad robótica solo describen el runtime actual hasta completar la migración.

La misión debe sentirse como explorar un lugar funcional. Las pistas se distribuyen entre la nave, el taller, el nivel de achique, la sala de bombas, control y archivo. No se exige inspeccionar todos los objetos; no hay llaves arbitrarias ni coleccionables obligatorios. La máquina de ensayo nunca arranca.

## 2. Contratos de exploración y circulación

- El edificio es una sola instalación con perímetro y circulación coherentes. Las salas principales A, B, C, D1, D2, M, E, F y G se distinguen por arquitectura, maquinaria, señalización y líneas de visión, no solo por texto o color.
- La entrada inicial es el túnel oeste → A. La salida final es una ruta distinta de la entrada; su nivel, lado del perímetro y conexión se deciden desde el grafo completo.
- S1 conecta P0↔P−1 y permanece transitable sin electricidad.
- El elevador conecta P0↔M (+1,5 m), solo con mantenimiento activo. No llega a P2.
- S2 conecta M↔P2, independientemente de energía.
- La escalera directa P0↔P2 permanece bloqueada.
- El retorno desde el rellano superior de S1 bordea el perímetro sur/este del hueco D1/D2 y llega a la galería de servicio. No se cruza el hueco ni se requiere un salto.
- G es una esclusa de doble puerta. Al abrir la compuerta exterior se envía la auditoría e inicia Containment; Elena retrocede por la puerta interior hacia F/E. La primera sección es evasión silenciosa por áreas potencialmente ocupadas. La carrera comienza en R1, la transición de la galería de servicio al retorno este de P0 (X≈29, Z≈1), tras una reacquisición real por LOS cuando la unidad sigue a Elena por el elevador existente. La ruta y la salida final se deciden desde el grafo completo. G no es la salida final.
- La galería de evacuación debe tener suelo, paredes/estructura, altura libre, colisiones y una boca exterior conectada al aparcamiento. No se permite teletransporte para simular la salida.

## 3. Circuito eléctrico — reglas preservadas

Estado inicial: mantenimiento OFF; selector ENSAYO; ensayo conectado; protección disponible; `last_trip` vacío; diagnóstico siempre operativo.

- El esquema muestra la distribución prevista: ARCHIVO hacia A y ENSAYO hacia T.
- El puente físico A→T está manipulado y constituye la anomalía.
- Escáner: mantener `scan` durante 0,9 s; revelar durante 3 s y aplicar 4 s de recarga desde la activación. Durante la ventana se resaltan el esquema/A, el puente A→T y el nodo T. Nunca resalta selector, aislador o rearme ni prescribe una acción.
- Orden seguro recomendado: aislar ENSAYO, seleccionar ARCHIVO y comprobar el estado. Resultado esperado: ARCHIVO estable y protección disponible.
- Si se selecciona ARCHIVO con ENSAYO conectado, la protección dispara inmediatamente y registra `DEMANDA_SIMULTANEA`. No hay muerte ni bloqueo permanente. Aislar ENSAYO y rearmar permite recuperarse.
- Cambiar selector o aislador no rearma por sí solo. Rearme solo tiene éxito con el fallo ausente.
- El diagnóstico permanece disponible en cualquier estado y muestra estado actual y último disparo como datos separados.
- Mantenimiento activa iluminación/elevador, pero no alimenta la protección de recuperación. En la transición OFF → ON, la interacción encola el flag de misión `SERVICE_OVERRIDE` como efecto narrativo separado; no altera el modelo de circuito. El flag persiste durante la misión aunque mantenimiento vuelva a OFF, y no se encola más de una vez.
- Consultar F solo está disponible cuando ARCHIVO está estable. El conocimiento adquirido se conserva durante la sesión aunque después se pierda alimentación; no se escribe en el guardado persistente en este hito.

## 4. Función de cada sector en la investigación

| Sector | Información/acción | Límite |
|---|---|---|
| A/B | Presenta Aster, nave, escala y canalizaciones. | No prescribe el orden de controles. |
| C | Añade contexto de mantenimiento y reparaciones improvisadas. | No introduce una llave nueva. |
| D1/D2 | Contrastar esquema y puente físico; activar mantenimiento. | El escáner no resuelve el circuito. |
| M | Mostrar respuesta de bombas/iluminación y enlazar cotas. | No crea una segunda regla eléctrica. |
| E | Diagnóstico, selector, aislador y rearme. | Mantener centros de interacción y contrato existentes. |
| F | Consultar con ARCHIVO estable. | Consulta no es extracción ni condición técnica para que el circuito funcione. |
| G | Puerta que envía la auditoría e inicia Containment. | No equivale a correr inmediatamente ni cambia de escena. |

Las pistas ambientales deben poder leerse en el espacio real y desde la cámara. Si el texto no se puede leer, debe corregirse su montaje/legibilidad; no compensarlo añadiendo marcadores que den la solución.

## 5. Huida interior

El segmento se activa cuando Elena abre la compuerta exterior de G con `SERVICE_OVERRIDE` encolado por la interacción de mantenimiento. Esta bandera pertenece al flujo de misión, no al modelo eléctrico de `FASE1_LOGIC_CONTRACT.md`; no modifica sus salidas ni su historial. Abrir G envía la auditoría, marca el evento como enviado y activa Containment una sola vez. Las llamadas repetidas no duplican el evento ni reinician la secuencia de huida. Consultar el archivo añade `RESTRICTED_RECORD_READ`, pero no dispara la persecución. Sin `SERVICE_OVERRIDE`, G devuelve una respuesta diegética de bloqueo y no inicia la huida. Reiniciar la misión restablece ambos flags; no se escriben en el guardado persistente.

- La transición de exploración a huida debe ser perceptible mediante respuesta audiovisual del edificio y cambio de comportamiento de la amenaza.
- La persecución sucede dentro del laboratorio. La escena del aparcamiento no debe cargarse hasta que Elena alcance la boca de servicio.
- Obstáculos candidatos para el greybox: compuerta de servicio que desciende, tramo de pasarela parcialmente bloqueado por un equipo desplazado y cruce técnico con tuberías/bandejas. Cada obstáculo requiere anticipación visual, colisión coherente, espacio de cámara y solución justa. No se consideran canon hasta quedar posicionados en el plano/greybox.
- No añadir combate obligatorio, armas ni nuevos sistemas de progresión.
- El descenso utiliza S2, elevador y S1 existentes. El estado del elevador durante la persecución debe definirse y probarse; no inventar una conexión vertical para salvar un bloqueo.
- La ruta termina en una salida de servicio alternativa distinta del túnel de entrada. Su nivel, lado del perímetro y conexión final se deciden desde el grafo completo; no se fuerza una boca para encajar el transform local del parking.

## 5.1 Contrato de evasión, personal y reacquisición

Esta capa es nueva y aún no está implementada ni validada. No debe mezclarse con el contrato eléctrico ni cambiar el guardado.

### Personal y ocupación

- **STAFF-M1 — operario de bombas:** ocupa la sala M durante el tramo silencioso. Su rutina corta transcurre entre el panel de bombas y la consola de mantenimiento, sin cruzar el paso crítico hacia el elevador. No es enemigo, no combate ni bloquea el corredor.
- Antes de abrir G, STAFF-M1 permanece en estado `WORKING`; la presencia de Elena en zonas normales de trabajo no provoca una alarma. Cuando G envía la auditoría, el personal recibe una señal diegética de Containment y pasa a una rutina de alerta/evacuación. El jugador puede evitar su línea de visión usando la masa de las bombas como cobertura C1 y el rack O2 como obstáculo/cobertura secundaria solo si el collider real bloquea visión.
- Estados mínimos: `WORKING`, `SUSPICIOUS`, `INVESTIGATING`, `ALERTED` y `WITHDRAWING`. Cada estado debe tener una respuesta ambiental legible (orientación, pausa, voz breve o retirada); ninguna transición debe depender de un texto opcional.
- Visión objetivo de diseño: rango 8 m, cono 100° y línea de visión libre. La cobertura opaca bloquea visión; no se detecta a Elena a través de muros, bombas o racks.
- Ventana de sospecha objetivo: tras 0,8 s de visión válida, el NPC da una señal de sospecha; tras 1,2 s continuos, confirma alerta. Si pierde LOS, la sospecha decae en 2 s. Estos tiempos son objetivos de diseño para playtest, no valores verificados de código.
- Ruido: si el sistema de ruido está disponible, caminar genera eventos de corto alcance (objetivo 4 m), correr de alcance medio (objetivo 8 m) e impactos/puertas fuertes de alcance mayor (objetivo 12 m). Si el sistema no existe, la primera implementación puede usar LOS y timing, pero no debe afirmar que el ruido está simulado.
- Al alertarse, STAFF-M1 emite una única llamada y se retira hacia un refugio fuera del paso crítico. El evento comunica al recovery unit la **última posición conocida**, no las coordenadas actuales de Elena. No activa la carrera por sí solo.
- La evasión se puede completar con movimiento, observación y timing; no requiere takedown, distracción consumible ni combate. Una detección puede adelantar la persecución solo si la unidad de recuperación obtiene LOS real; no debe producir muerte arbitraria.

### R1 — umbral de reacquisición y comienzo de carrera

**Ubicación de diseño:** P0, en la transición desde la galería de servicio hacia el retorno este, inmediatamente después del rellano del elevador P0↔M; coordenada de referencia aproximada `X≈29, Z≈1` según el grafo actual. El nodo está fijado como intención espacial; las huellas/colliders exactos requieren comprobación en la planta y la escena.

- Elena recorre M en silencio, toma el elevador existente hacia P0 y entra en la galería de servicio. El recovery unit la sigue por el mismo elevador y llega físicamente detrás de ella.
- R1 activa la transición a carrera cuando la unidad entra en el espacio abierto y reacquiere a Elena por línea de visión real. No se crea una unidad delante del jugador ni se teletransporta al perseguidor.
- R1 es el punto de reacquisición por defecto si la evasión anterior se completa sin detección. Si la unidad obtiene LOS real antes, la carrera puede comenzar antes; si no está físicamente presente en R1, el trigger espera a que llegue.
- El cambio de estado se comunica con sonido/animación/feedback y cambio de ritmo, sin corte de cámara, bloqueo de input ni muerte instantánea.
- Tras R1, la ruta de carrera es P0 retorno este → S1 → P−1 → galería de evacuación → salida exterior alternativa. La boca este de P−1 (X=34, Z=4,5..7,5, Y=−2) y el transform del parking (X_mundo=X_local+28,7; Z_mundo=Z_local−15,8) son el baseline seleccionado; no se inventa otra escalera ni elevador. La continuidad física queda pendiente de verificación.

Pruebas mínimas:
1. STAFF-M1 no detecta a Elena detrás de cobertura opaca.
2. Una detección requiere cono/rango/LOS o un evento de ruido válido.
3. Al perder visión, STAFF-M1 busca la última posición conocida y no sigue la posición real a través de muros.
4. La sección silenciosa admite una ruta completa sin takedowns.
5. La unidad sigue una ruta física por S2/M y el elevador; R1 solo cambia a carrera al existir presencia y LOS reales.
6. La carrera puede comenzar antes de R1 solo por reacquisición real; no hay detección omnisciente.
7. Reiniciar la misión restablece estados temporales sin alterar el circuito ni el guardado.

## 6. Transición a Fase 2

La salida de servicio seleccionada conecta físicamente con el aparcamiento mediante galería de 6×3 m. El umbral local del parking (5,3; 21,8) coincide con la boca P−1 (34; 6); el spawn local (6,8; 21,8) queda en mundo (35,5; 6). El transform es baseline de diseño y debe verificarse en escena. El handoff reutiliza `scenes/prototypes/phase2_parking_chase.tscn` y su checkpoint de entrada, si la prueba de integración confirma que conserva los contratos existentes. La versión standalone mantiene su propio inicio.

Criterios:
1. G abre y Containment comienza; la evasión silenciosa inicia sin transición instantánea de escena.
2. La fase silenciosa tiene cobertura, NPC/estados y percepción verificables.
3. Un umbral espacial legible produce la transición a carrera cuando la unidad reacquiere a Elena.
4. Elena puede navegar la ruta de huida con cámara y colisiones reales.
3. El perseguidor se mantiene dentro de los estados previstos y no detecta a Elena antes de tiempo.
6. La salida desemboca en el exterior y el aparcamiento es visible/continuo.
5. El cambio de escena no duplica al jugador ni pierde el estado requerido.
8. El checkpoint de aparcamiento se usa solo en el handoff canónico; el inicio standalone permanece intacto.

## 7. Historia y estado de decisiones

La identidad del laboratorio, el recorrido de huida y el contrato de evento del opening están especificados como propuesta en `docs/narrative_complete.md` y `docs/DESIGN_PIVOT_PROTOTYPE_BRIEF.md`. Permanecen abiertos el motivo de la supresión, el destinatario/supervisión exactos, la identidad final de la unidad, la cronología completa y el destino posterior. `SERVICE_OVERRIDE` y `RESTRICTED_RECORD_READ` son flags de misión en memoria; no cambian el esquema de guardado ni el modelo eléctrico.

## 8. Pruebas y aceptación

- Pruebas unitarias del circuito y del elevador existente.
- Prueba de integración de topología: rutas A/B/C, S1, retorno, elevador P0↔M, S2, E/F/G, evasión silenciosa, reacquisición, carrera y salida alternativa seleccionada.
- Pruebas de puerta G, estado de amenaza, obstáculos, elevador durante huida, boca de servicio y handoff al parking.
- Regresión de Fase 0 y vertical slice existente.
- Playtest manual con cámara de tercera persona: lectura del edificio, inferencia del puzle, recuperación tras error, navegación bajo persecución, alturas/anchos y continuidad exterior.
- Registrar commit, versión de Godot, renderer, comandos, exit codes, errores, warnings, resultados y evidencia visual.

No aceptar Fase 1 solo porque el circuito funcione o la escena importe. El edificio completo y la secuencia de salida deben poder jugarse de principio a fin.

## Owner-approved functional redesign target (2026-10-15)

This addendum records the latest target and does not claim that the current functional implementation satisfies it. The existing Aster circuit/field-notes contracts remain valid unless a separately justified change is approved.

- Phase 1 is an interconnected investigation space centered on a large pumping hall. Room progression must use meaningful observation, traversal, interaction and causal puzzle consequences. Avoid an overly open single room and avoid a maze.
- Entry is through a damaged service breach/culvert that collapses behind Elena. Enforce the blocked return with actual geometry/collision and test alternate approaches for unintended bypasses.
- After the required gate opens, Elena enters a previously unseen human operational area and observes meaningful Helix/Aster activity before a human security threat detects her.
- The target escape is hybrid first-person play: free movement/route choices plus short contextual actions and brief looks back that show player-caused consequences. It must not be a QTE-only sequence.
- The route proceeds to a separately designed parking garage and then a public street where Elena loses the pursuers among pedestrians. Maintain continuity through geometry or a deliberate transition.
- The current robot-led containment behavior remains an as-built prototype until replaced. Do not treat existing robot tests as proof of human-pursuit behavior.
- Full Marcus-led beat-'em-up and Elena companion progression are future scope; this specification should not pull that system into the current Phase 1/2 work.

Acceptance requires updated behavior tests, a full test run on the final integrated commit, and in-engine/manual verification of spatial clarity, pursuit fairness, camera comfort and the complete route.
