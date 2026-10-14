# FINAL THAW — Fase 1: grafo espacial (v0.1)

Estado: DISEÑO PARA REVISIÓN. Revisión estática de documentos; no se ha ejecutado Godot ni validado ningún recorrido. No autoriza construcción, dimensiones nuevas, habitaciones nuevas ni cambios en `FASE1_LOGIC_CONTRACT.md`, guardado o escenas existentes.

Fuentes: `fase1_fase2_mapa_progresion.md` (v0.3), `FASE1_GREYBOX_SPEC.md`, `FASE1_LOGIC_CONTRACT.md`.

Convención: **[R]** = existe en la especificación del greybox. **[P]** = propuesta, no es una capacidad disponible. Distancias: longitud aproximada sobre las coordenadas del greybox (m), medida por la línea de recorrido; son estimaciones de diseño, no mediciones en escena. El ascensor sigue sin validar y la rampa es PROVISIONAL.

## 1. Nodos y aristas existentes [R]

| Nodo | Posición (m) | Nota |
|---|---|---|
| Entrada | (3,0,7) | Destino visible: cabina |
| Escalera directa rota | X 2..4, Z -3..3 | Bloqueada, solo inspección en (4,0,3); no es ruta |
| Ruta sur y pasillo oeste del foso | X 7..19.5 Z 5..7; X 17.5..19.5 Z 5..10 | Y=0 |
| Explanada de servicio | X 20..28, Z 8..12 | Y=0; boca de la escalera del foso en X 24..26 |
| Escalera del foso | (25,0,11) a (25,-2,8) | Salida fija; no depende de mantenimiento |
| Foso (callejón sin salida) | X 20..28, Z 1..8, Y=-2 | Esquema (27,-2,6), puente (22,-2,4), interruptor (26,-2,2) |
| Ruta este | X 28..30 | Une explanada y rellano inferior |
| Rellano inferior / ascensor | X 24..28, Z -1..1 / X 24.5..27.5, Z -4.5..-1.5 | Ascensor sin validar; rampa provisional X 31..33 |
| Rellano superior | X 24..28, Z -7..-4.5, Y=3 | |
| Pasarela pública | X 9..26, Z -8..-6, Y=3 | Selector (12,3,-7); aislador (19,3,-7); indicadores legibles desde (15,3,-7) |
| Cabina / archivo | X 2..9, Z -9..-5, Y=3 | Archivo (5,3,-7); entrada este (9,3,-7); terminal de diagnóstico en cabina |
| Atajo oeste | puerta (2,3,-7.5), escalera X 0..2 | Desbloqueo solo desde la cabina; llega a (1,0,1) |

Hallazgo: la boca de la escalera del foso queda en la explanada, sobre el camino que lleva a la ruta este y al ascensor. Cualquier jugador pasa junto al foso antes de llegar a los controles, aunque no baje.

## 2. Variante A: foso primero, circuito después

```text
Entrada -> ruta sur -> pasillo oeste -> explanada
   explanada -> escalera foso -> [foso: esquema, interruptor, puente] -> escalera (vuelta a explanada)
explanada -> ruta este -> rellano inferior -> ascensor [rampa provisional] -> rellano superior
   -> pasarela (selector, aislador, indicadores) -> entrada este -> cabina (archivo)
```

- Conexiones: todas [R].
- Distancias: entrada a cima de la escalera del foso ≈ 28 m; excursión al foso (escalera 3.6 m + pie a interruptor ≈ 7 m, a puente ≈ 11 m en total, y vuelta) ≈ 30 m; cima del foso a pasarela ≈ 25 m por ascensor o ≈ 31 m por rampa provisional.
- Información disponible: al llegar a los controles, el jugador ya ha visto esquema, puente e interruptor.
- Revisitas: ninguna sobre tramos largos. El foso es una excursión corta de ida y vuelta junto al camino principal, que es un callejón sin salida por diseño.

## 3. Variante B: circuito primero, foso después

```text
Entrada -> ruta sur -> pasillo oeste -> explanada -> ruta este -> rellano inferior
   -> ascensor [rampa] -> rellano superior -> pasarela (controles) -> cabina (archivo)
   vuelta al foso: A) pasarela -> rellano superior -> ascensor -> rellano inferior -> ruta este -> explanada -> escalera foso
                   B) cabina -> atajo oeste -> (1,0,1) -> ruta sur -> pasillo oeste -> explanada -> escalera foso
   después del foso: el mismo camino de vuelta hasta la pasarela
```

- Conexiones: todas [R]. No hace falta ninguna conexión nueva.
- Distancias hasta la cima del foso: desde los controles por ascensor ≈ 32 m; desde la cabina por el atajo ≈ 45 m. Regreso a los controles ≈ 25 m por ascensor hasta la pasarela, más 7–14 m hasta selector o aislador.
- Información disponible antes del foso: indicadores de la pasarela y terminal de la cabina; no el esquema ni el puente. La deducción se apoya en indicadores y etiquetas. Probar el circuito sin haber visto el foso puede provocar disparos, recuperables localmente.
- Revisitas: ≈ 70 m adicionales por tramos ya recorridos (explanada, ruta este, rellano, ascensor) y dos viajes de ascensor, o el doble de cruces por rampa provisional.
- Dependencia técnica: B cruza el ascensor tres veces; A lo cruza una. El ascensor está sin validar.

## 4. Comparación

| Criterio | Variante A | Variante B |
|---|---|---|
| Conexiones nuevas necesarias | Ninguna | Ninguna |
| Interruptor alcanzable sin depender de E | Sí | Sí |
| Revisita larga | No | ≈ 70 m + 2 viajes de ascensor |
| Cruces del ascensor (sin validar) | 1 | 3 |
| Pistas del foso antes de operar el circuito | Sí | No |
| Orden natural por el recorrido | Sí: la boca del foso está en el camino | No: exige pasar de largo |

Decisión de diseño propuesta, para revisión: A es el orden previsto y B queda permitido como orden alternativo con coste de retorno asumido. No se añade ninguna estructura para reducir ese coste. Si en pruebas con jugadores B resulta frecuente y penaliza, se abrirá una decisión aparte sobre una conexión nueva, con medición del retorno.

## 5. Comprobaciones puntuales

### 5.1 Interruptor de mantenimiento (D)

- Posición en el greybox: (26,-2,2). Pie de la escalera: (25,-2,8). Separación horizontal ≈ 6 m en línea recta, ≈ 7 m por el recorrido que pasa por el punto del esquema.
- Corrección de redacción: el documento v0.3 lo describe «junto al acceso inferior del foso». Redacción propuesta: «interruptor en el recorrido del foso, a ≈ 6 m al norte del pie de la escalera fija». No se mueve en el greybox.
- Alcance: se llega a pie desde el pie de la escalera por el suelo del foso (Y=-2). La salida por escalera fija no depende de mantenimiento.
- Punto de acción seguro: área de observación de 2×2 m del greybox.
- Falta definir la plataforma: la especificación del greybox no la ubica. No se puede verificar que «mantenimiento habilita la plataforma» sin saber a qué da acceso. Queda como decisión abierta.
- Iluminación: las luces de servicio dependen de ese interruptor. El interruptor y la ruta hasta él deben ser visibles sin esas luces, mediante iluminación ambiental mínima o un indicador propio. Es un requisito visual, no cambia el contrato.

### 5.2 Indicador del archivo (F)

- Estado actual del greybox: indicadores del circuito en la pasarela, legibles desde (15,3,-7), a ≈ 10 m del archivo. Terminal de diagnóstico en la cabina, siempre accesible.
- Corrección al documento de progresión: v0.3 habla de «el diagnóstico completo de E»; en el greybox el terminal de diagnóstico está en la cabina. E aporta indicadores físicos y los controles. Debe alinearse la redacción con el greybox.
- [P] Indicador local de suministro en el punto de consulta del archivo (5,3,-7), con dos estados: suministro estable y no disponible. Lectura derivada de «archivo estable» del contrato. No indica qué control accionar. No sustituye el terminal ni los indicadores de la pasarela.
- [P] Posición a verificar con la cámara real: el archivo está en el mismo eje Z=-7 que la entrada este (9,3,-7). Un indicador visible por esa apertura permitiría leerlo desde la pasarela sin entrar.
- Esto añade un elemento visual, no una habitación ni un cambio de contrato.

### 5.3 Conexiones D–E y recuperación local

- Entrada al foso: escalera fija (25,0,11) a (25,-2,8) [R].
- Salida fija local al nivel principal: la misma escalera, de vuelta a la explanada [R]. El foso es un callejón sin salida, no una ruta intermedia.
- Conexión hacia el circuito: explanada, ruta este, rellano inferior, ascensor (o rampa provisional), pasarela [R]. Esta conexión es indirecta, ≈ 25 m desde la cima del foso.
- Recuperación de un fallo del circuito: ocurre en la pasarela, entre selector y aislador (7 m entre ambos). El disparo queda visible en los indicadores de la pasarela. El terminal completo está a 7 m del selector y 14 m del aislador.
- Falta ubicar el rearme: el contrato define la operación de rearme, pero el greybox no sitúa ningún control de rearme. [P] Colocarlo en la pasarela, junto a selector y aislador, para que corregir un fallo no obligue a ir al archivo. Decisión abierta.

### 5.4 Salida de F hacia G

- El greybox no ubica G ni H. La única salida de F distinta de la pasarela es el atajo oeste hasta (1,0,1).
- [P] La esclusa podría conectar con ese rellano o con la zona de la entrada. No se decide aquí; depende del guion.

## 6. Criterios de aceptación del grafo

| Criterio | Estado |
|---|---|
| Llegar al interruptor sin depender del circuito de recuperación | Cumple en el greybox (escalera fija y suelo del foso). Pendiente de visibilidad sin luces de servicio |
| Saber si el archivo tiene suministro antes de consultar | Parcial. Necesita el indicador local [P] |
| Corregir un fallo del circuito localmente | Parcial. Falta ubicar el rearme [P] |
| No retroceder largos tramos | Cumple en A. B tiene un retorno ≈ 70 m aceptado como coste |
| Sin dependencias narrativas o técnicas no aprobadas | Pendientes: plataforma, rearme, indicador F, esclusa G, ascensor sin validar |

## 7. Decisiones abiertas

1. Aceptar A como orden previsto y B como alternativa con coste.
2. Ubicación y función de la plataforma.
3. Ubicación del control de rearme.
4. Indicador local de F y su posición visible.
5. Alinear la redacción del documento de progresión: ubicación del interruptor, terminal de diagnóstico en la cabina y nota de resumen de correcciones.
6. Punto de conexión de G (guion).

Ninguna de estas decisiones exige cambiar `FASE1_LOGIC_CONTRACT.md`, el guardado o las escenas existentes. Si una la exige, se documenta como decisión separada.
