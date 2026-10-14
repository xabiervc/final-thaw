# FASE1 — Especificación funcional de implementación (v2.0)

**Estado:** contrato funcional revisado para el diseño de edificio completo, puzle distribuido y huida interior. Las nuevas fases de persecución y salida alternativa aún no están implementadas ni validadas en Godot. No se afirma aceptación de runtime.  
**Autoridad:** arquitectura espacial en `FASE1_ARCHITECTURAL_LAYOUT.md v2.0`; grafo en `FASE1_SPATIAL_GRAPH.md v1.0`; huellas y colisiones en `FASE1_GREYBOX_SPEC.md`; progresión en `fase1_fase2_mapa_progresion.md v1.0`; contrato eléctrico en `FASE1_LOGIC_CONTRACT.md`.

## 1. Objetivo jugable

Elena investiga una anomalía física en una instalación clandestina de investigación hidrológica/industrial, entiende la distribución eléctrica, activa mantenimiento, configura el circuito de forma segura y consulta el archivo. Después abre G y escapa en dos ritmos: evasión silenciosa por áreas que pueden seguir ocupadas y una persecución a la carrera tras una reacquisición espacialmente legible. La salida alternativa se conecta físicamente con el aparcamiento de Fase 2.

La misión debe sentirse como explorar un lugar funcional. Las pistas se distribuyen entre la nave, el taller, el nivel de achique, la sala de bombas, control y archivo. No se exige inspeccionar todos los objetos; no hay llaves arbitrarias ni coleccionables obligatorios. La máquina de ensayo nunca arranca.

## 2. Contratos de exploración y circulación

- El edificio es una sola instalación con perímetro y circulación coherentes. Las salas principales A, B, C, D1, D2, M, E, F y G se distinguen por arquitectura, maquinaria, señalización y líneas de visión, no solo por texto o color.
- La entrada inicial es el túnel oeste → A. La salida final es una ruta distinta a través de P−1 y la galería de evacuación hacia el exterior este.
- S1 conecta P0↔P−1 y permanece transitable sin electricidad.
- El elevador conecta P0↔M (+1,5 m), solo con mantenimiento activo. No llega a P2.
- S2 conecta M↔P2, independientemente de energía.
- La escalera directa P0↔P2 permanece bloqueada.
- El retorno desde el rellano superior de S1 bordea el perímetro sur/este del hueco D1/D2 y llega a la galería de servicio. No se cruza el hueco ni se requiere un salto.
- G es una esclusa de doble puerta. Al abrir la compuerta exterior se envía la auditoría e inicia Containment; Elena retrocede por la puerta interior hacia F/E. La primera sección es evasión silenciosa por áreas potencialmente ocupadas. La carrera comienza tras una reacquisición real en un umbral expuesto definido en el grafo (propuesta inicial: salida del elevador hacia P0). La ruta y la salida final se deciden desde el grafo completo. G no es la salida final.
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

El segmento se activa cuando Elena abre la compuerta exterior de G con `SERVICE_OVERRIDE` encolado por la interacción de mantenimiento. Esta bandera pertenece al flujo de misión, no al modelo eléctrico de `FASE1_LOGIC_CONTRACT.md`; no modifica sus salidas ni su historial. Abrir G envía la auditoría, marca el evento como enviado y activa Containment una sola vez. Las llamadas repetidas no duplican el evento ni reinician la persecución. Consultar el archivo añade `RESTRICTED_RECORD_READ`, pero no dispara la persecución. Sin `SERVICE_OVERRIDE`, G devuelve una respuesta diegética de bloqueo y no inicia la huida. Reiniciar la misión restablece ambos flags; no se escriben en el guardado persistente.

- La transición de exploración a huida debe ser perceptible mediante respuesta audiovisual del edificio y cambio de comportamiento de la amenaza.
- La persecución sucede dentro del laboratorio. La escena del aparcamiento no debe cargarse hasta que Elena alcance la boca de servicio.
- Obstáculos candidatos para el greybox: compuerta de servicio que desciende, tramo de pasarela parcialmente bloqueado por un equipo desplazado y cruce técnico con tuberías/bandejas. Cada obstáculo requiere anticipación visual, colisión coherente, espacio de cámara y solución justa. No se consideran canon hasta quedar posicionados en el plano/greybox.
- No añadir combate obligatorio, armas ni nuevos sistemas de progresión.
- El descenso utiliza S2, elevador y S1 existentes. El estado del elevador durante la persecución debe definirse y probarse; no inventar una conexión vertical para salvar un bloqueo.
- La ruta termina en una salida de servicio alternativa distinta del túnel de entrada. Su nivel, lado del perímetro y conexión final se deciden desde el grafo completo; no se fuerza una boca para encajar el transform local del parking.

## 6. Transición a Fase 2

La salida de servicio seleccionada conecta físicamente con el aparcamiento. No se exige que use una boca ni coordenada provisional específica: la continuidad se resuelve al cerrar la ruta y el plano del parking. El handoff reutiliza `scenes/prototypes/phase2_parking_chase.tscn` y su checkpoint de entrada, si la prueba de integración confirma que conserva los contratos existentes. La versión standalone mantiene su propio inicio.

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
- Prueba de integración de topología: rutas A/B/C, S1, retorno sur/este, elevador P0↔M, S2, E/F/G, descenso de huida y salida de P−1.
- Pruebas de puerta G, estado de amenaza, obstáculos, elevador durante huida, boca de servicio y handoff al parking.
- Regresión de Fase 0 y vertical slice existente.
- Playtest manual con cámara de tercera persona: lectura del edificio, inferencia del puzle, recuperación tras error, navegación bajo persecución, alturas/anchos y continuidad exterior.
- Registrar commit, versión de Godot, renderer, comandos, exit codes, errores, warnings, resultados y evidencia visual.

No aceptar Fase 1 solo porque el circuito funcione o la escena importe. El edificio completo y la secuencia de salida deben poder jugarse de principio a fin.