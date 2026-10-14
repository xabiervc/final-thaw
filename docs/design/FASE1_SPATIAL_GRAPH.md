# FINAL THAW — Fase 1: grafo espacial (v0.3)

Estado: DECISIONES DE DISEÑO CERRADAS CON VALIDACIÓN PENDIENTE. Revisión estática; Godot no ejecutado y no se han validado recorridos, colisiones, cámara ni experiencia. Este documento fija decisiones conceptuales para preparar el plano funcional; no autoriza todavía la construcción en escena ni cambios en código, contrato lógico, guardado o escenas existentes.

Fuentes: `fase1_fase2_mapa_progresion.md`, `FASE1_GREYBOX_SPEC.md`, `FASE1_LOGIC_CONTRACT.md`.

Convención: **[R]** existe en la especificación del greybox; **[D]** decisión de diseño tomada aquí, aún no construida/validada; **[P]** propuesta aún no aceptada. Las distancias son estimaciones derivadas de la descripción, no mediciones en escena. El ascensor sigue sin validar y la rampa es provisional.

## Decisiones ejecutivas

1. **Orden del recorrido:** se adopta A como recorrido canónico previsto: inspeccionar el foso antes de operar el circuito. B se conserva como ruta físicamente posible durante el playtest, no como secuencia narrativa equivalente garantizada. La prueba evaluará si B permite deducir y recuperarse con la información disponible; no se construirá una conexión nueva para abaratar B antes de esa evidencia.
2. **Plataforma:** se reserva como elemento de servicio del nivel inferior, en el anexo al este de la instalación ya descrito para la rampa (envolvente X=30..34), con zona de embarque en el rellano inferior y desembarque en el rellano superior. Función única: transporte vertical alternativo entre esos dos rellanos, no acceso a una sala ni atajo narrativo. El interruptor de mantenimiento habilita la plataforma; su comportamiento ante pérdida de alimentación queda decidido como **parada segura sin caída**: si está en movimiento, completa una parada controlada en el rellano alcanzable más cercano; si está entre niveles, no permite embarcar ni deja a Elena atrapada y ofrece recuperación desde ambos extremos. Esta decisión mecánica requiere prototipo y prueba independiente; no se considera existente ni validada.
3. **Rearme:** el punto de interacción se reserva en la pasarela, junto al selector y el aislador, en el espacio entre ambos controles y fuera de su alcance/collider inmediato. Debe poder operarse sin bloquear el paso ni confundirse con selector o aislador. Rearmar sigue siendo la operación lógica del contrato: solo tiene éxito cuando la condición de fallo ya no está presente; cambiar selector o aislador no rearma por sí solo. La posición exacta del objeto de interacción se ajustará dentro de esa zona durante el plano funcional, no alterando coordenadas contractuales de los controles.
4. **Indicador local de F:** se acepta como requisito visual en el punto de consulta del archivo (5,3,-7), montado en la cara orientada a la entrada este/pasarela, de forma que su estado sea legible desde la pasarela y al acercarse al archivo. Solo muestra «suministro estable» / «no disponible», derivado del estado del contrato; no sugiere qué control accionar y no sustituye los indicadores de E ni el terminal de diagnóstico de la cabina. La ubicación y legibilidad son una decisión conceptual [D], pendientes de prueba con la cámara real.
5. **Conexión F→G:** G se conecta al vestíbulo oeste del atajo de la cabina, con acceso inicial desde el lado de F/cabina. La salida del atajo al nivel inferior sigue siendo de un solo desbloqueo desde la cabina y luego bidireccional. La esclusa es un umbral de transición al exterior, no un acceso que requiera volver a la entrada inicial. La causa narrativa de la salida y la respuesta de Helix continúan PENDIENTE DE GUION; esta decisión espacial no autoriza fijar esos hechos.
6. **Validación de escena:** antes de construir la progresión final, debe probarse el ascensor por sí solo y la ruta provisional por rampa por separado, después colisiones, ancho de recorrido, cámara, lectura de indicadores y ambas variantes con jugadores nuevos. No declarar el grafo validado hasta registrar versión de Godot, commit, resolución, renderer, dispositivo y observaciones.

## 1. Nodos y aristas de referencia [R]

| Nodo | Posición / envolvente | Nota |
|---|---|---|
| Entrada | (3,0,7) | La cabina es destino visible inicial |
| Escalera directa rota | X 2..4, Z -3..3 | Bloqueada; inspección desde (4,0,3), no es ruta |
| Ruta sur / pasillo oeste | X 7..19.5, Z 5..7; X 17.5..19.5, Z 5..10, Y=0 | Ruta principal hacia explanada |
| Explanada | X 20..28, Z 8..12, Y=0 | Boca de escalera del foso |
| Escalera fija del foso | (25,0,11) a (25,-2,8) | Salida del foso independiente de mantenimiento |
| Foso | X 20..28, Z 1..8, Y=-2 | Esquema (27,-2,6), puente (22,-2,4), interruptor (26,-2,2) |
| Ruta este / rellano inferior | X 28..30; X 24..28, Z -1..1, Y=0 | Camino al ascensor |
| Ascensor | X 24.5..27.5, Z -4.5..-1.5, Y=0..3 | Transporte sin validar |
| Rellano superior | X 24..28, Z -7..-4.5, Y=3 | Conecta ascensor/rampa y pasarela |
| Pasarela pública | X 9..26, Z -8..-6, Y=3 | Selector (12,3,-7), aislador (19,3,-7); observación de indicadores desde (15,3,-7) |
| Cabina / archivo | X 2..9, Z -9..-5, Y=3 | Archivo (5,3,-7), entrada este (9,3,-7), terminal de diagnóstico |
| Atajo oeste | puerta (2,3,-7.5), escalera X 0..2 | Se desbloquea desde cabina; llega a (1,0,1) |
| Reserva plataforma | anexo X 30..34 | [D] transporte entre rellanos inferior y superior; sin volumen construido/validado |

La coordenada (15,3,-7) es un **punto de observación**, no la ubicación física del indicador de pasarela. El archivo está aproximadamente a 10 m de ese punto. La posición física de los indicadores de E debe definirse en el plano funcional y comprobarse con la cámara.

## 2. Recorrido canónico A

```text
Entrada -> ruta sur -> pasillo oeste -> explanada
  -> escalera fija -> foso: esquema, puente y mantenimiento -> vuelta por la misma escalera
Explanada -> ruta este -> rellano inferior -> ascensor (o rampa provisional)
  -> rellano superior -> pasarela: selector, aislador, indicadores y rearme
  -> entrada este -> cabina/archivo -> esclusa G en vestíbulo oeste -> exterior H
```

La visita al foso es una excursión de ida y vuelta antes del circuito. El interruptor (26,-2,2) está aproximadamente 6 m al norte del pie de la escalera (25,-2,8) en distancia horizontal; el recorrido pasa por el esquema y es más largo. El foso permanece como callejón sin salida con la misma escalera como salida fija.

## 3. Variante B para prueba comparativa

```text
Entrada -> explanada -> ruta este -> rellano inferior -> ascensor/rampa
  -> pasarela -> cabina/archivo
  -> retorno al foso por ascensor/ruta este o por atajo oeste hasta el nivel inferior
  -> inspección del foso -> regreso por la ruta principal a controles
```

B sigue siendo físicamente posible, pero no se toma como recorrido recomendado ni como equivalente de comprensión. Las estimaciones previas de unos 70 m adicionales no son reproducibles y no se usarán como dato de aceptación. Antes de comparar resultados hay que medir rutas concretas por aristas y contar cada trayecto vertical de ascensor con una convención explícita. No se añade conexión nueva hasta tener resultados de playtest.

## 4. Requisitos de colocación y comportamiento

### 4.1 Interruptor y plataforma

- Interruptor de mantenimiento [R] en (26,-2,2); el camino debe seguir legible aun con luces de servicio apagadas mediante iluminación ambiental mínima o señalización propia.
- Plataforma [D] reservada en la envolvente del anexo X=30..34; embarque en el rellano inferior, desembarque en el superior. No debe invadir el ancho libre de rutas ni el área de la rampa durante su prueba independiente.
- Mantenimiento habilita el servicio y las luces según el contrato. Si se pierde alimentación, la plataforma debe parar de forma segura y no atrapar al jugador; probar llamada desde ambos extremos, pérdida de alimentación en movimiento, llegada/parada segura, recuperación y caída.
- Si el volumen reservado, los espacios de embarque o el comportamiento seguro no caben sin reducir recorridos existentes o cambiar contratos, detenerse y abrir una decisión separada; no modificar el contrato por conveniencia.

### 4.2 Controles y rearme de E

- Selector en (12,3,-7); aislador en (19,3,-7). Mantener libre el espacio de operación de ambos.
- Rearme [D]: interacción física en la pasarela, entre los controles, con margen de seguridad y sin colisión con ellos. No se fija aún un punto exacto de coordenadas ni se mueve ningún control contractual.
- Indicadores de pasarela deben ser legibles desde el punto de observación (15,3,-7), sin afirmar que allí estén montados.
- El terminal completo permanece en la cabina y siempre accesible, aun sin alimentación de recuperación. Presenta estado actual y último disparo por separado.
- No cambiar semántica de disparo/rearme del contrato lógico.

### 4.3 Indicador del archivo F

- Indicador local [D] integrado en el mueble/zona de consulta (5,3,-7), cara visible hacia la entrada este y la pasarela.
- Dos estados derivados del contrato: suministro estable / no disponible. Sin color como único canal; usar texto o símbolo redundante legible.
- Debe poder leerse desde la pasarela y a corta distancia del archivo, pero la aceptación depende de una prueba en escena de línea de visión, tamaño legible, iluminación y cámara.
- No prescribe control, no constituye pista obligatoria para actuar y no reemplaza los indicadores de la pasarela ni el terminal.

### 4.4 Conexión F→G

- G se sitúa en el vestíbulo oeste de la cabina, conectado al interior de F; desde G se sale al exterior H.
- El atajo oeste no puede abrirse desde fuera inicialmente; la interacción de desbloqueo sigue siendo desde la cabina. Tras desbloquearse, sigue bidireccional.
- El motivo narrativo del paso a exterior, lo que detecta Helix y el destino inmediato de Elena siguen PENDIENTE DE GUION. Esta elección cierra la topología prevista, no esos acontecimientos.
- No añadir habitaciones ni contactos narrativos para justificar esta conexión sin una decisión de guion separada.

## 5. Criterios de aceptación pendientes de prueba

| Prueba | Criterio observable |
|---|---|
| Ruta A | Jugadores nuevos visitan naturalmente el foso antes de operar el circuito, o explican por qué lo omitieron |
| Ruta B | Puede completarse sin bloqueo accidental; registrar retrocesos, errores y comprensión sin dar por hecho equivalencia con A |
| Plataforma | Transporte entre ambos rellanos, parada segura ante pérdida de energía y ninguna situación que atrape al jugador |
| Rearme | Se localiza sin confundirlo con selector/aislador; el contrato rechaza rearme con fallo presente y conserva last_trip |
| Indicador F | Se lee antes de consultar desde el lugar objetivo y no oculta ni prescribe la deducción |
| G | Desde el archivo se encuentra una salida clara hacia la esclusa sin volver a la entrada; los motivos narrativos son coherentes con guion aprobado |
| Espacio completo | Sin colisiones accidentales, saltos necesarios, pérdida de cámara ni obstrucción de rutas; ascensor y rampa se prueban por separado |

Registrar entorno y observaciones: versión de Godot, commit, resolución, renderer, dispositivo de entrada, secuencia exacta, fallos, ayudas y explicación del jugador. Distinguir inspección del documento, ejecución técnica y validación manual.

## 6. Límites

Estas decisiones cierran la intención de diseño, no certifican la geometría. No se ha ejecutado Godot. No se cambian código, escenas, rutas de recursos, autoloads, controles, contrato lógico, guardado ni esquema de persistencia. Si una decisión requiere cualquier cambio de esos contratos o no cabe en las envolventes existentes, detenerse y abrir revisión separada.

## 7. Historial v0.3

- A se fija como recorrido canónico previsto; B permanece como alternativa para prueba comparativa, no como secuencia recomendada.
- Se decide la función conceptual y reserva espacial de plataforma entre rellanos, pendiente de prototipo mecánico seguro.
- Se reserva el rearme junto a los controles, sin modificar posición ni comportamiento contractual de selector/aislador.
- Se decide un indicador local de suministro en F, integrado con el archivo y pendiente de prueba visual.
- Se fija la conexión espacial G desde el vestíbulo oeste de F; contenido/causa narrativa sigue pendiente de guion.
