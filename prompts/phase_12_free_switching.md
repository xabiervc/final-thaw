You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and inspect both character systems and all reusable components. Phases 0–11 are complete.

**AWARD-LEVEL QUALITY STANDARD**: Character switching must feel emotionally meaningful, not just mechanical. Synergy combos should require genuine coordination and reward mastery. This is the gameplay peak of Act II.

GOAL
Implement controlled, reliable free switching between Elena and Marcus in the mountain transit hub, then use it in three combined puzzle-combat rooms.

STORY CONTEXT
Elena and Marcus now cooperate, though they disagree over whether saving the climate matters if Helix controls the solution.

CORE RULES
- Player switches via switch_character input.
- The inactive character is safe and predictable. Prefer standing at position with invulnerability only when outside active encounter design; do not allow abuse that trivializes combat. Clearly document exact behavior.
- Camera follows active character. Do not allow switching if a scripted sequence, transition, or invalid state would break it; show clear feedback.

SYNERGY COMBOS (Award-Level Innovation)
1. **Shield Hack + Flank**: Elena hacks enemy shield (3s window), Marcus must flank and eliminate before reactivation
2. **Throw to Terminal**: Marcus throws Elena across 4m gap to reach inaccessible terminal
3. **Lighting + Stealth**: Elena controls lighting; darkness enables Marcus stealth takedown on unaware enemies (immune if lit)
4. **Dual Calibration**: Both must calibrate separate terminals simultaneously (requires fast switching)

DELIVERABLES
1. Create a reusable CharacterSwitchController and clear HUD active-character indicator with diegetic styling. Include 0.3s transition effect (fade or wipe).
2. Build scenes/levels/transit_hub.tscn with three sequential rooms designed for 10-15 minute playthrough:
   - **Room 1**: Elena disables security via timed terminal interaction while Marcus protects her from 3 waves. Include Shield Hack synergy (Elena hacks, Marcus flanks shielded enemy).
   - **Room 2**: Marcus moves heavy object (crate/bridge) to create access, then Elena powers lift. Include Throw synergy (Marcus throws Elena to upper platform if she misses jump).
   - **Room 3**: Elena controls lighting; darkness enables Marcus single-target stealth takedown on eligible unaware enemies. Some enemies with lights are immune. Include Lighting + Stealth synergy.
3. Add Elena timed security interaction. It must visibly progress (0-100% bar), interrupt under defined conditions (enemy proximity, timer), and reset fairly (3s cooldown before retry).
4. Add Marcus heavy-object movement using a controlled, collision-safe approach. Avoid emergent physics that risks softlocks. Object moves at 50% Marcus speed, cannot be thrown while carrying.
5. Add lighting state system with clear visual difference (bright/dim/off), accessibility-safe alternative indicators (audio cue, UI icon), and deterministic enemy behavior changes (unaware in dim, alert in bright).
6. Create dialogue showing growing respect and the core disagreement. Dialogue is skippable and non-blocking during normal gameplay. Include:
   - **Room 1 start**: Marcus: "You handle the terminal. I'll keep them off you." Elena: "Try not to die. I need you for the next one."
   - **Room 2 mid**: Elena: "Your methods are crude, but effective." Marcus: "Your plans need someone to watch your back."
   - **Core disagreement**: Marcus: "If we deploy through Helix, we stabilise the climate and hand them the queue." Elena: "If we delay to expose them, people die while we argue."
   - **Final choice setup**: Marcus: "Then we do both. But someone has to choose which comes first."
7. At the end, present a clear binary, saved choice: preserve evidence of Helix's earlier Aster failure, or erase it to prioritize immediate activation. Store evidence_choice as "preserve" or "erase". Show consequences preview: "Preserve: Expose Helix, risk delay" / "Erase: Immediate activation, Helix controls narrative."
8. Add 3-4 memory fragments (2 Elena, 2 Marcus) hidden in rooms. Collecting all unlocks debug achievement "Transit Complete."
9. Implement adaptive music: Minimal in exploration, percussion layers in combat, full orchestral during synergy combos.

ACCEPTANCE CRITERIA
- Switching never leaves either character unusable, stuck, duplicated, or without a camera target.
- Each room requires both protagonists in a meaningful way.
- All synergy combos function correctly and feel rewarding.
- Security, heavy object, lighting, stealth, narrative choice, checkpointing, and save/load work.
- Dialogue feels earned, not forced.
- Adaptive music transitions smoothly (2-3s crossfade).

Finish with changed files, test results (verify all 4 synergy combos), known limitations, and propose this commit message exactly:
Phase 12: transit hub joint mission complete with synergy combos and character switching
