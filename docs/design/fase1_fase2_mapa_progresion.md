# FINAL THAW — Fases 1 y 2: mapa de progresión verificable (v0.9)

**Estado:** diseño arquitectónico cerrado para el siguiente greybox integrado; reconstrucción de escena ampliada, validación pendiente. Autoridad: FASE1_ARCHITECTURAL_LAYOUT.md v1.1, FASE1_SPATIAL_GRAPH.md v0.7, FASE1_GREYBOX_SPEC.md v1.4, FASE1_FUNCTIONAL_SPEC.md v1.1 y FASE1_LOGIC_CONTRACT.md (sin cambios).

## Recorrido de Fase 1

Túnel exterior → A/B en P0 → S1 ↓ D1/D2 en P−1 → volver por S1 → galería de servicio → elevador P0↔M (+1,5 m) → sala de bombas/galería → S2 ↑ E/P2 (+3 m) → F → G → H.

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

El registro contradice el acta: el acta declara alimentación exclusiva a T, pero la telemetría registra corriente simultánea en A y T. Consultar no es extracción y no cambia el guardado.

## Continuidad de Fase 2 — aparcamiento y huida

La compuerta exterior de G debe desembocar en una zona exterior de servicio/aparcamiento, no en un espacio abstracto ni en una transición visual sin contexto. El aparcamiento es el primer espacio jugable de Containment: plazas, pilares, coches inmóviles, carriles, una ruta principal de huida y al menos una alternativa visible, sin convertirlo en un laberinto. La amenaza detecta mediante sus reglas normales de visión, línea de visión y ruido; no conoce la posición del jugador por guion.

La escena de persecución conserva su versión standalone desde el inicio del corredor. Para el handoff canónico se usa `scenes/prototypes/phase2_parking_chase.tscn`, que reutiliza el mismo script y arranca en el checkpoint de entrada al aparcamiento (X=34,5). El enemigo debe comenzar fuera del alcance de detección inmediata y detectar por sus reglas normales. La integración G→H debe comprobarse en una ejecución combinada; no se considera implementada solo por cambiar de escena. Fase 2 puede iniciar con Elena cruzando hacia el aparcamiento, recibir la señal de sincronización y correr para alcanzar una salida segura. No añadir combate obligatorio ni bloqueo de progreso por no consultar el archivo.

## Orden de trabajo

1. Ejecutar la escena canónica ampliada y revisar parse/runtime.
2. Validar P0/P−1, S1 y el hueco continuo D1/D2.
3. Probar elevador a M y S2 a P2.
4. Validar E/F/G, circuito y recorrido completo.
5. Diseñar/ajustar el arranque de persecución en el aparcamiento usando la escena existente, sin crear otro documento de progresión.
6. Ejecutar pruebas de circuito, elevador, integración y Fase 0; hacer playtest manual.

Cerrar Fase 1 solo con pruebas automáticas, ruta manual, visibilidad, colisiones, pérdida de potencia y comprensión de jugador nuevo.
