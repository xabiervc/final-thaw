You are continuing FINAL THAW in Godot 4.x. This game targets award-worthy quality at The Game Awards, D.I.C.E. Awards, BAFTA Games Awards, and Game Developers Choice Awards.

Read CLAUDE.md and inspect both character systems and all reusable components. Phases 0–11 are complete with professional-grade foundation.

GOAL
Implement controlled, reliable free switching between Elena and Marcus in the mountain transit hub, then use it in three combined puzzle-combat rooms. Design with award-quality switching mechanics, arena design, and narrative integration.

STORY CONTEXT
Elena and Marcus now cooperate, though they disagree over whether saving the climate matters if Helix controls the solution.

CORE RULES
- Player switches via switch_character input (bound to Q or Tab by default, remappable)
- Inactive character is safe and predictable: prefer standing at position with invulnerability only when outside active encounter design; do not allow abuse that trivializes combat
- Clearly document exact behavior in comments and CLAUDE.md
- Camera follows active character; do not allow switching if scripted sequence, transition, or invalid state would break it; show clear feedback

QUALITY STANDARDS
- Switching never leaves either character unusable, stuck, duplicated, or without camera target
- Each room requires both protagonists in meaningful way
- Security, heavy object, lighting, stealth, narrative choice, checkpointing, and save/load all work flawlessly
- Accessibility: clear visual indicators for active character, skippable dialogue, input remapping

DELIVERABLES

1. Create reusable CharacterSwitchController (scripts/components/character_switch_controller.gd):
   - Handles switching between Elena and Marcus via input
   - Deactivates inactive character (no collision, no AI, invulnerable if appropriate)
   - Activates active character (full control, collision, camera follow)
   - Clear state machine: switching, active_elena, active_marcus
   - Prevent switching during invalid states (scripted sequences, transitions, combat locks)
   - Show clear feedback when switching is blocked (e.g., "Cannot switch now" icon or message)
   - Well-commented and debuggable

2. Create clear HUD active-character indicator (scenes/ui/character_indicator.tscn):
   - Shows which character is currently active (icon, name, or portrait)
   - High contrast, readable at 1280x720
   - Clear visual difference between Elena and Marcus indicators
   - Updates instantly on switch
   - Accessible (works for colorblind players: use shape/text, not just color)

3. Build scenes/levels/transit_hub.tscn with three sequential rooms:

   Room 1: Security Disable (combat + puzzle)
   - Elena disables security via timed terminal interaction (e.g., 10–15s progress bar)
   - Marcus protects her from fixed waves of enemies (3–4 scavengers/enforcers)
   - Terminal interaction visibly progresses, interrupts under defined conditions (e.g., Elena hit), resets fairly
   - Clear win condition: security disabled, gate opens
   - Environmental storytelling: transit hub security, surveillance equipment

   Room 2: Heavy Object + Lift (puzzle + combat)
   - Marcus moves heavy object (crate, barrier, or platform) to create access
   - Use controlled, collision-safe approach (no emergent physics that risks softlocks)
   - Elena powers lift after object is in place (terminal interaction)
   - Both actions required; neither works alone
   - Clear visual feedback for object position and lift activation

   Room 3: Lighting Control + Stealth (puzzle + stealth combat)
   - Elena controls lighting (terminal switches lights on/off)
   - Darkness enables Marcus's single-target stealth takedown on eligible unaware enemies
   - Some enemies have lights (flashlights, headlamps) and are immune to stealth takedown
   - Clear visual difference between lit and dark areas
   - Accessibility-safe alternative indicators (e.g., icons, text, or sound for lighting state)
   - Deterministic enemy behavior changes (enemies patrol in light, stop/search in dark)

4. Add Elena timed security interaction (scripts/components/timed_terminal.gd):
   - Visibly progresses (progress bar or circular indicator)
   - Interrupts under defined conditions (e.g., Elena takes damage, enemy enters radius)
   - Resets fairly (no permanent failure; player can retry)
   - Clear audio/visual feedback for progress, interruption, and completion

5. Add Marcus heavy-object movement (scripts/components/heavy_object.gd):
   - Controlled, collision-safe approach (fixed movement path or position, not physics-based)
   - Clear interaction prompt ("Push [E]")
   - Object moves to predefined position (no physics explosions or softlocks)
   - Visual feedback when object is in correct position
   - Works with remapped inputs

6. Add lighting state system (scripts/components/lighting_controller.gd):
   - Clear visual difference between lit and dark areas (brightness, shadows, or color)
   - Accessibility-safe alternative indicators (icons, text labels, or audio cues for lighting state)
   - Deterministic enemy behavior changes (patrol in light, stop/search in dark)
   - Well-commented and debuggable
   - Performance optimized (no excessive dynamic lighting)

7. Create dialogue showing growing respect and core disagreement:
   - Several short exchanges between rooms (2–3 sentences each)
   - Topics: mutual respect growing, disagreement over Helix control
   - Dialogue is skippable and non-blocking during normal gameplay
   - Clear, readable UI with good contrast
   - Does not pause combat automatically

8. At end, present clear binary, saved choice:
   - Preserve evidence of Helix's earlier Aster failure, OR
   - Erase it to prioritize immediate activation
   - Store evidence_choice as "preserve" or "erase" in GameManager
   - Clear UI prompt explaining consequences (brief, not spoiling endings)
   - Choice is saved and persists through playthrough
   - Visual/audio feedback on selection

9. Add checkpointing and save/load:
   - Checkpoint after each room completion
   - Save choice immediately with visible confirmation
   - Reload returns player to checkpoint with choice intact
   - No softlocks or lost progress

10. Add accessibility:
    - Clear visual indicators for active character, lighting state, and stealth eligibility
    - Skippable dialogue with text size options
    - Input remapping fully honored
    - Reduced motion option (if lighting changes are intense)
    - Clear audio/visual feedback for all events

ACCEPTANCE CRITERIA
- Switching never leaves either character unusable, stuck, duplicated, or without camera target
- Each room requires both protagonists in meaningful way (neither can complete alone)
- Security, heavy object, lighting, stealth, narrative choice, checkpointing, and save/load all work
- Performance is stable at 60 FPS
- All inputs work with remapped bindings

DO NOT
- Allow switching during invalid states (scripted sequences, transitions, combat locks)
- Create rooms where one character can complete everything alone
- Make stealth takedown random or unreliable (deterministic behavior)
- Lose player choice or progress through save/load

Finish by reporting:
- Changed files with brief descriptions
- Test results (all rooms tested, switching tested, save/load verified, accessibility checked)
- Known limitations (be honest)
- Propose this commit message exactly:
Phase 12: transit hub joint mission complete
