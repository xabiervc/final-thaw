# FASE1 — Especificación funcional de implementación (v1.1)

**Estado:** decisiones de diseño y comportamiento cerradas para construir el primer slice. Las pruebas de escena, cámara, colisiones y jugabilidad siguen pendientes; este documento no afirma validación en Godot.  
**Autoridad funcional:** este documento define la experiencia de Fase 1; el contrato lógico define las reglas del circuito; la arquitectura espacial y el greybox definen su geometría. Autoridad espacial: FASE1_ARCHITECTURAL_LAYOUT.md v1.1, FASE1_SPATIAL_GRAPH.md v0.7 y FASE1_GREYBOX_SPEC.md v1.4.

## 1. Objetivo jugable

Elena debe reconocer una discrepancia física en la distribución eléctrica, poner el circuito en una configuración segura que permita consultar el archivo y salir de la instalación. La máquina de ensayo nunca arranca. La amenaza exterior pertenece a Fase 2 y empieza cuando el controlador de salida sincroniza el registro de mantenimiento.

La experiencia se basa en inferencia ambiental, no en una secuencia arbitraria de interruptores. El jugador puede operar el circuito sin leer cada pista: las pistas explican el problema, pero no son llaves para los controles.

## 2. Recorrido definitivo

1. Entrada A en P0: observar la nave B y la columna vertical de calibración Aster.
2. Rodear el rig hasta la escalera fija S1.
3. Bajar a D (Y=−2 m); comparar esquema y puente A→T y activar mantenimiento.
4. Volver por S1 y llegar por la galería de servicio al elevador.
5. Subir desde P0 (Y=0) a M, sala de bombas (Y=+1,5 m). El elevador termina aquí, no en control.
6. Cruzar M y la galería de observación; subir por S2 a E/P2 (Y=+3 m).
7. Operar el circuito en E, consultar F con suministro estable, atravesar G y salir a H.

La escalera directa P0→P2 está colapsada y bloqueada. G no contiene escalera de retorno a P0. Las salas explican la infraestructura; no se exige leer todas las pistas para que funcionen los controles.

## 3. Plataforma elevadora y mantenimiento

- **Paradas de misión:** P0 Y=0 y M Y=+1,5 m; huella X=24,5..27,5, Z=−4,5..−1,5.
- **Inicialización:** deck acoplado abajo; mantenimiento apagado. No se guarda estado del elevador.
- **Uso normal:** llamada desde ambos rellanos, solo con mantenimiento activo. A 1,2 m/s, los 1,5 m de movimiento duran aprox. 1,25 s, más espera de puertas.
- **Mantenimiento OFF:** si está acoplado permanece quieto y rechaza llamadas.
- **Pérdida de energía en movimiento:** la reserva de seguridad lleva el deck a la parada más cercana a velocidad reducida; empate exacto elige M (+1,5 m). Nunca cae ni deja a Elena entre niveles.
- S1 es la escalera fija P0↔P−1, usable sin electricidad. S2 conecta M↔P2 y no depende de alimentación.

La rampa provisional y el anexo X=30..34 quedan eliminados. El componente service_lift.gd conserva sus tests genéricos de 3 m; la instancia de misión usa upper_y=1.5 y debe tener prueba de integración específica.

## 4. Contrato del circuito aplicado a la experiencia

Estado inicial: mantenimiento OFF; selector ENSAYO; ensayo conectado; protección disponible; last_trip vacío; diagnóstico siempre operativo.

- El esquema muestra la distribución prevista: ARCHIVO hacia A y ENSAYO hacia T.
- El puente físico A→T está manipulado y constituye la anomalía. **Escáner cerrado para implementación:** mantener `scan` durante 0,9 s; revelar durante 3 s y aplicar 4 s de recarga desde la activación. Durante la ventana se resaltan esquema/A, el puente A→T y el nodo T; se ocultan al terminar. El escáner revela continuidad, nunca resalta el selector, aislador o rearme ni prescribe una acción.
- El orden recomendado y más seguro es aislar ENSAYO, seleccionar ARCHIVO y comprobar el estado. Resultado esperado: ARCHIVO estable y protección disponible.
- Si el jugador selecciona ARCHIVO con ENSAYO conectado, la protección dispara inmediatamente y registra DEMANDA_SIMULTANEA. No hay muerte ni bloqueo permanente. Aislar ENSAYO y luego rearmar permite recuperarse.
- Cambiar selector o aislador no rearma por sí solo. Rearme solo tiene éxito con el fallo ausente.
- La maquinaria de ensayo nunca arranca. El diagnóstico permanece disponible en cualquier estado y muestra estado actual y último disparo como datos separados.
- Consultar solo está disponible cuando ARCHIVO está estable. Conocimiento adquirido se conserva durante la sesión aunque después se pierda alimentación; no se escribe en el guardado persistente en este hito.

### Instrumentación visual definitiva de E

Los controles contractuales mantienen sus centros de interacción: selector (12,3,-7), aislador (19,3,-7). No se mueven para acomodar la arquitectura.

- Panel de estado: montado en el muro norte de la sala E, orientado a la zona de operación, centro aproximado (15.5,4.55,-8.15), orientado al sur hacia el punto de observación (15,3,-7). Expone únicamente valores actuales: destino seleccionado, ensayo conectado/aislado, protección disponible/disparada y existencia de último disparo. No da instrucciones ni marca una secuencia correcta.
- Rearme: botón/asa independiente en (15.5,3.5,-8.15), en el mismo soporte pero claramente separado del panel y de los controles selector/aislador. Se interactúa desde el espacio libre de E; no invade la circulación hacia pasarela ni la puerta F.
- El panel usa texto/símbolos redundantes; el color nunca es el único canal. La aceptación de legibilidad se probará con la cámara real.

## 5. Archivo F y evidencia

- Consola de consulta en (5,3,-7). Solo acepta la interacción cuando ARCHIVO está estable.
- Indicador local de suministro en el interior de la entrada este, centro (8.55,3.8,-7), orientado hacia +X para que se lea desde la pasarela antes de entrar. Estados exactos: **SUMINISTRO ESTABLE** y **NO DISPONIBLE**. Es redundante con texto/símbolo, no instruye al jugador ni reemplaza el terminal de diagnóstico.
- La consulta concede un registro de evidencia a la sesión actual. Texto del registro: «El acta oficial declara alimentación exclusiva del nodo T. La telemetría de bornes registra corriente simultánea en A y T durante la ventana de ensayo; el cierre posterior la atribuye a una interrupción automática». Esto establece la contradicción sin identificar culpables ni explicar toda la trama.
- El registro no es una acción de extracción ni concede autorización de extracción. No se introduce inventario ni migración de guardado: el indicador de conocimiento existe solo en la sesión del slice.

## 6. Salida G y causa de Containment

G es una esclusa exterior compacta al oeste de F. La puerta F→G se desbloquea una sola vez desde F y después es bidireccional. La pared oeste contiene la compuerta exterior a H. G no tiene escalera ni conexión interna a P0.

El interruptor de mantenimiento crea un evento de auditoría local **SERVICE_OVERRIDE** en la sesión. El acceso al registro del archivo, si se consultó, se añade como **RESTRICTED_RECORD_READ**. Ambos quedan en cola local mientras Elena permanece dentro. Al cruzar la compuerta exterior G, el relé de salida transmite los eventos; Helix detecta el uso de mantenimiento y activa Containment. Así se explica la respuesta sin vigilancia omnisciente ni una extracción automática al consultar el archivo.

Elena percibe una señal de sincronización y alarma al cruzar la salida. En H, la unidad de recuperación comienza en patrulla y solo detecta a Elena mediante las reglas de visión, línea de visión y ruido del prototipo de persecución. No conoce su posición a través de paredes ni recibe una posición exacta por guion.

La consulta del archivo no es necesaria para operar los controles ni para abrir físicamente la salida; sí es el objetivo narrativo recomendado antes de salir. Si se omite, el evento SERVICE_OVERRIDE aún puede iniciar Containment, pero la sesión no concede el registro de evidencia.

## 7. Reglas de interfaz e interacción

- Interacción contextual única y consistente para interruptor, selector, aislador, rearme, terminal, consulta y puertas.
- Todo control expone el estado actual junto al resultado de la interacción. Se evita depender solo de color o de audio.
- No hay muerte por configurar mal el circuito; el disparo es reversible y diagnosticable.
- Las pistas del esquema, el puente y los indicadores apoyan la inferencia, pero ninguna lectura de pista es un requisito técnico para que una acción válida funcione.
- No se añaden tarjetas, fusibles, llaves, habitaciones, máquinas arrancables ni pasos de extracción.
- No se altera el contrato lógico, los nombres ENSAYO/ARCHIVO, las acciones de entrada de Fase 0, los autoloads, las rutas de recursos, el renderer ni el esquema JSON/CRC32.

## 8. Alcance, criterios de aceptación y prueba

Fase 1 está funcionalmente especificada y la escena `scenes/prototypes/phase1_canonical_greybox.tscn` tiene una reconstrucción geométrica ampliada en curso. El builder incluye el foso D1/D2 continuo, límites de salas y estructura industrial, pero la geometría aún requiere ejecución y validación en Godot. La escena de destino debe seguir FASE1_ARCHITECTURAL_LAYOUT.md v1.1, el grafo v0.7 y el greybox v1.4.

Aceptar la implementación solo si:
0. Mantener `scan` 0,9 s revela únicamente las trazas de A/puente A→T/T durante 3 s; después se ocultan y el escáner entra en recarga de 4 s.
1. No se puede subir de P0 a M hasta activar mantenimiento en el foso; S1 permanece utilizable sin electricidad.
2. El elevador conecta Y=0 con Y=+1,5 m y no llega a P2; S2 conecta M con P2 y no depende de energía.
3. El contrato cumple T1–T9, X1/X2 y las comprobaciones adicionales del documento lógico, incluido recuperar un disparo y conservar last_trip.
4. El panel de E muestra estado actual e historial por separado; rearme con fallo presente se rechaza sin modificar historial.
5. El indicador F refleja exactamente la condición ARCHIVO estable y es legible desde la aproximación con la cámara de juego.
6. No se puede consultar con suministro inestable; la consulta guarda el conocimiento en sesión y no equivale a extracción.
7. Cruzar G transmite el registro de servicio y activa la transición a H; la unidad externa usa su máquina de estados ordinaria.
8. No hay huecos transitables, colisión que reduzca el paso, paso por la escalera dañada, acceso a P2 desde elevador ni escalera de retorno en G.

Registrar versión de Godot, commit, resolución, renderer, entrada, comandos exactos, salida de pruebas, fallos y evidencia manual. No declarar aceptación por inspección documental solamente.

## 9. Decisiones cerradas / límites de evidencia

Cerradas: cuatro cotas; S1 P0↔D, elevador P0↔M, S2 M↔P2, G horizontal a H; comportamiento seguro del elevador, circuito recuperable, indicadores, rearme, evidencia y Containment.

Pendiente por definición: ninguna decisión arquitectónica o funcional dentro del slice. La escena existente aún no refleja la nueva arquitectura.  
Pendiente por evidencia: ejecución en Godot, corrección de errores, colisiones, cámara, legibilidad, flujo de recorrido, interacción y playtest humano. La integración con el aparcamiento de Fase 2 tampoco se considera validada. Véase `FASE1_CANONICAL_BUILD.md`.
