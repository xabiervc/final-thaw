# FINAL THAW — Fases 1 y 2: mapa de progresión verificable

Estado: BORRADOR DE DISEÑO v0.2. No autoriza construir ni ampliar escenarios.
Esta revisión precisa la relación entre recorrido, descubrimientos, decisiones y validación; no cierra el guion ni aprueba geometría.
Todo lo marcado como PENDIENTE DE GUION no debe rellenarse con hechos narrativos no aprobados.

## 1. Intención y límites

- Fase 1: Elena explora una instalación que no comprende, investiga sus anomalías y accede al archivo.
- Fase 2: Elena utiliza lo aprendido para escapar al exterior y sobrevivir a una amenaza.
- Son dos experiencias distintas conectadas por la misma historia: **comprender y después sobrevivir**.
- No se fija un número de habitaciones. El tamaño del nivel debe salir de la función de cada espacio.
- Regla de descarte: si eliminar un espacio no hace perder información, decisión, exploración o atmósfera significativa, se debe justificar por qué permanece.
- El conjunto existente de sala de ensayo, máquina central, foso, circuito y archivo se conserva como núcleo de una instalación mayor, no como toda la Fase 1.
- Este documento es diseño, no orden de implementación. No aprueba todavía plano, dimensiones, número de estancias, contenido narrativo ni construcción.

## 2. Las cuatro capas que debe cerrar el diseño

1. **Espacial:** posición relativa, alturas, entradas, salidas, visibilidad y rutas transitables.
2. **Narrativa:** qué observa Elena, qué evidencia encuentra y qué sigue sin comprender.
3. **Jugable:** qué hipótesis puede formular, qué acción puede probar y cómo interpreta el resultado.
4. **Progresión y recuperación:** qué permite avanzar, qué es opcional, qué estados persisten y cómo se corrige un error sin repetir un recorrido largo.

El mapa debe permitir revisar simultáneamente dos recorridos:
- **Recorrido físico:** por dónde pasa Elena y qué conexiones están disponibles.
- **Recorrido de conocimiento:** qué puede observar, aprender, inferir o confirmar en cada punto.

No se debe asumir que el orden espacial obliga a una única secuencia de descubrimientos, salvo que una dependencia de diseño o de guion lo justifique explícitamente.

## 3. Grafo de conexiones — provisional, no es un plano

### Ruta principal propuesta

A Acceso y recepción → B Observación → C Nave de ensayo → D Servicios y foso → E Distribución y control → F Archivo → G Esclusa → H Primer encuentro exterior.

Esta secuencia es una hipótesis de trabajo. El orden relativo entre D (foso) y E (circuito) queda abierto a pruebas en el grafo antes de fijar la ruta definitiva.

### Tipos de conexión que deben aparecer en el grafo

- **Principal:** sostiene la progresión hasta el archivo y la salida.
- **Desvío opcional:** regresa cerca de su entrada o reconecta más adelante; puede aportar contexto, pero no oculta requisitos obligatorios.
- **Bloqueo comprensible:** su causa se puede reconocer antes de exigir una solución.
- **Atajo de recuperación:** reduce desplazamientos o permite retomar el recorrido; no regala progreso ni sustituye una deducción necesaria.
- **Conexión de retorno:** permite regresar a una zona cercana cuando existe una razón nueva para hacerlo; no debe crear revisitas largas por defecto.

### Reglas contra las revisitas innecesarias

1. **Progresión sin retroceso obligatorio:** al resolver una zona, debe existir una conexión razonable hacia el siguiente sector sin atravesar de nuevo toda la instalación.
2. **Revisita con propósito:** volver a un espacio debe ofrecer información nueva, una interacción habilitada o una decisión pendiente.
3. **Recuperación local:** un error en el circuito se corrige cerca de los controles. El estado actual y el último disparo deben seguir siendo legibles y coherentes con `FASE1_LOGIC_CONTRACT.md`.
4. **Sin bloqueo arbitrario:** no se añaden llaves, fusibles coleccionables, tarjetas de acceso ni mecanismos obligatorios únicamente para alargar el paseo.
5. **Sin pistas imprescindibles escondidas:** una pista opcional puede enriquecer la interpretación, pero no debe ser un requisito invisible para ejecutar una acción que el jugador ya puede deducir.

### Pregunta de diseño abierta

¿Debe la inspección del foso preceder al circuito, o pueden descubrirse en otro orden sin perder comprensión? Preparar variantes del grafo y compararlas con jugadores que no conozcan el diseño. No cerrar esta decisión solo por comodidad de construcción.

## 4. Mapa de sectores — funciones, no dimensiones

No asignar cotas, dimensiones, cantidad de habitaciones ni geometría final hasta revisar el grafo. Los nombres siguientes son sectores funcionales, no un compromiso de número de estancias.

| Sector | Función espacial y jugable | Recorrido / salida prevista | Conocimiento que debe aportar | Estado |
|---|---|---|---|---|
| A. Acceso y recepción | Orientar al jugador y permitir reconocer un destino inicial | Entrada a B; evitar callejones sin salida obligatorios | Objetivo inmediato de Elena: PENDIENTE DE GUION | Función provisional |
| B. Observación | Permitir examinar parte de la instalación antes de entrar en su núcleo | Conexión a C; posibles observaciones desde una posición segura | Función del ensayo y relación con Aster: PENDIENTE DE GUION | Función provisional |
| C. Nave de ensayo | Reunir máquina central, estado físico y señales del sistema | Acceso a servicios/foso y continuación hacia control, según variante del grafo | Primera contradicción verificable; contenido concreto pendiente de guion | Núcleo existente; integración por validar |
| D. Servicios y foso | Permitir inspeccionar conexiones y la intervención física | Retorno por salida fija; conexión a E sin repetir todo el recorrido | Schematic, puente manipulado y mantenimiento como observaciones diferenciadas; interpretación narrativa pendiente | Geometría aún no aprobada |
| E. Distribución y control | Permitir comprobar una hipótesis actuando sobre el circuito | Controles próximos entre sí; ruta hacia F | Diferencia entre selector, aislamiento, protección y diagnóstico, según el contrato lógico | Contrato lógico separado; integración pendiente |
| F. Archivo | Permitir consultar y recuperar evidencia | Conexión hacia G sin retorno largo obligatorio | Contenido, conclusión y dudas restantes: PENDIENTE DE GUION | Acceso y contenido por definir |
| G. Esclusa | Convertir la investigación en una transición a supervivencia | Paso al exterior | Desencadenante y percepción de Elena: PENDIENTE DE GUION | Bloqueado por guion |
| H. Primer encuentro exterior | Enseñar detección, elección de ruta y ruptura de línea de visión | Continuación hacia el destino exterior | Destino y naturaleza exacta de la amenaza: PENDIENTE DE GUION | Prototipo pequeño antes de expandir |

Los desvíos opcionales y los atajos se incorporarán como conexiones identificadas en el grafo; no se asignan habitaciones nuevas hasta demostrar qué aportan.

## 5. Matriz de descubrimientos: ficha obligatoria por espacio

Antes de autorizar la construcción de un espacio, completar su ficha. Cuando una respuesta dependa del guion, marcarla como pendiente en lugar de inventarla.

| Campo | Pregunta que debe responder |
|---|---|
| Propósito | ¿Por qué debe existir este espacio? |
| Entrada y salida | ¿Desde dónde se llega y hacia dónde se progresa? |
| Observación | ¿Qué percibe el jugador sin interactuar? |
| Evidencia | ¿Qué información obtiene al investigar y cómo se distingue de una inferencia? |
| Hipótesis | ¿Qué puede deducir razonablemente con la información disponible? |
| Acción | ¿Qué puede hacer para comprobar la hipótesis? |
| Resultado | ¿Qué cambia o qué aprende según el resultado? |
| Recuperación | ¿Cómo puede corregirse sin repetir un recorrido largo? |
| Dependencias | ¿Qué debe conocer o haber hecho para avanzar, y cómo se comunica esa necesidad? |
| Validación | ¿Qué conducta o explicación observable demostraría que el espacio funciona? |
| Coste de eliminación | ¿Qué se perdería si se quitara el espacio? Si la respuesta es «nada significativo», justificar su permanencia o eliminarlo. |

### Reglas específicas del circuito

- El diagnóstico informa del estado actual y del último disparo; no prescribe qué control accionar.
- El terminal de diagnóstico sigue siendo accesible aunque se pierda la alimentación de recuperación.
- Una acción correcta no se bloquea por no haber leído una pista concreta.
- Una solución funcional no demuestra por sí sola comprensión; la validación de la deducción se evalúa aparte.
- La pérdida de alimentación no debe borrar el conocimiento ya adquirido durante la sesión.
- La maquinaria permanece bloqueada en este hito; no se debe presentar su arranque como funcional.
- Las reglas de circuito se rigen por `FASE1_LOGIC_CONTRACT.md`; este documento no las redefine.

## 6. Fase 2 — encuentro de referencia

No construir todavía toda la huida exterior. Primero diseñar y validar un encuentro pequeño con este ciclo:

1. Detectar la amenaza y comprender de dónde procede el peligro.
2. Elegir entre una ruta más expuesta/directa y otra con cobertura.
3. Romper la línea de visión usando la geometría, no solo velocidad.
4. Alcanzar una nueva posición y reorientarse hacia el objetivo inmediato.

La prueba debe demostrar que perder la línea de visión cambia de verdad la situación y que el jugador puede interpretar el espacio sin depender de instrucciones constantes. Registrar si la amenaza se percibe, si las rutas se distinguen y si el jugador comprende por qué ha ganado margen.

Solo después de validar ese ciclo se amplía el exterior con sectores funcionales como patio de servicio, zona de carga, conducciones, perímetro y salida. No constituyen todavía una lista cerrada de habitaciones.

Pasarelas elevadas, mecanismos ambientales y rutas alternativas complejas se añaden después de validar el encuentro básico. Clima y estado exterior (nieve, inundación, lluvia tóxica, incendio u otros): PENDIENTE DE GUION; no seleccionar uno para justificar la geometría.

## 7. Decisiones pendientes y límites de autorización

| Decisión | Qué debe fijarse | Qué bloquea |
|---|---|---|
| Evidencia del archivo | Qué obtiene Elena, qué concluye y qué permanece incierto | Contenido definitivo de F y transición |
| Respuesta de Helix | Hecho desencadenante, qué detecta Helix y qué percibe Elena | Evento de G y comienzo de la amenaza |
| Destino exterior | Lugar inmediato y plausible al que intenta llegar Elena | Objetivo de H y dirección de la Fase 2 |
| Orden foso/circuito | Variante que preserve comprensión y evite retrocesos innecesarios | Grafo definitivo |
| Contactos, voces o registros | Quién comunica, qué sabe y si la presencia es necesaria | Narrativa ambiental que dependa de ello |
| Condiciones del exterior | Momento, clima y estado físico del entorno | Arte y geometría que dependan de esas condiciones |

Mientras estas decisiones sigan abiertas, las conexiones afectadas son provisionales. El diseño puede reservar espacio y conexiones, pero no asignar hechos narrativos no aprobados ni compensar la falta de motivación con puertas cerradas o sistemas obligatorios.

Este documento tampoco autoriza cambios de contrato en escenas, rutas de recursos, autoloads, controles, guardado o estructura técnica. Cualquier cambio de esos contratos necesita su propia justificación y revisión.

## 8. Pruebas de recorrido y comprensión

| Prueba | Criterio de aceptación observable |
|---|---|
| Inicio | El jugador puede explicar el objetivo inmediato con la información disponible, sin que el equipo le revele la respuesta. |
| Exploración | Identifica una anomalía y señala la observación que respalda su hipótesis. |
| Orden de descubrimientos | Las variantes foso/circuito se comparan; no se elige el orden solo por comodidad de construcción. |
| Circuito | Predice un resultado, actúa, interpreta el diagnóstico y corrige un error localmente. |
| Archivo | Distingue qué ha confirmado, qué ha inferido y qué desconoce. |
| Transición | Entiende por qué sale y cuál es su destino inmediato, conforme al guion aprobado. |
| Encuentro exterior | Reconoce la amenaza, utiliza cobertura o una ruta alternativa y rompe su línea de visión. |

Condiciones:
- Usar participantes que no conozcan el diseño.
- Registrar dudas, pistas ignoradas, retrocesos, errores, ayudas y explicaciones, no solo si llegan al final.
- Distinguir entre inspección del documento, ejecución del escenario y validación manual.
- No declarar una prueba superada sin registrar versión/commit, condiciones y observaciones relevantes.
- La aceptación depende de evidencias observables, no de que las habitaciones estén construidas o sean transitables.

## 9. Hitos y puertas de decisión

1. **Diseño narrativo y mapa:** grafo de conexiones, fichas de sectores y registro de decisiones pendientes revisados. Sin autorización automática para construir.
2. **Fase 1 recorrible:** solo tras aprobar el grafo; conexiones legibles, sin bloqueos accidentales y sin retrocesos largos obligatorios.
3. **Investigación jugable:** pistas diferenciadas, circuito implementado conforme a su contrato y archivo integrado; pruebas ejecutadas y registradas.
4. **Transición:** evidencia, desencadenante y destino definidos por guion; salida espacial coherente con esas decisiones.
5. **Prototipo de huida:** encuentro exterior pequeño validado antes de ampliar el escenario.
6. **Expansión de la Fase 2:** solo después de que el encuentro de referencia demuestre que orientación, cobertura y ruptura de visión funcionan.

No se autoriza ampliar escenarios por el mero hecho de que este documento exista. Cada espacio debe tener una función verificable y la revisión de diseño debe aprobar el grafo y las dependencias antes de pasar a construcción.
