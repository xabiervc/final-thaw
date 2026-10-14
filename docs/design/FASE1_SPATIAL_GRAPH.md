# FINAL THAW — Fase 1: grafo espacial (v0.7)

**Estado:** topología arquitectónica decidida; primera reconstrucción geométrica ampliada en código, aún sin validación de runtime. Autoridad: FASE1_ARCHITECTURAL_LAYOUT.md v1.1 y planos SVG; footprints en FASE1_GREYBOX_SPEC.md v1.4; función en FASE1_FUNCTIONAL_SPEC.md v1.1. FASE1_LOGIC_CONTRACT.md no cambia.

| Nodo | Cota | Huella/posición | Función |
|---|---:|---|---|
| Túnel exterior | 0 m | X −3..0, Z 4,5..7,5; umbral X 0..1 | Aproximación cubierta y entrada física a A. |
| A · Acceso | 0 m | X 1..7, Z 4..10 | Esclusa y orientación. |
| B · Nave | 0 m | X 7..20, Z −9..1 | Columna Aster, rig central y circulación. |
| C · Taller | 0 m | X 20..24, Z −9..−2 | Cuadros, banco y colectores. |
| S1 · Escalera | 0↔−2 m | X 24..26, Z 8..11 | Conexión fija al foso. |
| D1 · Achique | −2 m | X 10..20, Z 1..8 (hueco abierto P0) | Bombas, sumidero y colector. |
| D2 · Distribución | −2 m | X 20..28, Z 1..8 | Esquema, puente A→T y mantenimiento. |
| Elevador | 0↔+1,5 m | X 24,5..27,5, Z −4,5..−1,5 | Transporte al mezzanine. |
| M · Bombas | +1,5 m | X 13..24, Z −9..−1,5 | Bombas y ruta a S2. |
| Galería observación | +1,5 m | X 9..13, Z −9..−1,5 | Vista de B y comienzo S2. |
| S2 · Escalera | +1,5↔+3 m | X 9..13, Z −4,5..−1,5 | Subida operativa a P2. |
| E · Control | +3 m | X 9..24, Z −8,5..−4,5 | Selector, aislador, panel/rearme. |
| F · Archivo | +3 m | X 3..9, Z −9..−4,5 | Consulta y terminal. |
| G · Esclusa | +3 m | X 0..3, Z −9..−4,5 | Salida horizontal a H. |
| Pasarela | +3 m | X 9..26, Z −4,5..−1,5 (hueco S2 X 9..13) | Vista de B y llegada S2. |
| H · Exterior | exterior | Oeste de G | Umbral de salida a la zona de aparcamiento/Containment. |

~~~text
A ── B ── galería de servicio ── elevador inferior
    │                                      │
    └─ S1 ↓ D1/D2                          │ P0 ↔ M (+1,5 m)
        esquema → puente →                 │
        mantenimiento ON                    └─ bombas → galería → S2 ↑
                                                       E (+3 m) ─ F ─ G ─ H → aparcamiento
~~~

Aristas aceptadas: exterior↔túnel↔A↔pasillo oeste↔B; B↔D por S1; D↔S1↔perímetro sur↔retorno este↔galería de servicio↔elevador; B↔galería de servicio; P0↔M solo por elevador, después de mantenimiento; M↔P2 por S2; E↔F; F↔G; G↔H.

D1 y D2 comparten un hueco vertical abierto en P0 (X=10..28, Z=1..8), con suelo continuo a Y=−2. B termina en Z=1, de modo que no se superponen suelo jugable y vacío. El pasillo A→B ocupa X=7..10, Z=1..8 y bordea la barandilla oeste del hueco.

No son aristas: escalera colapsada P0↔P2; escalera desde G a P0; rampa paralela; segunda plataforma; parada de elevador en P2; puertas secretas.

Los controles conservan posiciones lógicas de referencia: selector (12,3,-7), aislador (19,3,-7), panel (15.5,4.55,-8.15), rearme (15.5,3.5,-8.15), consola (5,3,-7), indicador F (8.55,3.8,-7). Ajustar montajes, no reglas.

La aceptación requiere que B quede al norte del foso, el pasillo A→B bordee el hueco sin cruzarlo, que los bordes abiertos de M/P2 y ambos lados del hueco del elevador estén protegidos, y que M se lea como sala de bombas, el elevador termine en M, S2 llegue a P2, G conduzca al exterior, la escalera dañada no se atraviese, la huella D1 exista realmente en P−1 y la orientación entre cotas sea legible. Planos no validan cámara ni colisiones.
