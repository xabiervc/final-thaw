# FINAL THAW — Fase 1: grafo espacial (v1.1)

**Estado:** grafo revisado para la dirección arquitectónica de edificio completo + huida interior + salida alternativa. La topología es el objetivo de diseño; footprints/colliders y navegación aún requieren verificación en Godot. Autoridad: `FASE1_ARCHITECTURAL_LAYOUT.md v2.1`. Los contratos funcionales y lógicos gobiernan el puzle, no las aristas del grafo.

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
| Galería de evacuación (candidato actual) | −2 | X 28..34, Z 4,5..7,5 (propuesta no bloqueante) | Ruta posible hacia una salida exterior nueva; no se ha construido/validado. Reubicarla si la topología completa requiere otra salida. |
| Boca de servicio alternativa | Y=−2 | X=34, Z=4,5..7,5 (3 m de apertura libre) | Salida este de la galería P−1, distinta del túnel oeste; conecta con la entrada local X=5,3, Z=21,8 del parking. |
| Elevador | 0↔+1,5 | X 24,5..27,5, Z −4,5..−1,5 | Transporte P0↔M, habilitado por mantenimiento; lo usa Elena y lo sigue físicamente la unidad. |
| R1 · Umbral de reacquisición | 0 | X≈29, Z≈1; transición de galería de servicio a retorno este P0 | La unidad sale del elevador detrás de Elena y la reacquiere por LOS real; inicia la carrera. Sin teletransporte ni spawn delante del jugador. |
| Galería de observación | +1,5 | X 9..13, Z −9..−1,5 | Vista a B y llegada de S2. |
| M · Bombas | +1,5 | X 13..24, Z −9..−1,5 | Bombas, colectores y paso al elevador. |
| S2 · Escalera fija | +1,5↔+3 | X 9..13, Z −4,5..−1,5 | M a P2, independiente de alimentación. |
| E · Control | +3 | X 9..24, Z −8,5..−4,5 | Selector, aislador, diagnóstico y rearme. |
| F · Archivo | +3 | X 3..9, Z −9..−4,5 | Consulta con ARCHIVO estable. |
| G · Esclusa de doble puerta | +3 | X 0..3, Z −9..−4,5 | La compuerta exterior envía la auditoría e inicia Containment; la puerta interior devuelve a F. El sigilo precede a la carrera. No es la salida final. |
| Pasarela superior | +3 | X 9..26, Z −4,5..−1,5, con hueco S2 | Circulación y observación protegidas. |
| Aparcamiento | Y=−2 | Coordenadas locales X=0..48, Z=0..30; mundo X=local X+28,7, Z=local Z−15,8 | Umbral mundo (34, 6); spawn seguro (35,5, 6); egress lejano (71,5, −14). |

La galería de evacuación y la boca este quedan seleccionadas como **baseline de diseño**: galería 6 × 3 m desde X=28..34, Z=4,5..7,5; boca en X=34, Y=−2. El suelo exterior del patio de servicio comparte Y=−2, por lo que no se añade rampa/escalón en el umbral. La geometría y continuidad física siguen pendientes de verificación en Godot.

### Handoff geométrico con Fase 2

La salida seleccionada es la boca este de P−1 en X=34, Z=4,5..7,5, Y=−2, conectada por una galería de servicio de 6 × 3 m. Es distinta del túnel oeste y comparte cota con el patio de servicio; no requiere una rampa nueva en el umbral. La ruta interior es: evasión silenciosa por F/E, pasarela y M → elevador existente a P0 → R1 → carrera por retorno este → S1/P−1 → galería de evacuación → boca este → parking.

La planta y overlays de parking usan coordenadas locales con transform seleccionado de diseño: `X_mundo = X_local + 28,7 m`, `Z_mundo = Z_local − 15,8 m`, `Y = −2,0 m`. El umbral local (5,3; 21,8) coincide con la boca P−1 (34; 6); el spawn local (6,8; 21,8) queda en mundo (35,5; 6). El egress local (42,8; 1,8) queda en mundo (71,5; −14). Validar orientación, cota, colliders y continuidad en Godot; no sustituir estas coordenadas por el checkpoint antiguo del prototipo.

## Estados de sigilo y transición a carrera (contrato provisional)

| Estado | Zona de referencia | Qué hace el jugador | Condición de salida | Requisito espacial |
|---|---|---|---|---|
| Evasión silenciosa | F/E → pasarela → S2/M; áreas de trabajo conectadas | Evita líneas de visión, ruido y atención de personal que puede seguir trabajando. | Elena recorre M en silencio, baja por el elevador existente y cruza R1 en P0; la unidad sale detrás y la reacquiere por LOS real. Una alerta de personal solo marca última posición conocida. | Marcar cobertura real, campos de visión, rutas de patrulla, refugios y rutas alternativas en los planos; NPC no bloquean pasillos como props. |
| Carrera interior | R1: transición de galería de servicio a retorno este P0, inmediatamente después del rellano del elevador | Corre por el retorno este hacia S1 y P−1, interpretando obstáculos legibles. | Cruza el umbral exterior alternativo elegido en P−1. | La unidad debe llegar por el mismo elevador y reacquirir por LOS real; R1 no teletransporta ni fuerza la carrera si la unidad no está presente. |
| Transición a parking | Umbral exterior seleccionado | Continúa el movimiento hacia la zona de servicio/aparcamiento. | El checkpoint integrado de Phase 2 toma el control una sola vez. | Transform de diseño seleccionado: X_mundo=X_local+28,7; Z_mundo=Z_local−15,8; verificar en escena. |

## Grafo de circulación

~~~text
INVESTIGACIÓN:
Entrada oeste → túnel → A → B/C → P0 → S1 ↓ P−1 (D1/D2)
D2: mantenimiento + circuito seguro → elevador ↑ M → S2 ↑ P2 → E/F → G

HUIDA (dos ritmos, sin rutas nuevas):
G abre → Containment → retroceso por puerta interior → F/E → pasarela → S2 ↓ M
→ evasión silenciosa en M (STAFF-M1 + cobertura C1/O2) → elevador ↓ P0
→ R1 (X≈29, Z≈1; reacquisición por LOS real) → carrera por retorno este
→ S1 ↓ P−1 → galería de evacuación 6×3 m → boca este (X=34, Z=4,5..7,5, Y=−2)
→ aparcamiento

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
- **Ruta de huida:** abrir G inicia Containment, pero no un sprint ininterrumpido. Elena retrocede por la puerta interior a F/E y atraviesa un primer tramo de evasión silenciosa por áreas de trabajo potencialmente ocupadas. Después, en un umbral expuesto registrado en el grafo, la unidad reacquiere a Elena y comienza la carrera. La ruta vuelve por conexiones verticales existentes y sale por una boca alternativa elegida desde el layout completo. G no es la salida final.
- La galería final de servicio conecta el último espacio interior aprobado con el exterior elegido. No conecta con el túnel de entrada ni crea una escalera vertical nueva. Si la salida cambia de lado, hay que dibujar el tramo completo en planta/sección antes de implementarlo.

## No-aristas y restricciones

- La escalera dañada P0↔P2 permanece bloqueada.
- No hay parada de elevador en P2.
- No se añade un segundo elevador ni una escalera secreta.
- G no es una salida exterior instantánea; abrirla inicia Containment. El tramo silencioso y el trigger de transición a carrera deben tener nodos/aristas y condiciones de percepción explícitos.
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
7. El tramo de evasión silenciosa y la carrera son legibles y verificables; la salida exterior finalmente elegida conecta físicamente con el aparcamiento y es distinta del acceso inicial.
8. Se prueban cámara, oclusiones, altura libre, puertas, anchura de paso y obstáculos con la cápsula real de Elena.
9. Se registra evidencia de ejecución Godot; los planos y los tests estáticos no prueban aceptación de runtime.