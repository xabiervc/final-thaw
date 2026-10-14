# Phase 1 — Canonical build and verification

**Estado:** reconstrucción de la escena canónica implementada en GDScript y recurso .tscn; ejecución de pruebas y playtest pendientes.

## Autoridad

FASE1_ARCHITECTURAL_LAYOUT.md v1.0; FASE1_SPATIAL_GRAPH.md v0.6; FASE1_GREYBOX_SPEC.md v1.3; FASE1_FUNCTIONAL_SPEC.md v1.1; FASE1_LOGIC_CONTRACT.md (sin cambios); mapa v0.8.

## Estado de la escena

El builder canónico construye ahora las cuatro cotas, M/S2, salas funcionales y una esclusa G horizontal. La instancia del elevador usa Y=0→1,5; el componente genérico y sus tests de 3 m no cambian. Se ha añadido un recurso .tscn explícito y el test de integración lo instancia. Reutiliza circuito, jugador, HUD y materiales; no modifica persistencia ni inputs.

## Orden de verificación

1. Ejecutar test de circuito, elevador genérico, transporte, integración canónica y regresión Fase 0.
2. Corregir errores de parseo/runtime antes de ampliar el slice.
3. Recorrer A→B→D→P0→M→S2→E→F→G→H a mano.
4. Revisar cámara, sightlines, colisiones, anchos, puertas y pérdida de energía.
5. Validar el prototipo motion/chase v2 por separado y después la transición combinada.

~~~sh
godot --headless --path . res://tests/test_phase1_circuit_model.tscn
godot --headless --path . res://tests/test_service_lift.tscn
godot --headless --path . res://tests/test_service_lift_transport.tscn
godot --headless --path . res://tests/test_phase1_canonical_greybox.tscn
godot --headless --path . res://tests/test_phase_0.tscn
~~~

El test genérico puede usar 3 m; el test de misión debe verificar 1,5 m, S2, puertas y pérdida de energía. Godot no está instalado en el entorno de edición; registra versión, commit, comandos, salida y exit code al ejecutar localmente. Test automático no sustituye playtest.
