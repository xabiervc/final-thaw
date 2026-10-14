# Elena — animations (MPFB rig)

Status: **13 procedural animations embedded in `assets/models/lab_ref/ref_elena_mpfb.glb`; verified in Godot 4.7.2 by `tests/test_elena_animations.tscn` (75 checks) and by contact-sheet captures. Not wired into `elena_controller.gd`, not reviewed in a playtest, not final.** They are keyed by script, not hand-animated or mocap: they read correctly as poses and cycles but are stiff.

Same skeleton and bone names as the model (53 bones, `game_engine` rig), front = +Z, 30 fps, no root motion: the pelvis only changes height (so the feet stay on the floor in the grounded animations) and its horizontal drift is under 1.3 cm.

## Exact names in the file (Godot `AnimationPlayer` on the imported scene)

| Name | Length | Loop | Notes |
|---|---|---|---|
| `idle` | 3.0 s | yes | subtle breathing, arms relaxed (not fully down, the long coat would clip) |
| `walk` | 1.0 s | yes | two steps, arm counter-swing |
| `run` | 0.67 s | yes | forward lean, bent elbows |
| `crouch_idle` | 3.0 s | yes | ankles kept under the hips, torso forward |
| `crouch_walk` | 1.2 s | yes | |
| `jump` | 0.77 s | no | anticipation, push-off, rise and tuck (airborne part does not lift the pelvis: Godot moves the body) |
| `fall` | 1.0 s | yes | held, arms out |
| `land` | 0.37 s | no | absorb then stand, chains into `idle`/`walk` |
| `climb` | 1.47 s | no | reach, pull, knee up, push to stand; in place |
| `scan` | 1.47 s | no | right arm (the Aster hand) raised, head sweep |
| `interact` | 1.17 s | no | right arm reaches and presses |
| `alert` | 0.57 s | no | quick stiffening, head turn |
| `caught` | 1.17 s | no | stagger back and slump to kneeling; the last frame is held for the restart |

Looping animations are closed (last key equals the first) and the loop mode is set in `ref_elena_mpfb.glb.import` (`_subresources` → `settings/loop_mode`), so Godot imports them looping. Non-looping ones end on their last pose.

## Regenerate

```text
blender --background --factory-startup --python tools/blender/elena_mpfb/animate_elena.py -- --repo <repo> --blend <elena_mpfb_baked.blend> --blend-dir <dir>
```

The input is the `.blend` written by `bake_elena.py` (outside the repo). The script overwrites `ref_elena_mpfb.glb`; re-run `bake_elena.py` first if the model changed, then this script.

## Known limits

- Fingers, face and hair do not animate; the Aster and backpack follow their bones.
- The coat, hair cards and backpack are rigid-skinned to bones: expect some clipping at the shoulders in the deepest arm poses and at the knees in crouches.
- The hip/knee solver keeps ankles under the hips for crouches; foot sliding in `walk`/`run` against a moving body has not been tuned against the controller's real speed.
- Not tested: blending between animations, an `AnimationTree`, or the controller driving them.
- `jump`, `fall` and `land` are separate clips; the controller must sequence them.
