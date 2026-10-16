# FINAL THAW — Fases 1 y 2: mapa de progresión verificable (v2.0 · misión rediseñada)

**Estado:** propuesta de misión y progresión. No describe todavía una secuencia implementada. El runtime actual debe consultarse en [FASE1_PREMIUM_AUDIT.md](FASE1_PREMIUM_AUDIT.md).

## 1. Principio de misión

La Fase 1 es una investigación espacial dentro de una instalación mucho mayor. El jugador no recibe una lista de controles; observa indicios, formula una hipótesis, prueba una acción y lee el cambio del entorno. Las salas secundarias hacen que el lugar parezca usado y parcialmente desconocido. No todo objeto es una pista, no toda pista es obligatoria y no toda puerta se abre durante esta misión.

## 2. Cadena crítica

| Paso | Lugar | Acción del jugador | Evidencia / respuesta | Dependencia |
|---|---|---|---|---|
| 1 | Entrada colapsada | Entrar por el conducto | Derrumbe bloquea el regreso; objetivo de encontrar otra salida | Ninguna |
| 2 | Nave P0 | Orientarse y ver el ascensor apagado | Núcleo visible, indicadores sin energía | Paso 1 |
| 3 | Archivo de turno | Comparar pizarra y tira de presión | Dos indicios convergen en una regla para el código del cajón | Paso 1 |
| 4 | Despacho | Introducir el código deducido | Cajón se abre con animación y sonido; contiene llave de servicio y puente aislado | Paso 3 |
| 5 | Exploración P−2 | Localizar subestación y examinar terminales | Puerta cerrada por llave; se ve el hueco del puente tras abrirla | Paso 4 para abrir; antes se puede descubrir la puerta |
| 6 | Subestación | Usar la llave, insertar el puente y activar el seccionador | Relés, zumbido, luces por circuitos y bombas auxiliares | Paso 4 |
| 7 | Vestíbulo del ascensor | Solicitar ascensor | Se activa el indicador, se oye el mecanismo y las puertas operan | Paso 6 |
| 8 | M / P+3 | Subir y explorar la zona restringida | Contexto de la instalación y señales de peligro creciente | Paso 7 |
| 9 | Salida de emergencia | Alcanzar el acceso a Fase 2 | La huida se inicia desde un espacio conectado, no desde un corte arbitrario | Paso 8 |

## 3. Pistas y puzle del cajón

El código debe derivarse de información visible en el entorno, no de una secuencia elegida solo porque resulte cómoda de implementar. La pizarra muestra el orden de comprobación de las bombas; la tira de presión registra el valor estable de la prueba. El jugador usa la regla que aparece en la propia pizarra para convertir la lectura en el código. La pista no muestra el código final explícitamente.

La solución se considera justa si un jugador puede explicar qué dos datos combinó. Si en el playtest se adivina por ensayo, el puzle necesita revisión. No incluir una pantalla de texto que entregue la respuesta.

## 4. Energía, luces y ascensor

El puente aislado se reconoce por su forma y por las etiquetas físicas de los dos terminales. El panel debe tener un hueco real y legible; la acción correcta conecta el circuito visualmente. No usar una interacción genérica que cambie el estado sin animación. Tras el restablecimiento:
- los relés hacen clic y el transformador adquiere un zumbido de banda media;
- varias líneas de luz recorren la instalación;
- se encienden luces de emergencia y luminarias seleccionadas, pero algunas permanecen rotas;
- las bombas auxiliares arrancan con vibración visible;
- el indicador del ascensor cambia y las puertas realizan un ciclo de comprobación.

El cambio no debe encender cada luz de golpe ni eliminar toda la oscuridad: el contraste sirve a la legibilidad y a la tensión.

## 5. Descubrimientos opcionales

- Sala de espera: objetos abandonados y señal de una evacuación precipitada; sin objeto crítico.
- Taller de instrumentos: una nota visual opcional que explica por qué hay dos terminales en la subestación.
- Anexo oscurecido del mezzanine: atmósfera y posible ventaja opcional, sin llave obligatoria.
- Laboratorio sellado de P+3: anticipación narrativa; no abrirlo en esta misión si requiere una cadena nueva de llaves.

El objetivo es que algunas salas no signifiquen nada para el progreso inmediato. Deben seguir teniendo coherencia ambiental y no parecer un error.

## 6. Puente a Fase 2

La salida de emergencia de P+3 conduce al tramo de transición previsto para Fase 2. La Fase 2 mantiene su propuesta de escape humano/híbrido: descubrir presencia humana, elegir rutas, ser detectada, afrontar obstáculos y persecución, llegar al garaje y salir a la calle. El diseño del aparcamiento existente se conserva como material de partida, pero requiere integración real con el recorrido y prueba de juego.

## 7. Criterios de aceptación

- El código del cajón se puede deducir de dos indicios y no se entrega en el texto.
- La llave abre la puerta correcta y el puente resuelve el corte de energía; no se puede saltar la dependencia.
- El jugador puede descubrir la subestación y el ascensor antes de tener los objetos, sin softlock.
- El cambio eléctrico se ve y se oye, y el ascensor queda operativo únicamente después.
- Dos salas opcionales se pueden explorar sin objeto crítico y al menos una ofrece una recompensa opcional clara.
- Tres jugadores nuevos pueden describir la deducción del cajón y la causa de la activación del ascensor después de jugar.
- Todos los criterios de juego requieren prototipo y QA; los documentos no son evidencia de ejecución.
