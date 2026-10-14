# Phase 1 — Canonical build and verification

**Estado:** primera reconstrucción arquitectónica ampliada en GDScript y recurso .tscn; ejecución de pruebas y playtest pendientes. No declarada como greybox aceptado.

## Autoridad y estados de decisión

La topología espacial de referencia se describe en FASE1_ARCHITECTURAL_LAYOUT.md v1.1, los SVG existentes bajo docs/design/assets/phase1_architecture/, FASE1_SPATIAL_GRAPH.md v0.7 y FASE1_GREYBOX_SPEC.md v1.4. El comportamiento se rige por FASE1_FUNCTIONAL_SPEC.md v1.1 y FASE1_LOGIC_CONTRACT.md. El mapa de progresión existente mantiene la trazabilidad entre recorrido y beats narrativos.

No confundir tres estados: **aprobado conceptualmente** (diseño de referencia), **propuesto** (requiere aprobación, especialmente beats narrativos) y **pendiente de validación** (requiere ejecución Godot o playtest). Ningún documento ni test estático convierte una propuesta en canon ni acredita colisiones/jugabilidad.

## Cambios de esta reconstrucción

- P0 conserva su perímetro, acceso, nave, taller y rutas contractuales; B queda en X=7..20, Z=−9..1 y el pasillo A→B discurre por X=7..10, Z=1..8. Se añaden particiones con pasos anchos, bandejas, armarios y estructura de cubierta.
- El arranque incluye un túnel exterior físico de 3 m (X=−3..0, Z=4,5..7,5), con suelo, paredes, techo de 2,2 m y umbral a A; Elena aparece en el túnel orientada hacia la abertura a A.
- P−1 tiene suelo continuo D1/D2 (X=10..28, Z=1..8) a Y=−2. El hueco P0 coincide con esa huella y S1 conserva su abertura; B termina en Z=1, por lo que nave y vacío no se solapan.
- M/P2 mantienen sus cotas, huecos de elevador y S2, pasarela, archivo, control y esclusa G. El panel E conserva su coordenada contractual y tiene pared de soporte real; se protegen los laterales del elevador, el borde oeste de M y los bordes expuestos de E/pasarela.
- La instancia de misión usa el elevador Y=0→1,5; el componente genérico y sus tests de 3 m no cambian. Las compuertas fijas se alinean con los bordes del hueco y las barandillas laterales protegen ambas cotas.
- Las barandillas del foso están sobre la losa P0, no enterradas; la abertura de S1 se mantiene deliberadamente.
- El banco del taller no invade el paso B↔C y la marca del pasillo de servicio queda sobre suelo sólido, no suspendida sobre el foso.
- El test de integración comprueba cotas, suelo y huecos, apoyos del Aster/equipos, separación del taller, puertas y pérdida de energía del elevador de misión.
- Se conservan circuito, jugador, HUD, rutas de recursos, inputs y guardado; no se altera el contrato lógico.

## Correcciones de revisión estática ya aplicadas

La auditoría detectó una discrepancia crítica entre plano y constructor: el plano y el test esperaban el túnel en el muro oeste (X=−3..0, Z=4,5..7,5), pero el builder lo generaba en el muro sur y colocaba allí el spawn. Se corrigió la geometría del túnel, el marco de la apertura oeste y el spawn/orientación de Elena; el test de integración ahora comprueba la huella, paredes laterales y ausencia de la entrada sur obsoleta. **Corrección estática pendiente de ejecución en Godot.**

La auditoría geométrica también detectó y corrigió: solape entre banco y armario; marca de ruta sobre el vacío; columna Aster sin apoyo y marcador T desplazado; compuertas del elevador desalineadas; elementos del foso con separación respecto al suelo; y la escalera colapsada orientada en sentido inverso. Se coordinó B al norte del hueco D1/D2 y se redibujó la ruta de P0 para bordear el foso. El panel E conserva su coordenada contractual y ahora tiene pared de soporte real; se ajustó el borde norte del suelo E para que la pared cierre la sala. La pasarela P2 se extendió hasta el borde protegido. La ruta de retorno desde S1 se dibuja por el perímetro sur y el pasillo este. Se añadieron barandillas laterales en el elevador en P0/M, barandilla oeste del mezzanine, protección de los bordes norte/este de control y de los bordes abiertos de la pasarela, y pasamanos inclinados en S1/S2. Los SVG existentes se actualizaron para mostrar las huellas y protecciones.

Las pruebas de integración ahora comprueban el túnel y la orientación inicial, la escalera colapsada, cotas, huecos de colisión, apoyos de equipos, ausencia de solapes críticos, guardarraíles, alineación Aster/escáner, compuertas, y pérdida de alimentación del elevador de misión. Todo esto sigue siendo revisión estática y cobertura escrita: no demuestra comportamiento físico hasta ejecutar Godot y recorrer la escena.

## Límites

La ampliación geométrica ni la corrección del túnel prueban que las paredes, barandillas, cubierta o huecos sean transitables/correctos. Godot no está disponible en el entorno de edición; la ejecución y el recorrido manual siguen pendientes. El handoff G→H apunta a la variante de aparcamiento y tiene un smoke test dedicado; su comportamiento en ejecución sigue sin estar validado.

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

Se añadió `.github/workflows/godot-headless-tests.yml` para importar recursos y ejecutar Fase 0, el vertical slice existente, contrato de circuito, elevador genérico, transporte, integración canónica y el smoke test del checkpoint de aparcamiento en Godot 4.7.1. El resultado de GitHub Actions no se ha verificado durante esta revisión; no se declara CI verde sin consultar el run real.

## Orden de verificación

1. Ejecutar test de circuito, elevador genérico, transporte, integración canónica, checkpoint de aparcamiento, vertical slice previo y regresión Fase 0.
2. Corregir errores de parseo/runtime antes de ampliar el slice.
3. Recorrer A→B→D1/D2→B→galería de servicio→M→S2→E→F→G→H a mano.
4. Revisar cámara, sightlines, colisiones, anchos, puertas y pérdida de energía.
5. Comprobar que G carga `phase2_parking_chase.tscn` en el checkpoint de entrada al aparcamiento (X=34,5), no al inicio del prototipo standalone, y que la unidad no detecta a Elena automáticamente al cargar.
6. Ejecutar el smoke test del checkpoint de aparcamiento; validar el prototipo motion/chase v2 por separado y después la transición combinada.

~~~sh
godot --headless --path . res://tests/test_phase1_circuit_model.tscn
godot --headless --path . res://tests/test_service_lift.tscn
godot --headless --path . res://tests/test_service_lift_transport.tscn
godot --headless --path . res://tests/test_phase1_canonical_greybox.tscn
godot --headless --path . res://tests/test_phase2_parking_entry.tscn
godot --headless --path . res://tests/test_vertical_slice.tscn
godot --headless --path . res://tests/test_phase_0.tscn
~~~

El test genérico puede usar 3 m; el test de misión debe verificar 1,5 m, S2, puertas y pérdida de energía. Registrar versión de Godot, commit, comandos, salida y exit code al ejecutar localmente. Test automático no sustituye playtest.
