# Phase 1 — Canonical build and verification

**Estado:** arquitectura v1.0 definida; la escena actual refleja la geometría anterior. Requiere reconstrucción; ningún test se declara ejecutado o superado.

## Autoridad

FASE1_ARCHITECTURAL_LAYOUT.md v1.0; FASE1_SPATIAL_GRAPH.md v0.6; FASE1_GREYBOX_SPEC.md v1.3; FASE1_FUNCTIONAL_SPEC.md v1.1; FASE1_LOGIC_CONTRACT.md (sin cambios); mapa v0.8.

## Estado de la escena

La escena canónica actual sube elevador de Y=0 a 3 y tiene escalera de retorno en G; ambas contradicen el nuevo plano. Reconstruir superficies/particiones, configurar elevador P0↔M (+1,5 m), construir M/S2 y eliminar la escalera de G. Reutilizar circuito, elevador, jugador, HUD y materiales. No borrar prototipos históricos ni alterar contratos.

## Orden

1. Reconstruir P0/P−1: A/B/C, columna, galerías, D1/D2 y S1.
2. Reconfigurar elevador a upper_y=1.5; ajustar compuerta y añadir test de misión.
3. Construir mezzanine M y S2.
4. Construir E/F/G y pasarela sin escaleras a P0.
5. Reintegrar fixtures/interacciones.
6. Actualizar pruebas y ejecutar regresión Fase 0.
7. Probar el recorrido a mano antes de Containment.

~~~sh
godot --headless --path . res://tests/test_phase1_circuit_model.tscn
godot --headless --path . res://tests/test_service_lift.tscn
godot --headless --path . res://tests/test_service_lift_transport.tscn
godot --headless --path . res://tests/test_phase1_canonical_greybox.tscn
godot --headless --path . res://tests/test_phase_0.tscn
~~~

El test genérico puede usar 3 m; el test de misión debe verificar 1,5 m, S2, puertas y pérdida de energía. No puedo ejecutar Godot desde este entorno; registra versión, commit, comandos, salida y exit code cuando se ejecute. Test automático no sustituye playtest.
