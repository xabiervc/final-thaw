# FINAL THAW — Fase 1: grafo espacial (v1.0)

**Estado:** grafo revisado para la dirección arquitectónica de edificio completo + huida interior + salida alternativa. La topología es el objetivo de diseño; footprints/colliders y navegación aún requieren verificación en Godot. Autoridad: `FASE1_ARCHITECTURAL_LAYOUT.md v2.0`. Los contratos funcionales y lógicos gobiernan el puzle, no las aristas del grafo.

## Nodos y huellas de referencia

Coordenadas en metros; X positivo hacia el este, Z positivo hacia el sur, norte arriba. Se conserva la base de coordenadas del greybox existente y se extiende el perímetro este donde la nueva salida de servicio lo necesita.

| Nodo | Cota | Huella/posición de referencia | Acceso / función |
|---|---:|---|---|
| Exterior de entrada | 0 | Oeste de X=−3 | Entrada inicial, fuera del perímetro. |
| Túnel de entrada | 0 | X −3..0, Z 4,5..7,5 | Entrada cubierta hacia A. No es salida final. |
| A · Esclusa | 0 | X 1..7, Z 4..10 | Control de acceso y orientación. |
| B · Nave Aster | 0 | X 7..20, Z −9..1 | Nave de ensayo; circulación alrededor del rig. |
| C · Taller | 0 | X 20..24, Z −9..−2 | Taller y cuadros auxiliares. |
| Galería de servicio P0 | 0 | X 20..30, Z −2..1 | Conecta C, el elevador y el retorno. |
| Retorno este P0 | 0 | X 28..30, Z 1..8 | Pasillo de 2 m, al este del hueco D1/D2. |
| Hueco D1/D2 | abierto desde P0 | X 10..28, Z 1..8 | Vacío protegido; acceso inferior por S1. |
| S1 · Escalera fija | 0↔−2 | X 24..26, Z 8..11 | P0 a P−1, siempre utilizable. |
| D1 · Achique | −2 | X 10..20, Z 1..8 | Bombas, sumidero y colector. |
| D2 · Distribución | −2 | X 20..28, Z 1..8 | Esquema, puente A→T y mantenimiento. |
| Galería de evacuación | −2 | X 28..34, Z 4,5..7,5 (extensión de diseño) | Ruta final hacia una salida exterior nueva; no se ha construido/validado. |
| Boca de servicio | variable | X≈34, Z≈6 | Salida al exterior de servicio y conexión con aparcamiento. |
| Elevador | 0↔+1,5 | X 24,5..27,5, Z −4,5..−1,5 | Transporte P0↔M, habilitado por mantenimiento. |
| Galería de observación | +1,5 | X 9..13, Z −9..−1,5 | Vista a B y llegada de S2. |
| M · Bombas | +1,5 | X 13..24, Z −9..−1,5 | Bombas, colectores y paso al elevador. |
| S2 · Escalera fija | +1,5↔+3 | X 9..13, Z −4,5..−1,5 | M a P2, independiente de alimentación. |
| E · Control | +3 | X 9..24, Z −8,5..−4,5 | Selector, aislador, diagnóstico y rearme. |
| F · Archivo | +3 | X 3..9, Z −9..−4,5 | Consulta con ARCHIVO estable. |
| G · Esclusa de doble puerta | +3 | X 0..3, Z −9..−4,5 | La compuerta exterior activa la persecución; la puerta interior devuelve a F. No es la salida final. |
| Pasarela superior | +3 | X 9..26, Z −4,5..−1,5, con hueco S2 | Circulación y observación protegidas. |
| Aparcamiento | exterior | Al este de la boca de servicio | Inicio del tramo exterior de Fase 2. |

Las coordenadas de la galería de evacuación y la boca de servicio son **extensión de diseño**, no geometría ya implementada. Los planos deben reflejarlas; si el ancho o el desnivel requieren más espacio, ampliar el perímetro de forma coherente en vez de estrechar el paso.

### Handoff geométrico con Fase 2

La boca de servicio se sitúa aproximadamente en `(X=34, Z=6)`, con la galería de evacuación llegando desde X=28..34 y Z=4,5..7,5. El plano de parking define un sistema local separado. Su transformación candidata es `X_mundo = X_local + 27,2 m` y `Z_mundo = Z_local − 15,8 m`, que coloca el centro de entrada conceptual en `(34, 6)`. Esta transformación es una hipótesis de coordinación, no un dato de runtime: antes de aceptarla hay que comprobar el ancho/orientación de la boca, la altura de suelo y el volumen de colisión en los SVG y la escena canónica. La planta de Fase 2 no debe desplazarse para acomodar el checkpoint antiguo del prototipo.

## Grafo de circulación

~~~text
ENTRADA OESTE → túnel → A → B ─────→ galería de servicio ─→ elevador ↑ M
                              │                              │             │
                              S1                             │             S2 ↑
                              ↓                              │             E → F → G
                         D1 ↔ D2                             │                  │
                              │                              │             inicio huida
                              └─ galería de evacuación       │                  ↓
                                   → boca de servicio        └─ elevador ↓ P0 ← S2
                                      → aparcamiento                         │
                                                                           S1 ↓
                                                                              P−1
                                                                              │
                                                                   galería evacuación
                                                                              ↓
                                                                         aparcamiento
~~~

## Aristas contractuales

- Entrada ↔ túnel oeste ↔ A ↔ pasillo de acceso ↔ B.
- B ↔ taller C y galería de servicio por pasos claramente señalizados.
- B ↔ P−1 mediante S1; el hueco de D1/D2 no se atraviesa por la superficie P0.
- D1 ↔ D2 por suelo continuo a Y=−2; la diferenciación se hace con maquinaria, tuberías y señalización, no con una pared que impida la investigación.
- Desde el rellano superior de S1: retorno por perímetro sur/este y galería de servicio; el jugador no necesita saltar el hueco.
- Galería de servicio ↔ elevador P0↔M; la llegada superior desemboca en la sala de bombas, no en control.
- M ↔ galería de observación ↔ S2 ↔ P2; E ↔ F ↔ G.
- **Ruta de huida:** al abrir la compuerta exterior de G, la amenaza entra por ese umbral y Elena retrocede por la puerta interior a F/E; después vuelve por S2/M, desciende por el elevador a P0, baja por S1 a P−1 y sale por la galería de evacuación hacia el aparcamiento. G no es la salida final.
- La galería de evacuación conecta D2 con el exterior este. No conecta con el túnel de entrada ni crea una escalera vertical nueva.

## No-aristas y restricciones

- La escalera dañada P0↔P2 permanece bloqueada.
- No hay parada de elevador en P2.
- No se añade un segundo elevador ni una escalera secreta.
- G no es una salida exterior instantánea; abrirla inicia la huida.
- La entrada oeste no se reutiliza como salida final.
- Los accesos cerrados deben corresponder a puertas/colliders, daños físicos o seguridad diegética; no a límites invisibles.
- La ruta exterior debe ser un corredor físico con suelo, techo/estructura cuando proceda, paredes, altura libre y continuidad de colisión hasta el exterior.

## Condiciones de aceptación espacial

1. El plano y la escena usan el mismo sistema de coordenadas y footprints.
2. Las áreas A, B, C, D1, D2, M, E, F y G se identifican y se pueden recorrer; las zonas auxiliares tienen función ambiental o de navegación.
3. El vacío P0 sobre D1/D2 es real; S1 mantiene su boca libre y protegida.
4. El retorno S1→perímetro sur/este→galería de servicio existe en colisión, no solo en el dibujo.
5. Elevador, S1 y S2 tienen destinos correctos, superficies caminables y protecciones.
6. La ruta de ida y la ruta de huida se distinguen; la huida se completa sin teletransporte, saltos imposibles ni atajos no dibujados.
7. La galería de evacuación y la salida exterior conectan físicamente con el aparcamiento y son distintas del acceso inicial.
8. Se prueban cámara, oclusiones, altura libre, puertas, anchura de paso y obstáculos con la cápsula real de Elena.
9. Se registra evidencia de ejecución Godot; los planos y los tests estáticos no prueban aceptación de runtime.