You are continuing FINAL THAW in Godot 4.x. This game targets award-worthy quality at The Game Awards, D.I.C.E. Awards, BAFTA Games Awards, and Game Developers Choice Awards.

Read CLAUDE.md and reuse the combat, switching, hazard, checkpoint, and narrative systems. Phases 0–13 are complete with professional-grade foundation.

GOAL
Build the final boss in the atmospheric control chamber. It must require Elena and Marcus coordination, be fully deterministic, readable, and fair. Design with award-quality boss mechanics, arena design, and narrative integration.

BOSS DESIGN
The Helix Retrieval Commander claims the Aster Protocol belongs to Helix. The boss has fixed phases and telegraphed moves: ranged energy blast, temporary shield barrier, reinforcement call, and reactor sabotage attempt.

QUALITY STANDARDS
- Boss can be consistently defeated through learned patterns without random luck
- All attacks are telegraphed and avoidable
- Calibration/switching design requires both characters without creating input confusion
- Retry, save/load, and victory transition are stable
- Accessibility: clear telegraphs, no audio-only information, input remapping, reduced motion option

DELIVERABLES

1. Create scenes/levels/boss_arena.tscn with:
   - Clear chamber layout: reactor/prototype in center or side
   - Three calibration panels (for Elena) positioned around arena
   - Vents/overload panels (environmental actions) in accessible locations
   - Boss center zone (Commander patrols/stands)
   - Fixed reinforcement spawn areas (clear spawn points)
   - Safe movement lanes (cover, barriers, or open space for dodging)
   - Good lighting and readability
   - Environmental storytelling: atmospheric control machinery, Helix equipment, storm visible outside

2. Create boss_helix_commander.tscn (scripts/bosses/boss_helix_commander.gd) with documented deterministic state machine:
   - No random move selection
   - Use repeating or health-threshold-based attack order (e.g., phase 1: blast, shield, reinforcements; phase 2: adds sabotage; phase 3: enraged)
   - Clear state machine: idle, blast, shield, reinforcements, sabotage, vulnerable, defeated
   - Well-commented and debuggable
   - Visible health bar with phase indicators

3. Implement boss moves (all telegraphed, dodgeable, deterministic):

   Ranged Energy Blast:
   - Telegraph: 1.5s aim/windup with clear visual (charge effect, laser sight) and audio cue
   - Dodgeable: clear safe zones or timing window
   - Fixed damage and knockback
   - Cooldown: 3–5s between blasts

   Temporary Shield Barrier:
   - Telegraph: 1s activation with visual (shield glow, barrier appearance) and audio
   - Duration: 5–8s of damage reduction/invulnerability
   - Clearly communicated (UI message, boss glow, or audio)
   - Ends with clear visual/audio feedback

   Reinforcement Call:
   - Telegraph: 2s call animation with audio (radio, beacon, or shout)
   - Fixed reinforcement: 1–2 existing enemy types (scavengers/enforcers) from fixed spawn points
   - Not random: same enemies each call
   - Cooldown: 15–20s between calls

   Reactor Sabotage Attempt:
   - Boss moves to reactor/prototype (clear path)
   - Telegraph: 2s sabotage animation with visual (tools, sparks) and audio
   - Clear warning (UI message: "Boss is sabotaging reactor!")
   - Counterplay: Elena must interact with calibration panel to stop sabotage
   - If uninterrupted: reactor damage (visible feedback, e.g., sparks, alarm)

4. Create three Elena Aster calibration interactions (scripts/components/calibration_panel.gd):
   - Each has visible progress (progress bar or circular indicator, 5–8s)
   - Defined interruption/reset behavior (e.g., Elena hit = reset, or boss sabotage = pause)
   - Nearby/meaningful protection task for Marcus (defend Elena from enemies while she calibrates)
   - Completing each creates fixed boss vulnerability window (5–8s of increased damage)
   - Clear visual/audio feedback for calibration progress, completion, and vulnerability
   - Works with remapped inputs

5. Implement vulnerability windows:
   - During vulnerability: Marcus can deal standard damage (boss takes 2x or normal damage)
   - Outside vulnerability: boss damage reduction/invulnerability (clearly communicated via UI, boss glow, or audio)
   - Clear visual indicator when boss is vulnerable (e.g., boss flashes, UI message, or color change)
   - Deterministic timing (no randomness)

6. Final phase design:
   - Triggered at health threshold (e.g., 30% health)
   - Elena maintains reactor balance through simple repeated interaction/monitoring (e.g., hold button or mash input gently)
   - Marcus stops boss pressure (defends Elena from boss and reinforcements)
   - Keep inputs manageable (not overwhelming)
   - Clear visual/audio feedback for reactor stability
   - Deterministic outcome (no random failure)

7. Add optional environmental actions:
   - Venting steam: telegraphed (1s warning), fixed effect (boss stun or damage over time), visible availability, cooldown/limited charge (e.g., 3 uses)
   - Overload stun: telegraphed (2s charge), fixed effect (boss stun 3–5s), visible availability, cooldown (e.g., 20s)
   - Each must have visible availability, fixed effect, cooldown/limited charge
   - Never mandatory (boss beatable without using them)
   - Clear visual/audio feedback for activation and effect

8. Add boss checkpoint policy:
   - Retries resume at documented fair checkpoint (e.g., start of phase 2 or 3, not full boss)
   - Clear UI message on retry ("Resuming from Phase 2")
   - No loss of progress or frustration
   - Save/load returns to checkpoint with boss state intact

9. Add dialogue and transition to epilogue:
   - Boss defeat: Commander's final lines (2–3 sentences: "Perhaps you are right. But the world will not thank you for this.")
   - Marcus response (1–2 sentences: "It does not need to. It needs to exist.")
   - Transition to epilogue (fade, cut, or walk to next scene)
   - All dialogue skippable and non-blocking
   - Clear audio/visual feedback for victory

10. Add accessibility:
    - Clear visual telegraphs for all boss attacks
    - No audio-only information (visual backup for all audio cues)
    - Input remapping fully honored
    - Reduced motion option (if boss effects are intense)
    - Clear audio/visual feedback for all events

ACCEPTANCE CRITERIA
- Boss can be consistently defeated through learned patterns without random luck
- All attacks are telegraphed and avoidable (no unavoidable damage)
- Calibration/switching design requires both characters without creating input confusion
- Retry, save/load, and victory transition are stable
- Performance is stable at 60 FPS (boss effects optimized)
- All inputs work with remapped bindings

DO NOT
- Randomize boss moves, damage, or behavior
- Create unavoidable damage phases
- Make environmental actions mandatory (must be optional but helpful)
- Lose player progress through save/load or retry

Finish by reporting:
- Changed files with brief descriptions
- Test results (boss tested, all phases tested, save/load verified, accessibility checked)
- Known limitations (be honest)
- Propose this commit message exactly:
Phase 14: final boss battle complete
