# FINAL THAW

**A climate-thriller sci-fi adventure about investigation, physical risk, and consequential discoveries.**

Final Thaw is being reconsidered around a compact, Elena-led third-person 3D prototype: first an investigation/system puzzle, then a physical escape under pursuit. This is the current design hypothesis, not yet a locked full-game scope.

## Current status

The branch `feat/godot-vertical-slice` contains several prototypes from earlier design iterations:
- The Flooded Shelter 2.5D interaction/oxygen/rescue slice.
- An early 3D test room for Elena movement, interaction, scanning, presentation, and audio experiments.
- Lab geometry, materials, environmental art, character models, shaders, and tooling.

These are experiments and reusable source material. They are not proof that the new traversal/chase design has been implemented or validated.

**Next design goal:** build and playtest a small third-person 3D proof of concept that demonstrates movement, jump/landing, crawl, climb, an understandable pursuer, and a compact investigation puzzle. Do not expand content or production art before that test is successful.

See:
- [Design pivot and prototype brief](docs/DESIGN_PIVOT_PROTOTYPE_BRIEF.md) — current working direction and acceptance gate.
- [Project status](PROJECT_STATUS.md) — implementation evidence and known gaps.
- [Design authority](docs/DESIGN_AUTHORITY.md) — documents and conflict policy.
- [Art provenance and licences](docs/art/PROVENANCE.md) — external-resource and licence tracking.

## Engine and technical constraints

- Engine: Godot 4.7.x (verified patch documented in Project Status).
- Language: GDScript.
- Renderer: Compatibility pending an explicit evidence-based decision.
- Current technical base and Phase 0 contracts remain protected.
- The existing Web target is a technical constraint to evaluate, not a reason to compromise the quality of camera and traversal mechanics without measurement.
- Do not claim performance, accessibility, playability, or production readiness without recorded evidence.

## Quick start

1. Clone the repository and check out `feat/godot-vertical-slice`.
2. Open the repository root's `project.godot` in Godot 4.7.x.
3. Run the current project and inspect the debugger.
4. Run the Phase 0 acceptance test:

```text
godot --headless --path . res://tests/test_phase_0.tscn
```

The legacy scenes remain available for comparison. Their presence does not make their level design or camera direction binding for the new prototype.

## Design and AI-assisted development

Read `docs/DESIGN_AUTHORITY.md`, `docs/PROJECT_CONTRACT.md`, `docs/QUALITY_GATES.md`, and `AGENTS.md` before substantial work. The new brief supersedes legacy structural gameplay assumptions for the next prototype only; it does not silently rewrite save contracts or claim the complete game has been redesigned.

Keep changes narrow and reversible. Record test procedures and observed results. Do not remove prior prototypes or rewrite the entire art pipeline until a playable comparison justifies it.
