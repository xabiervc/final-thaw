# FINAL THAW — Fases 1 y 2: mapa de progresión verificable (v2.1 · transferencia en P−2)

**Estado:** contrato de progresión acordado para prototipado; todavía no implementado ni validado en runtime. El runtime construido se describe en [FASE1_PREMIUM_AUDIT.md](FASE1_PREMIUM_AUDIT.md).

## 1. Principio de misión

La Fase 1 es una investigación espacial dentro de un edificio industrial aparentemente abandonado que sirve de cobertura para una instalación clandestina adyacente. Ambos edificios están conectados por una puerta de transferencia oculta en el muro oriental del taller muerto de P−2. Elena puede descubrirla antes de tener la llave o restaurar la energía, pero solo puede cruzarla cuando la llave de transferencia independiente y la alimentación necesaria estén disponibles. El jugador no recibe una lista de controles; observa indicios, formula una hipótesis, prueba una acción y lee el cambio del entorno. Las salas secundarias hacen que el lugar parezca usado y parcialmente desconocido. No todo objeto es una pista, no toda pista es obligatoria y no toda puerta se abre durante esta misión.

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
| 8 | M / P+3 (opcional para la transición) | Subir y explorar las alas superiores | Contexto de la instalación y señales de peligro creciente; el ascensor no es un requisito para descubrir el umbral de P−2 | Paso 7 si se decide subir |
| 9 | Taller muerto, P−2 | Investigar la franja limpia, marcas de arrastre y corriente de aire | Inspección revela un panel oculto y una puerta de transferencia bloqueada | Acceso a P−2 |
| 10 | Taller muerto | Leer la nota de mantenimiento | La nota indica que la llave de transferencia se guardó en el armario seco del almacén tras una fuga | Paso 9, aunque el jugador puede haber explorado el almacén antes |
| 11 | Almacén de repuestos, P−2 | Buscar el armario seco elevado sobre la marca de humedad | El símbolo del armario coincide con el de la puerta; se obtiene la llave de transferencia | Paso 10 como pista; el armario puede encontrarse antes |
| 12 | Puerta oculta, P−2 | Usar la llave de transferencia con la alimentación restablecida | Se abre el umbral y se revela el vestíbulo técnico de un segundo edificio activo, con maquinaria, luces de trabajo y señales recientes de operación clandestina | Pasos 6 y 11; ambas cadenas deben completarse |

## 3. Pistas y puzle del cajón

El código debe derivarse de información visible en el entorno, no de una secuencia elegida solo porque resulte cómoda de implementar. La pizarra de turnos indica la secuencia de comprobación B → D → A → C. La tira de presión muestra las últimas cifras estables: A=3, B=0, C=7, D=4. El jugador debe leer las cifras siguiendo el orden de la pizarra y obtiene 0437. Una nota opcional del taller recuerda que debe seguirse el orden de prueba, sin mostrar la secuencia ni el resultado. No se entrega el código en un texto narrativo.

La solución se considera justa si un jugador puede explicar que combinó el orden B → D → A → C con las cifras finales de la tira. Si se adivina por ensayo, hay que revisar la visibilidad de los datos o el feedback del cajón. No incluir una pantalla de texto que entregue la respuesta.

## 4. Cadena independiente de transferencia clandestina

La progresión del umbral no es una extensión de la cadena eléctrica: son dos cadenas paralelas que convergen al final.

- **Energía:** SERVICE_KEY + INSULATED_BRIDGE → subestación operativa → PowerRestored → luces parciales, bombas auxiliares y ascensor.
- **Transferencia:** indicios del taller muerto → panel/puerta descubiertos → nota de mantenimiento → armario seco en almacén → TRANSFER_KEY.
- **Convergencia:** TRANSFER_KEY + PowerRestored → apertura de la puerta oculta de P−2 → vestíbulo técnico del edificio clandestino.

La llave de servicio no abre la puerta oculta. La llave de transferencia no abre la subestación ni completa el circuito. El jugador puede investigar estas rutas en distinto orden; no se bloquea la exploración por descubrir una puerta demasiado pronto.

## 5. Energía, luces y ascensor

El jugador sigue la bandeja de cables desde la maquinaria del ascensor hasta la subestación y encuentra el terminal LIFT AUX con el puente ausente. El puente aislado tiene un conector y una forma que coinciden con ese hueco; otros bornes están cubiertos o no tienen la geometría compatible. El panel debe mostrar la conexión físicamente y el seccionador queda bloqueado hasta insertar el puente. No exigir conocimientos eléctricos reales ni permitir que un clic genérico cambie el estado sin animación. Tras el restablecimiento:
- los relés hacen clic y el transformador adquiere un zumbido de banda media;
- varias líneas de luz recorren la instalación;
- se encienden luces de emergencia y luminarias seleccionadas, pero algunas permanecen rotas;
- las bombas auxiliares arrancan con vibración visible;
- el indicador del ascensor cambia y las puertas realizan un ciclo de comprobación.

El cambio no debe encender cada luz de golpe ni eliminar toda la oscuridad: el contraste sirve a la legibilidad y a la tensión.

## 6. Descubrimientos opcionales

- Sala de espera: objetos abandonados y señal de una evacuación precipitada; sin objeto crítico.
- Taller de instrumentos: una nota visual opcional que explica por qué hay dos terminales en la subestación.
- Anexo oscurecido del mezzanine: atmósfera y posible ventaja opcional, sin llave obligatoria.
- Laboratorio sellado de P+3: anticipación narrativa; no abrirlo en esta misión si requiere una cadena nueva de llaves.

El objetivo es que algunas salas no signifiquen nada para el progreso inmediato. Deben seguir teniendo coherencia ambiental y no parecer un error.

## 7. Puente a Fase 2

La transición principal a la siguiente fase se realiza a través de la puerta oculta de P−2, en el muro oriental del taller muerto, que conduce al vestíbulo técnico del edificio donde trabajan clandestinamente los antagonistas. No sustituir este umbral por P+3, el ascensor o una salida de emergencia genérica. La Fase 2 mantiene su propuesta de escape humano/híbrido: descubrir presencia humana, elegir rutas, ser detectada, afrontar obstáculos y persecución, llegar al garaje y salir a la calle. El diseño del aparcamiento existente se conserva como material de partida, pero requiere integración real con el recorrido y prueba de juego.

## 8. Criterios de aceptación

- El código del cajón se puede deducir de dos indicios y no se entrega en el texto.
- La llave de servicio abre solo la subestación; el puente resuelve el corte de energía; la llave de transferencia abre solo la puerta oculta. No se puede saltar ninguna dependencia.
- El jugador puede descubrir la subestación, el ascensor y la puerta oculta antes de tener los objetos, sin softlock.
- El cambio eléctrico se ve y se oye, y el ascensor queda operativo únicamente después.
- Dos salas opcionales se pueden explorar sin objeto crítico y al menos una ofrece una recompensa opcional clara.
- Tres jugadores nuevos pueden describir la deducción del cajón y la causa de la activación del ascensor después de jugar.
- Todos los criterios de juego requieren prototipo y QA; los documentos no son evidencia de ejecución.
