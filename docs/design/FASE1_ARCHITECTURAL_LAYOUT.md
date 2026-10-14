# FINAL THAW — Arquitectura espacial de Fase 1 (v1.0)

**Estado:** decisión arquitectónica cerrada para el nuevo greybox. Planos esquemáticos y cotas de diseño; no equivalen a geometría construida ni validada en Godot.

## Decisión

Recuperamos la idea narrativa histórica: **descender para descubrir la causa y subir para comprender el sistema**. Es un ala industrial de ensayo y control de inundaciones de Helix, evacuada durante el deshielo. La columna vertical de calibración Aster liga visualmente la nave, el mezzanine y la pasarela superior.

| Cota | Programa |
|---|---|
| P−1 · Y=−2 m | Foso D: esquema, puente A→T, interruptor de mantenimiento. |
| P0 · Y=0 m | Acceso A, nave B y taller C. |
| M · Y=+1,5 m | Sala de bombas y galería de observación. Mezzanine parcial. |
| P2 · Y=+3 m | Control E, archivo F y esclusa G. |
| H | Exterior e inicio de Containment. |

## Circulación vertical definitiva

1. **S1 · P0↔P−1:** escalera fija al foso, siempre utilizable.
2. **Elevador · P0↔M:** elevador de mantenimiento que termina en la sala de bombas a +1,5 m.
3. **S2 · M↔P2:** escalera fija del mezzanine a control.
4. **Escalera directa P0↔P2:** colapsada y bloqueada, visible pero no transitable.
5. **G↔H:** esclusa horizontal al exterior; no tiene escalera de retorno a P0.

Cada conexión vertical cumple un propósito distinto: no hay dos escaleras operativas al mismo destino ni un elevador que replique la subida a control.

## Programa de estancias

| Zona | Cota | Contenido y función |
|---|---:|---|
| A · Esclusa de acceso | 0 m | Señal de evacuación, armario, primera vista a la nave. |
| B · Nave de ensayo | 0 m | Rig bajo, columna Aster, bandejas y barreras; rodear la maquinaria. |
| C · Taller técnico | 0 m | Cuadros, banco, repuestos y colectores; sin llave nueva. |
| D1 · Galería de achique | −2 m | Bombas, sumidero, colector y marcas de marea. |
| D2 · Foso de distribución | −2 m | Esquema previsto, puente físico manipulado A→T e interruptor. |
| M · Sala de bombas | +1,5 m | Bombas, manómetros, colectores, banco y zumbido mecánico. |
| Galería de observación | +1,5 m | Barandilla y vista parcial de B/columna. |
| E · Control | +3 m | Selector, aislador, diagnóstico, panel y rearme. |
| F · Archivo | +3 m | Consulta, terminal independiente e indicador local. |
| G · Esclusa exterior | +3 m | Puerta desde F, compuerta exterior y señal de sincronización. |
| H · Exterior | exterior | Inicio de huida bajo reglas normales de percepción. |

No añadimos coleccionables, llaves, puzzles nuevos ni salas de relleno. Taller, galería y sala de bombas tienen función industrial/orientativa, no nuevas barreras de progreso.

## Recorrido narrativo

A → B → S1 ↓ D → S1 ↑ B → galería de servicio → elevador ↑ M → bombas/galería → S2 ↑ E → F → G → H.

Mantenimiento empieza apagado. Al activarlo se encienden luces y se habilita el elevador; el circuito de recuperación permanece independiente. El escáner revela continuidad A→T, pero no señala los controles. F solo permite consulta con suministro estable; consultar no es extracción. Cruzar G transmite SERVICE_OVERRIDE y, si procede, RESTRICTED_RECORD_READ; Helix inicia Containment.

## Planos

- P−1: [foso de mantenimiento](assets/phase1_architecture/plan_p_minus2.svg)
- P0: [acceso, nave y taller](assets/phase1_architecture/plan_p0.svg)
- M: [bombas y observación](assets/phase1_architecture/plan_m_plus1_5.svg)
- P2: [control, archivo y esclusa](assets/phase1_architecture/plan_p_plus3.svg)
- [Sección vertical de cuatro cotas](assets/phase1_architecture/section_vertical.svg)

La decisión espacial queda cerrada; medidas finales, cámara, colisiones y experiencia requieren reconstrucción y validación en Godot. La escena actual usa geometría previa. Contrato lógico, guardado JSON/CRC32, autoloads, inputs y renderer no cambian.
