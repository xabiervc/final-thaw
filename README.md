# FINAL THAW

**A climate-thriller sci-fi adventure about investigation, physical risk, and consequential discoveries.**

The current working direction is an Elena-led opening: investigate a Helix/Aster system, uncover evidence, then escape a containment response through traversal and stealth. This is a prototype hypothesis, not yet the locked full-game scope.

## Current prototype

The branch `feat/godot-vertical-slice` contains the **motion/chase prototype v2**:
- third-person camera and movement;
- walk/run/crouch/jump;
- gaps, low passage, authored climb and elevated route;
- a recovery unit with patrol, investigate, alert, chase, search and return states;
- noise, line of sight, scanner reveal, checkpoints and escape completion.

Open `scenes/prototypes/motion_chase_prototype.tscn` in Godot and run it with F6. The implementation and known limitations are documented in [Motion and chase prototype](docs/design/MOTION_CHASE_PROTOTYPE.md). The v2 test is currently documented as not yet run; do not assume it passes.

The branch also retains earlier Flooded Shelter 2.5D and Elena test-room experiments. They remain available for comparison and reusable components.

## Current design documents

1. [Working vision](docs/VISION.md)
2. [Design pivot and prototype brief](docs/DESIGN_PIVOT_PROTOTYPE_BRIEF.md)
3. [Motion/chase prototype specification](docs/design/MOTION_CHASE_PROTOTYPE.md)
4. [Core gameplay loop](docs/CORE_LOOP.md)
5. [Level structure](docs/LEVEL_STRUCTURE.md)
6. [Project status and evidence boundary](PROJECT_STATUS.md)
7. [Traceability matrix](docs/TRACEABILITY_MATRIX.md)
8. [Design authority](docs/DESIGN_AUTHORITY.md)
9. [Asset provenance and licences](docs/art/PROVENANCE.md)

The older 16-phase, dual-protagonist campaign documents are retained as historical design material while the prototype is evaluated. They are not automatically binding requirements for the new prototype.

## Engine and technical constraints

- Engine: Godot 4.7.x (see project status for the recorded patch).
- Language: GDScript.
- Renderer: Compatibility, pending evidence-based review.
- Preserve Phase 0 input, autoload, resource, save and CRC32 contracts.
- Profile the actual target before making renderer or platform changes.
- Do not claim performance, accessibility, playability or production readiness without recorded evidence.

## Verification commands

Run from the repository root:

```sh
godot --headless --path . res://tests/test_motion_chase_prototype.tscn
godot --headless --path . res://tests/test_phase_0.tscn
```

Then run the prototype manually. Automated tests do not verify camera comfort, movement feel, enemy fairness, audio quality or whether the chase is fun.

## Asset and development workflow

Treat existing character models, lab kit, shaders, visual wrappers, scanner effects, HUD and synthesized audio as prototype assets. Review them from the intended third-person camera and verify collision, scale, traversal clearance, occlusion, provenance and licensing before production use.

Keep changes narrow and reversible. Do not remove earlier scenes, change the save schema, or rewrite the full campaign until the combined puzzle/escape prototype has passed owner review.
