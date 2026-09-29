You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and inspect both character systems and all reusable components. Phases 0–11 are complete.

GOAL
Implement controlled, reliable free switching between Elena and Marcus in the mountain transit hub, then use it in three combined puzzle-combat rooms.

STORY CONTEXT
Elena and Marcus now cooperate, though they disagree over whether saving the climate matters if Helix controls the solution.

CORE RULES
- Player switches via switch_character input.
- The inactive character is safe and predictable. Prefer standing at position with invulnerability only when outside active encounter design; do not allow abuse that trivializes combat. Clearly document exact behavior.
- Camera follows active character. Do not allow switching if a scripted sequence, transition, or invalid state would break it; show clear feedback.

DELIVERABLES
1. Create a reusable CharacterSwitchController and clear HUD active-character indicator.
2. Build scenes/levels/transit_hub.tscn with three sequential rooms:
   - Room 1: Elena disables security via a timed terminal interaction while Marcus protects her from fixed waves.
   - Room 2: Marcus moves a heavy object to create access, then Elena powers a lift.
   - Room 3: Elena controls lighting; darkness enables Marcus's single-target stealth takedown on eligible unaware enemies. Some enemies with lights are immune.
3. Add Elena timed security interaction. It must visibly progress, interrupt under defined conditions, and reset fairly.
4. Add Marcus heavy-object movement using a controlled, collision-safe approach. Avoid emergent physics that risks softlocks.
5. Add lighting state system with clear visual difference, accessibility-safe alternative indicators, and deterministic enemy behavior changes.
6. Create dialogue showing growing respect and the core disagreement. Dialogue is skippable and non-blocking during normal gameplay.
7. At the end, present a clear binary, saved choice: preserve evidence of Helix's earlier Aster failure, or erase it to prioritize immediate activation. Store evidence_choice as preserve or erase.

ACCEPTANCE CRITERIA
- Switching never leaves either character unusable, stuck, duplicated, or without a camera target.
- Each room requires both protagonists in a meaningful way.
- Security, heavy object, lighting, stealth, narrative choice, checkpointing, and save/load work.

Finish with changed files, test results, known limitations, and propose this commit message exactly:
Phase 12: transit hub joint mission complete
