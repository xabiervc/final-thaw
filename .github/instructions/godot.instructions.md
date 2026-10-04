---
applyTo: "**/*.tscn,**/*.tres,project.godot"
---

# Godot Project Instructions

- Treat `project.godot` as the canonical Godot project configuration.
- Preserve node paths and resource references unless the task explicitly changes them.
- Do not move or rename scenes, resources, or assets without checking references.
- Prefer small, reversible changes.
- Do not edit `.godot/` generated data.
- Verify scene loading and relevant runtime behavior after changes.
- Record engine-version assumptions in `docs/TECHNICAL_DESIGN.md`.
