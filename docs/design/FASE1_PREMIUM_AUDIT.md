# FINAL THAW — Fase 1: auditoría premium y registro as-built (v3.0)

**Fecha:** 2026-10-15 · **Rama:** `feat/godot-vertical-slice` · **Motor:** Godot 4.7.2-stable (win64), renderer GL Compatibility (ANGLE, Intel HD 630).
**Estado:** implementado y verificado por tests automáticos y un bot de recorrido que usa las acciones de input reales. **Sin playtest humano.** Rendimiento por debajo del objetivo de 60 FPS (ver §6). Este documento es la fuente de verdad del *as-built* v3.0. Donde contradice a v2.1, gana este documento y la escena; las specs v2.1 llevan una nota que remite aquí.

## 1. Contradicciones encontradas y decisión tomada

| # | Contradicción | Decisión v3.0 | Motivo |
|---|---|---|---|
| C1 | Datums P−1 −2 / P0 0 / M +1,5 / P2 +3 en todas las specs v2.1, con forjados de 0,25 m | **P−1 −2 · P0 0 · M +3 · P2 +6** | Con +1,5 m entre plantas quedaban 1,25 m de altura libre: imposible para una persona de 1,7 m. No había forma de cumplir el greybox v2.1 sin cambiar datums. |
| C2 | S2 en X 9..13 subiendo hacia el norte; el pie quedaba con un labio de 22 cm accesible solo de lado | S2 es una cuña sólida (9,3,−3)→(13,5,6,−3) que sube hacia el este, con rellano en M en X 7,5..9 y barandilla inclinada | Entrada frontal, sin labios, sin caídas laterales. |
| C3 | S1: la barandilla inclinada invadía el rellano superior (1 m), haciéndolo inalcanzable | S1 es una cuña sólida; guardas en P0; muro sur a Z=13,65 (rellano de 2,5 m) | La ruta P0→P−1 es transitable. |
| C4 | El puente A→T y la galería de evacuación compartían Z 4,5..7,5; los muros de la galería (tope 0,48) cortaban el tablero | Tablero del puente de retorno a Y=0,35 sobre la galería; muros de la galería con tope a 0,23 | Cruce a distinto nivel; la galería queda libre debajo. |
| C5 | La tabla del esquema estaba en la boca de la galería | SCHEMATIC_AT = (27,3, −2, 2,9), en el muro este del foso, al norte de la boca | Nada bloquea Z 4,5..7,5. |
| C6 | MISSION1_GHOST_PROTOCOL sitúa selector/aislador en D1/D2; FUNCTIONAL_SPEC y LOGIC_CONTRACT los sitúan en E (control) | **En E (P2)**: SELECTOR (12,6,−7,6), AISLADOR (19,6,−7,6), REARME (17,2,6,−7,6), panel (15,5,7,55,−8,15) | La spec funcional es más reciente y el contrato lógico no cambia. MISSION1 es narrativa de la misión. |
| C7 | El panel de E en el contrato funcional está a cota +3 | El panel queda +3 m más alto (P2 = +6) | Consecuencia directa de C1; el **contrato eléctrico no cambia**. |
| C8 | El ascensor de misión estaba especificado a 1,5 m | Paradas P0 (0) y M (+3); el componente genérico ya usaba 3 m | Consecuencia de C1. |
| C9 | DESIGN_PIVOT_PROTOTYPE_BRIEF describe un handoff directo G→H | Handoff físico: boca este de P−1 (X=34) → aparcamiento, sin teletransporte. El estado (momentum, orientación, unidad oculta que llega por la izquierda) se pasa con `phase1_handoff.gd`, consumido una sola vez | Respeta el brief del usuario: "sin cortes ni pérdida de estado". |
| C10 | La spec v2.1 no explica cómo garantiza la persecución a la carrera si la jugadora huye antes de que la unidad la vea | Decisiones nuevas: **telemetría de contención** (el uso del ascensor y la liberación de R1 informan de la *ubicación*, nunca de la posición de Elena) + **persiana R1** con manivela (0,17 m/s; la unidad la fuerza a 0,9 m/s) + **barrido urgente** | Un jugador rápido sigue teniendo una persecución legible, con la reacquisición en el puente, sin trampas de información. |
| C11 | O3 en (22,5, 0, −1,5) | O3 cae en (27,7, 0, 0,1) | La posición antigua bloqueaba la salida del ascensor en P0. |
| C12 | Las cabeceras "no canónico" de varias specs citan versiones antiguas | Las specs v2.1 llevan nota v3.0 que remite aquí | Una sola fuente as-built. |

## 2. Geometría as-built (metros; X este, Z sur, Y vertical)

- **Plantas:** P−1 Y −2 · P0 Y 0 · M Y +3 · P2 Y +6. Cubierta del bloque norte 9,2; bloque sur 4,5.
- **Foso P−1:** X 10..28, Z 1..8. **Pozo S1:** X 24..26, Z 8..11. **Hueco del ascensor:** X 24,5..27,5, Z −4,5..−1,5.
- **Galería de evacuación:** X 28..34, Z 4,5..7,5, Y −2; **boca este** en X=34. **Explanada** X 34..44, Z 0,5..11,5.
- **Puente de retorno:** corte X 28..30, Z 3..9, tablero Y 0,35.
- **R1 (persiana P0):** abierta Y 3,5 / cerrada Y 1,15; manivela en (29,4, 0, 0,3).
- **O1** estantería del archivo (8, 6+1,1, −9,6) cae al iniciar la contención; **O2** rack de tuberías en M (13,2, 3,6, −6,8), 1,2 m, cubierta parcial; **O3** bandeja caída (27,7, 0, 0,1).
- **Barandillas:** capa física 5 (valor 16). Elena colisiona con ellas (máscara 1|16) pero **no puede trepar sobre ellas ni a través de ellas**; los rayos de visión y la cámara usan solo la capa 1, así que se ve a través.
- **Mantenimiento** (26,4, −2, 2,2) habilita el ascensor y pone en cola `SERVICE_OVERRIDE`. Llamadas del ascensor: P0 (28,2, 0, −1,2), M (28,2, 3, −4,9).
- **Archivo** (4,6, 6, −8,8); **G** interior (3, 6, −7,25), exterior (0, 6, −7,5); **diagnóstico** (7,4, 6, −5,4).

## 3. Ruta jugable verificada (bot de recorrido)

Túnel oeste → nave A → foso P−1 (esquema y puente A→T) → mantenimiento (luces, bombas, el ascensor se activa) → ascensor P0→M → S2 → E: aislar ENSAYO, seleccionar ARCHIVO, comprobar, rearmar → archivo (solo con ARCHIVO estable) → abrir G exterior → la unidad entra → G interior → F/E → S2 → M (STAFF-M1, cubierta en O2) → ascensor → P0 (R1) → S1 → P−1 → galería → boca este → aparcamiento (Fase 2 continúa la persecución).

## 4. Movimiento (`scripts/characters/elena_controller.gd`)

- Andar 4,5 m/s; correr (Shift, acción `run`) ≥1,5× con drenaje de aguante 14/s; agacharse (Ctrl o C, acción `crouch`): cápsula 1,7→1,05 m, y no se levanta bajo techo bajo.
- Salto con coyote time y buffer; control aéreo 7.
- **Encaramarse** (salto + dirección): 0,45–1,85 m; comprueba apoyo, que no haya capa 16, hueco para la cápsula y rayos "a través" a 0,3/0,9/1,5 m. Coste de aguante 10. No hay escalada libre.
- Cámara al hombro (desplazamiento 0,45 m); el modelo se oculta si el brazo de cámara mide menos de 1 m; el pivote baja al agacharse.

## 5. Amenazas

- **Unidad de recuperación** (`phase1_recovery_unit.gd`): estados latente/barrido/investigar/alerta/persecución/búsqueda. Visión de 9 m con semiángulo de 55° (×0,55 si Elena va agachada), sentido cercano de 1,6 m, oído según su movimiento; solo percibe en la misma planta. Usa el ascensor de verdad. Captura a 1,15 m. Iconos · ? ! !! y color del ojo; el escáner muestra su cono de visión.
- **STAFF-M1** (`phase1_staff.gd`): ignora a Elena antes de la contención; visión 8 m con semiángulo de 50°; SOSPECHA a 0,8 s, ALERTA a 1,2 s → informa a la unidad y se retira. Nunca ataca. **No hay combate obligatorio.**
- **Capturas:** checkpoints F/M/P0/P−1 restauran el estado y reponen a la unidad en un nodo justo (gantry_far / f_mid / lift_m / lift_p0).
- **Ascensor:** espera mientras alguien va dentro (`hold_departure`), así no devuelve a Elena hacia la unidad.

## 6. Rendimiento (honesto)

Medido con `tools/capture/scene_capture.tscn --bench` a 720p en la HD 630, en el peor encuadre de cada zona:

| Vista | Antes | Ahora |
|---|---|---|
| Nave | 20–22 ms | 23 ms |
| Foso | ~27 ms | ~24 ms |
| Bombas (M) | 29,7 ms | 30,4 ms |
| Control (E) | 30–33 ms | 22–26 ms |
| Persecución en R1 | 17,6 ms | 14,7–16,5 ms |
| Draw calls (peor vista) | 620 | 330 |

La sala de pruebas de referencia cuesta 9,7 ms. **El objetivo de 60 FPS (16,7 ms) no se cumple** en nave, foso, bombas ni control con este hardware. El coste aparece cuando coinciden materiales variados y luces; la causa sospechada es el cambio de programa de shader bajo ANGLE. El escalado de resolución empeoró el resultado; la separación del discard y las capas de luz por planta no tuvieron efecto medible, pero se mantienen. Siguiente paso: perfilar en el PC nuevo antes de decidir (sin cambiar de renderer sin aprobación del propietario).

## 7. Evidencia de tests

Ver §7 de `PROJECT_STATUS.md` (comando, exit codes y recuento por suite del commit registrado).
