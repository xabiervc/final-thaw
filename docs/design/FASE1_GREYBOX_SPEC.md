# Fase 1 — Especificación de greybox arquitectónico (v1.3)

**Estado:** nueva distribución de diseño cerrada; todavía no construida en escena. La escena actual representa una geometría previa y debe reconstruirse.

## P−1 · Foso, Y=−2

| Área | Footprint | Requisitos |
|---|---|---|
| D1 · Achique | X 10..20, Z 1..8 | Bombas, sumidero, colector y luz mínima. |
| D2 · Distribución | X 20..28, Z 1..8 | Esquema, puente A→T y mantenimiento. |
| Boca S1 | X 24..26, Z 8..11 | Escalera P0↔P−1, salida continua. |

Referencias: esquema (27,−2,6), puente A→T (22,−2,4), switch (26,−2,2).

## P0 · Acceso, nave, taller — Y=0

| Área | Footprint | Requisitos |
|---|---|---|
| A · Esclusa | X 1..7, Z 4..10 | Entrada desde túnel, señal y vista a B. |
| B · Nave | X 7..20, Z −3..8 | Columna Aster, rig bajo, bandejas y circulación. |
| C · Taller | X 20..24, Z −9..−2 | Cuadros y banco; utilería perimetral. |
| Galería servicio | X 20..30, Z −2..1 | Paso al elevador, ancho libre mínimo 2 m. |
| Hueco D2 | X 20..28, Z 1..8 | Hueco real y protegido. |
| Elevador inferior | X 24,5..27,5, Z −4,5..−1,5 | Parada Y=0. |
| Tramo dañado | X 2..4, Z −3..3 | Barrera/collider; no paso a P2. |

## M · Mezzanine, Y=+1,5

Galería observación X 9..13, Z −9..−1,5; sala de bombas X 13..24, Z −9..−1,5; rellano de elevador X 24..28, Z −4,5..−1,5; S2 a P2 X 9..13, Z −4,5..−1,5. Barandilla deja ver B. Las bombas y manómetros aportan función, escala y respuesta al mantenimiento.

## P2 · Control, archivo, esclusa — Y=+3

G X 0..3, Z −9..−4,5; F X 3..9, Z −9..−4,5; E X 9..24, Z −9..−4,5; pasarela X 9..26, Z −4,5..−2. G no tiene escalera a P0. Mantener libres los anchos de paso y probar legibilidad con cámara real.

## Regla vertical y elevador

- S1: P0↔P−1, siempre transitable.
- Elevador: P0↔M; no llega a P2.
- S2: M↔P2, sin depender de energía.
- Tramo directo P0↔P2: bloqueado.
- G↔H horizontal; sin escalera secundaria.
- Instancia de misión upper_y=1.5 y lower_y=0 antes de entrar al árbol; componente genérico/tests se quedan en 3 m.
- Compuerta fija superior alineada con M (Y centro aprox. 2.05 m). Pérdida de potencia lleva a la parada segura más cercana; el punto medio elige M.

Mantenimiento activa iluminación/elevador, no la protección de recuperación. Escáner revela continuidad A→T; no señala controles. F indica SUMINISTRO ESTABLE / NO DISPONIBLE. Conocimiento de la sesión no se borra con cambios de circuito.

## Construcción

1. Reconstruir P0, galerías, hueco D y S1.
2. Reconfigurar elevador a +1,5 m y compuertas; añadir prueba de misión.
3. Construir M y S2.
4. Construir E/F/G y pasarela; retirar escalera de G.
5. Alinear columna y sightlines.
6. Reintegrar interacciones sin cambiar contrato.
7. Actualizar tests de navegación/integración y ejecutar regresión Fase 0.

No añadir rampas o segunda plataforma. Sin arte final antes de validar greybox.
