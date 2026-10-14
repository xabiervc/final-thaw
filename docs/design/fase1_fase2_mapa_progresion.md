# FINAL THAW — Fases 1 y 2: mapa de progresión verificable (v0.9)

**Estado:** topología espacial y contrato funcional del circuito aprobados conceptualmente; reconstrucción de escena ampliada, validación pendiente. Los beats específicos de Helix/Containment siguen siendo propuestas narrativas, no canon aprobado. Autoridad: FASE1_ARCHITECTURAL_LAYOUT.md v1.1, FASE1_SPATIAL_GRAPH.md v0.7, FASE1_GREYBOX_SPEC.md v1.4, FASE1_FUNCTIONAL_SPEC.md v1.1 y FASE1_LOGIC_CONTRACT.md (sin cambios).

## Recorrido de Fase 1

Túnel exterior → A/B en P0 → S1 ↓ D1/D2 en P−1 → subir por S1 → rodear el foso por el perímetro sur y el retorno este → galería de servicio → elevador P0↔M (+1,5 m) → sala de bombas/galería → S2 ↑ E/P2 (+3 m) → F → G → H.

La escalera directa P0↔P2 está dañada y bloqueada. G no incluye atajo vertical a P0. El elevador termina en M; S2 lleva a control. Cada conexión vertical tiene destino propio.

## Sectores funcionales

| Zona | Cota | Función |
|---|---:|---|
| A · Acceso | 0 m | Orientación y primera vista al hito central. |
| B · Nave | 0 m | Columna Aster, rig y circulación industrial. |
| C · Taller | 0 m | Cuadros/banco opcionales, sin llaves. |
| D1/D2 · Foso | −2 m | Contrastar esquema y puente; activar mantenimiento. |
| M · Bombas | +1,5 m | Ver efecto de mantenimiento y orientarse. |
| E · Control | +3 m | Probar hipótesis y recuperarse de errores. |
| F · Archivo | +3 m | Consultar con suministro estable. |
| G · Esclusa | +3 m | Transmitir auditoría y cruzar a H. |
| H · Umbral exterior | exterior | Transición espacial directa al aparcamiento de Fase 2. |

## Circuito/evidencia

Estado inicial: mantenimiento OFF; ENSAYO seleccionado; ensayo conectado; protección disponible; no hay último disparo. Orden seguro recomendado: aislar ENSAYO, seleccionar ARCHIVO, comprobar diagnóstico. ARCHIVO seleccionado con ensayo conectado dispara DEMANDA_SIMULTANEA; aislar y rearmar tras eliminar el fallo recupera. Selector/aislador no rearman implícitamente. La máquina no arranca; mantenimiento no alimenta el circuito de recuperación.

La evidencia funcional prevista contrapone el acta (alimentación exclusiva a T) con la telemetría (corriente simultánea en A y T). La formulación definitiva del texto y su estatus como pista narrativa deben aprobarse antes de tratarla como canon. Consultar no es extracción y no cambia el guardado.

## Continuidad de Fase 2 — aparcamiento y huida

La compuerta exterior de G debe desembocar físicamente en una zona exterior de servicio/aparcamiento, no en un espacio abstracto ni en una transición visual sin contexto. La continuidad espacial G→H es requisito de arquitectura. El aparcamiento con plazas, pilares, coches inmóviles, carriles y rutas de huida, así como el comportamiento de la amenaza, pertenece a la integración de Fase 2 y debe validarse en el prototipo existente; no añadir nuevos sistemas ni convertir una propuesta narrativa en canon sin aprobación.

La escena de persecución conserva su versión standalone desde el inicio del corredor. El handoff canónico propuesto usa `scenes/prototypes/phase2_parking_chase.tscn`, reutiliza el mismo script y arranca en el checkpoint de entrada al aparcamiento (X=34,5). Esto sigue pendiente de ejecución combinada. La señal de sincronización, el motivo concreto de Containment y la reacción/percepción de Elena no se consideran decisiones narrativas aprobadas. No añadir combate obligatorio ni bloquear el progreso por no consultar el archivo.

## Estado de decisiones

- **Aprobado conceptualmente:** huellas y cotas de las cuatro plantas; S1 P0↔P−1, elevador P0↔M, S2 M↔P2; G→H como salida horizontal; contrato lógico del circuito; consulta de F condicionada a ARCHIVO estable y separada de extracción.
- **Propuesto, pendiente de aprobación narrativa:** redacción exacta de la evidencia, eventos de auditoría transmitidos en G, causa y timing de Containment, señal que percibe Elena, comportamiento narrativo inicial de la unidad de recuperación y destino posterior.
- **Pendiente de validación en Godot:** geometría y colisiones reales, retorno por perímetro sur/este, escaleras, elevador y compuertas, legibilidad desde cámara, interacciones, consulta, recorrido completo y handoff G→H.
- **Regla de trabajo:** si una prueba contradice el diseño aprobado, registrar la desviación y corregir implementación/documentación con evidencia; no cambiar contratos o canon narrativo para hacer pasar el test.

## Orden de trabajo

1. Ejecutar la escena canónica ampliada y revisar parse/runtime.
2. Validar P0/P−1, S1 y el hueco continuo D1/D2.
3. Probar elevador a M y S2 a P2.
4. Validar E/F/G, circuito y recorrido completo.
5. Diseñar/ajustar el arranque de persecución en el aparcamiento usando la escena existente, sin crear otro documento de progresión.
6. Ejecutar pruebas de circuito, elevador, integración y Fase 0; hacer playtest manual.

Cerrar Fase 1 solo con pruebas automáticas, ruta manual, visibilidad, colisiones, pérdida de potencia y comprensión de jugador nuevo.
