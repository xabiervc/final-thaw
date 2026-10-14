# Phase 1 Visual Audit — First Pass

**Status:** first HUD hierarchy pass committed for review. Not run in Godot; no visual or performance claim is made.

## Scope

Target branch: `feat/godot-vertical-slice`  
Work branch: `feat/godot-vertical-slice`  
Targets: the art wrapper used by the Elena 3D test room (`scripts/levels/lab_art_dressing.gd`) and the gameplay HUD (`scripts/ui/prompt_hud.gd`).

This is a visual/performance pass only. It must not be merged into `main` as part of Phase 0 foundation work. It does not alter gameplay scripts, colliders, interaction nodes, input actions, autoloads, save state, `project.godot`, or renderer selection.

## Change in this pass

The room dressing retains every visible wall-lamp mesh, but emits a dynamic OmniLight3D for every second fixture instead of every fixture. Fixture light energy is lowered from 1.1 to 0.72 and range from 7.5 m to 5.5 m. Shadows remain disabled for these supplementary lights.

Expected effect: preserve industrial lighting rhythm while reducing the number and overlap of local dynamic lights, especially in the 3D test room and on integrated GPUs.

This is a hypothesis until measured. A sparse light pattern may create visibly uneven pools; the owner must compare screenshots and restore/tune the constants if the light rhythm becomes distracting.

### Lighting restraint pass

- Environment glow intensity was reduced from 0.50 to 0.32 and the HDR threshold raised from 1.00 to 1.15. The intent is to keep emissive accents readable without allowing the bloom to dominate edges and nearby surfaces.
- This is a tuning hypothesis for the Compatibility renderer, not a verified improvement. Compare the same camera frame before/after and confirm the scanner, terminal, hazard accents, and door state remain easy to read.

### HUD hierarchy pass

- The objective font was reduced from 22 to 18 px (still scaled by the existing accessibility setting), and long objective text now wraps within a 510 px content width.
- Hint and instruction text now wrap within the same width; the hint font is 15 px and instructions 13 px before accessibility scaling. This removes the former 820 px hint minimum that could dominate a 1280x720 view.
- Status, condition, and interaction prompt typography were reduced modestly; the right-side HUD width was narrowed from 360 to 320 px. Existing accessibility scaling, high-contrast colours, prompt animation, and gameplay setters remain in place.
- These are layout hypotheses, not verified visual outcomes. Check clipping, overlap, readability, and minimum supported resolution in the running game before accepting the pass.

## Known technical risks to inspect

- The original room and art dressing each add lighting/environment settings; inspect their combined result rather than tuning either in isolation.
- Check the alignment and height of the art floor/wall overlays against their greybox meshes.
- Check all mirrored emissive states (scan, generator lever, door, terminal) with the visual component dressing enabled.
- Check HUD layout at 1280x720 and a narrower window; ensure the objective, hint, status, stamina condition, and interaction prompt never overlap or clip.
- Test both `phase1` and `lab` profiles; fixture counts/layout differ.
- Do not enable expensive effects or shadow casting on every fixture merely to compensate for the sparse light setup.
- `MultiMeshInstance3D` batches reduce instance overhead, but do not make shader complexity or texture sampling free.

## Verification protocol

1. Open the canonical checkout on the work branch with Godot 4.7.2.
2. Import project resources and confirm there are no parse/import errors.
3. Run `res://scenes/levels/elena_test_room_art.tscn`; capture at 1280x720 from the gameplay camera.
4. Compare before/after from the same camera and settings: floor/wall separation, fixture pools, emissive clipping, Elena readability, scan visibility and interactive prompts.
5. Run `res://scenes/levels/abandoned_lab_art.tscn` and inspect the whole corridor, especially the two gaps and the hazard room.
6. Measure stable runs with Godot Profiler (CPU/GPU/frame time) on the same device and settings. Record hardware, average frame time, 99th percentile or frame-time distribution, and any frames over 33 ms. Do not infer performance from editor appearance alone.
7. Perform a focused playtest: movement, jumping over barriers, scanning through walls, interaction, save/load and door state.
8. Run the existing Phase 0 acceptance test as a regression check, but do not treat it as art acceptance:
   ```bash
   godot --headless --path . res://tests/test_phase_0.tscn
   ```

## Acceptance criteria

- No script parse errors, missing resources, or broken scene references.
- Gameplay colliders and interaction origins unchanged.
- All prompts and scan highlights remain legible from the gameplay camera.
- Long objective and hint strings wrap cleanly; HUD text stays within the viewport at target and narrow resolutions, with accessibility scaling and high contrast enabled.
- No visible floor/wall z-fighting, holes, overlay drift, or distracting light bands.
- Lighting remains readable in grayscale and respects the style palette: cool desaturated architecture, amber interactive screens, cyan scan/Elena accents.
- Frame-time comparison is recorded on the same machine; the change is accepted only if visual quality is maintained and performance is neutral or improved.
- Owner visual review required before considering this art pass complete.

## Not done

- No Godot runtime execution was available from this connector session.
- No images were rendered and no frame-time measurements were taken.
- No new models or textures were added.
- No gameplay, save, input, autoload, design authority, or Phase 0 contract was changed.
