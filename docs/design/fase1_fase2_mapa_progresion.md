# FINAL THAW — Fases 1 y 2: mapa de progresión verificable (v2.0 · misión rediseñada)

**Estado:** propuesta de misión y progresión. No describe todavía una secuencia implementada. El runtime actual debe consultarse en [FASE1_PREMIUM_AUDIT.md](FASE1_PREMIUM_AUDIT.md).

## 1. Principio de misión

La Fase 1 es una investigación espacial dentro de un edificio industrial aparentemente abandonado que sirve de cobertura para una instalación clandestina adyacente. Ambos edificios están conectados por una puerta de seguridad sellada que Elena abrirá al reunir los elementos y restablecer los sistemas necesarios. El jugador no recibe una lista de controles; observa indicios, formula una hipótesis, prueba una acción y lee el cambio del entorno. Las salas secundarias hacen que el lugar parezca usado y parcialmente desconocido. No todo objeto es una pista, no toda pista es obligatoria y no toda puerta se abre durante esta misión.

## 2. Cadena crítica

| Paso | Lugar | Acción del jugador | Evidencia / respuesta | Dependencia |
|---|---|---|---|---|
| 1 | Brecha de Elena | Entrar por el conducto de servicio | El acceso se derrumba después de entrar y bloquea físicamente el retorno. Es distinto del acceso antiguo al pasillo principal que aparece en el plano. | Ninguna |
| 2 | Nave P0 | Orientarse y ver el ascensor apagado | Núcleo visible, indicadores sin energía | Paso 1 |
| 3 | Archivo de turno | Comparar pizarra y tira de presión | Dos indicios convergen en una regla para el código del cajón | Paso 1 |
| 4 | Despacho | Introducir el código deducido | Cajón se abre con animación y sonido; contiene llave de servicio y puente aislado | Paso 3 |
| 5 | Exploración P−2 | Localizar subestación y examinar terminales | Puerta cerrada por llave; se ve el hueco del puente tras abrirla | Paso 4 para abrir; antes se puede descubrir la puerta |
| 6 | Subestación | Usar la llave, insertar el puente y activar el seccionador | Relés, zumbido, luces por circuitos y bombas auxiliares | Paso 4 |
| 7 | Vestíbulo del ascensor | Solicitar ascensor | Se activa el indicador, se oye el mecanismo y las puertas operan | Paso 6 |
| 8 | M / P+3 | Subir y explorar la zona restringida | Contexto de la instalación y señales de peligro creciente | Paso 7 |
| 9 | Puerta de conexión sellada | Abrir la puerta entre ambos edificios | Tras completar la cadena de objetos y energía, Elena abre el umbral y descubre que al otro lado hay una instalación activa donde los antagonistas trabajan clandestinamente. Es el cierre de esta fase y la entrada narrativa a la siguiente. | Paso 8 |

## 3. Pistas y puzle del cajón

El código debe derivarse de información visible en el entorno, no de una secuencia elegida solo porque resulte cómoda de implementar. La pizarra de turnos indica la secuencia de comprobación B → D → A → C. La tira de presión muestra las últimas cifras estables: A=3, B=0, C=7, D=4. El jugador debe leer las cifras siguiendo el orden de la pizarra y obtiene 0437. Una nota opcional del taller recuerda que debe seguirse el orden de prueba, sin mostrar la secuencia ni el resultado. No se entrega el código en un texto narrativo.

La solución se considera justa si un jugador puede explicar que combinó el orden B → D → A → C con las cifras finales de la tira. Si se adivina por ensayo, hay que revisar la visibilidad de los datos o el feedback del cajón. No incluir una pantalla de texto que entregue la respuesta.

## 4. Energía, luces y ascensor

El jugador sigue la bandeja de cables desde la maquinaria del ascensor hasta la subestación y encuentra el terminal LIFT AUX con el puente ausente. El puente aislado tiene un conector y una forma que coinciden con ese hueco; otros bornes están cubiertos o no tienen la geometría compatible. El panel debe mostrar la conexión físicamente y el seccionador queda bloqueado hasta insertar el puente. No exigir conocimientos eléctricos reales ni permitir que un clic genérico cambie el estado sin animación. Tras el restablecimiento:
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

La transición principal a la siguiente fase se realiza a través de la puerta sellada que conecta el edificio aparentemente abandonado con el edificio donde trabajan clandestinamente los antagonistas. No sustituir este umbral por una salida de emergencia genérica. La localización exacta de la puerta y el recorrido hasta ella deben quedar coordinados en planta, sección y grafo antes de implementar el greybox. La Fase 2 mantiene su propuesta de escape humano/híbrido: descubrir presencia humana, elegir rutas, ser detectada, afrontar obstáculos y persecución, llegar al garaje y salir a la calle. El diseño del aparcamiento existente se conserva como material de partida, pero requiere integración real con el recorrido y prueba de juego.

## 7. Criterios de aceptación

- El código del cajón se puede deducir de dos indicios y no se entrega en el texto.
- La llave abre la puerta correcta y el puente resuelve el corte de energía; no se puede saltar la dependencia.
- El jugador puede descubrir la subestación y el ascensor antes de tener los objetos, sin softlock.
- El cambio eléctrico se ve y se oye, y el ascensor queda operativo únicamente después.
- Dos salas opcionales se pueden explorar sin objeto crítico y al menos una ofrece una recompensa opcional clara.
- Tres jugadores nuevos pueden describir la deducción del cajón y la causa de la activación del ascensor después de jugar.
- Todos los criterios de juego requieren prototipo y QA; los documentos no son evidencia de ejecución.
