# Phase 1 — Lift gate (mission integration decision closed)

**Status:** the service lift is approved for integration into the canonical Phase 1 slice. The existing isolated component is reused; the older question about whether to include it is superseded. No Godot execution or manual validation is claimed.

**Authorities:** `FASE1_FUNCTIONAL_SPEC.md` v1.0 and `FASE1_SPATIAL_GRAPH.md` v0.4.  
**Implementation component:** `scripts/prototypes/service_lift.gd`.  
**Existing tests:** `tests/test_service_lift.tscn` and `tests/test_service_lift_transport.tscn`.

## Decision

Use exactly one elevator/platform in the canonical lift shaft, footprint X=24.5..27.5, Z=-4.5..-1.5, travelling from Y=0 to Y=3. Maintenance starts OFF; the player must activate the maintenance switch in the pit before the elevator can be called. The fixed stairs out of the pit are always usable. Do not build the provisional ramp or the former X=30..34 annex platform. The separate six-room prototype remains a preserved comparison build, not the authority for this route.

## Locked component behaviour

| Rule | Value |
|---|---|
| Landings | `lower` at Y=0 and `upper` at Y=3 |
| Speed | 1.2 m/s; 3 m trip ≈ 2.5 s |
| Docking | Deck flush with the reached landing |
| Gates | Each end opens only when docked at that end; both close while moving |
| Calls | Calls at either landing; calls made during a trip are queued and served after docking/dwell |
| Dwell | 3 s after docking, giving a rider time to disembark |
| Power loss while docked | Remains docked; landing-facing gate stays open; calls are rejected until power returns |
| Power loss while moving | Completes travel at 30% speed to the nearest landing, then remains there and rejects calls until power returns |
| Exact midpoint | Upper landing, matching `platform_y >= midpoint` in the existing component |
| Initial mission state | Docked at lower landing, maintenance OFF and lift unpowered |

If safety behaviour fails during testing, the implementation fails acceptance; do not add rescue mini-games, damage, falls or alternative routes to compensate.

## Wiring into the mission

The mission calls `set_powered(maintenance_on)` when the independent maintenance state changes. The platform itself does not own electrical logic and does not write persistence. Place the controller buttons at the lower landing and the upper landing; interact requests `call_to("upper")` or `call_to("lower")`. No automatic movement begins merely because maintenance turns on.

The lift deck is centred at world position (26,0,-3), with the north end aligned to the upper landing and the south end aligned to the lower connector. The player must board and leave by walking, not by jumping. Gate geometry must prevent entry into the shaft while the deck is absent.

## Existing tests and remaining validation

Run both commands in Godot 4.7.x / Compatibility:

```sh
godot --headless --path . res://tests/test_service_lift.tscn
godot --headless --path . res://tests/test_service_lift_transport.tscn
```

Record exact engine version, output, exit code and commit. Then validate manually: calls from both landings; ten round trips; cut power while docked and near the start, exact midpoint and near the destination; board/ride/disembark without jumping; no sliding or fall; gate readability; camera comfort while riding. The midpoint case is added to acceptance explicitly.

Until these runs are recorded, the component behaviour is specified and implemented in code, but not validated.
