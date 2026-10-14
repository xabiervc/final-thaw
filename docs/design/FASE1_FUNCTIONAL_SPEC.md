# FASE1 — Especificación funcional de implementación (v1.0)

**Estado:** decisiones de diseño y comportamiento cerradas para construir el primer slice. Las pruebas de escena, cámara, colisiones y jugabilidad siguen pendientes; este documento no afirma validación en Godot.  
**Autoridad funcional:** este documento define la experiencia de Fase 1; el contrato lógico define las reglas del circuito; el grafo espacial y el greybox definen su geometría.

## 1. Objetivo jugable

Elena debe reconocer una discrepancia física en la distribución eléctrica, poner el circuito en una configuración segura que permita consultar el archivo y salir de la instalación. La máquina de ensayo nunca arranca. La amenaza exterior pertenece a Fase 2 y empieza cuando el controlador de salida sincroniza el registro de mantenimiento.

La experiencia se basa en inferencia ambiental, no en una secuencia arbitraria de interruptores. El jugador puede operar el circuito sin leer cada pista: las pistas explican el problema, pero no son llaves para los controles.

## 2. Recorrido definitivo

Recorrido obligatorio por dependencias físicas, no por una puerta de pista:

1. Entrada y observación del acceso roto y la máquina central.
2. Ruta sur, pasillo oeste y explanada.
3. Descenso al foso por la escalera fija; inspección del esquema, el puente manipulado y el interruptor de mantenimiento.
4. Activación de mantenimiento. Esto alimenta la iluminación de servicio y la plataforma elevadora; no altera el circuito de recuperación.
5. Regreso por la misma escalera fija y ascenso por la plataforma elevadora al rellano superior.
6. Pasarela E: selector, aislador, panel de estado y rearme.
7. Entrada este a F, indicador local y consola de archivo.
8. Desbloqueo del acceso oeste desde el lado de la cabina; vestíbulo G; apertura de la salida exterior y transición a H.

No hay rampa paralela en el slice final. La variante B —subir antes de visitar el foso— queda retirada: con mantenimiento inicialmente apagado y sin rampa, la plataforma no puede subir. Esto evita dos soluciones de transporte y hace coherente la dependencia física de la visita al foso. No se exige leer una pista concreta para accionar el circuito una vez que se llega a E.

## 3. Plataforma elevadora y mantenimiento

- **Ubicación:** huella existente del ascensor, X=24.5..27.5, Z=-4.5..-1.5; suelo de plataforma Y=0 en el rellano inferior y Y=3 en el superior.
- **Inicialización:** plataforma detenida en el rellano inferior; mantenimiento apagado. No se guarda estado de plataforma en el archivo de partida ni se cambia el esquema de persistencia.
- **Uso normal:** pulsador de llamada en ambos rellanos; solo responde con mantenimiento activo. Viaje de una terminal a la otra en 2.5 s, con arranque y frenado suaves. Las compuertas móviles del deck se cierran durante el viaje. Además hay compuertas fijas de seguridad en los rellanos inferior (centro aproximado `(26,0.55,-1.1)`) y superior (`(26,3.55,-4.9)`); cada una se abre solo cuando el deck está acoplado en ese nivel. La compuerta fija del rellano abandonado se cierra al iniciar el movimiento, por lo que el hueco nunca queda accesible desde la plataforma de llegada.
- **Mantenimiento apagado estando parada:** permanece en su rellano, no acepta llamadas ni inicia movimiento.
- **Pérdida de mantenimiento en movimiento:** activa la reserva de seguridad, reduce velocidad y llega al rellano más cercano; si la posición está exactamente a mitad de camino, el destino es el rellano superior (regla ya implementada en `service_lift.gd`). Se detiene allí y queda deshabilitada. Nunca cae ni deja a Elena entre niveles.
- La reserva de seguridad se considera parte obligatoria del mecanismo, no una segunda rama de comportamiento: la implementación debe garantizar la llegada al rellano más cercano. Si la prueba induce una detención entre niveles o requiere un rescate manual, la prueba falla y la plataforma no se acepta; no se añade un minijuego de rescate ni una ruta alternativa.
- **Interruptor:** posición (26,-2,2). Las luces de servicio y la plataforma comparten el estado de mantenimiento. La escalera fija del foso no depende de electricidad. La iluminación ambiental mínima conserva legible la ruta con mantenimiento apagado.

La rampa provisional y la reserva de plataforma X=30..34 se eliminan del diseño implementable. No construirlas ni medirlas como rutas alternativas.

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

- Panel de estado: montado en el borde norte de la pasarela, centro aproximado (15.5,4.55,-8.15), orientado al sur hacia el punto de observación (15,3,-7). Expone únicamente valores actuales: destino seleccionado, ensayo conectado/aislado, protección disponible/disparada y existencia de último disparo. No da instrucciones ni marca una secuencia correcta.
- Rearme: botón/asa independiente en (15.5,3.5,-8.15), en el mismo soporte pero claramente separado del panel y de los controles selector/aislador. Se interactúa desde la pasarela; el soporte y su collider quedan fuera del rectángulo libre Z=-8..-6, al norte de la pasarela (Z más negativo).
- El panel usa texto/símbolos redundantes; el color nunca es el único canal. La aceptación de legibilidad se probará con la cámara real.

## 5. Archivo F y evidencia

- Consola de consulta en (5,3,-7). Solo acepta la interacción cuando ARCHIVO está estable.
- Indicador local de suministro en el interior de la entrada este, centro (8.55,3.8,-7), orientado hacia +X para que se lea desde la pasarela antes de entrar. Estados exactos: **SUMINISTRO ESTABLE** y **NO DISPONIBLE**. Es redundante con texto/símbolo, no instruye al jugador ni reemplaza el terminal de diagnóstico.
- La consulta concede un registro de evidencia a la sesión actual. Texto del registro: «El acta oficial declara alimentación exclusiva del nodo T. La telemetría de bornes registra corriente simultánea en A y T durante la ventana de ensayo; el cierre posterior la atribuye a una interrupción automática». Esto establece la contradicción sin identificar culpables ni explicar toda la trama.
- El registro no es una acción de extracción ni concede autorización de extracción. No se introduce inventario ni migración de guardado: el indicador de conocimiento existe solo en la sesión del slice.

## 6. Salida G y causa de Containment

G es el vestíbulo de salida al oeste de la cabina. La puerta F→G se desbloquea una sola vez desde el lado de la cabina y después es bidireccional. La pared oeste del vestíbulo contiene la compuerta exterior hacia H; la escalera de retorno a Y=0 es una salida secundaria, no el camino de transición de Fase 2. No se simula presurización.

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

Fase 1 está funcionalmente especificada y tiene una primera escena en `scenes/prototypes/phase1_canonical_greybox.tscn`; el código aún requiere ejecución y validación. La escena debe seguir el grafo v0.4 y el greybox v1.1.

Aceptar la implementación solo si:
0. Mantener `scan` 0,9 s revela únicamente las trazas de A/puente A→T/T durante 3 s; después se ocultan y el escáner entra en recarga de 4 s.
1. No se puede ascender por la plataforma hasta activar mantenimiento en el foso; la escalera del foso sigue siendo utilizable sin electricidad.
2. El ascensor/plataforma conecta ambos rellanos, acepta llamadas desde ambos extremos y nunca deja a Elena atrapada o en caída ante una pérdida de energía.
3. El contrato cumple T1–T9, X1/X2 y las comprobaciones adicionales del documento lógico, incluido recuperar un disparo y conservar last_trip.
4. El panel de E muestra estado actual e historial por separado; rearme con fallo presente se rechaza sin modificar historial.
5. El indicador F refleja exactamente la condición ARCHIVO estable y es legible desde la aproximación con la cámara de juego.
6. No se puede consultar con suministro inestable; la consulta guarda el conocimiento en sesión y no equivale a extracción.
7. Cruzar G transmite el registro de servicio y activa la transición a H; la unidad externa usa su máquina de estados ordinaria.
8. No hay huecos transitables involuntarios, bloqueo de la escalera, colisión que reduzca el pasillo libre, desvíos a la rampa eliminada ni rutas a una salida exterior inexistente.

Registrar versión de Godot, commit, resolución, renderer, entrada, comandos exactos, salida de pruebas, fallos y evidencia manual. No declarar aceptación por inspección documental solamente.

## 9. Decisiones cerradas / límites de evidencia

Cerradas para implementación: topología A, plataforma sin rampa paralela, comportamiento mecánico de pérdida de energía, estado inicial y solución recuperable del circuito, posición y significado de indicadores, interacción de rearme, registro de evidencia y desencadenante de Containment.

Pendiente por definición: ninguna decisión de diseño dentro de este slice.  
Pendiente por evidencia: ejecución en Godot, corrección de errores, colisiones, cámara, legibilidad, flujo de recorrido, interacción y playtest humano. Véase `FASE1_CANONICAL_BUILD.md`.
