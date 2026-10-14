# Phase 1 — Canonical build and verification

**Estado:** primera reconstrucción arquitectónica ampliada en GDScript y recurso .tscn; ejecución de pruebas y playtest pendientes. No declarada como greybox aceptado.

## Autoridad

FASE1_ARCHITECTURAL_LAYOUT.md v1.1; planos SVG bajo docs/design/assets/phase1_architecture/; FASE1_SPATIAL_GRAPH.md v0.7; FASE1_GREYBOX_SPEC.md v1.4; FASE1_FUNCTIONAL_SPEC.md v1.1; FASE1_LOGIC_CONTRACT.md (sin cambios); mapa de progresión v0.9.

## Cambios de esta reconstrucción

- P0 conserva su perímetro, acceso, nave, taller y rutas contractuales; B queda en X=7..20, Z=−9..1 y el pasillo A→B discurre por X=7..10, Z=1..8. Se añaden particiones con pasos anchos, bandejas, armarios y estructura de cubierta.
- P−1 tiene suelo continuo D1/D2 (X=10..28, Z=1..8) a Y=−2. El hueco P0 coincide con esa huella y S1 conserva su abertura; B termina en Z=1, por lo que nave y vacío no se solapan.
- M/P2 mantienen sus cotas, huecos de elevador y S2, pasarela, archivo, control y esclusa G.
- La instancia de misión usa el elevador Y=0→1,5; el componente genérico y sus tests de 3 m no cambian. La compuerta fija superior se alinea con el borde del hueco en M.
- Las barandillas del foso están sobre la losa P0, no enterradas; la abertura de S1 se mantiene deliberadamente.
- El banco del taller no invade el paso B↔C y la marca del pasillo de servicio queda sobre suelo sólido, no suspendida sobre el foso.
- El test de integración comprueba cotas, suelo y huecos, apoyos del Aster/equipos, separación del taller, puertas y pérdida de energía del elevador de misión.
- Se conservan circuito, jugador, HUD, rutas de recursos, inputs y guardado; no se altera el contrato lógico.

## Correcciones de revisión estática ya aplicadas

La auditoría geométrica encontró defectos antes de ejecutar Godot: barandillas del foso con el centro vertical por debajo de P0, banco del taller invadiendo el umbral/armario, marca del pasillo sobre el vacío, columna Aster suspendida, compuerta superior desalineada y trazador T desplazado de Aster. Se corrigieron y se añadieron aserciones. También se coordinaron las huellas para que el pasillo A→B no cruce el foso, se extendió la pasarela P2 hasta la barandilla y se apoyaron sobre el suelo el puente manipulado, el alojamiento de mantenimiento, el sumidero y las bombas. Esta revisión estática no demuestra todavía el comportamiento físico. Se corrigieron y se añadieron aserciones de integración. También se apoyaron sobre el suelo el puente manipulado y el alojamiento del interruptor de mantenimiento. Esta revisión de código no demuestra todavía el comportamiento físico.

## Límites

La ampliación geométrica no prueba que las paredes, barandillas, cubierta o huecos sean transitables/correctos. Godot no está disponible en el entorno de edición; la ejecución y el recorrido manual siguen pendientes. El aparcamiento de Fase 2 está definido como continuidad de diseño, no como escena integrada y validada.

## Quality gates — no aceptar solo por apariencia o compilación

### Arquitectura y geometría
- Comparar cada planta SVG con la escena desde arriba y en sección; toda diferencia debe resolverse en el plano o registrarse como desviación intencional aprobada.
- Comprobar que los huecos P0 de D1/D2 y S1 son reales en la colisión, que el foso tiene suelo a Y=−2 y que las barandillas se apoyan en P0 sin cerrar S1.
- Verificar puertas, dinteles, vigas, conductos, mobiliario, barandillas y maquinaria contra los volúmenes de jugador y cámara; ninguna pieza decorativa puede bloquear una ruta contractual.
- Recorrer S1, el elevador P0↔M y S2 M↔P2 en ambos sentidos, sin saltar cuando el diseño promete caminar. Probar la pérdida de alimentación en ambas mitades del recorrido y en el punto medio.
- Verificar el paso B↔C, galería de servicio, rellanos, E→F→G y el hueco de salida con cámara de tercera persona. Ningún punto de control debe quedar detrás de un collider, dentro de una pared o en una zona sin espacio para detenerse.

### Jugabilidad y narrativa
- Una persona que no conozca el diseño debe poder distinguir acceso, nave, taller, achique, distribución, sala de bombas, control, archivo y esclusa por composición espacial y señalización, sin depender solo del color.
- La anomalía A→T debe poder inferirse comparando esquema y puente; el escáner amplía información, pero no señala selector, aislador ni la respuesta.
- El fallo eléctrico debe ser reversible y diagnosticable; el panel separa estado actual de last_trip; la consulta del archivo no equivale a extracción.
- La causa de Containment debe leerse como consecuencia de cruzar la esclusa y transmitir la auditoría. La transición al aparcamiento no puede teletransportar al jugador sin continuidad audiovisual/espacial perceptible.

### Accesibilidad y presentación
- Texto de paneles legible en resolución de referencia y en la cámara real; estados críticos se expresan con texto/símbolo y no solo con color.
- Indicaciones de interacción visibles sin tapar el objeto, el recorrido ni los indicadores. Validar tamaños, contraste, distancia de lectura y oclusión desde las posiciones de juego.
- No introducir audio como único canal para eventos importantes; si se añade sonido, acompañarlo con señal visual o texto. Mantener las acciones de entrada contractuales y respetar remapeos existentes.

### Ingeniería y evidencia
- Ningún cambio a autoloads, acciones existentes, rutas de recursos, renderer Compatibility o formato JSON/CRC32 sin decisión explícita y pruebas de compatibilidad.
- Tests unitarios del circuito/elevador, integración canónica, regresión Fase 0 y recorrido manual son puertas separadas; una no sustituye a otra.
- Registrar commit exacto, versión de Godot, renderer, resolución, comando, exit code, salida de tests, incidencias y evidencia visual. No declarar CI verde sin el resultado del run y no declarar jugabilidad aceptada sin playtest.
- Cualquier fallo de parseo/runtime bloquea ampliación artística. Corregir primero, ejecutar regresión, luego continuar con detalle y presentación.

## Regresión automatizada

Se añadió `.github/workflows/godot-headless-tests.yml` para importar recursos y ejecutar Fase 0, el vertical slice existente, contrato de circuito, elevador genérico, transporte y la integración canónica en Godot 4.7.1. El resultado de GitHub Actions no se ha verificado durante esta revisión; no se declara CI verde sin consultar el run real.

## Orden de verificación

1. Ejecutar test de circuito, elevador genérico, transporte, integración canónica y regresión Fase 0.
2. Corregir errores de parseo/runtime antes de ampliar el slice.
3. Recorrer A→B→D1/D2→B→galería de servicio→M→S2→E→F→G→H a mano.
4. Revisar cámara, sightlines, colisiones, anchos, puertas y pérdida de energía.
5. Comprobar que G carga `phase2_parking_chase.tscn` en el checkpoint de entrada al aparcamiento (X=34,5), no al inicio del prototipo standalone, y que la unidad no detecta a Elena automáticamente al cargar.
6. Validar el prototipo motion/chase v2 por separado y después la transición combinada.

~~~sh
godot --headless --path . res://tests/test_phase1_circuit_model.tscn
godot --headless --path . res://tests/test_service_lift.tscn
godot --headless --path . res://tests/test_service_lift_transport.tscn
godot --headless --path . res://tests/test_phase1_canonical_greybox.tscn
godot --headless --path . res://tests/test_phase_0.tscn
~~~

El test genérico puede usar 3 m; el test de misión debe verificar 1,5 m, S2, puertas y pérdida de energía. Registrar versión de Godot, commit, comandos, salida y exit code al ejecutar localmente. Test automático no sustituye playtest.
