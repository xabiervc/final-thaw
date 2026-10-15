# Project Status — FINAL THAW

## Current phase

**Playable demo: Phase 1 "The Ghost Protocol" and Phase 2 "Containment", one continuous scene, with intro and ending cinematics. Automated tests and a route bot verify it; it has had no human playtest yet. Performance reaches 60 FPS on the reference GPU only with the "Performance" graphics preset.**

The main menu's "Iniciar demo" opens `scenes/prototypes/phase1_canonical_greybox.tscn`:
- an intro cinematic (about 51 s, skippable);
- the investigation inside the Helix facility;
- the Containment escape through the building and into the service yard (no scene change);
- an ending cinematic (about 37 s, skippable);
- results, then back to the menu.

The as-built record, its design decisions and the measured performance are in [`docs/design/FASE1_PREMIUM_AUDIT.md`](docs/design/FASE1_PREMIUM_AUDIT.md) (v4.0). Where a v2.1 spec disagrees with it, v4.0 and the scene win.

## Verified by automated tests

**Latest full run (2026-10-15):** after the illustrated art proof, on the tree now committed as `bf67912`, `b85b8ab` and `851dfe1`. Only documentation was committed on top.
- Setup: Godot 4.7.2-stable, Windows 10, Intel HD 630 (Compatibility/ANGLE), `tools/run_tests.sh`.
- Result: all 33 suites exit 0, with 1051 PASS checks, 0 FAIL and 0 script errors.
- The first run of `test_elena_animations` failed one check: the new `scan` clip is standing capture (hips sway 4.6 cm, feet pinned), so it moved to the standing-clip limits. The suite then passed 84/84.

Earlier baseline: commit `1ad45d8`, all 32 suites exit 0, with 932 PASS checks (plus two suites that print a single PASS), 0 FAIL and 0 script errors.

- **Full route on real inputs** (`test_phase1_playthrough`, 64 checks), tunnel to street:
  - investigation, puzzle, record, G, Containment;
  - lift, R1, gallery, yard response;
  - O3 aperture and emergency lane;
  - ending and results; the game is never left paused.
- **Negative paths:**
  - reading the record alone never starts Containment;
  - G refuses before the record is read;
  - the hypothesis needs evidence beyond the schematic;
  - a second G opening sends no second audit.
- **Live escape against the real unit** (`test_phase1_escape_live`): a careful first attempt escapes without a catch; the run starts from a real reacquisition; the unit physically follows to the lower level.
- **Recovery unit** (`test_phase1_containment`, 33 checks):
  - senses: cone, floors, crouch, darkness, hearing;
  - suspicion stage that decays without an alert once line of sight breaks;
  - lift ride, R1 reacquisition, pursuit camera;
  - loss of contact, trail check, search, then return to the sweep;
  - noise misdirection; difficulty changes its real parameters;
  - catch and restore, never inside geometry.
- **Movement** (`test_elena_movement`, 17 checks): speeds; turns keep momentum; 0.13 s reversal; fatigue floor; crouch under low ceilings; mantle rules; jump height.
- **Systems** (`test_game_systems`, 56 checks):
  - every key in ES and EN, and every key used in code exists;
  - field-note derivation; colour-blind palette;
  - options with an observable effect (game speed, volumes, subtitles, graphics);
  - remapping: conflict swap, defaults, persistence through the JSON/CRC32 save, and older saves still load;
  - injected gamepad stick and button events; intro skip safety; pause menu.
- **Structure and contracts:** canonical, edges, navigation, layout, interactions, circuit model (contract unchanged), lift. Phase 0 still passes 7/7.

Visual review captures, kept outside the repository in `D:/Projects/evidence/final-thaw/master_2026-10-15/`, covered: intro shots, ending shots, yard views, pause and notes, options, main menu, credits, the unit model sheet and the gait sheet.

## Implemented but not verified by a person

- Feel and fun: movement, pursuit tension, puzzle clarity without hints, camera comfort.
- A real gamepad (only injected events were tested; no hardware was available).
- Audio: music, effects and mix are synthesised placeholders and have **not been listened to**.
- English text was reviewed only as text.

## Known limitations

- **Art:**
  - The illustrated style (`docs/art/ASSET_PRODUCTION_BIBLE.md`, "Illustrated style") is applied to the building, its hall and Elena: painted textures, half-tone light, ink line.
  - The rest of the city is still boxes. The recovery unit is a generated model with no concept art.
  - Elena v2 uses MakeHuman CC0 assets, licence verified on 2026-10-15. Her Aster scanner is a wrist unit on the left forearm.
  - Register: `docs/art/MASTER_ASSET_LIST.md`.
- **Animation:**
  - Elena's locomotion is CMU motion capture retargeted to her rig: idle, walk, run, sprint, crouch, jump/fall/land, start/stop, turns, alert and the wrist scan.
  - `climb`, `interact` and `caught` are still procedural.
  - No crawl or hit reaction. Low passages are taken crouched (R1 shutter, boom barrier).
- **Voice:** none. Lines and public-address announcements are subtitles, plus a chime for the PA.
- **Saves:** Phase 1/2 progress is session-only by contract; options are saved.
- **Legacy actions:** the Phase 0 combat and legacy actions remain defined (contract) but unused. Captions, font and colour-blind hotkeys have no handler; the same options exist in the menu.
- **Untested:** Web export; any GPU other than the HD 630.

## Outstanding defects

None known that block progression. Polish issues: dim corners in the pit and pump room, some world labels are small, and the city backdrop is basic.

## Performance status

**Measured 2026-10-15, after the illustrated art pass.** Intel HD 630 at 1280×720. Median of 300 frames after 300 warm-up frames (`tools/capture/scene_capture.tscn --bench`, `--graphics=<preset>`). Six views: hall, pump gallery M, control P2, pit, entry channel, and the yard with the Containment floodlights on.

| Driver | Preset | Six views (ms) | 60 FPS (16.7 ms) |
|---|---|---|---|
| ANGLE on Direct3D 11 (Godot's choice for this GPU) | Balanced (default) | 23.3–29.9 | not met (33–43 FPS) |
| ANGLE | Performance | 19.8–24.6 | not met (41–50 FPS) |
| Native OpenGL 3.3, Intel driver 31.0.101.2112 | Balanced | 7.7–9.5 | met (105–130 FPS) |
| Native OpenGL | High (glow) | 8.7–10.4 | met |

**What changed.** Before this pass, Balanced measured 17.2–21.2 ms and Performance reached 60 FPS indoors. The illustrated pass added the hall art, painted materials, the ink line, Elena v2 and more lights. On ANGLE that raised the hall from 19.0 to 29.2 ms at Balanced.

**Root cause.**
- Godot replaces native OpenGL with ANGLE on this GPU because the driver is on its `rendering/gl_compatibility/force_angle_on_devices` list. Here ANGLE costs about 3×: the same hall frame takes 9.4 ms native, 29.2 ms on ANGLE.
- Profiling (`--tweak`, `--report` in `scene_capture.gd`) shows that the ANGLE cost tracks draw calls, per-object lights and material setup, not pixel shading. Rendering 3D at a quarter of the resolution is slower than at full resolution.

**Fixes applied in this pass:**
1. Diffuse-only environment, which is also the illustrated-style rule: −2 to −3 ms on ANGLE.
2. Flat-colour materials merged into vertex-colour palette batches: 41–53 fewer draws per view, about −0.5 ms.
3. VRAM compression and mipmaps for 167 textures that had been imported raw: VRAM 301 → 131 MB.
4. The 12 m batch cell confirmed as the best size: 8 m and 24 m cells were both slower.

Tried and rejected: per-vertex lighting (it loses the light pools and saves only 2 ms) and 3D render scaling.

**Owner decision needed: native OpenGL on Intel Gen9.** It needs a change to `project.godot` (AGENTS.md: owner approval required).
- **Change:** remove the HD 630 family from `rendering/gl_compatibility/force_angle_on_devices`. Keep `fallback_to_angle` on, so a driver that fails to create a context still gets ANGLE.
- **Impact:** about 3× faster on this machine (every preset ≥ 100 FPS). No change on other GPUs. The rendered output in the review views is the same.
- **Risk:** Godot lists these drivers for known OpenGL quality problems. Only one driver version was tried (31.0.101.2112), and it showed a 45 ms shader-compilation hitch at start-up.
- **Alternative:** ship ANGLE and treat the HD 630 as below minimum spec, measuring the minimum spec on the planned new PC.

The earlier figures and the full diagnosis are in the as-built record, §9 and §9.1.

## Next highest-value work

1. Human playtest of the whole demo with first-time players. Record time, catches, hints, where they got lost, and whether they can answer the narrative acceptance questions in `docs/narrative_complete.md`.
2. Real gamepad pass and audio listening pass; fix what they reveal.
3. Owner decision on native OpenGL for Intel Gen9 (see "Performance status"), then profile on the planned new PC.
4. Replace Elena's remaining procedural clips (`climb`, `interact`, `caught`) with captured or keyed motion.

Preserve the autoloads, the Phase 0 InputMap action names, resource paths, JSON/CRC32 save compatibility and the Compatibility renderer.

## Owner-approved redesign target and evidence boundary — 2026-10-15

The owner has approved a substantial refinement of the current vertical-slice direction. The current as-built descriptions and test results above remain historical evidence for the recorded commits; they must not be mistaken for proof that the redesign below is already implemented.

### Approved target
- **Art:** illustrated 3D adventure, using the owner-provided Marcus character concept and illustrated industrial laboratory reference. Not photorealistic, not generic cartoon and not deliberately low-resolution retro-console styling. Validate character and environment treatment in Godot before scaling production.
- **Phase 1:** a substantially interconnected industrial research facility anchored by the large central pumping hall, with purposeful rooms, verticality, landmarks, secrets and causal environmental interactions. Avoid a maze and repetitive backtracking. Elena enters through a damaged service breach/culvert that physically collapses behind her.
- **Phase 2:** a human operational zone connected to Helix/Aster; Elena observes personnel and discovers meaningful information before detection. The target escape is hybrid first-person gameplay combining free movement/route choice with short contextual actions and brief consequence-revealing glances back. It leads through a separately designed parking garage to a public street where Elena loses the pursuers among pedestrians.
- **Elena's scanner:** redesign its mounting/use so it is credibly wrist-mounted or holstered, or provide proper draw/use/stow animation; it must not look stuck to her hand.
- **Future Marcus phases:** Marcus is player-controlled in beat-'em-up phases. Elena begins unable to defend herself and relies on him, then learns limited defensive skills from him and becomes more autonomous. Later encounters can challenge Marcus with stronger/more coordinated enemies. This is a future design contract, not current vertical-slice implementation scope.

### Required next work, in order
1. Reconcile the real branch state, current commits, local changes and test results; do not rely on prior-agent claims alone.
2. Prove the illustrated style in one playable Godot section with Elena and the central-hall art language.
3. Refine Phase 1's interconnected layout, traversal, puzzle context and physically blocked entry.
4. Design and implement the human operational discovery and hybrid first-person escape, including the distinct parking garage and public exit.
5. Update existing art, narrative, level, traceability and status documents to match the actual implementation.
6. Keep the full Marcus beat-'em-up system deferred; preserve its future progression contract in design documents.

The current code and test evidence above describe the previous robot-led, one-scene escape prototype. They must remain clearly distinguished from this approved target until the replacement is committed, the full test suite is rerun and the relevant route is reviewed in Godot. No new runtime, visual or performance verification is claimed by this documentation update.
