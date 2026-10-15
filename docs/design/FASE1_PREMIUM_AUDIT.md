# FINAL THAW — Fases 1 y 2: registro as-built (v4.0)

**Fecha:** 2026-10-15 · **Rama:** `feat/godot-vertical-slice`
**Motor:** Godot 4.7.2-stable (win64), renderer GL Compatibility (ANGLE sobre Intel HD 630).
**Escena:** `scenes/prototypes/phase1_canonical_greybox.tscn`. Se abre con «Iniciar demo» y contiene la intro, la Fase 1, la Fase 2, el final y los resultados.

**Estado:**
- Implementado y verificado con tests automáticos y con un bot de recorrido que usa las acciones de input reales.
- **Sin playtest humano.**
- El audio no se ha escuchado.
- El rendimiento solo alcanza el objetivo con la calidad gráfica «Rendimiento» (§9).

Este documento es la fuente de verdad del *as-built*. Sustituye a la v3.0 (solo Fase 1) y prevalece sobre las specs v2.1. Las specs afectadas llevan una nota que remite aquí.

## 1. Decisiones de diseño (v4.0) y motivo

| # | Decisión | Motivo |
|---|---|---|
| D1 | **Fases 1 y 2 en una sola escena.** El patio de servicio (aparcamiento) se construye junto al edificio, detrás de la boca este de P−1. Se eliminan el handoff a la escena del prototipo de movimiento (`phase1_handoff.gd`, `phase2_parking_chase.tscn`) y su test. | Sin cortes, teletransportes ni pérdida de estado: la unidad sigue físicamente a Elena. El prototipo de movimiento era un pasillo de 82 m con controlador, enemigo y HUD duplicados. |
| D2 | **Se elimina STAFF-M1.** La sección silenciosa la sostiene la unidad, con una fase de sospecha visible (se frena y gira hacia el estímulo; «?» que aparece gradualmente). | El operario estaba quieto en una instalación clandestina y no aportaba nada que la unidad no pudiera dar con más coherencia. |
| D3 | **G no se abre sin el registro.** Elena se niega («No me voy sin el registro del ensayo»). La auditoría sigue necesitando el `SERVICE_OVERRIDE` encolado por el mantenimiento. | Evita una contención sin la prueba. Leer el registro, por sí solo, nunca la activa (test negativo). |
| D4 | **La causa se hace explícita sin revelar soluciones.** Al activar el mantenimiento se avisa de que se registra una orden de servicio que se auditará al abrir G exterior. Queda anotado en el cuaderno como «Riesgo asumido». | El jugador entiende la relación entre lo que hizo y el peligro que provoca. |
| D5 | **Cuaderno de campo.** Las observaciones generan inferencias: la hipótesis aparece con el esquema más la medición o el examen del puente; la «hipótesis confirmada», tras un disparo real; la conclusión, con el registro. | Ciclo de investigación real (observar, hipótesis, prueba, conclusión) sin volcados de texto. Las notas nunca nombran el control ni el orden. |
| D6 | **Telemetría de contención.** Usar el ascensor, la manivela de R1 o la cámara de la boca de servicio informa a la unidad de un *lugar*, nunca de la posición de Elena. Cada caso lo anuncia la megafonía. | Detección explicable; la persecución llega al patio. Antes, la unidad se quedaba buscando dentro. |
| D7 | **La visión depende de la luz** en el patio: ×0,6 a oscuras, ×1 en los focos. Se combina con estar agachada (×0,55). Un indicador del HUD lo comunica con símbolo y texto. | Sigilo legible: el entorno importa y el jugador sabe por qué le ven. |
| D8 | **Dos dispositivos de ruido en el patio:** el compresor de la jaula (arranque diferido 2 s) y la persiana del muelle 2 (se controla junto a la boca y suena al fondo del patio). | Despistar a la unidad con los sistemas de la propia instalación, lo que encaja con la identidad de científica. |
| D9 | **Salida peatonal de emergencia** con apertura libre junto a la barrera de vehículos, que la contención baja. | La salida es obvia por diseño ambiental (rótulo verde, luz, carril pintado) y es creíble: una salida de emergencia no se bloquea. |
| D10 | **El cansancio cuesta correr, no andar.** Andando, la velocidad nunca baja del 85 % del paso normal. | Antes, con 0 de aguante andaba al 60 %, una captura injusta. |
| D11 | **Planificación de ruta de la unidad.** Empieza en el nodo más cercano al que puede ir en línea recta y replanifica si se atasca. | Corrige bloqueos detrás de muros, por ejemplo junto al hueco de S1, que impedían llegar al patio. |

El contrato eléctrico (`FASE1_LOGIC_CONTRACT.md`) **no cambia**. Las contradicciones C1–C12 de la v3.0 siguen resueltas tal como se decidieron. Las cotas son P−1 −2, P0 0, M +3 y P2 +6.

## 2. Flujo completo

**Intro** (~51 s, saltable). Explica quién es Elena, por qué está en Helix y qué sospecha. Plano exterior de la instalación; la nave con la columna Aster; el foso con el puente A–T; Elena saliendo del túnel; título.

**Fase 1, investigación:**
- Túnel oeste y el plan de evacuación del acceso, que adelanta la ruta de huida.
- Informe oficial en control: «fallido, solo nodo T».
- Foso P−1: esquema, puente A–T (examen o escáner, que da la hipótesis), etiqueta del taller y mantenimiento (riesgo asumido; da corriente al ascensor).
- Ascensor a M, S2 a control E: aislar ENSAYO, seleccionar ARCHIVO, comprobar y rearmar. Un error provoca un disparo, que confirma la hipótesis.
- Archivo F con ARCHIVO estable: registro y conclusión.
- G exterior: auditoría y contención.

**Fase 2, contención:**
- Alarmas, R1 baja, la estantería O1 cae y la megafonía anuncia el protocolo.
- La unidad entra por la pasarela exterior y hace un barrido silencioso; Elena retrocede por F, E, S2 y M.
- Ascensor (telemetría) a P0 y bandeja O3 caída. La unidad la readquiere por línea de visión real: cámara de persecución y música de persecución.
- Manivela de R1 (telemetría) y paso agachada; luego S1, el foso, la galería y la boca este.
- **En el patio**, la cámara reporta la salida: la unidad acude, se encienden los focos en secuencia y baja la barrera.
- Rutas A (sur, iluminada, corta) o B (norte, oscura, coches y columnas). Dispositivos de ruido. Hueco O3 de 1,3 m, recinto de salida y carril de emergencia.

**Final** (~37 s, saltable). La unidad se detiene en el límite del sector y la megafonía transfiere a «seguridad exterior». Plano desde lo alto de la rampa: focos en secuencia y el lector «SECTOR EXTERIOR»; línea N2-06. Plano en la calle: consecuencia (la auditoría llevaba su credencial). Cartelas finales: el resultado se transfirió a la ESTACIÓN FINAL THAW; continuará en la Fase 3.

**Resultados:** tiempo, entradas del cuaderno, capturas, pistas y dificultad. Vuelta al menú.

## 3. Geometría as-built (metros; X este, Z sur, Y vertical)

- **Edificio:** igual que la v3.0 (§2 anterior). Cubiertas solo visibles desde fuera (planos de una cara, sin colisión ni sombra).
- **Patio:** suelo a Y −2; x 34..76, z −15,5..14. El concepto v0.3 se ajustó al borde real del edificio, así que la franja de fachada es el bloque de planta x 30,3..34. Muros perimetrales de 2,6 m que no se pueden escalar. La boca está en x 34, z 4,5..7,5.
- **Filas de coches:** norte z −15,5..−10,5 y sur z 9..14 (bahías de 3×5). Columnas con racks a z −9,6 y 8.
- **Cobertura:**
  - O1, carro con bidones: (42, −2,4).
  - Furgoneta: (47, 0,9).
  - Pila de cajas escalonada (escalable): (54,5, −3,1).
  - Jaula técnica (malla: bloquea el paso, no la vista): x 58..63,6, z −4,4..−0,9.
  - O2: (65,6, 1,2).
- **Recinto de salida:** valla en x 69,4 y en z −0,8, con el hueco O3 en x 72,3..73,6. La puerta del muro norte está en x 69,6..73,2: carril de vehículos con barrera (fondo a 1,15 m) y carril peatonal en x 72,1..73,2.
- **Rampa y calle:** de z −15,8 a −24 (a Y 0,4); la calle va de z −24 a −34. Cruzar z < −16,6 termina la fase.
- **Grafo de la unidad:** `phase1_route_graph.gd`, con nodos `yard_*`, `ya_*` (ruta A), `yb_*` (ruta B), `join`, `bar_s/n`, `egress` y `gate_in`.

## 4. Puntos de control

| ID | Elena | La unidad reinicia en |
|---|---|---|
| F | (6, 6, −6,2) | gantry_far |
| M | (10,2, 3, −5,6) | f_mid |
| P0 | (25, 0, 0,4) | lift_m |
| P−1 | (25, −2, 6,8) | lift_p0 |
| YARD | (35,6, −2, 6) | pit_w |
| JOIN | (70, −2, 2,4) | yard_dec |
| EGRESS | (72,95, −2, −4) | ya_2 |

En cada caso hay al menos 15 m de ruta entre ambos y la unidad no tiene línea de visión inmediata (test). El menú de pausa permite «Volver al último punto seguro».

## 5. Unidad de recuperación (`phase1_recovery_unit.gd`)

- **Estados** (símbolo y color del visor, nunca solo color): barrido «·», sospecha «?» que aparece gradualmente, investigación «?», alerta «!», persecución «!!» y búsqueda «?».
- **Sentidos:**
  - Vista: cono de 55° con línea de visión real; alcance según dificultad. Agachada ×0,55; a oscuras ×0,6.
  - Contacto cercano: 1,6 m.
  - Oído según el movimiento de Elena: quieta 1,5 m, agachada 2,5, andando 6, corriendo 10, todo × la dificultad.
  - Solo percibe en su mismo nivel.
- **Memoria:** va a la última posición conocida. Al perder el contacto comprueba 5 m en la dirección en que la vio huir (solo si esa línea está despejada), busca y vuelve al barrido.
- **Movimiento:** usa el grafo de rutas, el mismo ascensor y la persiana R1 (la fuerza). Nunca se teletransporta. Se detiene en el límite del sector.
- **Audio posicional:** zumbido de servos según la velocidad, golpes de oruga y un aviso al entrar en alerta.

## 6. Movimiento y cámara

- **Velocidades:** paso por defecto 4,2 m/s, sprint 6,8 m/s (gasta aguante), agachada 1,4 m/s.
- **Giros:** conservan la velocidad (11 rad/s). Una inversión frena y gira en unos 0,13 s.
- **Salto y escalada:** caída ×1,25 para una parábola firme; coyote y buffer de salto. Puede encaramarse a bordes de 0,45 a 1,85 m (cajas, coches tapados, O2), nunca a vallas ni barandillas.
- **Animación:** la velocidad de cada clip va ligada a su velocidad natural medida (andar 1,8, correr 4,3, agachada 0,85 m/s), con histéresis. Inclinación del cuerpo al acelerar y girar (reducida con «reducir movimiento»).
- **Cámara:**
  - «Exploración»: 5 m de distancia, FOV 65.
  - «Persecución»: 3,4 m, FOV 71, hombro 0,6. Transición suave mientras la unidad está en alerta o persiguiendo, y 2,5 s más.
  - Stick derecho; sensibilidad e inversión configurables.

## 7. Opciones, accesibilidad y entrada

Todas tienen efecto real y están cubiertas por `tests/test_game_systems.gd`.

- **Remapeo de teclado y mando** de mover, correr, agacharse, saltar, interactuar, escanear y pista. Si la tecla o el botón ya se usa, las acciones se intercambian. Hay restaurar predeterminados. Se guarda en `GameManager.settings` (guardado JSON/CRC32, compatible con partidas antiguas). Esc y Start quedan fijos para el menú. Las acciones de combate heredadas de la Fase 0 siguen definidas (contrato de la Fase 0) pero no se usan ni se muestran.
- **Dificultad** (Exploración / Estándar / Exigente): cambia la visión, la reacción, la velocidad, la búsqueda y el oído de la unidad, y el gasto de aguante.
- **Accesibilidad:** tamaño de texto, alto contraste, reducir movimiento (sin destellos de alarma, sin cambio de FOV, inclinación reducida), subtítulos activables y su fondo, paleta para daltonismo (deuteranopía, protanopía, tritanopía) y velocidad de juego (50/75/100 %).
- **Cámara:** sensibilidad e inversión. **Audio:** volumen general, música y efectos.
- **Calidad gráfica:** Alta / Equilibrada / Rendimiento (§9).
- **Idioma:** todo el texto del juego está en `data/game_text.json` (ES/EN). La señalética del mundo es diegética y está en español; las acciones y los paneles muestran la traducción al lado.

## 8. Audio

Todo el audio es sintético y provisional.
- **Música adaptativa:** investigación, tensión, persecución y liberación. Cambia según el estado real del juego, no por temporizador.
- **Ambiente y efectos:** zumbido de bombas mientras el mantenimiento está encendido; viento exterior en el patio; megafonía (campanilla y subtítulo); compresor, persiana y barrera.

**No se ha escuchado.** Lista de producción y prompts en `docs/art/MASTER_ASSET_LIST.md`.

## 9. Rendimiento medido

Intel HD 630, 1280×720, Compatibility (ANGLE/D3D11). Medianas en ms de 300 fotogramas tras 300 de calentamiento, con `tools/capture/scene_capture.tscn --bench`. **Patio = con la respuesta de contención activa (focos encendidos), el caso real de juego.**

| Lugar | Inicial (hoy) | Equilibrada (por defecto) | Rendimiento |
|---|---|---|---|
| Nave | 21,8 | 19,0 | 16,1 |
| Bombas (M) | 24,7 | 18,9 | 16,2 |
| Control (E) | 18,6 | 17,2 | 15,8 |
| Patio centro, focos | 23,8* | 21,2 | 19,1 |
| Patio salida, focos | 22,0* | 20,1 | 17,8 |

\* La medición inicial del patio se hizo con los focos apagados.

**Correcciones aplicadas:**
1. Las texturas 3D se importaban sin compresión ni mipmaps; ahora usan S3TC con mipmaps (de −1 a −4,5 ms).
2. Las cajas estáticas grandes (losas, muros largos) se dividen en la rejilla de 12 m. Cada malla solo recibe las luces cercanas (de −1 a −1,5 ms en el patio).
3. Opción de calidad gráfica: el glow cuesta ~2 ms y la sombra direccional ~2–3 ms.

**Diagnóstico de lo que queda:** el equipo está limitado sobre todo por la tasa de relleno a 720p.
- Una ventana de 640×360 ahorra ~5 ms.
- Sin geometría estática queda una base de ~11 ms (Elena, HUD, coches, pantalla completa).
- Las luces omni del patio cuestan ~1,3 ms.
- El escalado de resolución 3D *empeora* este renderer: de 19,2 pasa a 25–27 ms. Se descartó.

**Estado frente a 16,7 ms:**
- «Rendimiento» lo cumple en interiores (15,8–16,2). En el patio con focos se queda en 17,8–19,1, es decir, 1–2,4 ms por encima.
- «Equilibrada» y «Alta» no lo cumplen en este equipo.

**Siguiente paso de valor:** medir en el PC nuevo previsto. En la HD 630, reducir el número y el alcance de los focos del patio en «Rendimiento», y probar la valla con geometría en lugar de recorte alfa.

### 9.1 Medición tras el pase ilustrado (2026-10-15, posterior a v4.0)

El pase ilustrado añadió materiales pintados, luz en dos tonos, trazo de tinta, el arte de la nave, Elena v2 y más luces.

Medición: mismo equipo y mismo método, seis vistas (nave, galería de bombas M, control P2, foso, canal de entrada, patio con focos). Se compara el controlador por defecto (ANGLE sobre Direct3D 11) con OpenGL nativo (driver Intel 31.0.101.2112).

| Controlador | Calidad | Rango (ms) | 60 FPS |
|---|---|---|---|
| ANGLE (por defecto en esta GPU) | Equilibrada | 23,3–29,9 | no |
| ANGLE | Rendimiento | 19,8–24,6 | no |
| OpenGL nativo | Equilibrada | 7,7–9,5 | sí |
| OpenGL nativo | Alta | 8,7–10,4 | sí |

**Diagnóstico.**
- Godot sustituye OpenGL por ANGLE en esta GPU: su lista `rendering/gl_compatibility/force_angle_on_devices` la incluye. Aquí ANGLE cuesta unas tres veces más; la misma vista de la nave tarda 29,2 ms con ANGLE y 9,4 ms en nativo.
- Con ANGLE, el coste sigue a las llamadas de dibujo, a las luces por objeto y a la preparación de materiales, no al sombreado de píxeles. Prueba de ello: renderizar el 3D a un cuarto de resolución es *más lento* que a resolución completa.

**Correcciones aplicadas:**
1. Entorno solo difuso, sin especular, que además es la norma del estilo ilustrado: −2 a −3 ms con ANGLE.
2. Lote de paleta: los colores planos comparten un material de color por vértice. Hay de 41 a 53 llamadas menos por vista, unos −0,5 ms.
3. 167 texturas nuevas se importaban sin compresión ni mipmaps; ahora usan S3TC/BPTC con mipmaps y los mapas normales RGTC. La VRAM baja de 301 a 131 MB.
4. Celdas de 12 m confirmadas como óptimas: con 8 m y con 24 m va más lento.

Probado y descartado: iluminación por vértice (pierde los charcos de luz y solo ahorra 2 ms) y escalado 3D.

**Decisión pendiente del propietario.** Usar OpenGL nativo en Intel Gen9 exige quitarla de `force_angle_on_devices` en `project.godot`, y ese archivo requiere aprobación (AGENTS.md). Impacto y riesgo en `PROJECT_STATUS.md`, «Performance status».

## 10. Evidencia de tests

Ver `PROJECT_STATUS.md` (comando, commit y recuento por suite).

## 11. Lo que no está hecho o no está verificado

- No hay playtest humano. Diversión, claridad del puzle sin pistas, justicia de la persecución con jugadores reales y confort de cámara siguen sin verificar.
- Mando real sin probar: solo hay eventos inyectados en tests.
- No hay voz grabada.
- No existe gatear (prone). Los pasos bajos se hacen agachada: persiana R1 y barrera.
- Faltan animaciones de giro en el sitio, arranque y parada, y reacción a golpes.
- Arte provisional: edificio en greybox con texturas foto, ciudad de cajas, unidad generada.
- Exportación web y licencia de MPFB sin verificar.

## Owner-approved redesign target (2026-10-15) — not part of this as-built record

This document remains the historical as-built record for the implementation and evidence described above. The owner has since approved a new target direction. Do not interpret this addendum as a claim that the existing scene already implements it.

- Replace the intended final visual direction of realistic/textured greybox presentation with illustrated 3D adventure art based on the owner-provided Marcus character concept and illustrated industrial laboratory reference.
- Redesign Phase 1 as a larger but legible interconnected facility anchored by the central pumping hall, with purposeful rooms, verticality, environmental storytelling, meaningful traversal and optional discoveries.
- Use a damaged service breach/culvert that physically collapses behind Elena; the entrance must be blocked by actual geometry/collision.
- Redesign Phase 2 around a human operational area that Elena observes before being discovered. The target escape is hybrid first-person gameplay with free movement and route choices plus brief contextual actions and consequence-revealing looks back.
- Use a separately designed parking garage and public-street exit where Elena loses the pursuers in a crowd.
- Correct Elena's scanner/device integration so it is credibly wrist-mounted/holstered or has proper draw/use/stow animation.
- Document future Marcus-led beat-'em-up phases in which Elena learns limited defense from Marcus, progressing from dependence to basic self-defense. Full combat is deferred beyond this vertical-slice redesign.

The existing test and performance evidence in this document applies only to the commits and behavior recorded above. It does not verify the new target. Reconcile the actual repository, update the relevant existing specifications and rerun the complete suite after implementation. Record visual and human-playtest evidence separately from automated results.
