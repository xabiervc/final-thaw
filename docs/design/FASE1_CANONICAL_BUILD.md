# Phase 1 — Canonical build and verification

**Estado:** primera reconstrucción arquitectónica ampliada en GDScript y recurso .tscn; ejecución de pruebas y playtest pendientes. No declarada como greybox aceptado.

## Autoridad

FASE1_ARCHITECTURAL_LAYOUT.md v1.1; planos SVG bajo docs/design/assets/phase1_architecture/; FASE1_SPATIAL_GRAPH.md v0.7; FASE1_GREYBOX_SPEC.md v1.4; FASE1_FUNCTIONAL_SPEC.md v1.1; FASE1_LOGIC_CONTRACT.md (sin cambios); mapa de progresión v0.9.

## Cambios de esta reconstrucción

- P0 conserva su perímetro, acceso, nave, taller y rutas contractuales; se añaden particiones con pasos anchos, bandejas, armarios y estructura de cubierta.
- P−1 ahora reserva un hueco continuo para D1/D2 (X=10..28, Z=1..8), con suelo de mantenimiento, bombas/sumidero, señalización y protección perimetral. S1 conserva su abertura.
- M/P2 mantienen sus cotas, huecos de elevador y S2, pasarela, archivo, control y esclusa G.
- La instancia de misión usa el elevador Y=0→1,5; el componente genérico y sus tests de 3 m no cambian. La compuerta fija superior se alinea con el borde del hueco en M.
- Las barandillas del foso están sobre la losa P0, no enterradas; la abertura de S1 se mantiene deliberadamente.
- El banco del taller no invade el paso B↔C y la marca del pasillo de servicio queda sobre suelo sólido, no suspendida sobre el foso.
- El test de integración añade aserciones para estos puntos de regresión.
- Se conservan circuito, jugador, HUD, rutas de recursos, inputs y guardado; no se altera el contrato lógico.

## Correcciones de revisión estática ya aplicadas

La auditoría geométrica encontró cuatro defectos concretos antes de ejecutar Godot: barandillas del foso con el centro vertical por debajo de P0, banco del taller invadiendo el umbral y solapando un armario, marca del pasillo sobre el vacío, columna Aster suspendida sobre el suelo, y compuerta superior del elevador desalineada respecto al plano. Se corrigieron y se añadieron aserciones de integración. También se apoyaron sobre el suelo el puente manipulado y el alojamiento del interruptor de mantenimiento. Esta revisión de código no demuestra todavía el comportamiento físico.

## Límites

La ampliación geométrica no prueba que las paredes, barandillas, cubierta o huecos sean transitables/correctos. Godot no está disponible en el entorno de edición; la ejecución y el recorrido manual siguen pendientes. El aparcamiento de Fase 2 está definido como continuidad de diseño, no como escena integrada y validada.

## Regresión automatizada

Se añadió `.github/workflows/godot-headless-tests.yml` para importar recursos y ejecutar Fase 0, el vertical slice existente, contrato de circuito, elevador genérico, transporte y la integración canónica en Godot 4.7.1. El workflow aún no se ha observado en ejecución; hasta que GitHub Actions publique un resultado, la CI también está pendiente.

## Orden de verificación

1. Ejecutar test de circuito, elevador genérico, transporte, integración canónica y regresión Fase 0.
2. Corregir errores de parseo/runtime antes de ampliar el slice.
3. Recorrer A→B→D1/D2→B→galería de servicio→M→S2→E→F→G→H a mano.
4. Revisar cámara, sightlines, colisiones, anchos, puertas y pérdida de energía.
5. Comprobar que el umbral exterior ofrece contexto para iniciar la escena de aparcamiento/Containment.
6. Validar el prototipo motion/chase v2 por separado y después la transición combinada.

~~~sh
godot --headless --path . res://tests/test_phase1_circuit_model.tscn
godot --headless --path . res://tests/test_service_lift.tscn
godot --headless --path . res://tests/test_service_lift_transport.tscn
godot --headless --path . res://tests/test_phase1_canonical_greybox.tscn
godot --headless --path . res://tests/test_phase_0.tscn
~~~

El test genérico puede usar 3 m; el test de misión debe verificar 1,5 m, S2, puertas y pérdida de energía. Registrar versión de Godot, commit, comandos, salida y exit code al ejecutar localmente. Test automático no sustituye playtest.
