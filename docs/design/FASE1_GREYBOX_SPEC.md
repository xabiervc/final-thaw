# FINAL THAW — Fase 1: especificación de greybox (v2.1)

> **Nota v4.0 (2026-10-15, as-built):** STAFF-M1 se ha eliminado. El aparcamiento es ahora un patio de servicio construido en la misma escena tras la boca este (x 34..76, z −15,5..14, Y −2). Ver [FASE1_PREMIUM_AUDIT.md](FASE1_PREMIUM_AUDIT.md) (v4.0).

> **Nota v3.0 (2026-10-15, as-built):** Datums pasan a P−1 −2 · P0 0 · M +3 · P2 +6 (con +1,5 m quedaban 1,25 m libres). S2 sube hacia el este con rellano en M (X 7,5..9). El puente de retorno cruza sobre la galería a Y 0,35. Se añaden la persiana R1 con manivela y las barandillas en la capa física 5. O3 pasa a (27,7, 0, 0,1). Fuente de verdad del as-built y de las contradicciones resueltas: [FASE1_PREMIUM_AUDIT.md](FASE1_PREMIUM_AUDIT.md).

**Estado:** objetivo espacial ampliado. Las huellas base de las plantas existentes se conservan donde son compatibles; la galería de evacuación y la huida interior son nuevas y deben incorporarse a SVG, constructor y tests antes de considerarse construidas. Medidas sujetas a prueba de volumen de jugador/cámara; no reducir anchos para encajar el guion.

## Rediseño arquitectónico acordado — objetivo de greybox (2026-10-16)

Esta sección define el nuevo objetivo espacial y **no describe el edificio construido**. El as-built permanece en [FASE1_PREMIUM_AUDIT.md](FASE1_PREMIUM_AUDIT.md). No reutilizar las cotas antiguas como si ya fueran compatibles con la nueva distribución.

| Parámetro | Objetivo de diseño | Estado / regla |
|---|---|---|
| Huella bruta del complejo principal | 48 × 34 m = 1.632 m² | Objetivo conceptual; no es superficie útil ni huella ya construida |
| P−2 | Suelo −4,00 m; altura libre objetivo 3,2–3,5 m | Nueva planta de mantenimiento, subestación, almacén, taller muerto y puerta de transferencia |
| P0 | Suelo ±0,00 m; nave central 6–8 m de altura libre | Mantener el hito Aster y las dos entradas diferenciadas |
| M | Suelo +1,50 m; mezzanine parcial | Solo alas laterales; no cruzar el vacío de la nave |
| P+3 | Suelo +3,00 m; ala superior parcial | Control/archivo en bandas laterales; no cerrar la nave con un forjado |
| Salas ordinarias P0 | 3,5–4,5 m de altura libre objetivo | Ajustar a estructura, cámara y colisión |
| Salas superiores | 3,0–3,5 m de altura libre objetivo | Ajustar a estructura y altura real de los niveles |
| Circulación principal | 2,0 m libres como objetivo; mínimo puntual 1,8 m solo con justificación | Medir entre colisiones, no entre bounds visuales |
| Acceso de Elena | Brecha/alcantarilla colapsable | Bloqueo real mediante geometría y colisión |
| Acceso antiguo al pasillo | Entrada arquitectónica independiente | No confundir con el spawn de Elena |
| Puerta clandestina | Muro oriental del taller muerto en P−2 | Oculta al principio; conduce al vestíbulo técnico del segundo edificio |
| Acceso vertical a P−2 | Escalera transitable independiente del ascensor | El jugador puede explorar el sótano con el ascensor sin energía |
| Progresión de transferencia | TRANSFER_KEY + PowerRestored + investigación Aster completada | La llave de transferencia no sustituye SERVICE_KEY ni INSULATED_BRIDGE |

### Coordenadas y continuidad con el patio

El constructor existente usa un sistema de coordenadas y una salida de servicio hacia el patio en torno a X=34. La nueva huella no debe desplazarse a ese umbral de forma accidental. Antes de cambiar el constructor, fijar una única transformación mundo/plano que preserve una conexión física continua entre edificio, puerta de transferencia, segundo edificio y ruta posterior hacia el patio. La huella 48 × 34 m es una dimensión bruta de diseño, no una autorización para desplazar el umbral de patio sin actualizar también la ruta, los obstáculos, el grafo de la unidad, las cámaras, los checkpoints y sus tests.

### Contratos espaciales no negociables

- La sección debe mostrar la nave central abierta a través de M y P+3. Las cotas de suelo (−4,00 / ±0,00 / +1,50 / +3,00) no son alturas libres.
- La puerta de transferencia se descubre mediante una franja de suelo limpia, marcas recientes de arrastre y corriente de aire en la junta; al inspeccionarla se revela un panel, no se abre automáticamente.
- La nota de mantenimiento del taller muerto dirige al armario seco elevado del almacén de repuestos; el símbolo del armario coincide con el de la puerta.
- La llave de transferencia es distinta de la llave de servicio y del puente eléctrico.
- La investigación Aster y el cuaderno de campo existentes se conservan; la nueva cadena de mantenimiento/transferencia se añade sin cambiar el contrato lógico Aster.
- Los planos conceptuales no prueban colisiones, alturas, navegación, rendimiento ni jugabilidad. Esos criterios requieren constructor, pruebas automáticas y playtest.

## Convenciones heredadas v2.1 — referencia del as-built, no del rediseño

- Unidades Godot: metros; X este, Z sur, Y vertical; norte arriba en planos.
- P0 = Y 0; P−1 = Y −2; M = Y +1,5; P2 = Y +3. Estas convenciones pertenecen a la especificación heredada; para el objetivo ampliado se aplican exclusivamente las cotas definidas en el bloque de rediseño anterior.
- Altura libre mínima de rutas principales: 2,2 m; objetivo en zonas de persecución: 2,5 m cuando la estructura lo permita.
- Ancho libre mínimo de circulación normal: 1,8 m; ruta de huida: objetivo ≥2,0 m sin mobiliario ni barandillas invadiendo el paso. Puertas y giros se validan con cápsula y cámara reales.
- Las plantas son planos de diseño, no prueba de colisión. Los footprints del constructor deben ser trazables a estas medidas.

## Programa por planta

### P−1 · D1/D2 y salida de servicio — Y=−2

| Área | Huella de referencia | Requisitos |
|---|---|---|
| D1 · Galería de achique | X=10..20, Z=1..8 | Bombas, sumidero, colector, marcas de nivel y acceso de S1. |
| D2 · Distribución | X=20..28, Z=1..8 | Esquema, puente A→T manipulado, switch de mantenimiento; espacio caminable alrededor de equipo. |
| S1 inferior | X=24..26, Z=8..11 | Boca de escalera abierta en suelo, llegada segura y orientación a D1/D2. |
| Galería de evacuación | X=28..34, Z=4,5..7,5 (propuesta heredada, no bloqueante) | Corredor de servicio con ancho libre ≥2 m, paredes y techo donde proceda. Conservarlo solo si la ruta completa lo justifica; si la salida se traslada, dibujar el corredor nuevo y retirar esta huella de los planos antes de implementar. |
| Boca de servicio alternativa | X=34, Z=4,5..7,5; Y=−2,0 (baseline de diseño) | Apertura libre de 3 m al este, conectada por galería 6×3 m al parking. Distinta del túnel oeste; verificar cota y continuidad en escena. |

La extensión hacia el este es una decisión arquitectónica nueva respecto a v1.1. Los planos y la sección deben incluirla. Si la topografía requiere pendiente, rampa o escalones, dibujarlos y comprobar que son transitables. La galería no debe parecer un túnel secreto añadido al final: integrar canaletas, colectores, compuerta de mantenimiento, señalización de descarga y huellas de uso.

### P0 · Acceso, nave, taller y circulación — Y=0

| Área | Huella | Requisitos |
|---|---|---|
| Túnel de entrada | X=−3..0, Z=4,5..7,5 | Suelo Y=0, paredes laterales, techo y apertura oeste; altura libre 2,2 m. Spawn X=−2,3, Z=6. |
| A · Esclusa | X=1..7, Z=4..10 | Entrada desde túnel, protocolo de acceso y primera vista a B. |
| B · Nave Aster | X=7..20, Z=−9..1 | Rig, columna, bandejas y circulación alrededor; no bloquear sightlines principales. |
| C · Taller | X=20..24, Z=−9..−2 | Banco, armarios y cuadros sin invadir paso. |
| Galería de servicio | X=20..30, Z=−2..1 | Ancho libre ≥2 m hacia elevador y retorno. |
| Retorno este | X=28..30, Z=1..8 | Pasillo de 2 m entre perímetro y hueco; conexión real desde S1 a galería. |
| Hueco D1/D2 | X=10..28, Z=1..8 | Vacío de colisión en P0, con protecciones; no suelo falso sobre el foso. |
| Elevador inferior | X=24,5..27,5, Z=−4,5..−1,5 | Parada Y=0; compuertas alineadas con el hueco. |
| Tramo directo dañado | X=2..4, Z=−3..3 | Visualmente legible y físicamente bloqueado; no ruta de huida. |

### M · Bombas y observación — Y=+1,5

Galería de observación X=9..13, Z=−9..−1,5; sala de bombas X=13..24, Z=−9..−1,5; rellano de elevador X=24..28, Z=−4,5..−1,5; S2 X=9..13, Z=−4,5..−1,5. Proteger el borde oeste, hueco del elevador y bordes expuestos. Mantener vista parcial a B/Aster y paso técnico entre bombas y elevador. El acceso a S2 debe leerse desde la llegada del elevador.

### P2 · Control, archivo, pasarela y puerta G — Y=+3

G X=0..3, Z=−9..−4,5; F X=3..9, Z=−9..−4,5; E X=9..24, Z=−8,5..−4,5; pasarela X=9..26, Z=−4,5..−1,5, con hueco de S2 X=9..13. El panel E conserva su centro contractual (15,5; 4,55; −8,15) y su soporte. G es una esclusa de doble puerta: la compuerta oeste abre al umbral exterior, envía la auditoría e inicia Containment; la puerta interior vuelve a F. El primer tramo es evasión silenciosa; la carrera comienza en R1, la transición de la galería de servicio al retorno este P0 (X≈29, Z≈1), tras una reacquisición real. La unidad sigue a Elena por el mismo elevador; no aparece delante de ella. La puerta exterior no es la salida final ni teletransporta al jugador. La ruta de huida vuelve hacia E/S2; la salida final se decide desde el grafo completo.

## Ruta de huida y obstáculos — posiciones candidatas acotadas

Ruta de referencia: G → F/E → pasarela superior → S2/M y áreas de trabajo potencialmente ocupadas (evasión silenciosa) → umbral expuesto/trigger de reacquisición → tramo a la carrera por circulación de servicio → conexiones existentes hacia P0/P−1 → salida este seleccionada en P−1 (X=34, Z=4,5..7,5, Y=−2) por galería 6×3 m → aparcamiento con transform de diseño X_mundo=X_local+28,7, Z_mundo=Z_local−15,8. Validar en escena, no rediseñar por el checkpoint antiguo.

| ID | Cota/centro aproximado | Volumen de referencia | Lectura y solución | Aceptación geométrica |
|---|---|---|---|---|
| O1 · Estantería caída | P2: (8,0; 3,0; −7,0) | 1,0 × 1,1 × 0,8 m | Estantería de archivo vencida hacia el paso. Rodear por el lateral abierto, con aproximación visible desde F. | Mantener al menos 1,2 m de paso continuo; no tapar la puerta ni ocultar el acceso a E. |
| O2 · Bastidor de tuberías | M: (18,0; 1,5; −3,0) | 2,0 × 0,8 × 1,2 m | Bastidor desplazado durante la evacuación; rodear siguiendo las líneas de servicio. | Dejar un recorrido ≥2,0 m entre maquinaria/barandillas; no invadir el acceso a elevador ni S2. |
| O3 · Bandeja desprendida | P0: (22,5; 0,0; −1,5) | 1,2 × 0,8 × 0,6 m | Bandeja/canaleta caída en la galería de servicio; el paso lateral debe ser obvio y estable. | Dejar ≥1,2 m libres a ambos lados donde el trazado lo permita; no bloquear la llegada al elevador ni S1. |

Estas posiciones son la primera propuesta de layout de persecución y deben dibujarse en planta antes de construir los colliders. Las dimensiones son máximos iniciales, no autorización para reducir pasos. Ajustar los obstáculos si la cápsula/cámara reales no permiten una solución justa; actualizar SVG y pruebas en el mismo cambio.

- Máximo tres obstáculos principales en la primera pasada; anticipación visual, colisión visible y margen de recuperación.
- No usar saltos ciegos ni exigir habilidades no enseñadas. No convertir la persecución en combate obligatorio. La fase silenciosa requiere refugios/cobertura reales, NPC con percepción/estados comprobables y una ruta que no obligue a matar o derribar a nadie.
- Al abrir G, el elevador está disponible porque mantenimiento debe estar activo en la progresión normal; definir y probar qué ocurre si el estado se altera. No bloquear al jugador por una llamada imposible.
- La cámara de tercera persona debe conservar lectura del perseguidor, borde de paso y solución; vigas/tuberías no pueden ocluir simultáneamente al jugador y la salida. Las zonas de sigilo deben permitir leer qué ve el personal y cuándo Elena queda expuesta.

## Arquitectura legible como instalación real

- Espesor y alineación coherentes de muros, jambas, dinteles y losas.
- Las bandejas y tuberías siguen rutas plausibles entre cuadros, bombas y distribución; no flotan ni atraviesan puertas.
- Señalización consistente: nomenclatura A/B/C/D1/D2/M/E/F/G, cotas y direcciones.
- Cada espacio explorable tiene función ambiental, de orientación o de investigación.
- Los cierres son diegéticos y los pasillos de servicio no terminan en paredes arbitrarias.
- La iluminación de emergencia y las zonas abandonadas guían sin depender solo del color.
- No añadir arte final hasta cerrar planta, sección, circulación, cámaras y colisiones.

## Evasión, cobertura y R1 — v2.1

Estos son contratos de diseño para el greybox; no afirman que los colliders o la IA estén implementados.

### STAFF-M1 y C1 en M

- STAFF-M1 es un operario no hostil situado en M, con rutina corta entre el panel de bombas y la consola de mantenimiento. La ruta de patrulla queda dentro de la huella de M y no cruza la ruta crítica hacia el elevador.
- El banco de bombas es cobertura opaca C1: debe interrumpir la línea de visión desde STAFF-M1 hacia la ruta de paso. Si la geometría real no bloquea LOS, no se puede etiquetar como cobertura.
- O2 es un rack de mantenimiento bajo que restringe la trayectoria y puede romper LOS solo si su altura/colisión lo permite. No se debe inferir cobertura por el icono del plano.
- Mantener un paso continuo de al menos 1,2 m alrededor de O2 y 1,5 m en la ruta de bypass junto al equipo; preferir 1,5 m en giros de evasión. Ningún NPC, rack ni pump collider puede bloquear por completo la ruta al elevador.
- STAFF-M1 no usa navegación omnisciente. Si detecta a Elena, emite una llamada y se retira; comunica al recovery unit la última posición conocida, no las coordenadas actuales.

### R1 — trigger de carrera en P0

- R1 está fijado como objetivo de diseño en la transición de galería de servicio P0 a retorno este, aproximadamente `X=29, Z=1`.
- Volumen objetivo de trigger: hasta 2,0 × 2,0 m dentro de la huella de circulación existente `X=28..30, Z=0..2`. No debe añadir pared, escalón ni obstáculo. Ajustar el volumen al footprint real de la puerta/corredor sin reducir la anchura libre.
- La secuencia física es: Elena desciende por el elevador P0↔M; la unidad la sigue por el mismo elevador; ambos entran en la galería; al alcanzar R1, la unidad obtiene LOS real y se inicia la carrera.
- Si la unidad no está presente o no tiene LOS, R1 no genera un spawn ni cambia a carrera. Una reacquisición anterior solo adelanta el trigger si la unidad ve a Elena por geometría real.
- Tras R1, el recorrido usa el retorno este existente, S1, P−1 y la galería de evacuación seleccionada. La boca exterior y el transform están seleccionados como baseline de diseño; su continuidad física debe verificarse en Godot.

## Criterios de aceptación

1. Comparar todos los SVG y la sección con la escena; registrar cualquier desviación.
2. Validar perímetro, huellas, suelo y huecos de P0/P−1.
3. Recorrer S1, elevador y S2 en ambos sentidos sin saltos no diseñados.
4. Verificar retorno sur/este y la galería de servicio.
5. Verificar que G abre hacia el corredor interior y no al exterior directo.
6. Recorrer la sección silenciosa con NPC, percepción, cobertura y ruido verificables.
7. Verificar el trigger de reacquisición propuesto en la salida del elevador a P0 y la transición continua a carrera.
8. Recorrer la persecución, conexiones verticales y salida alternativa seleccionada.
9. Confirmar continuidad visual/física al aparcamiento y handoff al checkpoint derivado de la boca real.
8. Ejecutar regresión Fase 0 y tests existentes; registrar versión, renderer, commit, resultados, errores/warnings y QA manual.

Un plano no se considera excelente por estética aislada: debe ser acotado, consistente entre cotas, legible, verificable y capaz de dirigir la implementación sin contradicciones.

## Owner-approved spatial target and reconciliation gate (2026-10-15)

The measurements and room schedule above document the previous spatial specification. The latest owner-approved direction requires a larger but legible interconnected facility anchored by the central pumping hall. Before treating this greybox specification as the active implementation target, reconcile its room topology, entrance, circulation and escape route with the new direction.

- Use purposeful connected rooms and vertical routes, not an oversized single room or a maze.
- Elena enters through a damaged service breach/culvert; a physical collapse blocks return.
- The route out must lead through a different operational area where human personnel are working on Helix/Aster.
- The escape target is hybrid first-person gameplay that continues through a distinct parking garage and ends at a public street.
- Do not assume existing robot-chase dimensions or the service-yard route automatically satisfy the new target.
- Update plans, sections, graph, dimension schedules and scene geometry together. Confirm all traversals, collision, camera clearance and route continuity in Godot.

These are design requirements, not proof of geometry. Keep the prior measurements as historical references until a reconciled plan is approved and implemented; do not silently change coordinate contracts or protected technical APIs.
