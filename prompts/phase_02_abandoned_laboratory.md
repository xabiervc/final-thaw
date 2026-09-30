You are continuing FINAL THAW in Godot 4.x. This game targets award-worthy quality at The Game Awards, D.I.C.E. Awards, BAFTA Games Awards, and Game Developers Choice Awards.

Read CLAUDE.md and inspect existing reusable systems before editing. Phases 0–1 are complete with professional-grade foundation.

GOAL
Create Elena's first complete puzzle chapter: an abandoned laboratory with four compact, sequential puzzle rooms. Use placeholder/stylised art only, but design with award-quality readability, pacing, and accessibility.

STORY CONTEXT
Elena escapes with the Aster Protocol prototype. In this laboratory, she discovers Helix withheld a viable stabilisation method because it could not control distribution. She retrieves a partial transmission for the future Final Thaw Station.

QUALITY STANDARDS
- Every puzzle must be readable within 5 seconds of entering the room
- Wrong input resets only the local mechanism quickly (under 3 seconds)
- No frame-perfect timing or pixel-perfect movement
- Environmental storytelling carries 60%+ of narrative (show, don't tell)
- Accessibility: colorblind-safe indicators, generous timing, no audio-only information

REUSABLE SYSTEMS TO BUILD
- Lightweight skippable narrative/message panel (does not pause gameplay by default)
- Room completion/checkpoint system using GameManager with visible feedback
- Reusable components: powered_terminal, door, moving_platform, hazard_zone, prototype_carrier
- Elena must have has_aster_prototype state (saved, visible in HUD or narrative)

ROOMS (design each with clarity and polish)

1. Lab Room 1 — Restore Power (5–7 min)
   - Fixed, clearly indicated terminal connection sequence opens exit
   - Visual clues show correct order (cable colors, labels, or symbols)
   - Wrong connection resets only that terminal quickly
   - Environmental storytelling: abandoned lab, emergency lights flickering
   - Narrative message on entry and completion

2. Lab Room 2 — Redirect Robotic Arm (7–10 min)
   - Terminal cycles arm through 3–4 fixed positions
   - Only one position permits safe passage (clearly telegraphed)
   - Arm movement is smooth, readable, with audio/visual cues
   - Wrong position: arm blocks path or triggers minor hazard (non-lethal, resets quickly)
   - Environmental storytelling: automation left running, no humans

3. Lab Room 3 — Moving Platform Traversal (7–10 min)
   - Platform cycle is fixed, readable, with clear indicator
   - Optionally callable from button (player controls timing)
   - Never require frame-perfect timing; generous windows
   - Platform has clear start/end positions with visual markers
   - Environmental storytelling: maintenance access, elevated walkway

4. Lab Room 4 — Prototype Calibration Chamber (10–12 min)
   - Elena carries visibly glowing prototype (particle or light effect)
   - Traverse telegraphed hazard zones (electrical, steam, or radiation)
   - Sustained hazard exposure lowers Prototype Integrity once per defined hazard event/checkpoint
   - Reaching exit without damage preserves integrity
   - Clear visual/audio telegraphs before hazard activates
   - Checkpoint mid-room to avoid excessive backtracking
   - Narrative: this is where Aster was tested, evidence of success

GENERAL REQUIREMENTS
- Connect rooms in order with clear transitions
- Auto-save after each room completion with visible confirmation
- Show short narrative messages on room entry and puzzle completion (2–3 sentences max)
- Final exit marks Phase 2 complete with temporary return-to-menu or next-phase placeholder transition
- All puzzles are fixed and readable; no randomization
- All interactables work with remapped inputs
- All visual indicators work for colorblind players
- Performance: 60 FPS stable, no stutter

ACCEPTANCE CRITERIA
- A player can complete all four rooms from start to finish without developer console actions
- All doors, terminals, arm positions, platform motion, hazards, checkpointing, and prototype integrity work correctly after save/load
- No puzzle is randomized, soft-lockable, or confusingly telegraphed
- Narrative messages are skippable and non-blocking
- Environmental storytelling is clear without exposition dumps
- Code is modular, commented, and reusable

DO NOT
- Add combat, enemies, or time pressure beyond natural puzzle pacing
- Create puzzles requiring precise timing or pixel-perfect movement
- Use color-only indicators (always add shape, brightness, or text)
- Write lengthy narrative text (show through environment)

Finish by reporting:
- Changed files with brief descriptions
- Test results (each room tested, save/load tested, accessibility verified)
- Known limitations (be honest)
- Propose this commit message exactly:
Phase 2: abandoned laboratory puzzles complete
