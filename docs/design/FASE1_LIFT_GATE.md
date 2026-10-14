# Phase 1 — Lift gate (mission integration decision closed, v1.1)

**Estado:** se conserva el componente genérico y se decide una parada de misión distinta al prototipo actual. Sin ejecución ni validación física claimada.

## Decisión

Un único elevador X=24,5..27,5, Z=−4,5..−1,5, entre P0 (Y=0) y M (Y=+1,5). No sube a P2 (+3 m); S2 conecta M con control. Mantenimiento empieza OFF; el switch en D lo habilita. No construir rampa ni plataforma extra.

El componente genérico conserva lower_y=0 y upper_y=3 en tests unitarios. La instancia de misión fija lower_y=0 y upper_y=1.5 antes de entrar al árbol. Añadir test de misión para 1,5 m.

| Regla | Valor |
|---|---|
| Paradas | P0 Y=0; M Y=+1,5 |
| Velocidad | 1,2 m/s; viaje de 1,5 m ≈ 1,25 s |
| Puertas | Solo abre lado acoplado; cierran durante movimiento |
| Llamadas | En ambos rellanos; llamadas durante viaje encoladas |
| Espera | 3 s |
| Mantenimiento OFF | Permanece acoplado y rechaza llamadas |
| Pérdida de energía en viaje | Reserva de seguridad hasta la parada más cercana |
| Punto medio | M (+1,5 m) |
| Estado inicial | P0; mantenimiento OFF |

Una detención entre niveles, caída, paso al hueco o rescate manual es fallo de aceptación.

Centros de compuertas fijas: inferior (26,0.55,−1.49), superior (26,2.05,−4.49), alineadas con los bordes del hueco en P0 y M. Barandillas laterales fijas protegen ambos lados del hueco en las dos cotas; los pasamanos de S1/S2 siguen la pendiente. No abrir al hueco cuando el deck no está acoplado.

~~~sh
godot --headless --path . res://tests/test_service_lift.tscn
godot --headless --path . res://tests/test_service_lift_transport.tscn
~~~

Mantener tests genéricos a 3 m; añadir test de misión a 1,5 m, test canónico actualizado y regresión de tests/test_phase_0.tscn. Registrar engine, commit, salida y exit code. Hasta entonces está especificado, no verificado.
