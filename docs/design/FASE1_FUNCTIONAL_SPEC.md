# FASE1 — Especificación funcional de implementación (v2.0)

**Estado:** contrato funcional revisado para el diseño de edificio completo, puzle distribuido y huida interior. Las nuevas fases de persecución y salida alternativa aún no están implementadas ni validadas en Godot. No se afirma aceptación de runtime.  
**Autoridad:** arquitectura espacial en `FASE1_ARCHITECTURAL_LAYOUT.md v2.0`; grafo en `FASE1_SPATIAL_GRAPH.md v1.0`; huellas y colisiones en `FASE1_GREYBOX_SPEC.md`; progresión en `fase1_fase2_mapa_progresion.md v1.0`; contrato eléctrico en `FASE1_LOGIC_CONTRACT.md`.

## 1. Objetivo jugable

Elena investiga una anomalía física en una instalación clandestina de investigación hidrológica/industrial, entiende la distribución eléctrica, activa mantenimiento, configura el circuito de forma segura y consulta el archivo. Después abre G, atraviesa una persecución dentro del edificio y escapa por una galería de servicio a una zona de aparcamiento que enlaza con Fase 2.

La misión debe sentirse como explorar un lugar funcional. Las pistas se distribuyen entre la nave, el taller, el nivel de achique, la sala de bombas, control y archivo. No se exige inspeccionar todos los objetos; no hay llaves arbitrarias ni coleccionables obligatorios. La máquina de ensayo nunca arranca.

## 2. Contratos de exploración y circulación

- El edificio es una sola instalación con perímetro y circulación coherentes. Las salas principales A, B, C, D1, D2, M, E, F y G se distinguen por arquitectura, maquinaria, señalización y líneas de visión, no solo por texto o color.
- La entrada inicial es el túnel oeste → A. La salida final es una ruta distinta a través de P−1 y la galería de evacuación hacia el exterior este.
- S1 conecta P0↔P−1 y permanece transitable sin electricidad.
- El elevador conecta P0↔M (+1,5 m), solo con mantenimiento activo. No llega a P2.
- S2 conecta M↔P2, independientemente de energía.
- La escalera directa P0↔P2 permanece bloqueada.
- El retorno desde el rellano superior de S1 bordea el perímetro sur/este del hueco D1/D2 y llega a la galería de servicio. No se cruza el hueco ni se requiere un salto.
- G no es la salida exterior. Al abrirse, inicia el segmento de huida y la persecución interior. La ruta continúa por circulación técnica, S2/M, elevador/P0, S1/P−1 y galería de evacuación.
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
- Mantenimiento activa iluminación/elevador, pero no alimenta la protección de recuperación.
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
| G | Puerta de huida y comienzo de persecución. | No cambiar de escena directamente al aparcamiento. |

Las pistas ambientales deben poder leerse en el espacio real y desde la cámara. Si el texto no se puede leer, debe corregirse su montaje/legibilidad; no compensarlo añadiendo marcadores que den la solución.

## 5. Huida interior

El segmento se activa cuando Elena abre G después de completar la condición de salida acordada. El disparador narrativo concreto de la amenaza sigue pendiente de cierre; la condición espacial de la huida queda fijada.

- La transición de exploración a huida debe ser perceptible mediante respuesta audiovisual del edificio y cambio de comportamiento de la amenaza.
- La persecución sucede dentro del laboratorio. La escena del aparcamiento no debe cargarse hasta que Elena alcance la boca de servicio.
- Obstáculos candidatos para el greybox: compuerta de servicio que desciende, tramo de pasarela parcialmente bloqueado por un equipo desplazado y cruce técnico con tuberías/bandejas. Cada obstáculo requiere anticipación visual, colisión coherente, espacio de cámara y solución justa. No se consideran canon hasta quedar posicionados en el plano/greybox.
- No añadir combate obligatorio, armas ni nuevos sistemas de progresión.
- El descenso utiliza S2, elevador y S1 existentes. El estado del elevador durante la persecución debe definirse y probarse; no inventar una conexión vertical para salvar un bloqueo.
- La ruta termina en la galería de evacuación de P−1 y en una salida exterior distinta del túnel de entrada.

## 6. Transición a Fase 2

La salida de servicio conecta físicamente con el aparcamiento. El handoff reutiliza `scenes/prototypes/phase2_parking_chase.tscn` y su checkpoint de entrada, si la prueba de integración confirma que conserva los contratos existentes. La versión standalone mantiene su propio inicio.

Criterios:
1. G abre y la persecución interior comienza.
2. Elena puede navegar la ruta de huida con cámara y colisiones reales.
3. El perseguidor se mantiene dentro de los estados previstos y no detecta a Elena antes de tiempo.
4. La galería de evacuación desemboca en el exterior y el aparcamiento es visible/continuo.
5. El cambio de escena no duplica al jugador ni pierde el estado requerido.
6. El checkpoint de aparcamiento se usa solo en el handoff canónico; el inicio standalone permanece intacto.

## 7. Historia y estado de decisiones

La identidad general del laboratorio y el recorrido de huida son requisitos de diseño. Permanecen pendientes de aprobación narrativa: el evento exacto recibido por Helix, si F se audita, la percepción de Elena, causa/timing de Containment, identidad y punto de entrada de la amenaza, y el destino posterior. No convertir `SERVICE_OVERRIDE`, `RESTRICTED_RECORD_READ` o señales de sincronización en canon sin cerrar esos puntos.

## 8. Pruebas y aceptación

- Pruebas unitarias del circuito y del elevador existente.
- Prueba de integración de topología: rutas A/B/C, S1, retorno sur/este, elevador P0↔M, S2, E/F/G, descenso de huida y salida de P−1.
- Pruebas de puerta G, estado de amenaza, obstáculos, elevador durante huida, boca de servicio y handoff al parking.
- Regresión de Fase 0 y vertical slice existente.
- Playtest manual con cámara de tercera persona: lectura del edificio, inferencia del puzle, recuperación tras error, navegación bajo persecución, alturas/anchos y continuidad exterior.
- Registrar commit, versión de Godot, renderer, comandos, exit codes, errores, warnings, resultados y evidencia visual.

No aceptar Fase 1 solo porque el circuito funcione o la escena importe. El edificio completo y la secuencia de salida deben poder jugarse de principio a fin.