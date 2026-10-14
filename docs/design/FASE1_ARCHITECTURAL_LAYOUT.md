# FINAL THAW — Arquitectura espacial de Fase 1 (v1.1)

**Estado:** topología espacial aprobada conceptualmente; reconstrucción geométrica ampliada en código, pendiente de ejecutar y validar en Godot. Los SVG son planos de diseño, no evidencia de colisiones o recorrido validado. Las causas concretas de la respuesta de Helix, la percepción de Elena y el destino posterior siguen siendo decisiones narrativas propuestas, no requisitos aprobados.

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
| Túnel de entrada | 0 m | Aproximación exterior de 3 m, cubierta, suelo y apertura a A. |
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

**Entrada:** el slice comienza en el túnel exterior (X=−3..0, Z=4,5..7,5) y continúa por A. La apertura del muro oeste se alinea con el túnel; el techo mantiene 2,2 m de altura libre.

**Coordinación de huellas:** B ocupa X=7..20, Z=−9..1. El pasillo A→B ocupa X=7..10, Z=1..8 y bordea el hueco abierto D1/D2 (X=10..28, Z=1..8). D1 y D2 tienen suelo continuo en Y=−2; la nave termina en Z=1, de modo que el vacío no se superpone al suelo de B.

No añadir coleccionables, llaves, puzzles nuevos ni salas de relleno. Taller, galería y sala de bombas tienen función industrial/orientativa, no nuevas barreras de progreso.

## Recorrido espacial y beats narrativos

**Recorrido físico de referencia:** exterior → túnel → A → B → S1 ↓ D1/D2 → S1 ↑ → perímetro sur del foso → retorno este → galería de servicio → elevador ↑ M → bombas/galería → S2 ↑ E → F → G → H → aparcamiento.

El regreso desde D1/D2 no debe interpretarse como volver a cruzar B: desde el rellano superior de S1 se rodea el foso por el perímetro sur y el pasillo este hasta la galería de servicio. Esta arista debe existir en la geometría y las colisiones, no solo en el plano.

**Beats funcionales acordados:** mantenimiento empieza apagado; activarlo en D enciende luces y habilita el elevador, sin alimentar la protección de recuperación. El escáner revela continuidad A→T, no los controles. F solo permite consulta con suministro estable; consultar no es extracción.

**Pendiente de aprobación narrativa:** el evento exacto que Helix recibe al salir, si la lectura de F se audita, cómo percibe Elena la respuesta, el momento y la forma de activar Containment y el destino posterior. `SERVICE_OVERRIDE`, `RESTRICTED_RECORD_READ`, una señal de sincronización y la patrulla en H son propuestas existentes en documentos/prototipos; no deben presentarse como canon ni ampliarse hasta aprobar el beat narrativo. La transición física G→H sí pertenece a la arquitectura espacial.

## Planos existentes

- P−1: [foso de mantenimiento](assets/phase1_architecture/plan_p_minus2.svg)
- P0: [acceso, nave y taller](assets/phase1_architecture/plan_p0.svg)
- M: [bombas y observación](assets/phase1_architecture/plan_m_plus1_5.svg)
- P2: [control, archivo y esclusa](assets/phase1_architecture/plan_p_plus3.svg)
- [Sección vertical de cuatro cotas](assets/phase1_architecture/section_vertical.svg)

Los SVG mantienen la autoridad de distribución y deben compararse con la escena en la revisión visual. Medidas finales, cámara, colisiones y experiencia requieren validación en Godot. Contrato lógico, guardado JSON/CRC32, autoloads, inputs y renderer no cambian.
