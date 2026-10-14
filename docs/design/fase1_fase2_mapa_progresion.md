# FINAL THAW — Fases 1 y 2: mapa de progresión verificable (v0.8)

**Estado:** diseño arquitectónico cerrado para el siguiente greybox; validación pendiente. Autoridad: FASE1_ARCHITECTURAL_LAYOUT.md v1.0, FASE1_SPATIAL_GRAPH.md v0.6, FASE1_GREYBOX_SPEC.md v1.3, FASE1_FUNCTIONAL_SPEC.md v1.1 y FASE1_LOGIC_CONTRACT.md (sin cambios).

## Recorrido

A/B en P0 → S1 ↓ D en P−1 → volver S1 → galería de servicio → elevador P0↔M (+1,5 m) → sala de bombas/galería → S2 ↑ E/P2 (+3 m) → F → G → H.

La escalera directa P0↔P2 está dañada y bloqueada. G no incluye atajo vertical a P0. El elevador termina en M; S2 lleva a control. Cada conexión vertical tiene destino propio.

## Sectores funcionales

| Zona | Cota | Función |
|---|---:|---|
| A · Acceso | 0 m | Orientación y hito central visible. |
| B · Nave | 0 m | Columna Aster y rig; lectura industrial. |
| C · Taller | 0 m | Cuadros/banco opcionales, sin llaves. |
| D1/D2 · Foso | −2 m | Contrastar esquema y puente; activar mantenimiento. |
| M · Bombas | +1,5 m | Ver efecto de mantenimiento y orientarse. |
| E · Control | +3 m | Probar hipótesis y recuperarse de errores. |
| F · Archivo | +3 m | Consultar con suministro estable. |
| G · Esclusa | +3 m | Transmitir auditoría y cruzar a H. |
| H · Exterior | exterior | Huida justa, con contrajuego. |

## Circuito/evidencia

Estado inicial: mantenimiento OFF; ENSAYO seleccionado; ensayo conectado; protección disponible; no hay último disparo. Orden seguro recomendado: aislar ENSAYO, seleccionar ARCHIVO, comprobar diagnóstico. ARCHIVO seleccionado con ensayo conectado dispara DEMANDA_SIMULTANEA; aislar y rearmar tras eliminar el fallo recupera. Selector/aislador no rearman implícitamente. La máquina no arranca; mantenimiento no alimenta el circuito de recuperación.

El registro contradice el acta: el acta declara alimentación exclusiva a T, pero la telemetría registra corriente simultánea en A y T. Consultar no es extracción ni cambia el guardado.

## Containment

Mantenimiento añade SERVICE_OVERRIDE a la auditoría. Consultar F añade RESTRICTED_RECORD_READ. Al cruzar G, el relé transmite eventos y activa Containment. En H, la unidad patrulla y detecta por visión/línea de visión/ruido. Omitir el registro no bloquea salida ni suprime el evento de mantenimiento.

## Orden de trabajo

1. Rehacer P0/P−1 y S1.
2. Reconfigurar elevador P0↔M y probar parada a +1,5 m.
3. Construir M/S2; conectar a P2.
4. Construir E/F/G sin escalera de retorno.
5. Reintegrar lógica sin cambiar contrato/guardado.
6. Ejecutar circuit, lift, navegación y Phase 0 tests.
7. Validar persecución v2 por separado y probar transición completa.

Cerrar Fase 1 solo con pruebas automáticas, ruta manual, visibilidad, colisiones, pérdida de potencia y comprensión de jugador nuevo.
