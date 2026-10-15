# Phase 1 — Canonical build and verification

> **Nota v4.0 (2026-10-15, as-built):** La escena canónica contiene intro, Fase 1, Fase 2 (patio), final y resultados. Tests nuevos o actualizados: playthrough (hasta la calle), containment (sin STAFF), escape_live (patio), game_systems; se retira test_phase2_parking_entry. Ver [FASE1_PREMIUM_AUDIT.md](FASE1_PREMIUM_AUDIT.md) (v4.0).

> **Nota v3.0 (2026-10-15, as-built):** La escena canónica implementa la ruta completa. Tests: playthrough, edges, containment, escape_live, canonical, parking_entry. Resultados en `PROJECT_STATUS.md` §7. Fuente de verdad del as-built y de las contradicciones resueltas: [FASE1_PREMIUM_AUDIT.md](FASE1_PREMIUM_AUDIT.md).

**Estado:** la arquitectura de referencia se ha revisado a v2.1 para representar un laboratorio completo, puzle distribuido, persecución interior y salida alternativa. La escena canónica aún refleja parcialmente el diseño anterior: la galería de evacuación, el segmento de persecución interior y la salida distinta del túnel de entrada no están implementados ni validados. No declarar greybox aceptado.

## Autoridad y estados de decisión

- Intención y programa espacial: `FASE1_ARCHITECTURAL_LAYOUT.md v2.1`.
- Nodos, aristas y accesibilidad: `FASE1_SPATIAL_GRAPH.md v1.1`.
- Plantas y sección: SVG existentes en `docs/design/assets/phase1_architecture/`, revisados para mostrar la salida alternativa.
- Footprints, anchos y colisiones: `FASE1_GREYBOX_SPEC.md v2.1`.
- Reglas de experiencia/puzle/huida: `FASE1_FUNCTIONAL_SPEC.md v2.1`.
- Recorrido y beats: `fase1_fase2_mapa_progresion.md v1.1`.
- Circuito eléctrico: `FASE1_LOGIC_CONTRACT.md`, sin cambios.

Distinguir siempre diseño objetivo, código implementado, test automatizado y validación manual. La actualización documental no acredita que la escena represente el nuevo diseño.

## Decisiones arquitectónicas fijadas

- El edificio se lee como una instalación clandestina de investigación hidrológica/industrial parcialmente abandonada.
- La investigación aprovecha A/B/C, D1/D2, M, E y F; las estancias no deben ser salas de relleno ni barreras arbitrarias.
- G inicia la huida dentro del edificio; no es una puerta exterior ni debe cambiar de escena inmediatamente.
- La huida usa S2, M, elevador, P0 y S1, y sale por una galería de evacuación nueva en P−1.
- La salida alternativa seleccionada enlaza físicamente con el aparcamiento y es distinta del túnel de entrada oeste. La galería y la boca este dibujadas actualmente son una propuesta, no una restricción para la ruta definitiva.
- Se conservan las conexiones verticales existentes; no añadir un segundo elevador ni una escalera secreta.
- El contrato del circuito, los inputs, autoloads, rutas de recursos, renderer Compatibility y guardado JSON/CRC32 no cambian sin aprobación explícita.

## Estado del constructor y riesgos

La reconstrucción anterior contiene túnel oeste, perímetro/salas P0, hueco D1/D2, retorno sur/este, elevador P0↔M, S1/S2, control/archivo y protecciones. Esas modificaciones siguen pendientes de ejecución Godot.

**Brecha principal contra arquitectura v2.1:** el constructor y la escena aún no implementan de forma completa la evasión silenciosa en áreas potencialmente ocupadas, la reacquisición que inicia la carrera, los obstáculos de huida, la ruta completa de descenso y la salida física al aparcamiento. Los SVG marcan O1 (estantería caída), O2 (bastidor de tuberías) y O3 (bandeja desprendida) como footprints iniciales medibles; son posiciones de diseño, no implementación ni evidencia de runtime. No afirmar que el código esté coordinado hasta reconstruir la geometría y las pruebas.

## Secuencia de implementación obligatoria

1. Capturar baseline: commit, versión de Godot, renderer, pruebas de Fase 0 y tests existentes.
2. Auditar el builder actual contra cada SVG, huella y arista del grafo.
3. Implementar la galería de evacuación P−1 y boca exterior; validar anchos, alturas, paredes, suelo y colisiones.
4. Cambiar G para abrir hacia la ruta interior de huida; conservar su lógica de interacción y no teletransportar.
5. Construir los obstáculos de persecución en el plano y greybox con footprints medibles, anticipación visual y solución justa.
6. Conectar el estado de amenaza con el recorrido interior; no arrancar la escena de aparcamiento al abrir G.
7. Crear el handoff a la escena de aparcamiento al cruzar la boca de servicio; conservar el checkpoint standalone.
8. Añadir pruebas para ruta G→S2/M→elevador/P0→S1/P−1→salida, estados del elevador y handoff.
9. Cubrir el contrato de evento de misión: mantenimiento OFF→ON encola `SERVICE_OVERRIDE` una sola vez; volver a OFF no lo borra; consultar F solo establece `RESTRICTED_RECORD_READ`; abrir G con la cola envía la auditoría y activa Containment una sola vez; abrir G sin cola no activa Containment; reiniciar la misión limpia los flags de sesión.
10. Verificar la sección de evasión silenciosa con STAFF-M1, percepción/cobertura/ruido y R1 en P0 (X≈29, Z≈1). La unidad debe seguir por el elevador existente y reacquirir por LOS real; el trigger debe coincidir con planos/grafo y no puede usar detección omnisciente.
10. Verificar que el evento de misión no altera las salidas ni el historial del modelo eléctrico definido en `FASE1_LOGIC_CONTRACT.md`.
9. Ejecutar todas las pruebas y playtest manual; corregir parse/runtime antes de añadir detalle visual.
10. Registrar commit, versión, renderer, comandos, exit codes, salida, errores/warnings, QA y limitaciones.

## Quality gates

### Arquitectura y geometría
- Todos los planos y la sección deben coincidir con el builder.
- El perímetro debe ser cerrado salvo puertas y salidas intencionadas.
- D1/D2 tienen suelo inferior y huecos reales en P0; el retorno S1→galería de servicio existe en colisión.
- G inicia el segmento interior; la galería de evacuación no se representa solo mediante una línea o un cambio de escena.
- La salida alternativa seleccionada se ve y se recorre hasta el aparcamiento; sus coordenadas se fijan tras cerrar el grafo completo.
- Todas las rutas se validan con cápsula de Elena y cámara real, sin saltos no diseñados.

### Puzle y huida
- El circuito mantiene el contrato existente; el error es reversible y diagnosticable.
- Las pistas distribuidas aportan contexto sin convertirse en llaves obligatorias.
- Los obstáculos de huida tienen posición, collider, solución, feedback y recuperación.
- El perseguidor entra en estados deterministas y no detecta antes del trigger acordado.
- El elevador durante la huida tiene un estado explícito y probado.

### Ingeniería y evidencia
- Regresión de Fase 0 obligatoria: `godot --headless --path . res://tests/test_phase_0.tscn`.
- Ejecutar circuit, lift, lift transport, canonical integration, parking entry y vertical slice.
- Inspeccionar debugger, errores/warnings, rutas de recursos y colisiones.
- Playtest manual de investigación, puzle, persecución, salida alternativa y continuidad al aparcamiento.
- No declarar CI verde sin el run real ni jugabilidad aceptada sin playtest.
- Registrar commit exacto, versión Godot, renderer, resolución, comandos, exit codes, resultados y evidencia visual.

La documentación ya no considera G→H una salida exterior directa. El código debe alcanzar este contrato antes de cerrar la preparación de Fase 1.