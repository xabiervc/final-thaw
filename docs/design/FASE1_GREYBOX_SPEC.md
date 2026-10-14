# FINAL THAW — Fase 1: especificación de greybox (v2.0)

**Estado:** objetivo espacial ampliado. Las huellas base de las plantas existentes se conservan donde son compatibles; la galería de evacuación y la huida interior son nuevas y deben incorporarse a SVG, constructor y tests antes de considerarse construidas. Medidas sujetas a prueba de volumen de jugador/cámara; no reducir anchos para encajar el guion.

## Convenciones

- Unidades Godot: metros; X este, Z sur, Y vertical; norte arriba en planos.
- P0 = Y 0; P−1 = Y −2; M = Y +1,5; P2 = Y +3.
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
| Galería de evacuación | X=28..34, Z=4,5..7,5 (propuesta acotada) | Corredor de servicio con ancho libre ≥2 m, paredes y techo donde proceda; suelo continuo desde D2 a la boca exterior. |
| Boca de servicio | X≈34, Z=4,5..7,5 | Umbral exterior físicamente abierto a zona de servicio/aparcamiento; no teletransporte. |

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

G X=0..3, Z=−9..−4,5; F X=3..9, Z=−9..−4,5; E X=9..24, Z=−8,5..−4,5; pasarela X=9..26, Z=−4,5..−1,5, con hueco de S2 X=9..13. El panel E conserva su centro contractual (15,5; 4,55; −8,15) y su soporte. La puerta G abre hacia una ruta de circulación interior y dispara la secuencia de huida; no puede representar una puerta exterior que teletransporte a H. Añadir puerta, umbral y corredor de huida en el plano y en la escena.

## Ruta de huida y obstáculos

Ruta de referencia: G → corredor/pasarela superior → S2 ↓ M → sala de bombas → elevador ↓ P0 → galería de servicio → S1 ↓ P−1 → D2 → galería de evacuación → exterior este → aparcamiento.

- Los obstáculos deben ubicarse en planos con footprint, ancho residual, altura, collider y solución esperada. No aprobar obstáculos descritos solo en prosa.
- Primera pasada: máximo tres obstáculos principales, cada uno con anticipación visual, colisión visible y margen de recuperación. Los obstáculos exactos siguen pendientes de layout de persecución.
- No usar obstáculos que exijan una habilidad aún no enseñada o un salto ciego. No convertir la persecución en combate obligatorio.
- El estado del elevador al comenzar la huida debe ser explícito. Si se requiere una llamada, tiempo de espera y riesgo deben formar parte del diseño y probarse.
- El camino debe funcionar con cámara de tercera persona; tuberías, vigas, barandillas y puertas no pueden tapar al jugador ni esconder la solución.

## Arquitectura legible como instalación real

- Espesor y alineación coherentes de muros, jambas, dinteles y losas.
- Las bandejas y tuberías siguen rutas plausibles entre cuadros, bombas y distribución; no flotan ni atraviesan puertas.
- Señalización consistente: nomenclatura A/B/C/D1/D2/M/E/F/G, cotas y direcciones.
- Cada espacio explorable tiene función ambiental, de orientación o de investigación.
- Los cierres son diegéticos y los pasillos de servicio no terminan en paredes arbitrarias.
- La iluminación de emergencia y las zonas abandonadas guían sin depender solo del color.
- No añadir arte final hasta cerrar planta, sección, circulación, cámaras y colisiones.

## Criterios de aceptación

1. Comparar todos los SVG y la sección con la escena; registrar cualquier desviación.
2. Validar perímetro, huellas, suelo y huecos de P0/P−1.
3. Recorrer S1, elevador y S2 en ambos sentidos sin saltos no diseñados.
4. Verificar retorno sur/este y la galería de servicio.
5. Verificar que G abre hacia el corredor de huida y no al exterior directo.
6. Recorrer la persecución interior, elevador, S1, galería de evacuación y salida alternativa.
7. Confirmar continuidad visual/física al aparcamiento y handoff al checkpoint correcto.
8. Ejecutar regresión Fase 0 y tests existentes; registrar versión, renderer, commit, resultados, errores/warnings y QA manual.

Un plano no se considera excelente por estética aislada: debe ser acotado, consistente entre cotas, legible, verificable y capaz de dirigir la implementación sin contradicciones.