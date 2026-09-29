You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and inspect existing reusable systems before editing. Phases 0–1 are complete.

GOAL
Create Elena's first complete puzzle chapter: an abandoned laboratory consisting of four compact, sequential puzzle rooms. Use placeholder/stylised art only.

STORY CONTEXT
Elena escapes with the Aster Protocol prototype. In this laboratory, she discovers Helix withheld a viable stabilisation method because it could not control distribution. She retrieves a partial transmission for the future Final Thaw Station.

REUSABLE SYSTEMS TO BUILD
- A lightweight skippable narrative/message panel that does not pause gameplay by default.
- Room completion/checkpoint system using GameManager.
- Reusable powered terminal, door, moving platform, hazard zone, and prototype-carrier components where practical.
- Elena must have has_aster_prototype state. It should be saved.

ROOMS
1. Lab Room 1: restore power. A fixed, clearly indicated terminal connection sequence opens the exit.
2. Lab Room 2: redirect a robotic arm. A terminal cycles the arm through fixed positions; only one permits passage.
3. Lab Room 3: traverse using a moving platform. Its cycle is fixed, readable, and optionally callable from a button. Never require frame-perfect timing.
4. Lab Room 4: prototype calibration chamber. Elena carries a visibly glowing prototype through telegraphed hazard zones. Sustained hazard exposure lowers Prototype Integrity only once per defined hazard event/checkpoint; reaching exit without damage preserves it.

REQUIREMENTS
- Every puzzle solution is fixed and readable.
- Wrong input resets only the local mechanism quickly; no long penalties.
- Connect rooms in order and save after each room.
- Show short narrative messages on room entry and puzzle completion.
- The final exit marks Phase 2 complete and presents a temporary return-to-menu or next-phase placeholder transition.

ACCEPTANCE CRITERIA
- A player can play all four rooms from start to finish without developer console actions.
- All doors, terminals, arm positions, platform motion, hazards, checkpointing, and prototype integrity work after a save/load.
- No puzzle is randomized or soft-lockable.

Finish with changed files, test results, known limitations, and propose this commit message exactly:
Phase 2: abandoned laboratory puzzles complete
