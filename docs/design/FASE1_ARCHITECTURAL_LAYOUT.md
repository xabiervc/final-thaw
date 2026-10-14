# FINAL THAW — Arquitectura espacial de Fase 1 (v1.1)

**Estado:** distribución arquitectónica de referencia cerrada; primera reconstrucción geométrica en código ampliada, pero pendiente de ejecutar y validar en Godot. Los SVG son planos de diseño, no evidencia de colisiones o recorrido validado.

## Decisión

Ala industrial de ensayo y control de inundaciones de Helix, evacuada durante el deshielo y parcialmente abandonada. No es una ruina genérica: estructura, señalización y equipos deben revelar una instalación operativa que se cerró con prisa. La columna de calibración Aster conecta visualmente nave, mezzanine y pasarela superior.

El edificio debe leerse como una sola instalación con perímetro, vestíbulos, salas técnicas, pasillos y circulación vertical. La primera versión de código era demasiado abierta y no representaba de forma suficiente la huella D1 del foso; la reconstrucción actual amplía el foso continuo D1/D2 y añade límites de salas, equipamiento industrial, bandejas y estructura de cubierta. Sigue siendo greybox, no arte final.

| Cota | Programa |
|---|---|
| P−1 · Y=−2 m | Foso D1 de achique y D2 de distribución; esquema, puente A→T e interruptor. |
| P0 · Y=0 m | Acceso A, nave de ensayo B, taller C, galería de servicio y hueco protegido del foso. |
| M · Y=+1,5 m | Sala de bombas y galería de observación; mezzanine parcial con barandilla. |
| P2 · Y=+3 m | Control E, archivo F, pasarela superior y esclusa G. |
| H | Exterior inmediato; transición a aparcamiento/Containment de Fase 2. |

## Circulación vertical definitiva

1. **S1 · P0↔P−1:** escalera fija al foso, siempre utilizable.
2. **Elevador · P0↔M:** elevador de mantenimiento que termina en la sala de bombas a +1,5 m.
3. **S2 · M↔P2:** escalera fija del mezzanine a control.
4. **Escalera directa P0↔P2:** colapsada y bloqueada, visible pero no transitable.
5. **G↔H:** esclusa horizontal al exterior; no tiene escalera de retorno a P0.

No añadir rampas, elevadores adicionales ni conexiones secretas. Las rutas verticales deben tener destino legible y responder a la arquitectura, no a una secuencia arbitraria.

## Programa de estancias

| Zona | Cota | Contenido y función |
|---|---:|---|
| A · Esclusa de acceso | 0 m | Señal de evacuación, armario y primera vista a B. |
| B · Nave de ensayo | 0 m | Rig bajo, columna Aster, bandejas y barreras; rodear maquinaria. |
| C · Taller técnico | 0 m | Cuadros, banco, repuestos y colectores; sin llave nueva. |
| D1 · Galería de achique | −2 m | Bombas, sumidero, colector y marcas de marea. |
| D2 · Foso de distribución | −2 m | Esquema previsto, puente físico manipulado A→T e interruptor. |
| M · Sala de bombas | +1,5 m | Bombas, manómetros, colectores, banco y zumbido mecánico. |
| Galería de observación | +1,5 m | Barandilla y vista parcial de B/columna. |
| E · Control | +3 m | Selector, aislador, diagnóstico, panel y rearme. |
| F · Archivo | +3 m | Consola de consulta, terminal independiente e indicador local. |
| G · Esclusa exterior | +3 m | Puerta desde F, compuerta exterior y señal de sincronización. |
| H · Exterior | transición | Salida legible hacia aparcamiento; inicio de persecución en Fase 2. |

**Coordinación de huellas:** B ocupa X=7..20, Z=−9..1. El pasillo A→B ocupa X=7..10, Z=1..8 y bordea el hueco abierto D1/D2 (X=10..28, Z=1..8). D1 y D2 tienen suelo continuo en Y=−2; la nave termina en Z=1, de modo que el vacío no se superpone al suelo de B.

No añadir coleccionables, llaves, puzzles nuevos ni salas de relleno. Taller, galería y sala de bombas tienen función industrial/orientativa, no nuevas barreras de progreso.

## Recorrido narrativo

A → B → S1 ↓ D → S1 ↑ B → galería de servicio → elevador ↑ M → bombas/galería → S2 ↑ E → F → G → H → aparcamiento/Containment.

Mantenimiento empieza apagado. Al activarlo se encienden luces y se habilita el elevador; el circuito de recuperación permanece independiente. El escáner revela continuidad A→T, pero no señala controles. F solo permite consulta con suministro estable; consultar no es extracción. Cruzar G transmite SERVICE_OVERRIDE y, si procede, RESTRICTED_RECORD_READ; Helix inicia Containment.

## Planos existentes

- P−1: [foso de mantenimiento](assets/phase1_architecture/plan_p_minus2.svg)
- P0: [acceso, nave y taller](assets/phase1_architecture/plan_p0.svg)
- M: [bombas y observación](assets/phase1_architecture/plan_m_plus1_5.svg)
- P2: [control, archivo y esclusa](assets/phase1_architecture/plan_p_plus3.svg)
- [Sección vertical de cuatro cotas](assets/phase1_architecture/section_vertical.svg)

Los SVG mantienen la autoridad de distribución y deben compararse con la escena en la revisión visual. Medidas finales, cámara, colisiones y experiencia requieren validación en Godot. Contrato lógico, guardado JSON/CRC32, autoloads, inputs y renderer no cambian.
