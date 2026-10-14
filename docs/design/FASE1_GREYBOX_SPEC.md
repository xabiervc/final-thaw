# Fase 1 — Especificación de greybox arquitectónico (v1.4)

**Estado:** distribución de diseño cerrada; reconstrucción geométrica ampliada en el builder canónico, pendiente de ejecución y validación. No equivale a greybox aceptado en Godot.

## P−1 · Foso, Y=−2

| Área | Footprint | Requisitos |
|---|---|---|
| D1 · Achique | X 10..20, Z 1..8 | Galería cubierta bajo B; suelo continuo, bombas, sumidero, colector y luz mínima. La altura libre es una condición crítica: no aceptar si el paso obliga a agacharse. |
| D2 · Distribución | X 20..28, Z 1..8 | Suelo continuo, esquema, puente A→T y mantenimiento. |
| Boca S1 | X 24..26, Z 8..11 | Escalera P0↔P−1, salida continua y barandillas sin bloquearla. |

Referencias: esquema (27,−2,6), puente (22,−2,4), switch (26,−2,2). D1 y D2 comparten un foso conectado; su lectura se diferencia por maquinaria, señalización e iluminación, no por una pared que corte el recorrido.

## P0 · Acceso, nave, taller — Y=0

| Área | Footprint | Requisitos |
|---|---|---|
| A · Esclusa | X 1..7, Z 4..10 | Entrada desde túnel, señal y vista a B. |
| B · Nave | X 7..20, Z −9..1 | Columna Aster, rig bajo, bandejas, barreras y circulación alrededor de maquinaria. |
| C · Taller | X 20..24, Z −9..−2 | Cuadros y banco; utilería perimetral; paso de servicio a B. |
| Galería servicio | X 20..30, Z −2..1 | Paso al elevador, ancho libre mínimo 2 m. |
| Hueco D2 | X 20..28, Z 1..8 | Hueco real, protegido y con acceso únicamente por S1; D1 queda cubierto por la losa P0. |
| Elevador inferior | X 24,5..27,5, Z −4,5..−1,5 | Parada Y=0. |
| Tramo dañado | X 2..4, Z −3..3 | Barrera/collider; no paso a P2. |

La planta debe leerse como vestíbulo, nave principal y taller, no como una sala diáfana sin función. El pasillo A→B discurre por X=7..10, Z=1..8 y bordea la barandilla oeste del hueco D2. D1 queda bajo una zona cubierta de B y debe conservar una altura libre suficiente para recorrerlo sin agacharse; verificarlo con la cámara y la cápsula reales.

## M · Mezzanine, Y=+1,5

Galería de observación X 9..13, Z −9..−1,5; sala de bombas X 13..24, Z −9..−1,5; rellano de elevador X 24..28, Z −4,5..−1,5; S2 a P2 X 9..13, Z −4,5..−1,5. Barandilla deja ver B. Bombas, colectores, manómetros y tuberías aportan función, escala y respuesta al mantenimiento.

## P2 · Control, archivo, esclusa — Y=+3

G X 0..3, Z −9..−4,5; F X 3..9, Z −9..−4,5; E X 9..24, Z −9..−4,5; pasarela X 9..26, Z −4,5..−2. G no tiene escalera a P0. Mantener libre la ruta E→F→G y los anchos de paso; el panel debe poder leerse desde el área de operación.

## Cubierta y lectura del edificio

La primera pasada de greybox incorpora estructura de cubierta y bandejas técnicas para dar escala al volumen. Mantener líneas de visión entre A/B, la columna Aster y la galería, sin convertir vigas o tuberías en barreras de cámara. No añadir materiales finales, postprocesado ni arte decorativo hasta validar recorrido y colisiones.

## Regla vertical y elevador

- S1: P0↔P−1, siempre transitable.
- Elevador: P0↔M; no llega a P2.
- S2: M↔P2, sin depender de energía.
- Tramo directo P0↔P2: bloqueado.
- G↔H horizontal; sin escalera secundaria.
- Instancia de misión upper_y=1.5 y lower_y=0 antes de entrar al árbol; componente genérico/tests se quedan en 3 m.
- Compuerta fija superior alineada con M. Pérdida de potencia lleva a la parada segura más cercana; el punto medio elige M.

Mantenimiento activa iluminación/elevador, no la protección de recuperación. Escáner revela continuidad A→T; no señala controles. F indica SUMINISTRO ESTABLE / NO DISPONIBLE. Conocimiento de la sesión no se borra con cambios de circuito.

## Construcción y aceptación

1. Ejecutar escena y corregir parse/runtime antes de ampliar.
2. Confirmar perímetro, salas, cubierta, foso D1/D2 y huecos.
3. Verificar S1, elevador P0↔M y S2 M↔P2.
4. Verificar rutas, puertas, colisiones, alturas libres y cámaras.
5. Reintegrar interacciones sin cambiar contrato.
6. Ejecutar tests de navegación/integración y regresión Fase 0.
7. Validar salida G→H; el aparcamiento pertenece a la continuidad de Fase 2, no a una nueva sala interior de Fase 1.

No añadir rampas o segunda plataforma. Sin arte final antes de validar greybox.
