# FINAL THAW — Fases 1 y 2: mapa de progresión verificable (v0.5)

Estado: DISEÑO ACTUALIZADO; decisiones espaciales conceptuales tomadas, validación en Godot pendiente. No autoriza construcción final ni ampliación del escenario. No inventar hechos marcados PENDIENTE DE GUION.

## 1. Intención y límites

- Fase 1: Elena explora una instalación que no comprende, investiga sus anomalías y accede al archivo.
- Fase 2: Elena utiliza lo aprendido para escapar al exterior y sobrevivir a una amenaza.
- Dos experiencias conectadas: **comprender y después sobrevivir**.
- No se fija un número de habitaciones; cada espacio necesita una función verificable.
- Se conserva el núcleo existente de sala de ensayo, máquina central, foso, circuito y archivo.
- Este documento es diseño; las decisiones espaciales aquí fijadas no certifican dimensiones, colisiones, cámara, ascensor, rampa ni recorrido.

## 2. Decisiones espaciales cerradas conceptualmente

La autoridad espacial detallada es `FASE1_SPATIAL_GRAPH.md` v0.3. Las siguientes son decisiones de diseño [D], no elementos ya construidos:

1. **Orden:** A es el recorrido canónico previsto: foso antes de operar el circuito. B continúa físicamente posible como variante de prueba, pero no se asume que produzca la misma comprensión. No se construirá una conexión nueva para acortar B sin resultados de playtest y desglose de recorrido.
2. **Plataforma:** reserva conceptual en el anexo X=30..34, entre rellano inferior y superior. Función única: transporte vertical; no desbloquea una sala. El interruptor de mantenimiento la habilita. La pérdida de alimentación debe producir una parada segura, sin caída ni jugador atrapado; si se mueve, debe completar una parada controlada en el rellano alcanzable más cercano. Esto requiere prototipo y prueba por separado.
3. **Rearme:** interacción en la pasarela, entre selector y aislador, colocada sin invadir su área de uso ni reducir el paso. No mueve las coordenadas de los controles ni modifica la lógica del contrato.
4. **Indicador local de F:** integrado en el mueble/zona del archivo (5,3,-7), mirando hacia la entrada este/pasarela; muestra «suministro estable» o «no disponible» con texto/símbolo redundante, no solo color. Debe probarse su lectura desde la pasarela y junto al archivo.
5. **Conexión F→G:** la esclusa G se conecta al vestíbulo oeste de la cabina, desde donde se transita al exterior H. El atajo sigue desbloqueándose desde la cabina y pasa a ser bidireccional después. La causa narrativa, la detección de Helix y el destino de Elena siguen PENDIENTE DE GUION.
6. **Validación:** ascensor y rampa se prueban por separado. Después se prueban colisiones, ancho libre, línea de visión, cámara e indicadores; registrar entorno y observaciones antes de afirmar aceptación.

## 3. Grafo de conexiones

Ruta canónica prevista:

A Acceso y recepción → B Observación → C Nave de ensayo → D Servicios y foso → E Distribución y control → F Archivo → G Esclusa → H Primer encuentro exterior.

La ruta física concreta de A/B y las reservas espaciales están en `FASE1_SPATIAL_GRAPH.md` v0.3. La cifra anterior de ≈70 m para el retorno de B no está validada y no es criterio de aceptación hasta contar con desglose reproducible por arista. La variante B debe evaluarse con participantes que no conozcan el diseño.

Reglas:
- La salida del foso es la misma escalera fija; no depende de mantenimiento.
- El fallo del circuito debe poder corregirse localmente en E.
- No se añaden llaves, fusibles, tarjetas ni habitaciones para prolongar el recorrido.
- Una pista opcional puede enriquecer la lectura, pero no bloquea una acción deducible.
- La consulta del archivo no es extracción, autorización ni activación automática de Helix.

## 4. Sectores funcionales

| Sector | Función | Salida / dependencia | Estado |
|---|---|---|---|
| A. Acceso y recepción | Orientar y mostrar un destino inicial | Hacia B | Función provisional |
| B. Observación | Permitir observación previa del núcleo | Hacia C | Función provisional; contenido PENDIENTE DE GUION |
| C. Nave de ensayo | Máquina central y anomalías verificables | Hacia D/E según orden del recorrido | Núcleo existente; integración por validar |
| D. Servicios y foso | Observar esquema, puente e interruptor por separado | Salida fija por la escalera; vuelta a explanada | Ubicación del interruptor en (26,-2,2); visibilidad sin luces pendiente de prueba |
| E. Distribución y control | Probar hipótesis sobre el circuito | Controles locales, ruta hacia F | Rearme reservado entre selector y aislador; posición constructiva por validar |
| F. Archivo | Consultar información cuando el suministro sea estable | A G por vestíbulo oeste, sin regresar a la entrada | Indicador local decidido conceptualmente; visibilidad por validar. Contenido PENDIENTE DE GUION |
| G. Esclusa | Umbral espacial entre investigación y exterior | Desde F hacia H | Conexión decidida; desencadenante y respuesta de Helix PENDIENTE DE GUION |
| H. Primer encuentro exterior | Probar detección, elección de ruta y ruptura de línea de visión | Continuación al objetivo inmediato, PENDIENTE DE GUION | Prototipo pequeño antes de expandir |

No asignar cotas ni habitaciones adicionales hasta que cada ficha espacial demuestre su necesidad.

## 5. Reglas de circuito y archivo

- El contrato de referencia es `FASE1_LOGIC_CONTRACT.md`; este mapa no redefine sus estados ni operaciones.
- Los indicadores físicos de E reflejan señales locales del circuito. El terminal de diagnóstico completo está en la cabina F, siempre accesible aunque se pierda la alimentación de recuperación.
- El terminal presenta estado actual y último disparo por separado; no recomienda qué control accionar.
- El indicador local de F muestra solo suministro estable/no disponible, antes de consultar. No sustituye terminal o indicadores de E.
- Consultar solo es posible con suministro estable. El conocimiento adquirido en la sesión no se pierde por la interrupción de alimentación.
- La maquinaria permanece bloqueada en este hito.
- La interacción de rearme debe respetar exactamente el contrato lógico: no rearma por cambiar selector o aislador, y solo tiene éxito cuando el fallo ya no está presente.

## 6. Fase 2: encuentro de referencia

No construir todavía toda la huida exterior. Prototipar un encuentro corto:
1. Detectar la amenaza y comprender el peligro.
2. Elegir entre una ruta expuesta/directa y otra con cobertura.
3. Romper línea de visión mediante la geometría, no solo velocidad.
4. Alcanzar una posición nueva y reorientarse al objetivo inmediato.

El desencadenante, qué detecta Helix, qué percibe Elena, destino, naturaleza de la amenaza y condiciones ambientales continúan PENDIENTE DE GUION. No crear hechos narrativos para justificar la geometría.

## 7. Guardado y contratos técnicos

- No añadir guardado intermedio ni checkpoints en este prototipo.
- No añadir estado de circuito, conocimiento o sector al formato de guardado.
- No cambiar escenas existentes, rutas de recursos, autoloads, controles, renderer Compatibility ni contrato de guardado.
- Si una decisión requiere cambiar cualquiera de esos contratos, detenerse y abrir una revisión separada de compatibilidad.

## 8. Pruebas de aceptación pendientes

| Prueba | Criterio observable |
|---|---|
| Ruta A | Jugadores nuevos inspeccionan el foso antes de operar el circuito, o explican por qué lo omitieron |
| Ruta B | Ruta completada sin bloqueo; registrar revisitas, errores e interpretación sin asumir equivalencia con A |
| Plataforma | Viaje entre ambos rellanos; pérdida de alimentación no provoca caída ni atrapamiento; llamadas desde ambos extremos |
| Rearme | El jugador lo localiza sin confundirlo con selector/aislador; reglas y `last_trip` respetan el contrato |
| Indicador de F | Se lee antes de consultar desde pasarela y junto al archivo, con iluminación y cámara reales |
| Conexión G | Desde F se encuentra la salida sin volver a la entrada; el guion aprobado motivará la transición |
| Recorrido completo | Sin colisiones accidentales, saltos obligatorios, pérdida de cámara o paso bloqueado; ascensor y rampa probados separadamente |
| Comprensión | Jugadores nuevos explican qué observaron, qué infirieron y por qué su acción produce el resultado |

Registrar versión de Godot, commit, resolución, renderer, dispositivo, secuencia de prueba, fallos, ayudas y explicaciones. Distinguir inspección documental, ejecución técnica y validación manual. El oráculo Python no sustituye las pruebas GDScript del contrato.

## 9. Decisiones narrativas aún pendientes

| Decisión | Qué falta | Qué bloquea |
|---|---|---|
| Evidencia consultada en F | Qué consulta Elena, qué concluye y qué permanece incierto | Contenido definitivo del archivo |
| Respuesta de Helix | Hecho desencadenante y percepción de Elena | Evento narrativo en G |
| Destino exterior | Objetivo inmediato plausible | Objetivo de H y orientación de Fase 2 |
| Contactos, voces o registros | Quién comunica y qué sabe | Narrativa ambiental dependiente de ellos |
| Condiciones del exterior | Momento, clima y estado físico | Arte o geometría que dependan de ello |

## 10. Historial v0.5

- Se adopta A como recorrido canónico previsto y B como variante posible de prueba comparativa, no como secuencia recomendada.
- Se fija conceptualmente plataforma, rearme, indicador de F y conexión espacial de G.
- Ninguna de estas decisiones constituye prueba de escena ni autoriza implementar aún la progresión final.
