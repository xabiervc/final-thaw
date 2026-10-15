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

Commit `1ad45d8`, Godot 4.7.2-stable, Windows 10, Intel HD 630 (Compatibility/ANGLE). All 32 suites exit 0: 932 PASS checks plus two suites that print a single PASS, 0 FAIL, 0 script errors.

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

- **Art:** the building is a textured greybox; the city is boxes; the recovery unit is a generated model with no concept art; Elena uses an MPFB base whose asset licence is **not yet verified**. Register: `docs/art/MASTER_ASSET_LIST.md`.
- **Animation:** procedural clips. No turn-in-place, start/stop, dedicated sprint, crawl or hit-reaction. Low passages are taken crouched (R1 shutter, boom barrier).
- **Voice:** none. Lines and public-address announcements are subtitles, plus a chime for the PA.
- **Saves:** Phase 1/2 progress is session-only by contract; options are saved.
- **Legacy actions:** the Phase 0 combat and legacy actions remain defined (contract) but unused. Captions, font and colour-blind hotkeys have no handler; the same options exist in the menu.
- **Untested:** Web export; any GPU other than the HD 630.

## Outstanding defects

None known that block progression. Polish issues: dim corners in the pit and pump room, some world labels are small, and the city backdrop is basic.

## Performance status

Median frame time, HD 630, 1280×720; the yard figures are measured with the Containment floodlights on:

| Preset | Interiors | Lit yard | Target (16.7 ms) |
|---|---|---|---|
| Balanced (default) | 17.2–19.0 ms | 20.1–21.2 ms | not met |
| Performance | 15.8–16.2 ms (60 FPS) | 17.8–19.1 ms | met indoors; yard 1–2.4 ms over |
| High | adds glow, about 2 ms | — | not met |

The bottleneck is mostly fill rate at 720p on this GPU. 3D render scaling makes it worse on this renderer. Details and the next steps are in the as-built record, §9.

## Next highest-value work

1. Human playtest of the whole demo with first-time players. Record time, catches, hints, where they got lost, and whether they can answer the narrative acceptance questions in `docs/narrative_complete.md`.
2. Real gamepad pass and audio listening pass; fix what they reveal.
3. Close the remaining 1–2 ms in the yard (light count, shadow distance) and profile on the planned new PC.
4. Animation gaps (turn, start/stop, sprint) and enemy concept art leading to a final model.
5. Verify the MPFB licence or replace Elena's base mesh.

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
